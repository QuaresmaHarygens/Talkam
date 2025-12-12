"use client"

import { useEffect, useState } from "react"
import { Navbar } from "@/components/navbar"
import { TabBar } from "@/components/tab-bar"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { useStore } from "@/lib/store"
import { apiClient } from "@/lib/api/client"
import { User, FileText, CheckCircle, Users, Settings } from "lucide-react"

export default function ProfilePage() {
  const { user, reports, challenges } = useStore()
  const [profile, setProfile] = useState<any>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const loadProfile = async () => {
      try {
        setLoading(true)
        setError(null)
        
        // Calculate stats from user's data
        const myReports = reports.filter((r) => r.status !== "rejected")
        const myVerifications = reports.filter((r) => r.status === "verified")
        const myChallenges = challenges
        const myCreatedChallenges = challenges.filter((c) => c.status === "active" || c.status === "completed")

        setProfile({
          id: user.id || "guest",
          name: user.name || "Guest User",
          email: user.email || "guest@example.com",
          avatar: null,
          stats: {
            reportsSubmitted: myReports.length,
            reportsVerified: myVerifications.length,
            challengesCreated: myCreatedChallenges.length,
            challengesJoined: myChallenges.length,
          },
        })
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Failed to load profile')
        console.error('Error loading profile:', err)
      } finally {
        setLoading(false)
      }
    }
    loadProfile()
  }, [user, reports, challenges])

  const myReports = reports.filter((r) => r.status !== "rejected")
  const myVerifications = reports.filter((r) => r.status === "verified")
  const myChallenges = challenges

  return (
    <div className="flex min-h-screen flex-col pb-16">
      <Navbar />
      <main className="container mx-auto flex-1 space-y-6 p-4">
        <div className="flex items-center gap-4">
          <div className="h-20 w-20 rounded-full bg-primary/10 flex items-center justify-center">
            <User className="h-10 w-10 text-primary" />
          </div>
          <div>
            <h1 className="text-2xl font-bold">{user.name || "Guest User"}</h1>
            <p className="text-muted-foreground">{user.email || "guest@example.com"}</p>
          </div>
        </div>

        {/* Stats */}
        {profile && (
          <div className="grid grid-cols-2 gap-4">
            <Card>
              <CardContent className="p-4 text-center">
                <FileText className="h-6 w-6 mx-auto mb-2 text-primary" />
                <p className="text-2xl font-bold">{profile.stats.reportsSubmitted}</p>
                <p className="text-xs text-muted-foreground">Reports</p>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="p-4 text-center">
                <CheckCircle className="h-6 w-6 mx-auto mb-2 text-secondary" />
                <p className="text-2xl font-bold">{profile.stats.reportsVerified}</p>
                <p className="text-xs text-muted-foreground">Verified</p>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="p-4 text-center">
                <Users className="h-6 w-6 mx-auto mb-2 text-primary" />
                <p className="text-2xl font-bold">{profile.stats.challengesCreated}</p>
                <p className="text-xs text-muted-foreground">Challenges</p>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="p-4 text-center">
                <Users className="h-6 w-6 mx-auto mb-2 text-secondary" />
                <p className="text-2xl font-bold">{profile.stats.challengesJoined}</p>
                <p className="text-xs text-muted-foreground">Joined</p>
              </CardContent>
            </Card>
          </div>
        )}

        {/* My Reports */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center">
              <FileText className="mr-2 h-5 w-5" />
              My Reports
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-2">
              {myReports.length > 0 ? (
                myReports.slice(0, 5).map((report) => (
                  <div key={report.id} className="p-3 border rounded-lg">
                    <p className="font-medium text-sm">{report.summary}</p>
                    <p className="text-xs text-muted-foreground mt-1">{report.status}</p>
                  </div>
                ))
              ) : (
                <p className="text-sm text-muted-foreground">No reports yet</p>
              )}
            </div>
          </CardContent>
        </Card>

        {/* My Verifications */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center">
              <CheckCircle className="mr-2 h-5 w-5" />
              My Verifications
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-2">
              {myVerifications.length > 0 ? (
                myVerifications.slice(0, 5).map((report) => (
                  <div key={report.id} className="p-3 border rounded-lg">
                    <p className="font-medium text-sm">{report.summary}</p>
                    <p className="text-xs text-muted-foreground mt-1">
                      Verified • {report.verificationScore && Math.round(report.verificationScore * 100)}%
                    </p>
                  </div>
                ))
              ) : (
                <p className="text-sm text-muted-foreground">No verifications yet</p>
              )}
            </div>
          </CardContent>
        </Card>

        {/* My Challenges */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center">
              <Users className="mr-2 h-5 w-5" />
              My Challenges
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-2">
              {myChallenges.length > 0 ? (
                myChallenges.map((challenge) => (
                  <div key={challenge.id} className="p-3 border rounded-lg">
                    <p className="font-medium text-sm">{challenge.title}</p>
                    <p className="text-xs text-muted-foreground mt-1">{challenge.progress}% complete</p>
                  </div>
                ))
              ) : (
                <p className="text-sm text-muted-foreground">No challenges yet</p>
              )}
            </div>
          </CardContent>
        </Card>

        {/* Settings */}
        <Button variant="outline" className="w-full">
          <Settings className="mr-2 h-4 w-4" />
          Settings
        </Button>
      </main>
      <TabBar />
    </div>
  )
}
