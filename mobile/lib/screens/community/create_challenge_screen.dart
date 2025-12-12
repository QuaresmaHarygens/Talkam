import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../providers.dart';
import '../../services/media_service.dart';

class CreateChallengeScreen extends ConsumerStatefulWidget {
  const CreateChallengeScreen({super.key});

  @override
  ConsumerState<CreateChallengeScreen> createState() => _CreateChallengeScreenState();
}

class _CreateChallengeScreenState extends ConsumerState<CreateChallengeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _expectedImpactController = TextEditingController();
  final _durationController = TextEditingController();

  String _selectedCategory = 'social';
  String _selectedUrgency = 'medium';
  Position? _currentPosition;
  String? _county;
  String? _district;
  List<File> _selectedMedia = [];
  bool _loading = false;
  bool _gettingLocation = false;

  final Map<String, String> _categories = {
    'social': 'Social',
    'health': 'Health',
    'education': 'Education',
    'environmental': 'Environmental',
    'security': 'Security',
    'religious': 'Religious',
    'infrastructure': 'Infrastructure',
    'economic': 'Economic',
  };

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _expectedImpactController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _gettingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location services are disabled')),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied')),
            );
          }
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });

      // Get address from coordinates
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          setState(() {
            _county = placemarks.first.administrativeArea;
            _district = placemarks.first.subAdministrativeArea;
          });
        }
      } catch (_) {
        // Ignore geocoding errors
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
    } finally {
      setState(() => _gettingLocation = false);
    }
  }

  Future<void> _submitChallenge() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable location services')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final client = ref.read(apiClientProvider);
      final mediaService = MediaService(client);

      // Upload media if any
      List<String> mediaUrls = [];
      for (var mediaFile in _selectedMedia) {
        try {
          final uploadResult = await mediaService.uploadMedia(
            file: mediaFile,
            type: mediaFile.path.endsWith('.mp4') || mediaFile.path.endsWith('.mov')
                ? 'video'
                : 'photo',
          );
          if (uploadResult['media_key'] != null) {
            mediaUrls.add(uploadResult['media_key'] as String);
          }
        } catch (e) {
          // Continue even if media upload fails
          print('Media upload error: $e');
        }
      }

      // Create challenge
      final challengeData = await client.createChallenge(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        county: _county,
        district: _district,
        urgencyLevel: _selectedUrgency,
        durationDays: _durationController.text.isNotEmpty
            ? int.tryParse(_durationController.text)
            : null,
        expectedImpact: _expectedImpactController.text.trim().isNotEmpty
            ? _expectedImpactController.text.trim()
            : null,
        mediaUrls: mediaUrls.isNotEmpty ? mediaUrls : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Challenge created successfully!')),
        );
        Navigator.of(context).pop(challengeData);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating challenge: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Challenge'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Challenge Title',
                hintText: 'e.g., Community Clean-up Drive',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                if (value.trim().length < 5) {
                  return 'Title must be at least 5 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Category
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: _categories.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Describe your challenge in detail...',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                if (value.trim().length < 20) {
                  return 'Description must be at least 20 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Urgency Level
            const Text('Urgency Level', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'low', label: Text('Low')),
                ButtonSegment(value: 'medium', label: Text('Medium')),
                ButtonSegment(value: 'high', label: Text('High')),
                ButtonSegment(value: 'critical', label: Text('Critical')),
              ],
              selected: {_selectedUrgency},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() => _selectedUrgency = newSelection.first);
              },
            ),
            const SizedBox(height: 16),

            // Duration
            TextFormField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Duration (days)',
                hintText: 'e.g., 30',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Expected Impact
            TextFormField(
              controller: _expectedImpactController,
              decoration: const InputDecoration(
                labelText: 'Expected Impact (optional)',
                hintText: 'Describe the expected impact of this challenge...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Location
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on),
                        const SizedBox(width: 8),
                        const Text(
                          'Location',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        if (_gettingLocation)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          TextButton.icon(
                            onPressed: _getCurrentLocation,
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Refresh'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_currentPosition != null)
                      Text(
                        'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}, '
                        'Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                        style: TextStyle(color: Colors.grey.shade700),
                      )
                    else
                      const Text(
                        'Location not available',
                        style: TextStyle(color: Colors.grey),
                      ),
                    if (_county != null) ...[
                      const SizedBox(height: 4),
                      Text('County: $_county'),
                    ],
                    if (_district != null) ...[
                      const SizedBox(height: 4),
                      Text('District: $_district'),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Media
            const Text('Add Media (optional)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implement image picker
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Image picker not implemented yet')),
                      );
                    },
                    icon: const Icon(Icons.photo),
                    label: const Text('Photo/Video'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implement audio recorder
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Audio recorder not implemented yet')),
                      );
                    },
                    icon: const Icon(Icons.mic),
                    label: const Text('Audio'),
                  ),
                ),
              ],
            ),
            if (_selectedMedia.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _selectedMedia.map((file) {
                  return Chip(
                    label: Text(file.path.split('/').last),
                    onDeleted: () {
                      setState(() => _selectedMedia.remove(file));
                    },
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 24),

            // Submit button
            ElevatedButton(
              onPressed: _loading ? null : _submitChallenge,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Create Challenge', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
