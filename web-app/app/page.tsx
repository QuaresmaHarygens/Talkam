"use client"

import { useEffect } from "react"
import { useRouter } from "next/navigation"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { ArrowRight, Shield, Users, MapPin } from "lucide-react"

export default function WelcomePage() {
  const router = useRouter()

  return (
    <div className="flex min-h-screen flex-col items-center justify-center bg-gradient-to-b from-primary/10 to-background p-4">
      <div className="w-full max-w-md space-y-8">
        <div className="text-center space-y-4">
          <h1 className="text-4xl font-bold text-primary">TalkAm</h1>
          <p className="text-lg text-muted-foreground">
            Your voice matters. Report issues, verify reports, and build a better community together.
          </p>
        </div>

        <Card>
          <CardHeader>
            <CardTitle>Welcome to TalkAm</CardTitle>
            <CardDescription>
              Join thousands of citizens making a difference in their communities
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="space-y-3">
              <div className="flex items-center space-x-3">
                <Shield className="h-5 w-5 text-primary" />
                <span className="text-sm">Report civic issues safely and securely</span>
              </div>
              <div className="flex items-center space-x-3">
                <Users className="h-5 w-5 text-secondary" />
                <span className="text-sm">Verify reports and help your community</span>
              </div>
              <div className="flex items-center space-x-3">
                <MapPin className="h-5 w-5 text-primary" />
                <span className="text-sm">Track issues on an interactive map</span>
              </div>
            </div>

            <div className="pt-4 space-y-3">
              <Button
                className="w-full"
                onClick={() => router.push("/login")}
              >
                Get Started
                <ArrowRight className="ml-2 h-4 w-4" />
              </Button>
              <Button
                variant="outline"
                className="w-full"
                onClick={() => {
                  // Set guest mode
                  router.push("/dashboard")
                }}
              >
                Continue as Guest
              </Button>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
