/**
 * Public Report Tracking Page
 * No authentication required
 */
'use client';

import { useState, useEffect } from 'react';
import { useParams } from 'next/navigation';
import { apiClient } from '@/lib/api/client';
import { ClockIcon, CheckCircleIcon, XCircleIcon, ExclamationTriangleIcon } from '@heroicons/react/24/outline';

const statusConfig: Record<string, { icon: any; color: string; label: string }> = {
  submitted: {
    icon: ClockIcon,
    color: 'text-blue-600',
    label: 'Submitted',
  },
  'under-review': {
    icon: ClockIcon,
    color: 'text-yellow-600',
    label: 'Under Review',
  },
  verified: {
    icon: CheckCircleIcon,
    color: 'text-green-600',
    label: 'Verified',
  },
  rejected: {
    icon: XCircleIcon,
    color: 'text-red-600',
    label: 'Rejected',
  },
  resolved: {
    icon: CheckCircleIcon,
    color: 'text-green-600',
    label: 'Resolved',
  },
  escalated: {
    icon: ExclamationTriangleIcon,
    color: 'text-orange-600',
    label: 'Escalated',
  },
};

export default function TrackReportPage() {
  const params = useParams();
  const reportId = params.reportId as string;
  const [trackingInfo, setTrackingInfo] = useState<TrackingResponse | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (reportId) {
      fetchTrackingInfo();
    }
  }, [reportId]);

  const fetchTrackingInfo = async () => {
    try {
      setLoading(true);
      setError(null);
      const report = await apiClient.getReport(reportId);
      const data: TrackingResponse = {
        report_id: report.id || reportId,
        status: report.status || 'submitted',
        category: report.category || 'unknown',
        severity: report.severity || 'medium',
        created_at: report.created_at || new Date().toISOString(),
        updated_at: report.updated_at,
        message: `Report is ${report.status || 'submitted'}`,
      };
      setTrackingInfo(data);
    } catch (err: any) {
      setError(err.message || err.detail || 'Failed to fetch report information');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading report information...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="max-w-md w-full bg-white rounded-lg shadow-lg p-8 text-center">
          <XCircleIcon className="h-12 w-12 text-red-600 mx-auto mb-4" />
          <h2 className="text-2xl font-bold text-gray-900 mb-2">Report Not Found</h2>
          <p className="text-gray-600 mb-6">{error}</p>
          <a
            href="/track"
            className="inline-block bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700"
          >
            Try Another Report ID
          </a>
        </div>
      </div>
    );
  }

  if (!trackingInfo) {
    return null;
  }

  const status = statusConfig[trackingInfo.status] || {
    icon: ClockIcon,
    color: 'text-gray-600',
    label: trackingInfo.status,
  };
  const StatusIcon = status.icon;

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
        <div className="bg-white rounded-lg shadow-lg p-8">
          <div className="text-center mb-8">
            <h1 className="text-3xl font-bold text-gray-900 mb-2">Track Your Report</h1>
            <p className="text-gray-600">Report ID: <span className="font-mono font-semibold">{trackingInfo.report_id}</span></p>
          </div>

          <div className="border-t border-gray-200 pt-8">
            <div className="flex items-center justify-center mb-6">
              <StatusIcon className={`h-16 w-16 ${status.color}`} />
            </div>
            <div className="text-center mb-8">
              <h2 className={`text-2xl font-semibold ${status.color} mb-2`}>
                {status.label}
              </h2>
              <p className="text-gray-600">{trackingInfo.message}</p>
            </div>

            <div className="space-y-4">
              <div className="flex justify-between items-center py-3 border-b border-gray-200">
                <span className="text-gray-600">Category</span>
                <span className="font-semibold text-gray-900 capitalize">{trackingInfo.category}</span>
              </div>
              <div className="flex justify-between items-center py-3 border-b border-gray-200">
                <span className="text-gray-600">Severity</span>
                <span className="font-semibold text-gray-900 capitalize">{trackingInfo.severity}</span>
              </div>
              <div className="flex justify-between items-center py-3 border-b border-gray-200">
                <span className="text-gray-600">Submitted</span>
                <span className="font-semibold text-gray-900">
                  {new Date(trackingInfo.created_at).toLocaleDateString()}
                </span>
              </div>
              {trackingInfo.updated_at && (
                <div className="flex justify-between items-center py-3">
                  <span className="text-gray-600">Last Updated</span>
                  <span className="font-semibold text-gray-900">
                    {new Date(trackingInfo.updated_at).toLocaleDateString()}
                  </span>
                </div>
              )}
            </div>

            <div className="mt-8 text-center">
              <a
                href="/"
                className="text-blue-600 hover:text-blue-700 font-medium"
              >
                ← Back to Home
              </a>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}















