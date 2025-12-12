/**
 * TypeScript type definitions for Talkam Liberia
 */

export interface Report {
  id: string;
  report_id?: string;
  status: string;
  created_at: string;
  updated_at?: string;
  summary: string;
  details?: string;
  category: string;
  severity: string;
  location: {
    latitude: number;
    longitude: number;
    county: string;
    district?: string;
    description?: string;
  };
  verification_score?: number;
  media: MediaFile[];
  anonymous?: boolean;
}

export interface MediaFile {
  key: string;
  type: string;
  checksum?: string;
  blur_faces?: boolean;
  voice_masked?: boolean;
  file?: File;
  hash_sha256?: string;
  metadata?: Record<string, any>;
}

export interface TrackingInfo {
  report_id: string;
  status: string;
  category: string;
  severity: string;
  created_at: string;
  updated_at?: string;
  message: string;
}

export type ReportCategory = 
  | 'social'
  | 'economic'
  | 'religious'
  | 'political'
  | 'health'
  | 'violence'
  | 'corruption'
  | 'gbv'
  | 'public-service'
  | 'human-rights'
  | 'other';

export type ReportSeverity = 'low' | 'medium' | 'high' | 'critical';

export type ReportStatus = 
  | 'submitted'
  | 'under-review'
  | 'verified'
  | 'rejected'
  | 'resolved'
  | 'escalated';















