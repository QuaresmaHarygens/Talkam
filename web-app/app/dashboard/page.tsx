"use client"

import { useEffect } from "react"
import Link from "next/link"
import { Navbar } from "@/components/navbar"
import { TabBar } from "@/components/tab-bar"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { useStore } from "@/lib/store"
import { mockAPI } from "@/lib/mock/api"
import { FileText, CheckCircle, Users, MapPin, Plus, ArrowRight } from "lucide-react"

export default function DashboardPage() {
  const { reports, setReports, setNotifications } = useStore()

  useEffect(() => {
    // Load data
    mockAPI.reports.list().then(setReports)
    mockAPI.notifications.list().then(setNotifications)
  }, [setReports, setNotifications])

  const recentReports = reports.slice(0, 5)

  return (
    <div className="flex min-h-screen flex-col pb-16">
      <Navbar />
      <main className="container mx-auto flex-1 space-y-6 p-4">
        <div>
          <h1 className="text-3xl font-bold">Dashboard</h1>
          <p className="text-muted-foreground">Welcome back! Here's what's happening in your community.</p>
        </div>

        {/* Main Action Cards */}
        <div className="grid grid-cols-2 gap-4">
          <Link href="/report">
            <Card className="hover:shadow-lg transition-shadow cursor-pointer">
              <CardHeader className="pb-3">
                <div className="flex items-center justify-between">
                  <FileText className="h-8 w-8 text-primary" />
                  <ArrowRight className="h-4 w-4 text-muted-foreground" />
                </div>
                <CardTitle className="text-lg">Report Issue</CardTitle>
              </CardHeader>
              <CardContent>
                <CardDescription>Submit a new civic issue</CardDescription>
              </CardContent>
            </Card>
          </Link>

          <Link href="/verify">
            <Card className="hover:shadow-lg transition-shadow cursor-pointer">
              <CardHeader className="pb-3">
                <div className="flex items-center justify-between">
                  <CheckCircle className="h-8 w-8 text-secondary" />
                  <ArrowRight className="h-4 w-4 text-muted-foreground" />
                </div>
                <CardTitle className="text-lg">Verify Reports</CardTitle>
              </CardHeader>
              <CardContent>
                <CardDescription>Help verify community reports</CardDescription>
              </CardContent>
            </Card>
          </Link>

          <Link href="/challenges">
            <Card className="hover:shadow-lg transition-shadow cursor-pointer">
              <CardHeader className="pb-3">
                <div className="flex items-center justify-between">
                  <Users className="h-8 w-8 text-primary" />
                  <ArrowRight className="h-4 w-4 text-muted-foreground" />
                </div>
                <CardTitle className="text-lg">Challenges</CardTitle>
              </CardHeader>
              <CardContent>
                <CardDescription>Join community challenges</CardDescription>
              </CardContent>
            </Card>
          </Link>

          <Link href="/map">
            <Card className="hover:shadow-lg transition-shadow cursor-pointer">
              <CardHeader className="pb-3">
                <div className="flex items-center justify-between">
                  <MapPin className="h-8 w-8 text-secondary" />
                  <ArrowRight className="h-4 w-4 text-muted-foreground" />
                </div>
                <CardTitle className="text-lg">Map View</CardTitle>
              </CardHeader>
              <CardContent>
                <CardDescription>Explore issues on map</CardDescription>
              </CardContent>
            </Card>
          </Link>
        </div>

        {/* Recent Reports */}
        <div>
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-xl font-semibold">Recent Reports</h2>
            <Link href="/verify">
              <Button variant="ghost" size="sm">
                View All
                <ArrowRight className="ml-2 h-4 w-4" />
              </Button>
            </Link>
          </div>

          <div className="space-y-3">
            {recentReports.length > 0 ? (
              recentReports.map((report) => (
                <Link key={report.id} href={`/verify/${report.id}`}>
                  <Card className="hover:shadow-md transition-shadow cursor-pointer">
                    <CardContent className="p-4">
                      <div className="flex items-start justify-between">
                        <div className="flex-1">
                          <h3 className="font-semibold mb-1">{report.summary}</h3>
                          <p className="text-sm text-muted-foreground">
                            {report.category} • {report.location.county}
                          </p>
                          <div className="flex items-center gap-2 mt-2">
                            <span
                              className={`text-xs px-2 py-1 rounded-full ${
                                report.severity === "critical"
                                  ? "bg-red-100 text-red-800"
                                  : report.severity === "high"
                                  ? "bg-orange-100 text-orange-800"
                                  : report.severity === "medium"
                                  ? "bg-yellow-100 text-yellow-800"
                                  : "bg-gray-100 text-gray-800"
                              }`}
                            >
                              {report.severity}
                            </span>
                            <span className="text-xs text-muted-foreground">
                              {new Date(report.createdAt).toLocaleDateString()}
                            </span>
                          </div>
                        </div>
                      </div>
                    </CardContent>
                  </Card>
                </Link>
              ))
            ) : (
              <Card>
                <CardContent className="p-8 text-center text-muted-foreground">
                  <p>No reports yet. Be the first to report an issue!</p>
                </CardContent>
              </Card>
            )}
          </div>
        </div>
      </main>
      <TabBar />
    </div>
  )
}
