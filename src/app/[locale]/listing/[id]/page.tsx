import { getDictionary } from "@/i18n/get-dictionary";
import type { Locale } from "@/i18n/config";
import { ArrowLeft, Heart, Phone, MessageCircle, Share2, MapPin, Shield, Eye } from "lucide-react";
import Link from "next/link";

export default async function ListingDetailPage({
  params,
}: {
  params: Promise<{ locale: string; id: string }>;
}) {
  const { locale, id } = await params;
  const dict = await getDictionary(locale as Locale);

  // TODO: fetch listing from DB
  const listing = {
    id,
    title: "Арашан кочкор, 2 жашта",
    priceKgs: 850000,
    category: "SHEEP",
    subcategory: "arashan",
    breed: "Арашан",
    ageMonths: 24,
    weightKg: 180,
    gender: "MALE",
    healthStatus: locale === "ky" ? "Соо" : "Здоровое",
    hasVetCert: true,
    village: "Ак-Суу",
    regionNameKy: "Ысык-Көл",
    regionNameRu: "Иссык-Кульская",
    description: locale === "ky"
      ? "Арашан породасындагы кочкор. Салмагы 180 кг. Ата тукуму белгилүү. Ветеринардык күбөлүгү бар."
      : "Баран породы Арашан. Вес 180 кг. Известная родословная. Есть ветеринарный сертификат.",
    viewsCount: 234,
    favoritesCount: 18,
    createdAt: new Date(Date.now() - 3600000 * 2).toISOString(),
    seller: {
      name: "Азамат Жумабеков",
      phone: "+996 555 123 456",
      trustScore: 4.8,
      isVerifiedBreeder: true,
      totalSales: 23,
      memberSince: "2024",
    },
  };

  const formatPrice = (price: number) => new Intl.NumberFormat("ru-RU").format(price);
  const locationText = [listing.village, locale === "ky" ? listing.regionNameKy : listing.regionNameRu].filter(Boolean).join(", ");

  return (
    <div className="flex flex-col pb-24">
      {/* Top bar */}
      <div className="sticky top-0 z-40 flex h-14 items-center justify-between bg-background/95 px-4 backdrop-blur">
        <Link
          href={`/${locale}`}
          className="flex h-10 w-10 items-center justify-center rounded-full transition-colors active:bg-muted"
        >
          <ArrowLeft className="h-5 w-5" />
        </Link>
        <div className="flex gap-1">
          <button className="flex h-10 w-10 items-center justify-center rounded-full transition-colors active:bg-muted">
            <Share2 className="h-5 w-5" />
          </button>
          <button className="flex h-10 w-10 items-center justify-center rounded-full transition-colors active:bg-muted">
            <Heart className="h-5 w-5" />
          </button>
        </div>
      </div>

      {/* Photo placeholder */}
      <div className="aspect-[4/3] w-full bg-muted flex items-center justify-center">
        <span className="text-6xl">🐑</span>
      </div>

      {/* Price & Title */}
      <div className="px-4 pt-4">
        <p className="text-2xl font-bold text-malsat-green">
          {formatPrice(listing.priceKgs)} <span className="text-base font-normal">сом</span>
        </p>
        <h1 className="mt-1 text-lg font-semibold">{listing.title}</h1>

        <div className="mt-2 flex items-center gap-1 text-sm text-muted-foreground">
          <MapPin className="h-4 w-4" />
          <span>{locationText}</span>
        </div>

        <div className="mt-1 flex items-center gap-3 text-xs text-muted-foreground">
          <span className="flex items-center gap-1">
            <Eye className="h-3 w-3" /> {listing.viewsCount}
          </span>
          <span className="flex items-center gap-1">
            <Heart className="h-3 w-3" /> {listing.favoritesCount}
          </span>
        </div>
      </div>

      {/* Details grid */}
      <div className="mx-4 mt-4 grid grid-cols-2 gap-2">
        {[
          { label: dict.listing.category, value: dict.categories.sheep },
          { label: dict.listing.breed, value: listing.breed },
          { label: dict.listing.age, value: `${listing.ageMonths} ${dict.common.months}` },
          { label: dict.listing.weight, value: `${listing.weightKg} ${dict.common.kg}` },
          { label: dict.gender.male === "Эркек" ? "Жынысы" : "Пол", value: locale === "ky" ? dict.gender.male : dict.gender.male },
          { label: dict.listing.healthStatus, value: listing.healthStatus },
        ].map((item, i) => (
          <div key={i} className="rounded-xl bg-muted/50 px-3 py-2.5">
            <p className="text-[11px] text-muted-foreground">{item.label}</p>
            <p className="text-sm font-medium">{item.value}</p>
          </div>
        ))}
      </div>

      {/* Vet cert badge */}
      {listing.hasVetCert && (
        <div className="mx-4 mt-3 flex items-center gap-2 rounded-xl bg-green-50 px-3 py-2.5">
          <Shield className="h-4 w-4 text-malsat-green" />
          <span className="text-sm font-medium text-malsat-green">
            {dict.listing.hasVetCert}
          </span>
        </div>
      )}

      {/* Description */}
      {listing.description && (
        <div className="px-4 mt-4">
          <h3 className="text-sm font-semibold mb-1">{dict.listing.description}</h3>
          <p className="text-sm text-muted-foreground leading-relaxed">
            {listing.description}
          </p>
        </div>
      )}

      {/* Seller card */}
      <div className="mx-4 mt-4 rounded-xl border border-border p-4">
        <div className="flex items-center gap-3">
          <div className="flex h-12 w-12 items-center justify-center rounded-full bg-malsat-green/10 text-lg font-bold text-malsat-green">
            {listing.seller.name.charAt(0)}
          </div>
          <div className="flex-1">
            <div className="flex items-center gap-1.5">
              <span className="font-semibold">{listing.seller.name}</span>
              {listing.seller.isVerifiedBreeder && (
                <span className="rounded-full bg-malsat-green px-1.5 py-0.5 text-[9px] font-semibold text-white">
                  ✓
                </span>
              )}
            </div>
            <div className="flex items-center gap-2 text-xs text-muted-foreground">
              <span>⭐ {listing.seller.trustScore}</span>
              <span>·</span>
              <span>{listing.seller.totalSales} {locale === "ky" ? "сатуу" : "продаж"}</span>
            </div>
          </div>
        </div>
      </div>

      {/* Contact buttons - fixed bottom */}
      <div className="fixed bottom-16 left-0 right-0 z-40 border-t border-border bg-background px-4 py-3">
        <div className="mx-auto flex max-w-lg gap-3">
          <a
            href={`tel:${listing.seller.phone}`}
            className="flex h-12 flex-1 items-center justify-center gap-2 rounded-xl bg-malsat-green font-semibold text-white transition-colors active:bg-malsat-green-dark"
          >
            <Phone className="h-5 w-5" />
            {dict.listing.call}
          </a>
          <Link
            href={`/${locale}/messages/${listing.id}`}
            className="flex h-12 flex-1 items-center justify-center gap-2 rounded-xl border border-malsat-green font-semibold text-malsat-green transition-colors active:bg-malsat-green/5"
          >
            <MessageCircle className="h-5 w-5" />
            {dict.listing.chat}
          </Link>
        </div>
      </div>
    </div>
  );
}
