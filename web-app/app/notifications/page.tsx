"use client"

import { useEffect, useState } from "react"
import { Navbar } from "@/components/navbar"
import { TabBar } from "@/components/tab-bar"
import { Card, CardContent } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { useStore } from "@/lib/store"
import { apiClient } from "@/lib/api/client"
import { Bell, CheckCircle, Users, MapPin, X } from "lucide-react"

export default function NotificationsPage() {
  const { notifications, setNotifications, markNotificationRead } = useStore()
  const [swipedId, setSwipedId] = useState<string | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const loadNotifications = async () => {
      try {
        setLoading(true)
        setError(null)
        const response = await apiClient.getNotifications({ limit: 50 })
        const transformedNotifications = (response.notifications || []).map((n: any) => {
          let notificationType: 'report' | 'challenge' | 'verification' | 'system' = 'system'
          if (n.notification_type?.includes('challenge')) {
            notificationType = 'challenge'
          } else if (n.notification_type?.includes('verification') || n.notification_type?.includes('attestation')) {
            notificationType = 'verification'
          } else if (n.report_id) {
            notificationType = 'report'
          }

          return {
            id: n.id,
            title: n.title || 'Notification',
            message: n.message || '',
            type: notificationType,
            read: n.read || false,
            createdAt: n.created_at || new Date().toISOString(),
            actionUrl: n.report_id ? `/verify/${n.report_id}` : n.challenge_id ? `/challenges/${n.challenge_id}` : undefined,
          }
        })
        setNotifications(transformedNotifications)
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Failed to load notifications')
        console.error('Error loading notifications:', err)
      } finally {
        setLoading(false)
      }
    }
    loadNotifications()
  }, [setNotifications])

  const getIcon = (type: string) => {
    switch (type) {
      case "report":
        return <MapPin className="h-5 w-5" />
      case "challenge":
        return <Users className="h-5 w-5" />
      case "verification":
        return <CheckCircle className="h-5 w-5" />
      default:
        return <Bell className="h-5 w-5" />
    }
  }

  const handleSwipe = async (id: string, action: "read" | "delete") => {
    if (action === "read") {
      try {
        await apiClient.markNotificationRead(id)
        markNotificationRead(id)
      } catch (err) {
        console.error('Error marking notification as read:', err)
      }
    } else {
      // Delete is handled client-side for now
      setNotifications(notifications.filter((n) => n.id !== id))
    }
    setSwipedId(null)
  }

  return (
    <div className="flex min-h-screen flex-col pb-16">
      <Navbar />
      <main className="container mx-auto flex-1 space-y-3 p-4">
        <div>
          <h1 className="text-3xl font-bold">Notifications</h1>
          <p className="text-muted-foreground">Stay updated with community activity</p>
        </div>

        {/* Loading State */}
        {loading && (
          <div className="flex items-center justify-center py-12">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
          </div>
        )}

        {/* Error State */}
        {error && !loading && (
          <Card>
            <CardContent className="p-6 text-center">
              <p className="text-destructive">{error}</p>
              <Button onClick={() => window.location.reload()} className="mt-4">Retry</Button>
            </CardContent>
          </Card>
        )}

        {/* Notifications List */}
        {!loading && !error && (
          <div className="space-y-2">
            {notifications.length > 0 ? (
            notifications.map((notification) => (
              <div
                key={notification.id}
                className="relative"
                onTouchStart={(e) => {
                  const touch = e.touches[0]
                  const startX = touch.clientX
                  const element = e.currentTarget

                  const onTouchMove = (moveEvent: TouchEvent) => {
                    const moveTouch = moveEvent.touches[0]
                    const diff = moveTouch.clientX - startX
                    if (diff < -50) {
                      setSwipedId(notification.id)
                    } else if (diff > 50) {
                      setSwipedId(null)
                    }
                  }

                  const onTouchEnd = () => {
                    document.removeEventListener("touchmove", onTouchMove)
                    document.removeEventListener("touchend", onTouchEnd)
                  }

                  document.addEventListener("touchmove", onTouchMove)
                  document.addEventListener("touchend", onTouchEnd)
                }}
              >
                <Card
                  className={`transition-transform ${
                    swipedId === notification.id ? "translate-x-[-80px]" : ""
                  } ${!notification.read ? "bg-primary/5 border-primary/20" : ""}`}
                >
                  <CardContent className="p-4">
                    <div className="flex items-start gap-3">
                      <div
                        className={`p-2 rounded-lg ${
                          notification.type === "report"
                            ? "bg-blue-100 text-blue-600"
                            : notification.type === "challenge"
                            ? "bg-green-100 text-green-600"
                            : "bg-purple-100 text-purple-600"
                        }`}
                      >
                        {getIcon(notification.type)}
                      </div>
                      <div className="flex-1">
                        <h3 className="font-semibold mb-1">{notification.title}</h3>
                        <p className="text-sm text-muted-foreground">{notification.message}</p>
                        <p className="text-xs text-muted-foreground mt-1">
                          {new Date(notification.createdAt).toLocaleDateString()}
                        </p>
                      </div>
                      {!notification.read && (
                        <div className="h-2 w-2 rounded-full bg-primary" />
                      )}
                    </div>
                  </CardContent>
                </Card>

                {/* Swipe Actions */}
                <div className="absolute right-0 top-0 h-full flex items-center gap-2 pr-4">
                  <Button
                    size="sm"
                    variant="outline"
                    onClick={() => handleSwipe(notification.id, "read")}
                    className="bg-blue-500 text-white"
                  >
                    Mark Read
                  </Button>
                  <Button
                    size="sm"
                    variant="outline"
                    onClick={() => handleSwipe(notification.id, "delete")}
                    className="bg-red-500 text-white"
                  >
                    <X className="h-4 w-4" />
                  </Button>
                </div>
              </div>
            ))
          ) : (
            <Card>
              <CardContent className="p-8 text-center text-muted-foreground">
                <Bell className="h-12 w-12 mx-auto mb-4 opacity-50" />
                <p>No notifications</p>
              </CardContent>
            </Card>
          )}
          </div>
        )}
      </main>
      <TabBar />
    </div>
  )
}
