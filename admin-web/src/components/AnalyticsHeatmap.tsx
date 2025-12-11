import { useQuery } from '@tanstack/react-query';
import { apiService } from '../services/api';

// Simple map component (in production, use a proper map library like Leaflet or Mapbox)
export default function AnalyticsHeatmap({ days = 30 }: { days?: number }) {
  const { data, isLoading } = useQuery({
    queryKey: ['heatmap', days],
    queryFn: () => apiService.getHeatmap(days),
  });

  if (isLoading) {
    return <div className="loading">Loading heatmap...</div>;
  }

  if (!data || !Array.isArray(data)) {
    return <div>No heatmap data available</div>;
  }

  // Simple visualization using a grid/table since we don't have a map library
  return (
    <div className="heatmap-container">
      <h3>Geographic Heatmap (Last {days} days)</h3>
      <div className="heatmap-grid">
        {data.map((point: any) => (
          <div
            key={`${point.latitude}-${point.longitude}`}
            className="heatmap-point"
            style={{
              opacity: Math.min(point.intensity / 10, 1),
              backgroundColor: point.intensity > 5 ? '#EF4444' : point.intensity > 2 ? '#F59E0B' : '#16A34A',
            }}
            title={`${point.county || 'Unknown'}: ${point.report_count} reports`}
          >
            <div className="heatmap-label">
              {point.county || 'Unknown'}
              <br />
              <small>{point.report_count} reports</small>
            </div>
          </div>
        ))}
      </div>
      <div className="heatmap-legend">
        <span>Low</span>
        <div className="legend-gradient" />
        <span>High</span>
      </div>
    </div>
  );
}
