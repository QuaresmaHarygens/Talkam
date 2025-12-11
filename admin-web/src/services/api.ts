import axios from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://127.0.0.1:8000/v1';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add auth token to requests
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('access_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export interface Report {
  id: string;
  status: string;
  created_at: string;
  summary: string;
  category: string;
  severity: string;
  location: {
    county: string;
    district?: string;
    latitude: number;
    longitude: number;
  };
  verification_score?: number;
}

export interface DashboardData {
  kpis: {
    total_reports: number;
    verified_reports: number;
    verification_rate: number;
    avg_response_time_hours: number;
    offline_sync_success_rate: number;
    active_alerts: number;
  };
  county_breakdown: Array<{
    county: string;
    report_count: number;
    verified_count: number;
  }>;
  category_trends: Array<{
    category: string;
    count: number;
    trend: string;
  }>;
  last_updated: string;
}

export const apiService = {
  async login(phone: string, password: string) {
    const response = await api.post('/auth/login', { phone, password });
    localStorage.setItem('access_token', response.data.access_token);
    return response.data;
  },

  async getDashboard(): Promise<DashboardData> {
    const response = await api.get('/dashboards/analytics');
    return response.data;
  },

  async getHeatmap(days: number = 30) {
    const response = await api.get('/dashboards/heatmap', { params: { days } });
    return response.data;
  },

  async getCategoryInsights() {
    const response = await api.get('/dashboards/category-insights');
    return response.data;
  },

  async getTimeSeries(days: number = 30, groupBy: 'day' | 'week' | 'month' = 'day') {
    const response = await api.get('/dashboards/time-series', {
      params: { days, group_by: groupBy },
    });
    return response.data;
  },

  async getReports(params?: {
    county?: string;
    category?: string;
    status?: string;
    text?: string;
    severity?: string;
    assigned_agency?: string;
    min_priority?: number;
    date_from?: string;
    date_to?: string;
    sort_by?: string;
    sort_order?: 'asc' | 'desc';
    page?: number;
    page_size?: number;
  }) {
    const response = await api.get('/reports/search', { params });
    return response.data;
  },

  async getReport(id: string): Promise<Report> {
    const response = await api.get(`/reports/${id}`);
    return response.data;
  },

  async verifyReport(id: string, action: string, comment?: string) {
    const response = await api.post(`/reports/${id}/verify`, {
      action,
      comment,
    });
    return response.data;
  },

  async broadcastAlert(data: {
    message: string;
    severity: string;
    target_counties?: string[];
    send_sms?: boolean;
    send_push?: boolean;
  }) {
    const response = await api.post('/alerts/broadcast', data);
    return response.data;
  },
};

export default api;
