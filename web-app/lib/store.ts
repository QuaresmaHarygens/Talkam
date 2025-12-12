import { create } from "zustand"
import { Report, Challenge, Notification } from "@/lib/mock/api"

interface AppState {
  user: {
    id: string | null
    name: string | null
    email: string | null
    isGuest: boolean
  }
  reports: Report[]
  challenges: Challenge[]
  notifications: Notification[]
  setUser: (user: { id: string | null; name: string | null; email: string | null; isGuest?: boolean }) => void
  setReports: (reports: Report[]) => void
  setChallenges: (challenges: Challenge[]) => void
  setNotifications: (notifications: Notification[]) => void
  addReport: (report: Report) => void
  addChallenge: (challenge: Challenge) => void
  markNotificationRead: (id: string) => void
}

export const useStore = create<AppState>((set) => ({
  user: {
    id: null,
    name: null,
    email: null,
    isGuest: false,
  },
  reports: [],
  challenges: [],
  notifications: [],
  setUser: (user) => set({ user: { ...user, isGuest: user.isGuest || false } }),
  setReports: (reports) => set({ reports }),
  setChallenges: (challenges) => set({ challenges }),
  setNotifications: (notifications) => set({ notifications }),
  addReport: (report) => set((state) => ({ reports: [report, ...state.reports] })),
  addChallenge: (challenge) => set((state) => ({ challenges: [challenge, ...state.challenges] })),
  markNotificationRead: (id) =>
    set((state) => ({
      notifications: state.notifications.map((n) => (n.id === id ? { ...n, read: true } : n)),
    })),
}))
