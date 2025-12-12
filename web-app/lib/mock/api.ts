// Mock API for development
export interface Report {
  id: string
  summary: string
  category: string
  severity: "low" | "medium" | "high" | "critical"
  status: "submitted" | "under-review" | "verified" | "resolved" | "rejected"
  location: {
    latitude: number
    longitude: number
    county: string
    district?: string
  }
  createdAt: string
  media?: string[]
  verificationScore?: number
  witnessCount?: number
}

export interface Challenge {
  id: string
  title: string
  description: string
  category: string
  status: "active" | "completed" | "expired"
  progress: number
  participants: number
  volunteers: number
  donors: number
  location: {
    latitude: number
    longitude: number
    county: string
  }
  createdAt: string
  expiresAt?: string
}

export interface Notification {
  id: string
  title: string
  message: string
  type: "report" | "challenge" | "verification" | "system"
  read: boolean
  createdAt: string
  actionUrl?: string
}

// Mock data
const mockReports: Report[] = [
  {
    id: "1",
    summary: "Pothole on Main Street causing traffic issues",
    category: "infrastructure",
    severity: "medium",
    status: "under-review",
    location: {
      latitude: 6.4281,
      longitude: -10.7619,
      county: "Montserrado",
      district: "Monrovia",
    },
    createdAt: new Date().toISOString(),
    verificationScore: 0.75,
    witnessCount: 3,
  },
  {
    id: "2",
    summary: "Street lights not working in West Point",
    category: "infrastructure",
    severity: "high",
    status: "verified",
    location: {
      latitude: 6.3153,
      longitude: -10.8074,
      county: "Montserrado",
      district: "West Point",
    },
    createdAt: new Date(Date.now() - 86400000).toISOString(),
    verificationScore: 0.9,
    witnessCount: 5,
  },
]

const mockChallenges: Challenge[] = [
  {
    id: "1",
    title: "Community Clean-up Drive",
    description: "Join us for a neighborhood clean-up this weekend",
    category: "environmental",
    status: "active",
    progress: 65,
    participants: 45,
    volunteers: 20,
    donors: 15,
    location: {
      latitude: 6.4281,
      longitude: -10.7619,
      county: "Montserrado",
    },
    createdAt: new Date().toISOString(),
    expiresAt: new Date(Date.now() + 7 * 86400000).toISOString(),
  },
]

const mockNotifications: Notification[] = [
  {
    id: "1",
    title: "New Report in Your Area",
    message: "A new infrastructure report has been submitted nearby",
    type: "report",
    read: false,
    createdAt: new Date().toISOString(),
    actionUrl: "/verify/1",
  },
]

// Mock API functions
export const mockAPI = {
  reports: {
    list: async (): Promise<Report[]> => {
      await new Promise((resolve) => setTimeout(resolve, 500))
      return mockReports
    },
    get: async (id: string): Promise<Report | null> => {
      await new Promise((resolve) => setTimeout(resolve, 300))
      return mockReports.find((r) => r.id === id) || null
    },
    create: async (report: Omit<Report, "id" | "createdAt">): Promise<Report> => {
      await new Promise((resolve) => setTimeout(resolve, 800))
      const newReport: Report = {
        ...report,
        id: String(mockReports.length + 1),
        createdAt: new Date().toISOString(),
      }
      mockReports.push(newReport)
      return newReport
    },
  },
  challenges: {
    list: async (): Promise<Challenge[]> => {
      await new Promise((resolve) => setTimeout(resolve, 500))
      return mockChallenges
    },
    get: async (id: string): Promise<Challenge | null> => {
      await new Promise((resolve) => setTimeout(resolve, 300))
      return mockChallenges.find((c) => c.id === id) || null
    },
    create: async (challenge: Omit<Challenge, "id" | "createdAt">): Promise<Challenge> => {
      await new Promise((resolve) => setTimeout(resolve, 800))
      const newChallenge: Challenge = {
        ...challenge,
        id: String(mockChallenges.length + 1),
        createdAt: new Date().toISOString(),
      }
      mockChallenges.push(newChallenge)
      return newChallenge
    },
  },
  verify: {
    list: async (): Promise<Report[]> => {
      await new Promise((resolve) => setTimeout(resolve, 500))
      return mockReports.filter((r) => r.status === "under-review" || r.status === "submitted")
    },
    verify: async (reportId: string, verified: boolean): Promise<Report> => {
      await new Promise((resolve) => setTimeout(resolve, 500))
      const report = mockReports.find((r) => r.id === reportId)
      if (report) {
        report.status = verified ? "verified" : "rejected"
        report.verificationScore = verified ? 0.9 : 0.1
      }
      return report!
    },
  },
  notifications: {
    list: async (): Promise<Notification[]> => {
      await new Promise((resolve) => setTimeout(resolve, 300))
      return mockNotifications
    },
    markRead: async (id: string): Promise<void> => {
      await new Promise((resolve) => setTimeout(resolve, 200))
      const notification = mockNotifications.find((n) => n.id === id)
      if (notification) {
        notification.read = true
      }
    },
  },
  profile: {
    get: async () => {
      await new Promise((resolve) => setTimeout(resolve, 300))
      return {
        id: "1",
        name: "John Doe",
        email: "john@example.com",
        avatar: null,
        stats: {
          reportsSubmitted: 12,
          reportsVerified: 45,
          challengesCreated: 3,
          challengesJoined: 8,
        },
      }
    },
  },
}
