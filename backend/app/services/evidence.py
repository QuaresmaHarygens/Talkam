"""Evidence handling and hash computation service."""
import datetime
import hashlib
from typing import BinaryIO
try:
    from PIL import Image
    from PIL.ExifTags import TAGS
    PIL_AVAILABLE = True
except ImportError:
    PIL_AVAILABLE = False
import json


def compute_file_hash(file: BinaryIO) -> str:
    """Compute SHA256 hash of file.
    
    Args:
        file: File-like object (must support read() and seek())
    
    Returns:
        Hexadecimal SHA256 hash string
    """
    sha256 = hashlib.sha256()
    file.seek(0)
    
    while chunk := file.read(8192):
        sha256.update(chunk)
    
    file.seek(0)
    return sha256.hexdigest()


def extract_exif_metadata(file: BinaryIO, file_type: str) -> dict:
    """Extract EXIF metadata from image file.
    
    Args:
        file: File-like object containing image data
        file_type: MIME type of file (e.g., "image/jpeg")
    
    Returns:
        Dictionary containing EXIF metadata
    """
    if not PIL_AVAILABLE or not file_type.startswith("image/"):
        return {}
    
    try:
        file.seek(0)
        image = Image.open(file)
        exif_data = image.getexif()
        
        if not exif_data:
            return {}
        
        metadata = {}
        for tag_id, value in exif_data.items():
            tag = TAGS.get(tag_id, tag_id)
            
            # Filter sensitive GPS data - store separately if needed
            if tag == "GPSInfo":
                metadata["gps"] = {
                    "lat": value.get("GPSLatitude"),
                    "lng": value.get("GPSLongitude"),
                    "timestamp": value.get("GPSTimeStamp"),
                }
            elif tag not in ["GPSInfo", "GPSLatitude", "GPSLongitude"]:
                # Store non-GPS metadata
                try:
                    # Convert to JSON-serializable format
                    if isinstance(value, (int, float, str, bool)):
                        metadata[tag] = value
                    else:
                        metadata[tag] = str(value)
                except (TypeError, ValueError):
                    pass
        
        file.seek(0)
        return metadata
    except Exception as e:
        # If EXIF extraction fails, return empty dict
        return {}


def strip_exif_metadata(file: BinaryIO, file_type: str) -> BinaryIO:
    """Strip EXIF metadata from image file.
    
    Args:
        file: File-like object containing image data
        file_type: MIME type of file
    
    Returns:
        New file-like object with EXIF stripped
    """
    if not PIL_AVAILABLE or not file_type.startswith("image/"):
        return file
    
    try:
        file.seek(0)
        image = Image.open(file)
        
        # Create new image without EXIF
        data = list(image.getdata())
        image_without_exif = Image.new(image.mode, image.size)
        image_without_exif.putdata(data)
        
        # Save to bytes
        from io import BytesIO
        output = BytesIO()
        image_without_exif.save(output, format=image.format)
        output.seek(0)
        
        return output
    except Exception as e:
        # If stripping fails, return original file
        file.seek(0)
        return file


def create_evidence_manifest(
    files: list[dict],
    report_id: str
) -> dict:
    """Create evidence manifest for chain of custody.
    
    Args:
        files: List of file metadata dicts with keys:
            - file_id: Unique file identifier
            - hash_sha256: SHA256 hash
            - file_type: MIME type
            - metadata: EXIF/metadata dict
        report_id: Report ID
    
    Returns:
        Manifest dictionary
    """
    return {
        "report_id": report_id,
        "timestamp": datetime.datetime.utcnow().isoformat(),
        "files": files,
        "integrity_check": "sha256",
    }

