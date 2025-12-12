"use client"

import Link from "next/link"
import { usePathname } from "next/navigation"
import { Bell, Menu, User } from "lucide-react"
import { Button } from "@/components/ui/button"
import { useStore } from "@/lib/store"

export function Navbar() {
  const pathname = usePathname()
  const { user, notifications } = useStore()
  const unreadCount = notifications.filter((n) => !n.read).length

  return (
    <nav className="sticky top-0 z-50 w-full border-b border-border bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
      <div className="container mx-auto flex h-16 items-center justify-between px-4">
        <Link href="/dashboard" className="flex items-center space-x-2">
          <span className="text-xl font-bold text-primary">TalkAm</span>
        </Link>

        <div className="flex items-center space-x-2">
          <Link href="/notifications">
            <Button variant="ghost" size="icon" className="relative">
              <Bell className="h-5 w-5" />
              {unreadCount > 0 && (
                <span className="absolute right-1 top-1 h-2 w-2 rounded-full bg-secondary"></span>
              )}
            </Button>
          </Link>
          <Link href="/profile">
            <Button variant="ghost" size="icon">
              <User className="h-5 w-5" />
            </Button>
          </Link>
        </div>
      </div>
    </nav>
  )
}
