/**
 * Report Submission Page
 * Allows users to submit reports anonymously or identified
 */
'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import * as z from 'zod';
import { apiClient } from '@/lib/api/client';
import { 
  DocumentTextIcon, 
  PhotoIcon, 
  MapPinIcon,
  LockClosedIcon,
  CheckCircleIcon 
} from '@heroicons/react/24/outline';

const reportSchema = z.object({
  category: z.string().min(1, 'Category is required'),
  severity: z.enum(['low', 'medium', 'high', 'critical']),
  summary: z.string().min(10, 'Summary must be at least 10 characters'),
  details: z.string().optional(),
  anonymous: z.boolean(),
  county: z.string().min(1, 'County is required'),
  district: z.string().optional(),
  latitude: z.number().min(-90).max(90),
  longitude: z.number().min(-180).max(180),
  witness_count: z.number().min(0).optional(),
});

type ReportFormData = z.infer<typeof reportSchema>;

const categories = [
  { value: 'social', label: 'Social Issue' },
  { value: 'economic', label: 'Economic Issue' },
  { value: 'religious', label: 'Religious Issue' },
  { value: 'political', label: 'Political Issue' },
  { value: 'health', label: 'Health Issue' },
  { value: 'violence', label: 'Violence' },
  { value: 'corruption', label: 'Corruption' },
  { value: 'gbv', label: 'Gender-Based Violence' },
  { value: 'public-service', label: 'Public Service' },
  { value: 'human-rights', label: 'Human Rights' },
  { value: 'other', label: 'Other' },
];

const liberiaCounties = [
  'Bomi', 'Bong', 'Gbarpolu', 'Grand Bassa', 'Grand Cape Mount',
  'Grand Gedeh', 'Grand Kru', 'Lofa', 'Margibi', 'Maryland',
  'Montserrado', 'Nimba', 'River Cess', 'River Gee', 'Sinoe'
];

export default function SubmitReportPage() {
  const router = useRouter();
  const [files, setFiles] = useState<File[]>([]);
  const [uploading, setUploading] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [success, setSuccess] = useState(false);
  const [reportId, setReportId] = useState<string | null>(null);
  const [locationError, setLocationError] = useState<string | null>(null);

  const {
    register,
    handleSubmit,
    formState: { errors },
    setValue,
    watch,
  } = useForm<ReportFormData>({
    resolver: zodResolver(reportSchema),
    defaultValues: {
      anonymous: false,
      severity: 'medium',
      witness_count: 0,
    },
  });

  const isAnonymous = watch('anonymous');

  // Get user's location
  const getLocation = () => {
    if (!navigator.geolocation) {
      setLocationError('Geolocation is not supported by your browser');
      return;
    }

    setLocationError(null);
    navigator.geolocation.getCurrentPosition(
      (position) => {
        setValue('latitude', position.coords.latitude);
        setValue('longitude', position.coords.longitude);
      },
      (error) => {
        setLocationError('Unable to get your location. Please enter manually.');
        console.error('Geolocation error:', error);
      }
    );
  };

  const handleFileSelect = (selectedFiles: File[]) => {
    setFiles((prev) => [...prev, ...selectedFiles]);
  };

  const removeFile = (index: number) => {
    setFiles((prev) => prev.filter((_, i) => i !== index));
  };

  const uploadFile = async (file: File): Promise<string> => {
    // Determine media type
    let mediaType: 'photo' | 'video' | 'audio' = 'photo'
    if (file.type.startsWith('video/')) {
      mediaType = 'video'
    } else if (file.type.startsWith('audio/')) {
      mediaType = 'audio'
    }

    // Get presigned URL from backend
    const uploadData = await apiClient.requestUploadUrl({
      type: mediaType,
      key: file.name,
    })

    // Upload file to S3 using presigned URL
    const formData = new FormData()
    Object.entries(uploadData.fields).forEach(([key, value]) => {
      formData.append(key, value)
    })
    formData.append('file', file)

    const response = await fetch(uploadData.upload_url, {
      method: 'POST',
      body: formData,
    })

    if (!response.ok) {
      throw new Error(`Failed to upload file: ${response.statusText}`)
    }

    return uploadData.media_key
  }

  const onSubmit = async (data: ReportFormData) => {
    try {
      setSubmitting(true);
      setUploading(true);

      // Upload files
      const mediaRefs = await Promise.all(
        files.map(async (file) => {
          const mediaKey = await uploadFile(file);
          return {
            key: mediaKey,
            type: file.type,
            blur_faces: true, // Default to blurring faces
            voice_masked: file.type.startsWith('audio/'),
          };
        })
      );

      setUploading(false);

      // Create report
      const report = await apiClient.createReport({
        summary: data.summary,
        details: data.details || data.summary,
        category: data.category,
        severity: data.severity,
        latitude: data.latitude,
        longitude: data.longitude,
        county: data.county,
        district: data.district,
        media_keys: mediaRefs.map((ref) => ref.key),
      })

      setSuccess(true);
      setReportId(report.id || null);
      
      // Redirect to tracking page after 3 seconds
      if (report.id) {
        setTimeout(() => {
          router.push(`/track/${report.id}`);
        }, 3000);
      }
    } catch (error: any) {
      console.error('Error submitting report:', error);
      alert(error.detail || 'Failed to submit report. Please try again.');
    } finally {
      setSubmitting(false);
      setUploading(false);
    }
  };

  if (success && reportId) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="max-w-md w-full bg-white rounded-lg shadow-lg p-8 text-center">
          <CheckCircleIcon className="h-16 w-16 text-green-600 mx-auto mb-4" />
          <h2 className="text-2xl font-bold text-gray-900 mb-2">Report Submitted!</h2>
          <p className="text-gray-600 mb-4">
            Your report has been submitted successfully.
          </p>
          <div className="bg-gray-100 rounded-lg p-4 mb-6">
            <p className="text-sm text-gray-600 mb-1">Your Report ID:</p>
            <p className="text-xl font-mono font-bold text-gray-900">{reportId}</p>
            <p className="text-xs text-gray-500 mt-2">
              Save this ID to track your report's status
            </p>
          </div>
          <button
            onClick={() => router.push(`/track/${reportId}`)}
            className="w-full bg-blue-600 text-white py-3 rounded-lg font-semibold hover:bg-blue-700 transition-colors"
          >
            Track Your Report
          </button>
          <button
            onClick={() => router.push('/')}
            className="w-full mt-3 text-gray-600 hover:text-gray-900"
          >
            Back to Home
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="bg-white rounded-lg shadow-lg p-8">
          <div className="mb-8">
            <h1 className="text-3xl font-bold text-gray-900 mb-2">Submit a Report</h1>
            <p className="text-gray-600">
              Report issues, concerns, or incidents. You can choose to report anonymously or with your identity.
            </p>
          </div>

          <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
            {/* Anonymous Toggle */}
            <div className="flex items-center space-x-3 p-4 bg-blue-50 rounded-lg">
              <input
                type="checkbox"
                id="anonymous"
                {...register('anonymous')}
                className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
              />
              <label htmlFor="anonymous" className="flex items-center text-gray-700 cursor-pointer">
                <LockClosedIcon className="h-5 w-5 mr-2 text-blue-600" />
                <span className="font-medium">Report anonymously</span>
              </label>
            </div>

            {!isAnonymous && (
              <div className="p-4 bg-yellow-50 border border-yellow-200 rounded-lg">
                <p className="text-sm text-yellow-800">
                  <strong>Note:</strong> If you report with your identity, your information will be kept confidential 
                  and only shared with authorized personnel when necessary for investigation.
                </p>
              </div>
            )}

            {/* Category */}
            <div>
              <label htmlFor="category" className="block text-sm font-medium text-gray-700 mb-2">
                Category <span className="text-red-500">*</span>
              </label>
              <select
                id="category"
                {...register('category')}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              >
                <option value="">Select a category</option>
                {categories.map((cat) => (
                  <option key={cat.value} value={cat.value}>
                    {cat.label}
                  </option>
                ))}
              </select>
              {errors.category && (
                <p className="mt-1 text-sm text-red-600">{errors.category.message}</p>
              )}
            </div>

            {/* Severity */}
            <div>
              <label htmlFor="severity" className="block text-sm font-medium text-gray-700 mb-2">
                Severity <span className="text-red-500">*</span>
              </label>
              <select
                id="severity"
                {...register('severity')}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              >
                <option value="low">Low</option>
                <option value="medium">Medium</option>
                <option value="high">High</option>
                <option value="critical">Critical</option>
              </select>
            </div>

            {/* Summary */}
            <div>
              <label htmlFor="summary" className="block text-sm font-medium text-gray-700 mb-2">
                Summary <span className="text-red-500">*</span>
              </label>
              <input
                type="text"
                id="summary"
                {...register('summary')}
                placeholder="Brief description of the issue"
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              />
              {errors.summary && (
                <p className="mt-1 text-sm text-red-600">{errors.summary.message}</p>
              )}
            </div>

            {/* Details */}
            <div>
              <label htmlFor="details" className="block text-sm font-medium text-gray-700 mb-2">
                Details
              </label>
              <textarea
                id="details"
                {...register('details')}
                rows={6}
                placeholder="Provide more details about the issue..."
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              />
            </div>

            {/* Location */}
            <div className="border-t border-gray-200 pt-6">
              <div className="flex items-center justify-between mb-4">
                <label className="block text-sm font-medium text-gray-700">
                  Location <span className="text-red-500">*</span>
                </label>
                <button
                  type="button"
                  onClick={getLocation}
                  className="flex items-center text-sm text-blue-600 hover:text-blue-700"
                >
                  <MapPinIcon className="h-4 w-4 mr-1" />
                  Use My Location
                </button>
              </div>

              {locationError && (
                <p className="mb-2 text-sm text-red-600">{locationError}</p>
              )}

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                <div>
                  <label htmlFor="county" className="block text-sm font-medium text-gray-700 mb-2">
                    County
                  </label>
                  <select
                    id="county"
                    {...register('county')}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  >
                    <option value="">Select county</option>
                    {liberiaCounties.map((county) => (
                      <option key={county} value={county}>
                        {county}
                      </option>
                    ))}
                  </select>
                  {errors.county && (
                    <p className="mt-1 text-sm text-red-600">{errors.county.message}</p>
                  )}
                </div>

                <div>
                  <label htmlFor="district" className="block text-sm font-medium text-gray-700 mb-2">
                    District (Optional)
                  </label>
                  <input
                    type="text"
                    id="district"
                    {...register('district')}
                    placeholder="District name"
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label htmlFor="latitude" className="block text-sm font-medium text-gray-700 mb-2">
                    Latitude
                  </label>
                  <input
                    type="number"
                    id="latitude"
                    step="any"
                    {...register('latitude', { valueAsNumber: true })}
                    placeholder="6.3153"
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  />
                  {errors.latitude && (
                    <p className="mt-1 text-sm text-red-600">{errors.latitude.message}</p>
                  )}
                </div>

                <div>
                  <label htmlFor="longitude" className="block text-sm font-medium text-gray-700 mb-2">
                    Longitude
                  </label>
                  <input
                    type="number"
                    id="longitude"
                    step="any"
                    {...register('longitude', { valueAsNumber: true })}
                    placeholder="-10.8074"
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  />
                  {errors.longitude && (
                    <p className="mt-1 text-sm text-red-600">{errors.longitude.message}</p>
                  )}
                </div>
              </div>
            </div>

            {/* Evidence Upload */}
            <div className="border-t border-gray-200 pt-6">
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Evidence (Photos, Videos, Audio, Documents)
              </label>
              <div className="mt-2">
                <label className="flex flex-col items-center justify-center w-full h-32 border-2 border-gray-300 border-dashed rounded-lg cursor-pointer bg-gray-50 hover:bg-gray-100">
                  <div className="flex flex-col items-center justify-center pt-5 pb-6">
                    <PhotoIcon className="w-10 h-10 mb-3 text-gray-400" />
                    <p className="mb-2 text-sm text-gray-500">
                      <span className="font-semibold">Click to upload</span> or drag and drop
                    </p>
                    <p className="text-xs text-gray-500">PNG, JPG, MP4, MP3, PDF (MAX. 10MB each)</p>
                  </div>
                  <input
                    type="file"
                    className="hidden"
                    multiple
                    accept="image/*,video/*,audio/*,.pdf"
                    onChange={(e) => {
                      if (e.target.files) {
                        handleFileSelect(Array.from(e.target.files));
                      }
                    }}
                  />
                </label>
              </div>

              {files.length > 0 && (
                <div className="mt-4 space-y-2">
                  {files.map((file, index) => (
                    <div
                      key={index}
                      className="flex items-center justify-between p-3 bg-gray-50 rounded-lg"
                    >
                      <div className="flex items-center space-x-3">
                        <DocumentTextIcon className="h-5 w-5 text-gray-400" />
                        <div>
                          <p className="text-sm font-medium text-gray-900">{file.name}</p>
                          <p className="text-xs text-gray-500">
                            {(file.size / 1024 / 1024).toFixed(2)} MB
                          </p>
                        </div>
                      </div>
                      <button
                        type="button"
                        onClick={() => removeFile(index)}
                        className="text-red-600 hover:text-red-700 text-sm font-medium"
                      >
                        Remove
                      </button>
                    </div>
                  ))}
                </div>
              )}
            </div>

            {/* Witness Count */}
            <div>
              <label htmlFor="witness_count" className="block text-sm font-medium text-gray-700 mb-2">
                Number of Witnesses (Optional)
              </label>
              <input
                type="number"
                id="witness_count"
                min="0"
                {...register('witness_count', { valueAsNumber: true })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              />
            </div>

            {/* Submit Button */}
            <div className="flex space-x-4 pt-6 border-t border-gray-200">
              <button
                type="button"
                onClick={() => router.push('/')}
                className="flex-1 px-6 py-3 border border-gray-300 rounded-lg text-gray-700 font-medium hover:bg-gray-50 transition-colors"
              >
                Cancel
              </button>
              <button
                type="submit"
                disabled={submitting || uploading}
                className="flex-1 px-6 py-3 bg-blue-600 text-white rounded-lg font-semibold hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              >
                {uploading ? 'Uploading...' : submitting ? 'Submitting...' : 'Submit Report'}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}

