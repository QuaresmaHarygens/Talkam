import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../api/client.dart';

class MediaService {
  final TalkamApiClient apiClient;
  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();

  MediaService(this.apiClient);

  /// Pick an image from gallery or camera
  Future<File?> pickImage({bool fromCamera = false}) async {
    final source = fromCamera ? ImageSource.camera : ImageSource.gallery;
    final pickedFile = await _imagePicker.pickImage(source: source);
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  /// Pick a video from gallery or camera
  Future<File?> pickVideo({bool fromCamera = false}) async {
    final source = fromCamera ? ImageSource.camera : ImageSource.gallery;
    final pickedFile = await _imagePicker.pickVideo(source: source);
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  /// Record audio
  Future<String?> startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      final path = 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _audioRecorder.start(
        const RecordConfig(),
        path: path,
      );
      return path;
    }
    return null;
  }

  /// Stop recording and return file path
  Future<File?> stopRecording() async {
    final path = await _audioRecorder.stop();
    return path != null ? File(path) : null;
  }

  /// Calculate file checksum (MD5)
  Future<String> calculateChecksum(File file) async {
    final bytes = await file.readAsBytes();
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  /// Upload file to S3 using presigned URL
  Future<Map<String, dynamic>> uploadMedia({
    required File file,
    required String type, // 'photo', 'video', or 'audio'
  }) async {
    try {
      // Calculate checksum
      final checksum = await calculateChecksum(file);
      final fileName = file.path.split('/').last;
      final fileExtension = fileName.split('.').last;
      
      // Request presigned URL from backend
      final uploadData = await apiClient.requestUploadUrl(
        key: 'media/${DateTime.now().millisecondsSinceEpoch}.$fileExtension',
        type: type,
        checksum: checksum,
      );

      final uploadUrl = uploadData['upload_url'] as String;
      final fields = uploadData['fields'] as Map<String, dynamic>;
      final mediaKey = uploadData['media_key'] as String;

      // Prepare multipart form data
      final formData = FormData.fromMap({
        ...fields,
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      // Upload to S3 using presigned POST
      final dio = Dio();
      // S3 presigned POST expects form fields + file
      final uploadFormData = FormData.fromMap({
        ...fields,
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      final response = await dio.post(
        uploadUrl,
        data: uploadFormData,
        options: Options(
          followRedirects: false,
          validateStatus: (status) => status! < 500,
        ),
      );

      // S3 presigned POST returns 204 on success, or redirects
      if (response.statusCode == 204 || response.statusCode == 200 || response.statusCode == 303) {
        return {
          'key': mediaKey,
          'type': type,
          'checksum': checksum,
          'blur_faces': type == 'photo', // Default blur faces for photos
          'voice_masked': type == 'audio', // Default mask voice for audio
          'success': true,
        };
      } else {
        throw Exception('Upload failed: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      throw Exception('Media upload error: $e');
    }
  }

  /// Get file size in MB
  Future<double> getFileSizeMB(File file) async {
    final bytes = await file.length();
    return bytes / (1024 * 1024);
  }

  /// Validate file size (max 50MB)
  Future<bool> validateFileSize(File file) async {
    final sizeMB = await getFileSizeMB(file);
    return sizeMB <= 50.0;
  }
}
