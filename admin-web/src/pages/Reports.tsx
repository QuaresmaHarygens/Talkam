import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { apiService, Report } from '../services/api';
import { format } from 'date-fns';

export default function Reports() {
  const [filters, setFilters] = useState({
    county: '',
    category: '',
    status: '',
    text: '',
    severity: '',
    assigned_agency: '',
    min_priority: '',
    date_from: '',
    date_to: '',
    sort_by: 'created_at',
    sort_order: 'desc' as 'asc' | 'desc',
    page: 1,
    page_size: 20,
  });
  const [showAdvancedFilters, setShowAdvancedFilters] = useState(false);
  const [selectedReport, setSelectedReport] = useState<Report | null>(null);

  const { data, isLoading, refetch } = useQuery({
    queryKey: ['reports', filters],
    queryFn: () => apiService.getReports(filters),
  });

  const handleVerify = async (reportId: string, action: 'confirm' | 'reject', comment?: string) => {
    if (!comment && action === 'reject') {
      const commentText = prompt('Please provide a reason for rejection:');
      if (!commentText) return;
      comment = commentText;
    }
    try {
      await apiService.verifyReport(reportId, action, comment);
      refetch();
      alert(`Report ${action === 'confirm' ? 'confirmed' : 'rejected'} successfully`);
    } catch (error: any) {
      alert(`Error: ${error.response?.data?.detail || error.message}`);
    }
  };

  const handleExport = () => {
    const reports = data?.results || [];
    const csv = [
      ['ID', 'Summary', 'Category', 'Severity', 'Status', 'County', 'Created At'].join(','),
      ...reports.map((r: Report) => [
        r.id,
        `"${r.summary}"`,
        r.category,
        r.severity,
        r.status,
        r.location.county,
        format(new Date(r.created_at), 'yyyy-MM-dd HH:mm:ss'),
      ].join(','))
    ].join('\n');

    const blob = new Blob([csv], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `reports-${format(new Date(), 'yyyy-MM-dd')}.csv`;
    a.click();
    window.URL.revokeObjectURL(url);
  };

  if (isLoading) {
    return <div className="loading">Loading reports...</div>;
  }

  const reports = data?.results || [];

  return (
    <div className="reports-page">
      <div className="page-header">
        <h1>Reports</h1>
        <button onClick={handleExport} className="btn-secondary">
          Export CSV
        </button>
      </div>

      {/* Filters */}
      <div className="filters">
        <div className="filter-row">
          <input
            type="text"
            placeholder="Search reports..."
            value={filters.text}
            onChange={(e) => setFilters({ ...filters, text: e.target.value, page: 1 })}
          />
          <button
            onClick={() => setShowAdvancedFilters(!showAdvancedFilters)}
            className="btn-secondary"
          >
            {showAdvancedFilters ? 'Hide' : 'Show'} Advanced Filters
          </button>
        </div>

        {showAdvancedFilters && (
          <div className="advanced-filters">
            <div className="filter-group">
              <label>Category</label>
              <select
                value={filters.category}
                onChange={(e) => setFilters({ ...filters, category: e.target.value, page: 1 })}
              >
                <option value="">All Categories</option>
                <option value="infrastructure">Infrastructure</option>
                <option value="security">Security</option>
                <option value="health">Health</option>
                <option value="education">Education</option>
                <option value="environment">Environment</option>
              </select>
            </div>

            <div className="filter-group">
              <label>Severity</label>
              <select
                value={filters.severity}
                onChange={(e) => setFilters({ ...filters, severity: e.target.value, page: 1 })}
              >
                <option value="">All Severities</option>
                <option value="low">Low</option>
                <option value="medium">Medium</option>
                <option value="high">High</option>
                <option value="critical">Critical</option>
              </select>
            </div>

            <div className="filter-group">
              <label>Status</label>
              <select
                value={filters.status}
                onChange={(e) => setFilters({ ...filters, status: e.target.value, page: 1 })}
              >
                <option value="">All Statuses</option>
                <option value="submitted">Submitted</option>
                <option value="under_review">Under Review</option>
                <option value="verified">Verified</option>
                <option value="rejected">Rejected</option>
                <option value="resolved">Resolved</option>
              </select>
            </div>

            <div className="filter-group">
              <label>County</label>
              <input
                type="text"
                placeholder="County name"
                value={filters.county}
                onChange={(e) => setFilters({ ...filters, county: e.target.value, page: 1 })}
              />
            </div>

            <div className="filter-group">
              <label>Assigned Agency</label>
              <input
                type="text"
                placeholder="Agency name"
                value={filters.assigned_agency}
                onChange={(e) => setFilters({ ...filters, assigned_agency: e.target.value, page: 1 })}
              />
            </div>

            <div className="filter-group">
              <label>Min Priority</label>
              <input
                type="number"
                min="0"
                max="1"
                step="0.1"
                placeholder="0.0 - 1.0"
                value={filters.min_priority}
                onChange={(e) => setFilters({ ...filters, min_priority: e.target.value, page: 1 })}
              />
            </div>

            <div className="filter-group">
              <label>Date From</label>
              <input
                type="date"
                value={filters.date_from}
                onChange={(e) => setFilters({ ...filters, date_from: e.target.value, page: 1 })}
              />
            </div>

            <div className="filter-group">
              <label>Date To</label>
              <input
                type="date"
                value={filters.date_to}
                onChange={(e) => setFilters({ ...filters, date_to: e.target.value, page: 1 })}
              />
            </div>

            <div className="filter-group">
              <label>Sort By</label>
              <select
                value={filters.sort_by}
                onChange={(e) => setFilters({ ...filters, sort_by: e.target.value, page: 1 })}
              >
                <option value="created_at">Created Date</option>
                <option value="priority_score">Priority</option>
                <option value="severity">Severity</option>
                <option value="updated_at">Updated Date</option>
              </select>
            </div>

            <div className="filter-group">
              <label>Sort Order</label>
              <select
                value={filters.sort_order}
                onChange={(e) => setFilters({ ...filters, sort_order: e.target.value as 'asc' | 'desc', page: 1 })}
              >
                <option value="desc">Descending</option>
                <option value="asc">Ascending</option>
              </select>
            </div>

            <button
              onClick={() => setFilters({
                county: '',
                category: '',
                status: '',
                text: '',
                severity: '',
                assigned_agency: '',
                min_priority: '',
                date_from: '',
                date_to: '',
                sort_by: 'created_at',
                sort_order: 'desc',
                page: 1,
                page_size: 20,
              })}
              className="btn-secondary"
            >
              Clear Filters
            </button>
          </div>
        )}
      </div>

      {/* Pagination Info */}
      {data && (
        <div className="pagination-info">
          <p>
            Showing {reports.length} of {data.total || 0} reports
            {data.page && data.page_size && (
              <span> (Page {data.page} of {Math.ceil((data.total || 0) / data.page_size)})</span>
            )}
          </p>
          {data.page && data.page > 1 && (
            <button
              onClick={() => setFilters({ ...filters, page: filters.page - 1 })}
              className="btn-secondary"
            >
              Previous
            </button>
          )}
          {data.page && data.total && data.page_size && data.page < Math.ceil(data.total / data.page_size) && (
            <button
              onClick={() => setFilters({ ...filters, page: filters.page + 1 })}
              className="btn-secondary"
            >
              Next
            </button>
          )}
        </div>
      )}

      {/* Reports List */}
      <div className="reports-list">
        {reports.length === 0 ? (
          <div className="empty-state">
            <p>No reports found matching your filters.</p>
          </div>
        ) : (
          reports.map((report: Report) => (
            <div key={report.id} className="report-card">
              <div className="report-header">
                <h3 
                  onClick={() => setSelectedReport(report)}
                  style={{ cursor: 'pointer', textDecoration: 'underline' }}
                >
                  {report.summary}
                </h3>
                <span className={`status-badge status-${report.status}`}>
                  {report.status}
                </span>
              </div>
              <div className="report-meta">
                <span className="badge">{report.category}</span>
                <span className={`badge severity-${report.severity}`}>{report.severity}</span>
                <span>{report.location.county}</span>
                <span>•</span>
                <span>{format(new Date(report.created_at), 'MMM d, yyyy HH:mm')}</span>
              </div>
              {report.verification_score && (
                <div className="verification-score">
                  Verification Score: {(report.verification_score * 100).toFixed(0)}%
                </div>
              )}
              <div className="report-actions">
                <button
                  onClick={() => setSelectedReport(report)}
                  className="btn-secondary"
                >
                  View Details
                </button>
                <button
                  onClick={() => handleVerify(report.id, 'confirm')}
                  className="btn-confirm"
                >
                  ✓ Confirm
                </button>
                <button
                  onClick={() => handleVerify(report.id, 'reject')}
                  className="btn-reject"
                >
                  ✗ Reject
                </button>
              </div>
            </div>
          ))
        )}
      </div>

      {/* Report Detail Modal */}
      {selectedReport && (
        <div className="modal-overlay" onClick={() => setSelectedReport(null)}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h2>Report Details</h2>
              <button onClick={() => setSelectedReport(null)} className="close-btn">×</button>
            </div>
            <div className="modal-body">
              <div className="detail-section">
                <h3>Summary</h3>
                <p>{selectedReport.summary}</p>
              </div>
              <div className="detail-grid">
                <div>
                  <strong>Category:</strong> {selectedReport.category}
                </div>
                <div>
                  <strong>Severity:</strong> {selectedReport.severity}
                </div>
                <div>
                  <strong>Status:</strong> {selectedReport.status}
                </div>
                <div>
                  <strong>County:</strong> {selectedReport.location.county}
                </div>
                <div>
                  <strong>Created:</strong> {format(new Date(selectedReport.created_at), 'PPpp')}
                </div>
                {selectedReport.verification_score && (
                  <div>
                    <strong>Verification Score:</strong> {(selectedReport.verification_score * 100).toFixed(0)}%
                  </div>
                )}
              </div>
              <div className="modal-actions">
                <button
                  onClick={() => {
                    handleVerify(selectedReport.id, 'confirm');
                    setSelectedReport(null);
                  }}
                  className="btn-confirm"
                >
                  ✓ Confirm Report
                </button>
                <button
                  onClick={() => {
                    handleVerify(selectedReport.id, 'reject');
                    setSelectedReport(null);
                  }}
                  className="btn-reject"
                >
                  ✗ Reject Report
                </button>
                <button
                  onClick={() => setSelectedReport(null)}
                  className="btn-secondary"
                >
                  Close
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
