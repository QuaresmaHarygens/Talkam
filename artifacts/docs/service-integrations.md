# Service Integration Guides

## SMS Gateway Integration

### Orange Liberia Integration

#### Setup
1. Contact Orange Liberia Business Solutions
2. Request SMS API credentials
3. Configure short code (e.g., 8888)

#### Implementation

Update `backend/app/services/sms_gateway.py`:

```python
import httpx
from ..config import Settings

class OrangeLiberiaSMS:
    def __init__(self, settings: Settings):
        self.api_url = settings.sms_gateway_url
        self.api_key = settings.sms_gateway_api_key
        self.short_code = settings.sms_short_code

    async def send_sms(self, phone: str, message: str) -> dict:
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{self.api_url}/send",
                headers={"Authorization": f"Bearer {self.api_key}"},
                json={
                    "to": phone,
                    "from": self.short_code,
                    "message": message,
                },
            )
            return response.json()

    async def receive_sms_webhook(self, request: dict) -> dict:
        """Process incoming SMS webhook from Orange."""
        sender = request.get("from")
        message = request.get("message", "")
        timestamp = request.get("timestamp")
        
        # Forward to SMS ingestion endpoint
        # This would be called by the webhook handler
        return {
            "sender": sender,
            "message": message,
            "timestamp": timestamp,
        }
```

#### Webhook Configuration

In `backend/app/api/sms.py`, add webhook endpoint:

```python
@router.post("/webhook")
async def sms_webhook(
    body: dict,
    settings: Settings = Depends(get_settings),
) -> dict:
    """Receive SMS webhook from Orange Liberia."""
    # Verify webhook signature
    signature = request.headers.get("X-Orange-Signature")
    if not verify_signature(body, signature, settings.sms_webhook_secret):
        raise HTTPException(status_code=403, detail="Invalid signature")
    
    # Process SMS
    sms_service = OrangeLiberiaSMS(settings)
    result = await sms_service.receive_sms_webhook(body)
    
    # Ingest as report
    await ingest_sms_report(
        message=result["message"],
        sender=result["sender"],
        sms_token=settings.sms_gateway_token,
    )
    
    return {"status": "ok"}
```

### Lonestar MTN Integration

Similar structure, different API endpoints:

```python
class LonestarMTNSMS:
    def __init__(self, settings: Settings):
        self.api_url = "https://api.lonestarmtn.com/sms/v1"
        self.username = settings.lonestar_username
        self.password = settings.lonestar_password
```

## Push Notifications

### Firebase Cloud Messaging (FCM)

#### Setup
1. Create Firebase project
2. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
3. Get server key from Firebase Console

#### Backend Implementation

Create `backend/app/services/push_notifications.py`:

```python
import httpx
from ..config import Settings

class FCMPushService:
    def __init__(self, settings: Settings):
        self.api_url = "https://fcm.googleapis.com/fcm/send"
        self.server_key = settings.fcm_server_key

    async def send_push(
        self,
        device_token: str,
        title: str,
        body: str,
        data: dict = None,
    ) -> dict:
        async with httpx.AsyncClient() as client:
            response = await client.post(
                self.api_url,
                headers={
                    "Authorization": f"key={self.server_key}",
                    "Content-Type": "application/json",
                },
                json={
                    "to": device_token,
                    "notification": {
                        "title": title,
                        "body": body,
                    },
                    "data": data or {},
                },
            )
            return response.json()

    async def send_multicast(
        self,
        device_tokens: list[str],
        title: str,
        body: str,
        data: dict = None,
    ) -> dict:
        """Send to multiple devices."""
        async with httpx.AsyncClient() as client:
            response = await client.post(
                "https://fcm.googleapis.com/fcm/send",
                headers={
                    "Authorization": f"key={self.server_key}",
                    "Content-Type": "application/json",
                },
                json={
                    "registration_ids": device_tokens,
                    "notification": {"title": title, "body": body},
                    "data": data or {},
                },
            )
            return response.json()
```

#### Mobile App Integration

In `mobile/lib/services/push_service.dart`:

```dart
import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  Future<void> initialize() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle foreground notifications
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle notification tap
    });
  }
}
```

### Apple Push Notification Service (APNs)

For iOS, configure APNs certificates:

1. Generate APNs key in Apple Developer Portal
2. Download `.p8` key file
3. Configure in backend:

```python
class APNSPushService:
    def __init__(self, settings: Settings):
        self.apns_key_path = settings.apns_key_path
        self.team_id = settings.apns_team_id
        self.key_id = settings.apns_key_id
        self.bundle_id = settings.ios_bundle_id
```

## Media Processing

### Face Blur Service

Create `backend/app/services/media_processing.py`:

```python
import cv2
import numpy as np
from PIL import Image
import io

async def blur_faces(image_bytes: bytes) -> bytes:
    """Blur faces in image using OpenCV."""
    # Load image
    nparr = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    
    # Load face detector
    face_cascade = cv2.CascadeClassifier(
        cv2.data.haarcascades + 'haarcascade_frontalface_default.xml'
    )
    
    # Detect faces
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    faces = face_cascade.detectMultiScale(gray, 1.1, 4)
    
    # Blur faces
    for (x, y, w, h) in faces:
        roi = img[y:y+h, x:x+w]
        blurred = cv2.GaussianBlur(roi, (99, 99), 30)
        img[y:y+h, x:x+w] = blurred
    
    # Convert back to bytes
    _, buffer = cv2.imencode('.jpg', img)
    return buffer.tobytes()
```

### Voice Masking

For audio masking, use libraries like `pydub`:

```python
from pydub import AudioSegment
import numpy as np

async def mask_voice(audio_bytes: bytes) -> bytes:
    """Mask voice in audio recording."""
    audio = AudioSegment.from_file(io.BytesIO(audio_bytes))
    
    # Apply low-pass filter to mask voice
    masked = audio.low_pass_filter(300)
    
    # Export
    output = io.BytesIO()
    masked.export(output, format="mp3")
    return output.getvalue()
```

## Environment Variables

Add to `.env`:

```bash
# SMS Gateway
SMS_GATEWAY_URL=https://api.orange.liberia.com
SMS_GATEWAY_API_KEY=your_key
SMS_SHORT_CODE=8888
SMS_WEBHOOK_SECRET=your_secret

# FCM
FCM_SERVER_KEY=your_fcm_server_key

# APNs
APNS_KEY_PATH=/path/to/AuthKey.p8
APNS_TEAM_ID=your_team_id
APNS_KEY_ID=your_key_id
IOS_BUNDLE_ID=com.talkam.liberia

# Media Processing
ENABLE_FACE_BLUR=true
ENABLE_VOICE_MASK=true
```

## Testing

### SMS Testing
- Use Orange/Lonestar test numbers
- Verify webhook receives messages
- Test SMS parsing logic

### Push Testing
- Use FCM test tokens
- Verify delivery on real devices
- Test notification handling

### Media Testing
- Upload test images with faces
- Verify blur quality
- Test audio masking
