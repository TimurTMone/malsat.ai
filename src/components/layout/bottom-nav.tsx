"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { Home, Search, Plus, MessageCircle, User } from "lucide-react";
import type { Dictionary } from "@/i18n/get-dictionary";
import { cn } from "@/lib/utils";

interface BottomNavProps {
  locale: string;
  dict: Dictionary;
}

export function BottomNav({ locale, dict }: BottomNavProps) {
  const pathname = usePathname();

  const navItems = [
    {
      href: `/${locale}`,
      label: dict.nav.home,
      icon: Home,
      match: (p: string) => p === `/${locale}` || p === `/${locale}/`,
    },
    {
      href: `/${locale}/search`,
      label: dict.nav.search,
      icon: Search,
      match: (p: string) => p.startsWith(`/${locale}/search`),
    },
    {
      href: `/${locale}/sell`,
      label: dict.nav.sell,
      icon: Plus,
      isSell: true,
      match: (p: string) => p.startsWith(`/${locale}/sell`),
    },
    {
      href: `/${locale}/messages`,
      label: dict.nav.messages,
      icon: MessageCircle,
      match: (p: string) => p.startsWith(`/${locale}/messages`),
    },
    {
      href: `/${locale}/profile`,
      label: dict.nav.profile,
      icon: User,
      match: (p: string) => p.startsWith(`/${locale}/profile`),
    },
  ];

  // Hide on auth pages
  if (pathname.includes("/auth/")) return null;

  return (
    <nav className="fixed bottom-0 left-0 right-0 z-50 border-t border-border bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/80">
      <div className="mx-auto flex h-16 max-w-lg items-center justify-around px-2">
        {navItems.map((item) => {
          const isActive = item.match(pathname);
          const Icon = item.icon;

          if (item.isSell) {
            return (
              <Link
                key={item.href}
                href={item.href}
                className="flex flex-col items-center justify-center -mt-5"
              >
                <div className="flex h-14 w-14 items-center justify-center rounded-full bg-malsat-green shadow-lg active:scale-95 transition-transform">
                  <Icon className="h-7 w-7 text-white" strokeWidth={2.5} />
                </div>
                <span className="mt-0.5 text-[10px] font-medium text-malsat-green">
                  {item.label}
                </span>
              </Link>
            );
          }

          return (
            <Link
              key={item.href}
              href={item.href}
              className={cn(
                "flex min-h-[56px] min-w-[56px] flex-col items-center justify-center gap-0.5 rounded-lg transition-colors active:bg-muted",
                isActive ? "text-malsat-green" : "text-muted-foreground"
              )}
            >
              <Icon className="h-6 w-6" strokeWidth={isActive ? 2.5 : 2} />
              <span className="text-[10px] font-medium">{item.label}</span>
            </Link>
          );
        })}
      </div>
    </nav>
  );
}
