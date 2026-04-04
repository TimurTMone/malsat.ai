"use client";

import Image from "next/image";
import Link from "next/link";
import { Heart, MapPin, Eye } from "lucide-react";
import { cn } from "@/lib/utils";

interface ListingCardProps {
  id: string;
  title: string;
  priceKgs: number;
  category: string;
  breed?: string | null;
  ageMonths?: number | null;
  weightKg?: number | null;
  village?: string | null;
  regionNameKy?: string;
  regionNameRu?: string;
  imageUrl?: string;
  viewsCount: number;
  favoritesCount: number;
  isVerifiedBreeder?: boolean;
  createdAt: string;
  locale: string;
}

function formatPrice(price: number): string {
  return new Intl.NumberFormat("ru-RU").format(price);
}

function timeAgo(dateStr: string, locale: string): string {
  const now = new Date();
  const date = new Date(dateStr);
  const diffMs = now.getTime() - date.getTime();
  const diffMins = Math.floor(diffMs / 60000);
  const diffHours = Math.floor(diffMs / 3600000);
  const diffDays = Math.floor(diffMs / 86400000);

  if (diffMins < 1) return locale === "ky" ? "Жаңы эле" : "Только что";
  if (diffMins < 60) return `${diffMins} ${locale === "ky" ? "мүн мурун" : "мин назад"}`;
  if (diffHours < 24) return `${diffHours} ${locale === "ky" ? "саат мурун" : "ч назад"}`;
  return `${diffDays} ${locale === "ky" ? "күн мурун" : "дн назад"}`;
}

export function ListingCard({
  id,
  title,
  priceKgs,
  village,
  regionNameKy,
  regionNameRu,
  imageUrl,
  viewsCount,
  favoritesCount,
  isVerifiedBreeder,
  createdAt,
  locale,
}: ListingCardProps) {
  const regionName = locale === "ky" ? regionNameKy : regionNameRu;
  const locationText = [village, regionName].filter(Boolean).join(", ");

  return (
    <Link
      href={`/${locale}/listing/${id}`}
      className="group block overflow-hidden rounded-xl border border-border bg-card shadow-sm transition-shadow hover:shadow-md active:scale-[0.98]"
    >
      {/* Image */}
      <div className="relative aspect-[4/3] w-full overflow-hidden bg-muted">
        {imageUrl ? (
          <Image
            src={imageUrl}
            alt={title}
            fill
            className="object-cover transition-transform group-hover:scale-105"
            sizes="(max-width: 640px) 50vw, 33vw"
          />
        ) : (
          <div className="flex h-full items-center justify-center">
            <span className="text-4xl text-muted-foreground/30">🐑</span>
          </div>
        )}

        {/* Favorite button */}
        <button
          onClick={(e) => {
            e.preventDefault();
            // TODO: toggle favorite
          }}
          className="absolute right-2 top-2 flex h-8 w-8 items-center justify-center rounded-full bg-white/80 backdrop-blur transition-colors hover:bg-white active:scale-90"
        >
          <Heart className="h-4 w-4 text-muted-foreground" />
        </button>

        {/* Verified badge */}
        {isVerifiedBreeder && (
          <div className="absolute left-2 top-2 rounded-full bg-malsat-green px-2 py-0.5 text-[10px] font-semibold text-white">
            ✓ {locale === "ky" ? "Текшерилген" : "Проверен"}
          </div>
        )}
      </div>

      {/* Content */}
      <div className="p-3">
        <p className="text-base font-bold text-malsat-green">
          {formatPrice(priceKgs)} <span className="text-sm font-normal">сом</span>
        </p>
        <h3 className="mt-0.5 truncate text-sm font-medium text-foreground">
          {title}
        </h3>

        {locationText && (
          <div className="mt-1.5 flex items-center gap-1 text-xs text-muted-foreground">
            <MapPin className="h-3 w-3 flex-shrink-0" />
            <span className="truncate">{locationText}</span>
          </div>
        )}

        <div className="mt-2 flex items-center justify-between text-[11px] text-muted-foreground">
          <span>{timeAgo(createdAt, locale)}</span>
          <div className="flex items-center gap-2">
            <span className="flex items-center gap-0.5">
              <Eye className="h-3 w-3" /> {viewsCount}
            </span>
            <span className="flex items-center gap-0.5">
              <Heart className="h-3 w-3" /> {favoritesCount}
            </span>
          </div>
        </div>
      </div>
    </Link>
  );
}
