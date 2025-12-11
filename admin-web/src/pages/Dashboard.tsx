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
  PieChart,
  Pie,
  Cell,
} from 'recharts';
import AnalyticsHeatmap from '../components/AnalyticsHeatmap';
import CategoryInsights from '../components/CategoryInsights';
import TimeSeriesChart from '../components/TimeSeriesChart';

const COLORS = ['#F59E0B', '#16A34A', '#EF4444', '#3B82F6', '#8B5CF6'];

export default function Dashboard() {
  const { data, isLoading } = useQuery({
    queryKey: ['dashboard'],
    queryFn: () => apiService.getDashboard(),
    refetchInterval: 30000, // Refresh every 30 seconds
  });

  if (isLoading) {
    return <div className="loading">Loading dashboard...</div>;
  }

  if (!data) {
    return <div>Error loading dashboard</div>;
  }

  return (
    <div className="dashboard">
      <h1>Analytics Dashboard</h1>
      
      {/* KPIs */}
      <div className="kpi-grid">
        <div className="kpi-card">
          <h3>Total Reports</h3>
          <p className="kpi-value">{data.kpis.total_reports}</p>
        </div>
        <div className="kpi-card">
          <h3>Verified</h3>
          <p className="kpi-value">{data.kpis.verified_reports}</p>
        </div>
        <div className="kpi-card">
          <h3>Verification Rate</h3>
          <p className="kpi-value">{data.kpis.verification_rate.toFixed(1)}%</p>
        </div>
        <div className="kpi-card">
          <h3>Avg Response Time</h3>
          <p className="kpi-value">{data.kpis.avg_response_time_hours.toFixed(1)}h</p>
        </div>
        <div className="kpi-card">
          <h3>Active Alerts</h3>
          <p className="kpi-value">{data.kpis.active_alerts}</p>
        </div>
      </div>

      {/* Charts */}
      <div className="charts-grid">
        <div className="chart-card">
          <h3>Reports by County</h3>
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={data.county_breakdown}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="county" />
              <YAxis />
              <Tooltip />
              <Bar dataKey="report_count" fill="#F59E0B" />
            </BarChart>
          </ResponsiveContainer>
        </div>

        <div className="chart-card">
          <h3>Category Trends</h3>
          <ResponsiveContainer width="100%" height={300}>
            <PieChart>
              <Pie
                data={data.category_trends}
                dataKey="count"
                nameKey="category"
                cx="50%"
                cy="50%"
                outerRadius={100}
                label
              >
                {data.category_trends.map((entry, index) => (
                  <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                ))}
              </Pie>
              <Tooltip />
            </PieChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Enhanced Analytics */}
      <div className="enhanced-analytics">
        <AnalyticsHeatmap days={30} />
        <CategoryInsights />
        <TimeSeriesChart days={30} groupBy="day" />
      </div>

      <p className="last-updated">
        Last updated: {new Date(data.last_updated).toLocaleString()}
      </p>
    </div>
  );
}
