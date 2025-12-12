"use client"

import { useState } from "react"
import { Navbar } from "@/components/navbar"
import { TabBar } from "@/components/tab-bar"
import { Card, CardContent } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Modal } from "@/components/modal"
import { useStore } from "@/lib/store"
import { MapPin, Filter } from "lucide-react"

export default function MapPage() {
  const { reports } = useStore()
  const [selectedReport, setSelectedReport] = useState<string | null>(null)
  const [categoryFilter, setCategoryFilter] = useState<string | null>(null)

  return (
    <div className="flex min-h-screen flex-col pb-16">
      <Navbar />
      <main className="container mx-auto flex-1 relative">
        {/* Map Container */}
        <div className="absolute inset-0 bg-gradient-to-br from-green-100 to-blue-100">
          {/* Mock Map with Pins */}
          <div className="relative w-full h-full">
            {/* Placeholder map background */}
            <div className="absolute inset-0 opacity-20">
              <div className="grid grid-cols-8 grid-rows-8 h-full">
                {Array.from({ length: 64 }).map((_, i) => (
                  <div key={i} className="border border-gray-300" />
                ))}
              </div>
            </div>

            {/* Mock Pins */}
            {reports.map((report, idx) => (
              <button
                key={report.id}
                onClick={() => setSelectedReport(report.id)}
                className="absolute"
                style={{
                  left: `${20 + (idx * 15) % 60}%`,
                  top: `${30 + (idx * 20) % 50}%`,
                }}
              >
                <MapPin
                  className={`h-8 w-8 ${
                    report.severity === "critical"
                      ? "text-red-500"
                      : report.severity === "high"
                      ? "text-orange-500"
                      : report.severity === "medium"
                      ? "text-yellow-500"
                      : "text-gray-500"
                  }`}
                />
              </button>
            ))}
          </div>
        </div>

        {/* Filter Button */}
        <div className="absolute top-4 right-4 z-10">
          <Button variant="outline" size="icon">
            <Filter className="h-4 w-4" />
          </Button>
        </div>

        {/* Selected Report Modal */}
        {selectedReport && (
          <Modal
            isOpen={!!selectedReport}
            onClose={() => setSelectedReport(null)}
            title={reports.find((r) => r.id === selectedReport)?.summary}
          >
            {reports
              .find((r) => r.id === selectedReport)
              ?.location && (
                <div className="space-y-2">
                  <p className="text-sm text-muted-foreground">
                    {reports.find((r) => r.id === selectedReport)?.location.county}
                  </p>
                  <Button className="w-full">View Details</Button>
                </div>
              )}
          </Modal>
        )}
      </main>
      <TabBar />
    </div>
  )
}
