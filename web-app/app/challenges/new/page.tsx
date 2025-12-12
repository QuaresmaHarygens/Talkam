"use client"

import { useState } from "react"
import { useRouter } from "next/navigation"
import { Navbar } from "@/components/navbar"
import { TabBar } from "@/components/tab-bar"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { useStore } from "@/lib/store"
import { apiClient } from "@/lib/api/client"

export default function NewChallengePage() {
  const router = useRouter()
  const { addChallenge } = useStore()
  const [title, setTitle] = useState("")
  const [description, setDescription] = useState("")
  const [category, setCategory] = useState("environmental")
  const [isSubmitting, setIsSubmitting] = useState(false)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!title || !description) return

    setIsSubmitting(true)
    try {
      const challenge = await mockAPI.challenges.create({
        title,
        description,
        category,
        status: "active",
        progress: 0,
        participants: 0,
        volunteers: 0,
        donors: 0,
        location: {
          latitude: 6.4281,
          longitude: -10.7619,
          county: "Montserrado",
        },
      })
      addChallenge(challenge)
      router.push("/challenges")
    } catch (error) {
      console.error("Failed to create challenge:", error)
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <div className="flex min-h-screen flex-col pb-16">
      <Navbar />
      <main className="container mx-auto flex-1 space-y-6 p-4">
        <div>
          <h1 className="text-3xl font-bold">Create Challenge</h1>
          <p className="text-muted-foreground">Start a new community challenge</p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle>Title</CardTitle>
            </CardHeader>
            <CardContent>
              <Input
                placeholder="Challenge title..."
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                required
              />
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Description</CardTitle>
            </CardHeader>
            <CardContent>
              <Textarea
                placeholder="Describe your challenge..."
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                rows={6}
                required
              />
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Category</CardTitle>
            </CardHeader>
            <CardContent>
              <select
                value={category}
                onChange={(e) => setCategory(e.target.value)}
                className="w-full rounded-md border border-border bg-background px-3 py-2"
              >
                <option value="environmental">Environmental</option>
                <option value="social">Social</option>
                <option value="health">Health</option>
                <option value="education">Education</option>
                <option value="infrastructure">Infrastructure</option>
              </select>
            </CardContent>
          </Card>

          <Button type="submit" className="w-full" size="lg" disabled={isSubmitting}>
            {isSubmitting ? "Creating..." : "Create Challenge"}
          </Button>
        </form>
      </main>
      <TabBar />
    </div>
  )
}
