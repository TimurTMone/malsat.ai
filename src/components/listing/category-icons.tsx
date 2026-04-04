"use client";

import Link from "next/link";
import type { Dictionary } from "@/i18n/get-dictionary";
import { cn } from "@/lib/utils";

interface CategoryIconsProps {
  locale: string;
  dict: Dictionary;
  activeCategory?: string;
}

function HorseIcon({ className }: { className?: string }) {
  return (
    <svg viewBox="0 0 64 64" fill="currentColor" className={className}>
      <path d="M52 12c-2-4-6-6-10-6-2 0-4 2-6 4l-4 6c-2 2-4 4-8 4h-4c-4 0-8 2-10 6l-4 8c-1 2 0 4 2 5s4 0 5-2l2-4v11c0 4 2 7 5 9v5c0 1 1 2 2 2h4c1 0 2-1 2-2v-4h8v4c0 1 1 2 2 2h4c1 0 2-1 2-2v-5c3-2 5-5 5-9V28l4-4c2-2 3-5 3-8 0-2-1-3-2-4z" />
    </svg>
  );
}

function CattleIcon({ className }: { className?: string }) {
  return (
    <svg viewBox="0 0 64 64" fill="currentColor" className={className}>
      <path d="M48 16c2-4 6-6 6-6s-2-4-6-4c-2 0-4 1-5 3h-22c-1-2-3-3-5-3-4 0-6 4-6 4s4 2 6 6c-4 2-6 6-6 10v10c0 4 2 8 6 10v5c0 1 1 2 2 2h4c1 0 2-1 2-2v-4h14v4c0 1 1 2 2 2h4c1 0 2-1 2-2v-5c4-2 6-6 6-10V26c0-4-2-8-6-10zM22 36c-2 0-4-2-4-4s2-4 4-4 4 2 4 4-2 4-4 4zm20 0c-2 0-4-2-4-4s2-4 4-4 4 2 4 4-2 4-4 4z" />
    </svg>
  );
}

function SheepIcon({ className }: { className?: string }) {
  return (
    <svg viewBox="0 0 64 64" fill="currentColor" className={className}>
      <path d="M50 24c-1-2-3-4-5-4 0-3-2-6-5-7 1-2 1-4 0-6s-3-3-5-3c-1-1-3-2-5-2s-4 1-5 2c-2 0-4 1-5 3s-1 4 0 6c-3 1-5 4-5 7-2 0-4 2-5 4-2 3-1 6 1 8 0 3 2 6 5 7v5c0 1 1 2 2 2h6c1 0 2-1 2-2v-3h8v3c0 1 1 2 2 2h6c1 0 2-1 2-2v-5c3-1 5-4 5-7 2-2 3-5 1-8z" />
    </svg>
  );
}

function GoatIcon({ className }: { className?: string }) {
  return (
    <svg viewBox="0 0 64 64" fill="currentColor" className={className}>
      <path d="M50 18l4-12h-4l-4 8c-2-2-4-4-7-4h-14c-3 0-5 2-7 4l-4-8h-4l4 12c-3 2-5 6-5 10v8c0 4 2 8 6 10v5c0 1 1 2 2 2h4c1 0 2-1 2-2v-4h12v4c0 1 1 2 2 2h4c1 0 2-1 2-2v-5c4-2 6-6 6-10v-8c0-4-2-8-5-10zM26 36c-2 0-3-2-3-4s1-4 3-4 3 2 3 4-1 4-3 4zm16 4h-10v-3c0-1-1-1-1-1h-2s0 0 0 0h2l-1 1v3h0zm0-4c-2 0-3-2-3-4s1-4 3-4 3 2 3 4-1 4-3 4z" />
    </svg>
  );
}

const categories = [
  { key: "horse", value: "HORSE", Icon: HorseIcon, color: "bg-amber-100 text-amber-800" },
  { key: "cattle", value: "CATTLE", Icon: CattleIcon, color: "bg-orange-100 text-orange-800" },
  { key: "sheep", value: "SHEEP", Icon: SheepIcon, color: "bg-emerald-100 text-emerald-800" },
  { key: "goat", value: "GOAT", Icon: GoatIcon, color: "bg-sky-100 text-sky-800" },
] as const;

export function CategoryIcons({ locale, dict, activeCategory }: CategoryIconsProps) {
  return (
    <div className="grid grid-cols-4 gap-3 px-4">
      {categories.map(({ key, value, Icon, color }) => {
        const isActive = activeCategory === value;
        return (
          <Link
            key={key}
            href={
              isActive
                ? `/${locale}/search`
                : `/${locale}/search?category=${value}`
            }
            className={cn(
              "flex flex-col items-center gap-2 rounded-2xl p-3 transition-all active:scale-95",
              isActive
                ? "bg-malsat-green text-white shadow-md"
                : color
            )}
          >
            <Icon className="h-10 w-10" />
            <span className="text-xs font-semibold text-center leading-tight">
              {dict.categories[key as keyof typeof dict.categories]}
            </span>
          </Link>
        );
      })}
    </div>
  );
}
