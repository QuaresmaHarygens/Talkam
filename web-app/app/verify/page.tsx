"use client"

import { useEffect, useState } from "react"
import Link from "next/link"
import { Navbar } from "@/components/navbar"
import { TabBar } from "@/components/tab-bar"
import { Card, CardContent } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Modal } from "@/components/modal"
import { useStore } from "@/lib/store"
import { apiClient } from "@/lib/api/client"
import { CheckCircle, XCircle, MessageSquare, Filter } from "lucide-react"
import type { Report } from "@/lib/mock/api"

export default function VerifyPage() {
  const { reports, setReports } = useStore()
  const [selectedReport, setSelectedReport] = useState<Report | null>(null)
  const [filter, setFilter] = useState<"all" | "submitted" | "under-review">("all")
  const [comments, setComments] = useState<{ id: string; text: string; author: string; createdAt: string }[]>([])

  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const loadReports = async () => {
      try {
        setLoading(true)
        setError(null)
        const response = await apiClient.searchReports({
          page_size: 50,
          ...(filter !== "all" ? { status: filter } : {}),
        })
        const transformedReports = response.results.map((r: any) => ({
          id: r.id,
          summary: r.summary || '',
          category: r.category || 'unknown',
          severity: r.severity || 'medium',
          status: r.status || 'submitted',
          location: {
            latitude: r.location?.latitude || 0,
            longitude: r.location?.longitude || 0,
            county: r.county || r.location?.county || 'Unknown',
            district: r.district || r.location?.district,
          },
          createdAt: r.created_at || new Date().toISOString(),
          verificationScore: r.verification_score,
          witnessCount: r.witness_count,
        }))
        setReports(transformedReports)
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Failed to load reports')
        console.error('Error loading reports:', err)
      } finally {
        setLoading(false)
      }
    }
    loadReports()
  }, [setReports, filter])

  const filteredReports = reports.filter((r) => {
    if (filter === "all") return true
    return r.status === filter
  })

  const handleVerify = async (reportId: string, verified: boolean) => {
    try {
      await apiClient.verifyReport(reportId, {
        verified,
        comments: verified ? 'Verified by community member' : 'Rejected',
      })
      // Reload reports
      const response = await apiClient.searchReports({ page_size: 50 })
      const transformedReports = response.results.map((r: any) => ({
        id: r.id,
        summary: r.summary || '',
        category: r.category || 'unknown',
        severity: r.severity || 'medium',
        status: r.status || 'submitted',
        location: {
          latitude: r.location?.latitude || 0,
          longitude: r.location?.longitude || 0,
          county: r.county || r.location?.county || 'Unknown',
          district: r.district || r.location?.district,
        },
        createdAt: r.created_at || new Date().toISOString(),
        verificationScore: r.verification_score,
        witnessCount: r.witness_count,
      }))
      setReports(transformedReports)
      setSelectedReport(null)
    } catch (err) {
      console.error('Error verifying report:', err)
      alert(err instanceof Error ? err.message : 'Failed to verify report')
    }
  }

  return (
    <div className="flex min-h-screen flex-col pb-16">
      <Navbar />
      <main className="container mx-auto flex-1 space-y-6 p-4">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold">Verify Reports</h1>
            <p className="text-muted-foreground">Help verify community reports</p>
          </div>
          <Button variant="outline" size="icon">
            <Filter className="h-4 w-4" />
          </Button>
        </div>

        {/* Filter Tabs */}
        <div className="flex gap-2 border-b">
          {[
            { value: "all", label: "All" },
            { value: "submitted", label: "Submitted" },
            { value: "under-review", label: "Under Review" },
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

        {/* Reports List */}
        {!loading && !error && (
          <div className="space-y-3">
            {filteredReports.length > 0 ? (
            filteredReports.map((report) => (
              <Card
                key={report.id}
                className="hover:shadow-md transition-shadow cursor-pointer"
                onClick={() => setSelectedReport(report)}
              >
                <CardContent className="p-4">
                  <div className="flex items-start justify-between">
                    <div className="flex-1">
                      <h3 className="font-semibold mb-1">{report.summary}</h3>
                      <p className="text-sm text-muted-foreground mb-2">
                        {report.category} • {report.location.county}
                      </p>
                      <div className="flex items-center gap-2">
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
                        {report.verificationScore && (
                          <span className="text-xs text-muted-foreground">
                            {Math.round(report.verificationScore * 100)}% verified
                          </span>
                        )}
                      </div>
                    </div>
                  </div>
                </CardContent>
              </Card>
            ))
          ) : (
            <Card>
              <CardContent className="p-8 text-center text-muted-foreground">
                <p>No reports to verify at the moment.</p>
              </CardContent>
            </Card>
          )}
          </div>
        )}
      </main>
      <TabBar />

      {/* Report Detail Modal */}
      <Modal
        isOpen={!!selectedReport}
        onClose={() => setSelectedReport(null)}
        title={selectedReport?.summary}
        className="max-w-2xl"
      >
        {selectedReport && (
          <div className="space-y-4">
            <div>
              <p className="text-sm text-muted-foreground mb-2">{selectedReport.category}</p>
              <p className="text-sm">{selectedReport.location.county}, {selectedReport.location.district}</p>
            </div>

            {selectedReport.media && selectedReport.media.length > 0 && (
              <div className="grid grid-cols-2 gap-2">
                {selectedReport.media.map((url, idx) => (
                  <div key={idx} className="h-32 rounded-lg bg-muted" />
                ))}
              </div>
            )}

            <div className="flex gap-2">
              <Button
                onClick={() => handleVerify(selectedReport.id, true)}
                className="flex-1"
                variant="default"
              >
                <CheckCircle className="mr-2 h-4 w-4" />
                Verify
              </Button>
              <Button
                onClick={() => handleVerify(selectedReport.id, false)}
                className="flex-1"
                variant="outline"
              >
                <XCircle className="mr-2 h-4 w-4" />
                Reject
              </Button>
            </div>

            {/* Comments */}
            <div className="border-t pt-4">
              <div className="flex items-center justify-between mb-3">
                <h3 className="font-semibold flex items-center">
                  <MessageSquare className="mr-2 h-4 w-4" />
                  Comments
                </h3>
              </div>
              <div className="space-y-2">
                {comments.length > 0 ? (
                  comments.map((comment) => (
                    <div key={comment.id} className="p-3 bg-muted rounded-lg">
                      <p className="text-sm">{comment.text}</p>
                      <p className="text-xs text-muted-foreground mt-1">{comment.author} • {new Date(comment.createdAt).toLocaleDateString()}</p>
                    </div>
                  ))
                ) : (
                  <p className="text-sm text-muted-foreground">No comments yet</p>
                )}
              </div>
            </div>
          </div>
        )}
      </Modal>
    </div>
  )
}
