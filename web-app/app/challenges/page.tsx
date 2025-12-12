"use client"

import { useEffect, useState } from "react"
import Link from "next/link"
import { Navbar } from "@/components/navbar"
import { TabBar } from "@/components/tab-bar"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { useStore } from "@/lib/store"
import { apiClient } from "@/lib/api/client"
import { Plus, Users, TrendingUp, ArrowRight } from "lucide-react"
import type { Challenge } from "@/lib/mock/api"

export default function ChallengesPage() {
  const { challenges, setChallenges } = useStore()
  const [filter, setFilter] = useState<"active" | "completed">("active")
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const loadChallenges = async () => {
      try {
        setLoading(true)
        setError(null)
        
        // Get user's location (default to Monrovia if not available)
        let lat = 6.4281
        let lng = -10.7619
        
        if (navigator.geolocation) {
          try {
            const position = await new Promise<GeolocationPosition>((resolve, reject) => {
              navigator.geolocation.getCurrentPosition(resolve, reject, { timeout: 5000 })
            })
            lat = position.coords.latitude
            lng = position.coords.longitude
          } catch (err) {
            // Use default location
          }
        }

        const response = await apiClient.listChallenges({
          lat,
          lng,
          radius_km: 10,
          status: filter,
        })
        
        const transformedChallenges = (response.challenges || []).map((c: any) => ({
          id: c.id,
          title: c.title || '',
          description: c.description || '',
          category: c.category || 'social',
          status: c.status || 'active',
          progress: c.progress_percentage || 0,
          participants: c.participant_count || 0,
          volunteers: c.volunteer_count || 0,
          donors: c.donor_count || 0,
          location: {
            latitude: c.latitude || lat,
            longitude: c.longitude || lng,
            county: c.county || 'Unknown',
          },
          createdAt: c.created_at || new Date().toISOString(),
          expiresAt: c.expires_at,
        }))
        setChallenges(transformedChallenges)
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Failed to load challenges')
        console.error('Error loading challenges:', err)
      } finally {
        setLoading(false)
      }
    }
    loadChallenges()
  }, [setChallenges, filter])

  const filteredChallenges = challenges.filter((c) => {
    if (filter === "active") return c.status === "active"
    return c.status === "completed"
  })

  return (
    <div className="flex min-h-screen flex-col pb-16">
      <Navbar />
      <main className="container mx-auto flex-1 space-y-6 p-4">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold">Community Challenges</h1>
            <p className="text-muted-foreground">Join challenges and make a difference</p>
          </div>
          <Link href="/challenges/new">
            <Button size="icon" className="rounded-full">
              <Plus className="h-5 w-5" />
            </Button>
          </Link>
        </div>

        {/* Filter Tabs */}
        <div className="flex gap-2 border-b">
          {[
            { value: "active", label: "Active" },
            { value: "completed", label: "Completed" },
          ].map((tab) => (
            <button
              key={tab.value}
              onClick={() => setFilter(tab.value as any)}
              className={`px-4 py-2 text-sm font-medium border-b-2 transition-colors ${
                filter === tab.value
                  ? "border-primary text-primary"
                  : "border-transparent text-muted-foreground hover:text-foreground"
              }`}
            >
              {tab.label}
            </button>
          ))}
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

        {/* Challenges List */}
        {!loading && !error && (
          <div className="space-y-4">
            {filteredChallenges.length > 0 ? (
            filteredChallenges.map((challenge) => (
              <Link key={challenge.id} href={`/challenges/${challenge.id}`}>
                <Card className="hover:shadow-md transition-shadow cursor-pointer">
                  <CardHeader>
                    <div className="flex items-start justify-between">
                      <div className="flex-1">
                        <CardTitle className="mb-2">{challenge.title}</CardTitle>
                        <p className="text-sm text-muted-foreground mb-3">{challenge.description}</p>
                        <div className="flex items-center gap-4 text-sm">
                          <div className="flex items-center gap-1">
                            <Users className="h-4 w-4 text-muted-foreground" />
                            <span>{challenge.participants}</span>
                          </div>
                          <div className="flex items-center gap-1">
                            <TrendingUp className="h-4 w-4 text-muted-foreground" />
                            <span>{challenge.progress}%</span>
                          </div>
                        </div>
                      </div>
                    </div>
                  </CardHeader>
                  <CardContent>
                    <div className="w-full bg-muted rounded-full h-2 mb-2">
                      <div
                        className="bg-primary h-2 rounded-full transition-all"
                        style={{ width: `${challenge.progress}%` }}
                      />
                    </div>
                    <p className="text-xs text-muted-foreground">
                      {challenge.location.county} • {new Date(challenge.createdAt).toLocaleDateString()}
                    </p>
                  </CardContent>
                </Card>
              </Link>
            ))
          ) : (
            <Card>
              <CardContent className="p-8 text-center text-muted-foreground">
                <p>No {filter} challenges at the moment.</p>
                <Link href="/challenges/new">
                  <Button variant="outline" className="mt-4">
                    Create First Challenge
                  </Button>
                </Link>
              </CardContent>
            </Card>
          )}
        </div>
      </main>
      <TabBar />
    </div>
  )
}
