"use client"

import { useState } from "react"
import { useRouter } from "next/navigation"
import { Navbar } from "@/components/navbar"
import { TabBar } from "@/components/tab-bar"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { Modal } from "@/components/modal"
import { useStore } from "@/lib/store"
import { mockAPI } from "@/lib/mock/api"
import {
  Camera,
  MapPin,
  Upload,
  X,
  AlertCircle,
  Wrench,
  Shield,
  Heart,
  Building,
  Users,
  Zap,
} from "lucide-react"

const categories = [
  { id: "infrastructure", label: "Infrastructure", icon: Building, color: "bg-blue-100 text-blue-800" },
  { id: "security", label: "Security", icon: Shield, color: "bg-red-100 text-red-800" },
  { id: "health", label: "Health", icon: Heart, color: "bg-pink-100 text-pink-800" },
  { id: "social", label: "Social", icon: Users, color: "bg-purple-100 text-purple-800" },
  { id: "environmental", label: "Environmental", icon: Zap, color: "bg-green-100 text-green-800" },
  { id: "other", label: "Other", icon: AlertCircle, color: "bg-gray-100 text-gray-800" },
]

const severities = [
  { value: "low", label: "Low", color: "bg-gray-100 text-gray-800" },
  { value: "medium", label: "Medium", color: "bg-yellow-100 text-yellow-800" },
  { value: "high", label: "High", color: "bg-orange-100 text-orange-800" },
  { value: "critical", label: "Critical", color: "bg-red-100 text-red-800" },
]

export default function ReportPage() {
  const router = useRouter()
  const { addReport } = useStore()
  const [selectedCategory, setSelectedCategory] = useState<string | null>(null)
  const [selectedSeverity, setSelectedSeverity] = useState("medium")
  const [summary, setSummary] = useState("")
  const [details, setDetails] = useState("")
  const [media, setMedia] = useState<string[]>([])
  const [location, setLocation] = useState<{ lat: number; lng: number; address: string } | null>(null)
  const [showMapModal, setShowMapModal] = useState(false)
  const [isSubmitting, setIsSubmitting] = useState(false)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!selectedCategory || !summary || !location) return

    setIsSubmitting(true)
    try {
      const report = await mockAPI.reports.create({
        summary,
        category: selectedCategory,
        severity: selectedSeverity as any,
        status: "submitted",
        location: {
          latitude: location.lat,
          longitude: location.lng,
          county: "Montserrado",
          district: location.address,
        },
        media,
      })
      addReport(report)
      router.push("/dashboard")
    } catch (error) {
      console.error("Failed to submit report:", error)
    } finally {
      setIsSubmitting(false)
    }
  }

  const handleGetLocation = () => {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          setLocation({
            lat: position.coords.latitude,
            lng: position.coords.longitude,
            address: "Current Location",
          })
        },
        () => {
          setShowMapModal(true)
        }
      )
    } else {
      setShowMapModal(true)
    }
  }

  return (
    <div className="flex min-h-screen flex-col pb-16">
      <Navbar />
      <main className="container mx-auto flex-1 space-y-6 p-4">
        <div>
          <h1 className="text-3xl font-bold">Report an Issue</h1>
          <p className="text-muted-foreground">Help improve your community by reporting issues</p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-6">
          {/* Category Selection */}
          <Card>
            <CardHeader>
              <CardTitle>Category</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-3 gap-3">
                {categories.map((cat) => {
                  const Icon = cat.icon
                  const isSelected = selectedCategory === cat.id
                  return (
                    <button
                      key={cat.id}
                      type="button"
                      onClick={() => setSelectedCategory(cat.id)}
                      className={`flex flex-col items-center justify-center p-4 rounded-lg border-2 transition-colors ${
                        isSelected
                          ? "border-primary bg-primary/10"
                          : "border-border hover:border-primary/50"
                      }`}
                    >
                      <Icon className={`h-6 w-6 mb-2 ${isSelected ? "text-primary" : "text-muted-foreground"}`} />
                      <span className={`text-xs font-medium ${isSelected ? "text-primary" : "text-muted-foreground"}`}>
                        {cat.label}
                      </span>
                    </button>
                  )
                })}
              </div>
            </CardContent>
          </Card>

          {/* Media Upload */}
          <Card>
            <CardHeader>
              <CardTitle>Add Media</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="flex gap-3">
                <Button type="button" variant="outline" className="flex-1">
                  <Camera className="mr-2 h-4 w-4" />
                  Photo/Video
                </Button>
                <Button type="button" variant="outline" className="flex-1">
                  <Upload className="mr-2 h-4 w-4" />
                  Audio
                </Button>
              </div>
              {media.length > 0 && (
                <div className="mt-4 flex flex-wrap gap-2">
                  {media.map((url, idx) => (
                    <div key={idx} className="relative">
                      <div className="h-20 w-20 rounded-lg bg-muted" />
                      <button
                        type="button"
                        onClick={() => setMedia(media.filter((_, i) => i !== idx))}
                        className="absolute -top-2 -right-2 rounded-full bg-red-500 p-1"
                      >
                        <X className="h-3 w-3 text-white" />
                      </button>
                    </div>
                  ))}
                </div>
              )}
            </CardContent>
          </Card>

          {/* Severity */}
          <Card>
            <CardHeader>
              <CardTitle>Severity</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="flex gap-2">
                {severities.map((sev) => (
                  <button
                    key={sev.value}
                    type="button"
                    onClick={() => setSelectedSeverity(sev.value)}
                    className={`flex-1 px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                      selectedSeverity === sev.value
                        ? sev.color
                        : "bg-muted text-muted-foreground hover:bg-muted/80"
                    }`}
                  >
                    {sev.label}
                  </button>
                ))}
              </div>
            </CardContent>
          </Card>

          {/* Summary */}
          <Card>
            <CardHeader>
              <CardTitle>Summary</CardTitle>
            </CardHeader>
            <CardContent>
              <Input
                placeholder="Brief summary of the issue..."
                value={summary}
                onChange={(e) => setSummary(e.target.value)}
                required
              />
            </CardContent>
          </Card>

          {/* Details */}
          <Card>
            <CardHeader>
              <CardTitle>Text Description</CardTitle>
            </CardHeader>
            <CardContent>
              <Textarea
                placeholder="Describe the issue in detail..."
                value={details}
                onChange={(e) => setDetails(e.target.value)}
                rows={6}
              />
            </CardContent>
          </Card>

          {/* Location */}
          <Card>
            <CardHeader>
              <CardTitle>Location</CardTitle>
            </CardHeader>
            <CardContent>
              <Button
                type="button"
                variant="outline"
                className="w-full"
                onClick={handleGetLocation}
              >
                <MapPin className="mr-2 h-4 w-4" />
                {location ? `${location.lat.toFixed(4)}, ${location.lng.toFixed(4)}` : "Get Location"}
              </Button>
              {location && (
                <p className="mt-2 text-sm text-muted-foreground">{location.address}</p>
              )}
            </CardContent>
          </Card>

          {/* Submit */}
          <Button type="submit" className="w-full" size="lg" disabled={isSubmitting || !selectedCategory || !summary || !location}>
            {isSubmitting ? "Submitting..." : "Submit Report"}
          </Button>
        </form>
      </main>
      <TabBar />

      {/* Map Modal */}
      <Modal isOpen={showMapModal} onClose={() => setShowMapModal(false)} title="Select Location">
        <div className="h-64 bg-muted rounded-lg mb-4 flex items-center justify-center">
          <p className="text-muted-foreground">Map selector placeholder</p>
        </div>
        <Button
          onClick={() => {
            setLocation({ lat: 6.4281, lng: -10.7619, address: "Monrovia" })
            setShowMapModal(false)
          }}
          className="w-full"
        >
          Use This Location
        </Button>
      </Modal>
    </div>
  )
}
