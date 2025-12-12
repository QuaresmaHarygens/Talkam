"use client"

import { useEffect, useState } from "react"
import { useParams, useRouter } from "next/navigation"
import { Navbar } from "@/components/navbar"
import { TabBar } from "@/components/tab-bar"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { apiClient } from "@/lib/api/client"
import { Users, TrendingUp, Heart, MapPin } from "lucide-react"
import type { Challenge } from "@/lib/mock/api"

export default function ChallengeDetailPage() {
  const params = useParams()
  const router = useRouter()
  const [challenge, setChallenge] = useState<Challenge | null>(null)

  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const loadChallenge = async () => {
      if (!params.id) return
      try {
        setLoading(true)
        setError(null)
        const challenge = await apiClient.getChallenge(params.id as string)
        const transformedChallenge = {
          id: challenge.id,
          title: challenge.title || '',
          description: challenge.description || '',
          category: challenge.category || 'social',
          status: challenge.status || 'active',
          progress: challenge.progress_percentage || 0,
          participants: challenge.participant_count || 0,
          volunteers: challenge.volunteer_count || 0,
          donors: challenge.donor_count || 0,
          location: {
            latitude: challenge.latitude || 6.4281,
            longitude: challenge.longitude || -10.7619,
            county: challenge.county || 'Unknown',
          },
          createdAt: challenge.created_at || new Date().toISOString(),
          expiresAt: challenge.expires_at,
        }
        setChallenge(transformedChallenge)
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Failed to load challenge')
        console.error('Error loading challenge:', err)
      } finally {
        setLoading(false)
      }
    }
    loadChallenge()
  }, [params.id])

  if (loading) {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
      </div>
    )
  }

  if (error || !challenge) {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <Card>
          <CardContent className="p-6 text-center">
            <p className="text-destructive">{error || 'Challenge not found'}</p>
            <Button onClick={() => router.push('/challenges')} className="mt-4">Back to Challenges</Button>
          </CardContent>
        </Card>
      </div>
    )
  }

  return (
    <div className="flex min-h-screen flex-col pb-16">
      <Navbar />
      <main className="container mx-auto flex-1 space-y-6 p-4">
        <div>
          <h1 className="text-3xl font-bold">{challenge.title}</h1>
          <p className="text-muted-foreground">{challenge.location.county}</p>
        </div>

        <Card>
          <CardHeader>
            <CardTitle>Progress</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-2">
              <div className="flex items-center justify-between">
                <span className="text-2xl font-bold">{challenge.progress}%</span>
              </div>
              <div className="w-full bg-muted rounded-full h-3">
                <div
                  className="bg-primary h-3 rounded-full transition-all"
                  style={{ width: `${challenge.progress}%` }}
                />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Description</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-sm">{challenge.description}</p>
          </CardContent>
        </Card>

        <div className="grid grid-cols-3 gap-4">
          <Card>
            <CardContent className="p-4 text-center">
              <Users className="h-6 w-6 mx-auto mb-2 text-primary" />
              <p className="text-2xl font-bold">{challenge.participants}</p>
              <p className="text-xs text-muted-foreground">Participants</p>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="p-4 text-center">
              <Heart className="h-6 w-6 mx-auto mb-2 text-secondary" />
              <p className="text-2xl font-bold">{challenge.volunteers}</p>
              <p className="text-xs text-muted-foreground">Volunteers</p>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="p-4 text-center">
              <TrendingUp className="h-6 w-6 mx-auto mb-2 text-primary" />
              <p className="text-2xl font-bold">{challenge.donors}</p>
              <p className="text-xs text-muted-foreground">Donors</p>
            </CardContent>
          </Card>
        </div>

        <div className="flex gap-3">
          <Button className="flex-1">Join Challenge</Button>
          <Button variant="outline" className="flex-1">Share</Button>
        </div>
      </main>
      <TabBar />
    </div>
  )
}
