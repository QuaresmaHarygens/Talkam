/**
 * Track Report - Entry Page
 * User enters report ID to track
 */
'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { MagnifyingGlassIcon } from '@heroicons/react/24/outline';

export default function TrackPage() {
  const router = useRouter();
  const [reportId, setReportId] = useState('');
  const [error, setError] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

    // Validate report ID format: RPT-YYYY-XXXXXX
    const reportIdPattern = /^RPT-\d{4}-\d{6}$/;
    if (!reportIdPattern.test(reportId)) {
      setError('Please enter a valid report ID (format: RPT-YYYY-XXXXXX)');
      return;
    }

    router.push(`/track/${reportId}`);
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
        <div className="bg-white rounded-lg shadow-lg p-8">
          <div className="text-center mb-8">
            <h1 className="text-3xl font-bold text-gray-900 mb-2">Track Your Report</h1>
            <p className="text-gray-600">
              Enter your report ID to check the status of your submission
            </p>
          </div>

          <form onSubmit={handleSubmit} className="space-y-6">
            <div>
              <label htmlFor="reportId" className="block text-sm font-medium text-gray-700 mb-2">
                Report ID
              </label>
              <div className="relative">
                <input
                  type="text"
                  id="reportId"
                  value={reportId}
                  onChange={(e) => {
                    setReportId(e.target.value.toUpperCase());
                    setError('');
                  }}
                  placeholder="RPT-2025-000123"
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 font-mono"
                  required
                />
                <MagnifyingGlassIcon className="absolute right-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
              </div>
              {error && (
                <p className="mt-2 text-sm text-red-600">{error}</p>
              )}
              <p className="mt-2 text-sm text-gray-500">
                Format: RPT-YYYY-XXXXXX (e.g., RPT-2025-000123)
              </p>
            </div>

            <button
              type="submit"
              className="w-full bg-blue-600 text-white py-3 rounded-lg font-semibold hover:bg-blue-700 transition-colors flex items-center justify-center"
            >
              <MagnifyingGlassIcon className="h-5 w-5 mr-2" />
              Track Report
            </button>
          </form>

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
  );
}














