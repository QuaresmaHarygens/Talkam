/**
 * Landing Page - Talkam Liberia
 * Public-facing homepage
 */
import Link from 'next/link';
import { ShieldCheckIcon, DocumentTextIcon, MapPinIcon, LockClosedIcon } from '@heroicons/react/24/outline';

export default function HomePage() {
  return (
    <div className="min-h-screen bg-gradient-to-b from-blue-50 to-white">
      {/* Header */}
      <header className="bg-white shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex justify-between items-center">
            <div className="flex items-center space-x-2">
              <ShieldCheckIcon className="h-8 w-8 text-blue-600" />
              <h1 className="text-2xl font-bold text-gray-900">Talkam Liberia</h1>
            </div>
            <nav className="flex space-x-4">
              <Link href="/submit" className="text-gray-600 hover:text-gray-900 font-medium">
                Submit Report
              </Link>
              <Link href="/track" className="text-gray-600 hover:text-gray-900 font-medium">
                Track Report
              </Link>
              <Link href="/login" className="text-blue-600 hover:text-blue-700 font-medium">
                Login
              </Link>
            </nav>
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
        <div className="text-center">
          <h2 className="text-4xl font-extrabold text-gray-900 sm:text-5xl md:text-6xl">
            Report Issues.
            <span className="text-blue-600"> Stay Safe.</span>
          </h2>
          <p className="mt-6 max-w-2xl mx-auto text-xl text-gray-500">
            Submit complaints, reports, and whistleblow — anonymously or identified — 
            with advanced evidence authentication and community verification.
          </p>
          <div className="mt-10 flex justify-center space-x-4">
            <Link
              href="/submit"
              className="bg-blue-600 text-white px-8 py-3 rounded-lg font-semibold hover:bg-blue-700 transition-colors"
            >
              Submit a Report
            </Link>
            <Link
              href="/track"
              className="bg-white text-blue-600 px-8 py-3 rounded-lg font-semibold border-2 border-blue-600 hover:bg-blue-50 transition-colors"
            >
              Track Report
            </Link>
          </div>
        </div>

        {/* Features */}
        <div className="mt-24 grid grid-cols-1 gap-8 sm:grid-cols-2 lg:grid-cols-4">
          <div className="text-center">
            <div className="flex justify-center">
              <LockClosedIcon className="h-12 w-12 text-blue-600" />
            </div>
            <h3 className="mt-4 text-lg font-semibold text-gray-900">Anonymous Reporting</h3>
            <p className="mt-2 text-gray-600">
              Submit reports anonymously or with your identity. Your choice, your safety.
            </p>
          </div>

          <div className="text-center">
            <div className="flex justify-center">
              <DocumentTextIcon className="h-12 w-12 text-blue-600" />
            </div>
            <h3 className="mt-4 text-lg font-semibold text-gray-900">Evidence Support</h3>
            <p className="mt-2 text-gray-600">
              Upload photos, videos, audio, and documents with tamper-evidence protection.
            </p>
          </div>

          <div className="text-center">
            <div className="flex justify-center">
              <MapPinIcon className="h-12 w-12 text-blue-600" />
            </div>
            <h3 className="mt-4 text-lg font-semibold text-gray-900">Location Tracking</h3>
            <p className="mt-2 text-gray-600">
              Reports are automatically tagged with location for better response.
            </p>
          </div>

          <div className="text-center">
            <div className="flex justify-center">
              <ShieldCheckIcon className="h-12 w-12 text-blue-600" />
            </div>
            <h3 className="mt-4 text-lg font-semibold text-gray-900">Community Verified</h3>
            <p className="mt-2 text-gray-600">
              Reports are verified by the community and trusted organizations.
            </p>
          </div>
        </div>

        {/* How It Works */}
        <div className="mt-24 bg-white rounded-lg shadow-lg p-8">
          <h3 className="text-2xl font-bold text-gray-900 text-center mb-8">How It Works</h3>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            <div>
              <div className="flex items-center justify-center w-12 h-12 bg-blue-100 rounded-full text-blue-600 font-bold text-xl mb-4">
                1
              </div>
              <h4 className="font-semibold text-gray-900 mb-2">Submit Your Report</h4>
              <p className="text-gray-600">
                Fill out the form with details, upload evidence, and choose to report anonymously or identified.
              </p>
            </div>
            <div>
              <div className="flex items-center justify-center w-12 h-12 bg-blue-100 rounded-full text-blue-600 font-bold text-xl mb-4">
                2
              </div>
              <h4 className="font-semibold text-gray-900 mb-2">Receive Report ID</h4>
              <p className="text-gray-600">
                Get a unique report ID (RPT-YYYY-XXXXXX) to track your report's status.
              </p>
            </div>
            <div>
              <div className="flex items-center justify-center w-12 h-12 bg-blue-100 rounded-full text-blue-600 font-bold text-xl mb-4">
                3
              </div>
              <h4 className="font-semibold text-gray-900 mb-2">Track Progress</h4>
              <p className="text-gray-600">
                Use your report ID to check status updates and see when action is taken.
              </p>
            </div>
          </div>
        </div>

        {/* CTA */}
        <div className="mt-16 text-center">
          <p className="text-lg text-gray-600 mb-4">
            Ready to make a difference?
          </p>
          <Link
            href="/submit"
            className="inline-block bg-blue-600 text-white px-8 py-3 rounded-lg font-semibold hover:bg-blue-700 transition-colors"
          >
            Submit Your Report Now
          </Link>
        </div>
      </main>

      {/* Footer */}
      <footer className="mt-24 bg-gray-900 text-white py-8">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center">
            <p className="text-gray-400">
              © 2025 Talkam Liberia. Privacy-first reporting platform.
            </p>
            <div className="mt-4 space-x-4">
              <Link href="/privacy" className="text-gray-400 hover:text-white">
                Privacy Policy
              </Link>
              <Link href="/terms" className="text-gray-400 hover:text-white">
                Terms of Service
              </Link>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}
