import { useQuery } from '@tanstack/react-query';
import { apiService } from '../services/api';
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Legend,
} from 'recharts';

interface TimeSeriesChartProps {
  days?: number;
  groupBy?: 'day' | 'week' | 'month';
}

export default function TimeSeriesChart({ days = 30, groupBy = 'day' }: TimeSeriesChartProps) {
  const { data, isLoading } = useQuery({
    queryKey: ['time-series', days, groupBy],
    queryFn: () => apiService.getTimeSeries(days, groupBy),
  });

  if (isLoading) {
    return <div className="loading">Loading time series...</div>;
  }

  if (!data || !data.data || !Array.isArray(data.data)) {
    return <div>No time series data available</div>;
  }

  return (
    <div className="time-series-chart">
      <h3>Report Trends Over Time</h3>
      <div className="chart-controls">
        <label>
          Group by:
          <select
            value={groupBy}
            onChange={(e) => {
              // In a real app, this would update state
              window.location.reload();
            }}
          >
            <option value="day">Day</option>
            <option value="week">Week</option>
            <option value="month">Month</option>
          </select>
        </label>
      </div>
      <ResponsiveContainer width="100%" height={400}>
        <LineChart data={data.data}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="period" />
          <YAxis />
          <Tooltip />
          <Legend />
          <Line
            type="monotone"
            dataKey="reports_created"
            stroke="#3B82F6"
            strokeWidth={2}
            name="Reports Created"
          />
          <Line
            type="monotone"
            dataKey="reports_verified"
            stroke="#16A34A"
            strokeWidth={2}
            name="Reports Verified"
          />
          <Line
            type="monotone"
            dataKey="attestations"
            stroke="#F59E0B"
            strokeWidth={2}
            name="Attestations"
          />
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
}
