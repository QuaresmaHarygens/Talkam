import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../services/offline_storage.dart';
import '../services/media_service.dart';
import '../providers.dart';

class CreateReportScreen extends ConsumerStatefulWidget {
  const CreateReportScreen({super.key});

  @override
  ConsumerState<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends ConsumerState<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _summaryController = TextEditingController();
  final _detailsController = TextEditingController();
  
  String _selectedCategory = 'social';
  String _selectedSeverity = 'medium';
  bool _anonymous = false;
  Position? _currentPosition;
  String? _county;
  bool _submitting = false;
  List<Map<String, dynamic>> _selectedMedia = [];
  bool _uploadingMedia = false;

  final Map<String, Map<String, dynamic>> _categories = {
    'social': {
      'label': 'Social',
      'icon': Icons.people,
      'api_value': 'social',
    },
    'economic': {
      'label': 'Economic',
      'icon': Icons.attach_money,
      'api_value': 'economic',
    },
    'religious': {
      'label': 'Religious',
      'icon': Icons.church,
      'api_value': 'religious',
    },
    'political': {
      'label': 'Political',
      'icon': Icons.how_to_vote,
      'api_value': 'political',
    },
    'health': {
      'label': 'Health',
      'icon': Icons.local_hospital,
      'api_value': 'health',
    },
    'violence': {
      'label': 'Violence',
      'icon': Icons.warning,
      'api_value': 'violence',
    },
    'infrastructure': {
      'label': 'Infrastructure',
      'icon': Icons.construction,
      'api_value': 'infrastructure',
    },
    'security': {
      'label': 'Security',
      'icon': Icons.security,
      'api_value': 'security',
    },
  };

  @override
  void dispose() {
    _summaryController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location services are disabled. Please enable them in Settings.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permissions are denied. Please enable location access in app settings.'),
                duration: Duration(seconds: 3),
              ),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permissions are permanently denied. Please enable them in app settings.'),
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Getting location...'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Get current position with desired accuracy
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() => _currentPosition = position);

      // Reverse geocode to get county
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          // Try to extract county from administrative area or locality
          final county = placemark.administrativeArea ??
              placemark.locality ??
              'Unknown';
          setState(() => _county = county);
        }
      } catch (e) {
        // If reverse geocoding fails, default to Montserrado
        setState(() => _county = 'Montserrado');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Location obtained: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } on TimeoutException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location request timed out. Please try again.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location error: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please get your location first')),
      );
      return;
    }

    setState(() => _submitting = true);

    final reportData = {
      'category': _categories[_selectedCategory]!['api_value'] as String,
      'severity': _selectedSeverity,
      'summary': _summaryController.text,
      'details': _detailsController.text.isEmpty ? null : _detailsController.text,
      'anonymous': _anonymous,
      'location': {
        'latitude': _currentPosition!.latitude,
        'longitude': _currentPosition!.longitude,
        'county': _county ?? 'Montserrado',
      },
    };

    try {
      final client = ref.read(apiClientProvider);
      await client.createReport(
        category: _categories[_selectedCategory]!['api_value'] as String,
        severity: _selectedSeverity,
        summary: _summaryController.text,
        details: _detailsController.text.isEmpty ? null : _detailsController.text,
        location: reportData['location'] as Map<String, dynamic>,
        media: _selectedMedia.map((m) => {
          'key': m['key'],
          'type': m['type'],
          'checksum': m['checksum'],
          'blur_faces': m['blur_faces'],
          'voice_masked': m['voice_masked'],
        }).toList(),
        anonymous: _anonymous,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted successfully!')),
        );
        _formKey.currentState!.reset();
        setState(() {
          _selectedMedia.clear();
        });
      }
    } catch (e) {
      // Queue offline if network fails
      final offlineStorage = OfflineStorageService();
      reportData['media'] = _selectedMedia;
      await offlineStorage.queueReport(reportData);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Queued offline. Will sync when connected.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  MediaService get _mediaService {
    final client = ref.read(apiClientProvider);
    return MediaService(client);
  }

  Future<void> _showMediaPicker(BuildContext context) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Record Video'),
              onTap: () => Navigator.pop(context, 'video'),
            ),
          ],
        ),
      ),
    );

    if (choice == null) return;

    setState(() => _uploadingMedia = true);

    try {
      File? file;
      String type = 'photo';

      if (choice == 'gallery') {
        file = await _mediaService.pickImage();
      } else if (choice == 'camera') {
        file = await _mediaService.pickImage(fromCamera: true);
      } else if (choice == 'video') {
        file = await _mediaService.pickVideo(fromCamera: true);
        type = 'video';
      }

      if (file != null) {
        // Validate file size
        if (!await _mediaService.validateFileSize(file)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File size exceeds 50MB limit'),
              ),
            );
          }
          return;
        }

        // Upload media
        final uploadResult = await _mediaService.uploadMedia(
          file: file,
          type: type,
        );

        if (uploadResult['success'] == true) {
          setState(() {
            _selectedMedia.add({
              'key': uploadResult['key'],
              'type': type,
              'checksum': uploadResult['checksum'],
              'blur_faces': uploadResult['blur_faces'],
              'voice_masked': uploadResult['voice_masked'],
            });
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Media upload failed: $e')),
        );
      }
    } finally {
      setState(() => _uploadingMedia = false);
    }
  }

  Future<void> _recordAudio(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Audio'),
        content: const Text('Start recording?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Start'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _uploadingMedia = true);

    try {
      final recordingPath = await _mediaService.startRecording();
      if (recordingPath == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recording permission denied')),
          );
        }
        return;
      }

      // Show recording dialog
      final stopRecording = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Recording...'),
          content: const Text('Tap stop when finished'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Stop Recording'),
            ),
          ],
        ),
      );

      if (stopRecording == true) {
        final audioFile = await _mediaService.stopRecording();
        if (audioFile != null) {
          // Validate file size
          if (!await _mediaService.validateFileSize(audioFile)) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Audio file size exceeds 50MB limit'),
                ),
              );
            }
            return;
          }

          // Upload audio
          final uploadResult = await _mediaService.uploadMedia(
            file: audioFile,
            type: 'audio',
          );

          if (uploadResult['success'] == true) {
            setState(() {
              _selectedMedia.add({
                'key': uploadResult['key'],
                'type': 'audio',
                'checksum': uploadResult['checksum'],
                'blur_faces': false,
                'voice_masked': uploadResult['voice_masked'],
              });
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Audio recording failed: $e')),
        );
      }
    } finally {
      setState(() => _uploadingMedia = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report an issue.'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Issue Categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Category grid matching wireframe
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final categoryKey = _categories.keys.elementAt(index);
                final category = _categories[categoryKey]!;
                final isSelected = _selectedCategory == categoryKey;

                return InkWell(
                  onTap: () => setState(() => _selectedCategory = categoryKey),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFF59E0B).withOpacity(0.2)
                          : Colors.grey.shade100,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFF59E0B)
                            : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          category['icon'] as IconData,
                          size: 32,
                          color: isSelected
                              ? const Color(0xFFF59E0B)
                              : Colors.grey.shade600,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          category['label'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected
                                ? const Color(0xFF0F172A)
                                : Colors.grey.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            // Add Media Section
            const Text(
              'Add Media',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _uploadingMedia ? null : () => _showMediaPicker(context),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Photo/Video'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _uploadingMedia ? null : () => _recordAudio(context),
                    icon: const Icon(Icons.mic),
                    label: const Text('Audio'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            if (_selectedMedia.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedMedia.map((media) {
                  return Chip(
                    label: Text(media['type'] as String),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () {
                      setState(() {
                        _selectedMedia.remove(media);
                      });
                    },
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 24),
            // Severity Selection
            const Text(
              'Severity',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'low', label: Text('Low')),
                ButtonSegment(value: 'medium', label: Text('Medium')),
                ButtonSegment(value: 'high', label: Text('High')),
                ButtonSegment(value: 'critical', label: Text('Critical')),
              ],
              selected: {_selectedSeverity},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() => _selectedSeverity = newSelection.first);
              },
            ),
            const SizedBox(height: 24),
            // Summary field
            TextFormField(
              controller: _summaryController,
              decoration: const InputDecoration(
                labelText: 'Summary',
                hintText: 'Brief summary of the issue...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Summary is required' : null,
            ),
            const SizedBox(height: 16),
            // Text Description matching wireframe
            TextFormField(
              controller: _detailsController,
              decoration: const InputDecoration(
                labelText: 'Text Description',
                hintText: 'Describe the issue...',
                border: OutlineInputBorder(),
              ),
              maxLines: 6,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.location_on),
              label: Text(_currentPosition == null
                  ? 'Get Location'
                  : 'Location: ${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}'),
            ),
            const SizedBox(height: 24),
            // Anonymous checkbox matching wireframe
            CheckboxListTile(
              title: const Text('Report anonymously'),
              value: _anonymous,
              onChanged: (value) => setState(() => _anonymous = value ?? false),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitting ? null : _submitReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _submitting
                  ? const CircularProgressIndicator()
                  : const Text('Submit Report', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
