/**
 * API Endpoints for Talkam Liberia
 */
import { apiClient } from './client';

export interface Location {
  latitude: number;
  longitude: number;
  county: string;
  district?: string;
  description?: string;
}

export interface MediaRef {
  key: string;
  type: string;
  checksum?: string;
  blur_faces?: boolean;
  voice_masked?: boolean;
}

export interface ReportCreateRequest {
  category: string;
  severity: string;
  anonymous?: boolean;
  summary: string;
  details?: string;
  media: MediaRef[];
  location: Location;
  witness_count?: number;
}

export interface ReportResponse {
  id: string;
  report_id?: string;
  status: string;
  created_at: string;
  summary: string;
  details?: string;
  category: string;
  severity: string;
  location: Location;
  verification_score?: number;
  media: MediaRef[];
}

export interface TrackingResponse {
  report_id: string;
  status: string;
  category: string;
  severity: string;
  created_at: string;
  updated_at?: string;
  message: string;
}

export const reportsApi = {
  /**
   * Create a new report
   */
  create: async (data: ReportCreateRequest): Promise<ReportResponse> => {
    return apiClient.post<ReportResponse>('/reports/create', data);
  },

  /**
   * Get report by ID (requires auth)
   */
  getById: async (id: string): Promise<ReportResponse> => {
    return apiClient.get<ReportResponse>(`/reports/${id}`);
  },

  /**
   * Track report status (public, no auth required)
   */
  track: async (reportId: string): Promise<TrackingResponse> => {
    return apiClient.get<TrackingResponse>(`/reports/track/${reportId}`);
  },

  /**
   * Search reports (requires auth)
   */
  search: async (params: {
    county?: string;
    category?: string;
    status?: string;
    text?: string;
    page?: number;
    page_size?: number;
  }): Promise<any> => {
    return apiClient.get('/reports/search', { params });
  },
};

export const authApi = {
  /**
   * Login
   */
  login: async (phone: string, password: string): Promise<{ access_token: string; refresh_token: string }> => {
    return apiClient.post('/auth/login', { phone, password });
  },

  /**
   * Register
   */
  register: async (data: {
    full_name: string;
    phone: string;
    password: string;
    email?: string;
  }): Promise<{ access_token: string; refresh_token: string }> => {
    return apiClient.post('/auth/register', data);
  },
};

export const mediaApi = {
  /**
   * Request presigned URL for media upload
   */
  getUploadUrl: async (fileType: string, fileName: string): Promise<{ upload_url: string; media_key: string; expires_at: string }> => {
    // Determine media type from file type
    let mediaType = 'photo';
    if (fileType.startsWith('video/')) {
      mediaType = 'video';
    } else if (fileType.startsWith('audio/')) {
      mediaType = 'audio';
    } else if (fileType === 'application/pdf') {
      mediaType = 'document';
    }
    
    return apiClient.post('/media/upload', {
      type: mediaType,
      key: fileName,
    });
  },
};

