import { useQuery } from '@tanstack/react-query';
import { apiService } from '../services/api';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  LineChart,
  Line,
} from 'recharts';

export default function CategoryInsights() {
  const { data, isLoading } = useQuery({
    queryKey: ['category-insights'],
    queryFn: () => apiService.getCategoryInsights(),
  });

  if (isLoading) {
    return <div className="loading">Loading category insights...</div>;
  }

  if (!data) {
    return <div>No category insights available</div>;
  }

  return (
    <div className="category-insights">
      <h3>Category Insights</h3>
      
      <div className="insights-grid">
        <div className="insight-card">
          <h4>Reports by Category</h4>
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={data.by_category || []}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="category" />
              <YAxis />
              <Tooltip />
              <Bar dataKey="total_reports" fill="#3B82F6" />
              <Bar dataKey="verified_reports" fill="#16A34A" />
            </BarChart>
          </ResponsiveContainer>
        </div>

        <div className="insight-card">
          <h4>Verification Rates by Category</h4>
          <ResponsiveContainer width="100%" height={300}>
            <LineChart data={data.by_category || []}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="category" />
              <YAxis />
              <Tooltip />
              <Line
                type="monotone"
                dataKey="verification_rate"
                stroke="#F59E0B"
                strokeWidth={2}
              />
            </LineChart>
          </ResponsiveContainer>
        </div>
      </div>

      {data.most_reported && data.most_reported.length > 0 && (
        <div className="most-reported">
          <h4>Most Reported Categories</h4>
          <ul>
            {data.most_reported.map((item: any, index: number) => (
              <li key={index}>
                <strong>{item.category}</strong>: {item.count} reports
                {item.verification_rate && (
                  <span className="verification-rate">
                    ({item.verification_rate.toFixed(1)}% verified)
                  </span>
                )}
              </li>
            ))}
          </ul>
        </div>
      )}
    </div>
  );
}
