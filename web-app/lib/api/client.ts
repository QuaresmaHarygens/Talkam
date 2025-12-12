// Real API client for TalkAm backend
const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'https://little-amity-talkam-c84a1504.koyeb.app/v1'

interface ApiResponse<T> {
  data?: T
  error?: string
  message?: string
}

class ApiClient {
  private baseUrl: string
  private token: string | null = null

  constructor(baseUrl: string = API_BASE_URL) {
    this.baseUrl = baseUrl
    // Load token from localStorage if available
    if (typeof window !== 'undefined') {
      this.token = localStorage.getItem('auth_token')
    }
  }

  setToken(token: string | null) {
    this.token = token
    if (typeof window !== 'undefined') {
      if (token) {
        localStorage.setItem('auth_token', token)
      } else {
        localStorage.removeItem('auth_token')
      }
    }
  }

  private async request<T>(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<T> {
    const url = `${this.baseUrl}${endpoint}`
    const headers = new Headers(options.headers)
    headers.set('Content-Type', 'application/json')

    if (this.token) {
      headers.set('Authorization', `Bearer ${this.token}`)
    }

    try {
      const response = await fetch(url, {
        ...options,
        headers,
      })

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}))
        throw new Error(errorData.detail || errorData.message || `HTTP ${response.status}`)
      }

      const data = await response.json()
      return data
    } catch (error) {
      if (error instanceof Error) {
        throw error
      }
      throw new Error('Network error')
    }
  }

  // Auth endpoints
  async register(data: {
    full_name: string
    phone?: string
    email?: string
    password: string
    language?: string
  }) {
    return this.request<{ access_token: string; user: any }>('/auth/register', {
      method: 'POST',
      body: JSON.stringify(data),
    })
  }

  async login(data: { phone: string; password: string; device_id?: string }) {
    const response = await this.request<{ access_token: string; user: any }>('/auth/login', {
      method: 'POST',
      body: JSON.stringify(data),
    })
    if (response.access_token) {
      this.setToken(response.access_token)
    }
    return response
  }

  async anonymousStart(data: {
    device_hash: string
    county?: string
    capabilities?: string[]
  }) {
    const response = await this.request<{ access_token: string; user: any }>('/auth/anonymous-start', {
      method: 'POST',
      body: JSON.stringify(data),
    })
    if (response.access_token) {
      this.setToken(response.access_token)
    }
    return response
  }

  // Reports endpoints
  async searchReports(params?: {
    page?: number
    page_size?: number
    category?: string
    severity?: string
    county?: string
    text?: string
  }) {
    const queryParams = new URLSearchParams()
    if (params) {
      Object.entries(params).forEach(([key, value]) => {
        if (value !== undefined && value !== null) {
          queryParams.append(key, String(value))
        }
      })
    }
    const query = queryParams.toString()
    return this.request<{
      results: any[]
      total: number
      page: number
      page_size: number
      total_pages: number
    }>(`/reports/search${query ? `?${query}` : ''}`)
  }

  async getReport(id: string) {
    return this.request<any>(`/reports/${id}`)
  }

  async createReport(data: {
    summary: string
    details: string
    category: string
    severity: string
    latitude: number
    longitude: number
    county?: string
    district?: string
    media_keys?: string[]
  }) {
    return this.request<any>('/reports/create', {
      method: 'POST',
      body: JSON.stringify(data),
    })
  }

  // Challenges endpoints
  async listChallenges(params?: {
    lat: number
    lng: number
    radius_km?: number
    category?: string
    status?: string
  }) {
    const queryParams = new URLSearchParams()
    if (params) {
      Object.entries(params).forEach(([key, value]) => {
        if (value !== undefined && value !== null) {
          queryParams.append(key, String(value))
        }
      })
    }
    const query = queryParams.toString()
    return this.request<{ challenges: any[] }>(`/challenges/list${query ? `?${query}` : ''}`)
  }

  async getChallenge(id: string) {
    return this.request<any>(`/challenges/${id}`)
  }

  async createChallenge(data: {
    title: string
    description: string
    category: string
    latitude: number
    longitude: number
    county?: string
    district?: string
    needed_resources?: Record<string, any>
    urgency_level?: string
    duration_days?: number
    expected_impact?: string
    media_urls?: string[]
  }) {
    return this.request<any>('/challenges/create', {
      method: 'POST',
      body: JSON.stringify(data),
    })
  }

  async joinChallenge(id: string, data: { role: string; contribution_details?: any }) {
    return this.request<any>(`/challenges/${id}/join`, {
      method: 'POST',
      body: JSON.stringify(data),
    })
  }

  // Notifications endpoints
  async getNotifications(params?: { read?: boolean; limit?: number }) {
    const queryParams = new URLSearchParams()
    if (params) {
      Object.entries(params).forEach(([key, value]) => {
        if (value !== undefined && value !== null) {
          queryParams.append(key, String(value))
        }
      })
    }
    const query = queryParams.toString()
    return this.request<{ notifications: any[] }>(`/notifications${query ? `?${query}` : ''}`)
  }

  async markNotificationRead(id: string) {
    return this.request<any>(`/notifications/${id}/read`, {
      method: 'POST',
    })
  }

  // Verify endpoints
  async verifyReport(id: string, data: { verified: boolean; comments?: string }) {
    return this.request<any>(`/verify/${id}`, {
      method: 'POST',
      body: JSON.stringify(data),
    })
  }

  // Media endpoints
  async requestUploadUrl(data: { type: 'photo' | 'video' | 'audio'; key?: string }) {
    return this.request<{
      upload_url: string
      fields: Record<string, string>
      expires_in: number
      media_key: string
    }>('/media/upload', {
      method: 'POST',
      body: JSON.stringify(data),
    })
  }
}

// Export singleton instance
export const apiClient = new ApiClient()

// Export types
export type { ApiResponse }
