"use client"

import { useState } from "react"
import { useRouter } from "next/navigation"
import Link from "next/link"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { useStore } from "@/lib/store"
import { apiClient } from "@/lib/api/client"
import { ArrowLeft, AlertCircle } from "lucide-react"

export default function LoginPage() {
  const router = useRouter()
  const setUser = useStore((state) => state.setUser)
  const [email, setEmail] = useState("")
  const [phone, setPhone] = useState("")
  const [password, setPassword] = useState("")
  const [fullName, setFullName] = useState("")
  const [isSignUp, setIsSignUp] = useState(false)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError(null)

    try {
      if (isSignUp) {
        // Register
        const response = await apiClient.register({
          full_name: fullName,
          email: email || undefined,
          phone: phone || undefined,
          password,
        })
        if (response.access_token) {
          setUser({
            id: response.user?.id || "1",
            name: response.user?.full_name || fullName,
            email: response.user?.email || email,
            isGuest: false,
          })
          router.push("/dashboard")
        }
      } else {
        // Login - backend expects phone, but we'll try email if phone is empty
        const loginData = phone || email
        const response = await apiClient.login({
          phone: loginData,
          password,
        })
        if (response.access_token) {
          setUser({
            id: response.user?.id || "1",
            name: response.user?.full_name || email.split("@")[0],
            email: response.user?.email || email,
            isGuest: false,
          })
          router.push("/dashboard")
        }
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : "Authentication failed")
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="flex min-h-screen flex-col items-center justify-center bg-gradient-to-b from-primary/10 to-background p-4">
      <div className="w-full max-w-md">
        <Link href="/" className="mb-6 inline-flex items-center text-sm text-muted-foreground hover:text-foreground">
          <ArrowLeft className="mr-2 h-4 w-4" />
          Back to welcome
        </Link>

        <Card>
          <CardHeader>
            <CardTitle>{isSignUp ? "Create Account" : "Welcome Back"}</CardTitle>
            <CardDescription>
              {isSignUp
                ? "Sign up to start reporting and verifying issues"
                : "Sign in to your account to continue"}
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div className="space-y-2">
                <label htmlFor="email" className="text-sm font-medium">
                  Email
                </label>
                <Input
                  id="email"
                  type="email"
                  placeholder="you@example.com"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  required
                />
              </div>
              <div className="space-y-2">
                <label htmlFor="password" className="text-sm font-medium">
                  Password
                </label>
                <Input
                  id="password"
                  type="password"
                  placeholder="••••••••"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  required
                />
              </div>
              <Button type="submit" className="w-full" disabled={loading}>
                {loading ? "Please wait..." : isSignUp ? "Sign Up" : "Sign In"}
              </Button>
            </form>

            <div className="mt-4 text-center">
              <button
                type="button"
                onClick={() => setIsSignUp(!isSignUp)}
                className="text-sm text-muted-foreground hover:text-foreground"
              >
                {isSignUp
                  ? "Already have an account? Sign in"
                  : "Don't have an account? Sign up"}
              </button>
            </div>

            <div className="mt-6">
              <Button
                variant="outline"
                className="w-full"
                onClick={async () => {
                  try {
                    // Generate a simple device hash
                    const deviceHash = typeof window !== 'undefined' 
                      ? localStorage.getItem('device_hash') || `guest_${Date.now()}`
                      : `guest_${Date.now()}`
                    
                    if (typeof window !== 'undefined') {
                      localStorage.setItem('device_hash', deviceHash)
                    }

                    const response = await apiClient.anonymousStart({
                      device_hash: deviceHash,
                    })
                    
                    if (response.access_token) {
                      setUser({
                        id: response.user?.id || null,
                        name: null,
                        email: null,
                        isGuest: true,
                      })
                      router.push("/dashboard")
                    }
                  } catch (err) {
                    // Fallback to local guest mode if API fails
                    setUser({
                      id: null,
                      name: null,
                      email: null,
                      isGuest: true,
                    })
                    router.push("/dashboard")
                  }
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
