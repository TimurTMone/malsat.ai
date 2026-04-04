import { getDictionary } from "@/i18n/get-dictionary";
import type { Locale } from "@/i18n/config";
import { Header } from "@/components/layout/header";
import { Camera } from "lucide-react";

export default async function SellPage({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  const dict = await getDictionary(locale as Locale);

  return (
    <div className="flex flex-col">
      <Header locale={locale} dict={dict} />

      <div className="px-4 py-6">
        <h1 className="text-xl font-bold">{dict.listing.create}</h1>
        <p className="mt-1 text-sm text-muted-foreground">
          {locale === "ky"
            ? "Сүрөт тартыңыз же тандаңыз"
            : "Сделайте фото или выберите из галереи"}
        </p>

        {/* Photo upload area */}
        <button className="mt-4 flex h-48 w-full flex-col items-center justify-center gap-3 rounded-2xl border-2 border-dashed border-malsat-green/30 bg-malsat-green/5 transition-colors active:bg-malsat-green/10">
          <div className="flex h-16 w-16 items-center justify-center rounded-full bg-malsat-green/10">
            <Camera className="h-8 w-8 text-malsat-green" />
          </div>
          <span className="text-sm font-medium text-malsat-green">
            {dict.listing.addPhoto}
          </span>
        </button>

        {/* Category selection */}
        <div className="mt-6">
          <h2 className="text-sm font-semibold text-foreground mb-3">
            {dict.listing.category}
          </h2>
          <div className="grid grid-cols-2 gap-3">
            {[
              { label: dict.categories.horse, value: "HORSE", emoji: "🐴" },
              { label: dict.categories.cattle, value: "CATTLE", emoji: "🐄" },
              { label: dict.categories.sheep, value: "SHEEP", emoji: "🐑" },
              { label: dict.categories.arashan, value: "ARASHAN", emoji: "🐏" },
            ].map((cat) => (
              <button
                key={cat.value}
                className="flex h-14 items-center gap-3 rounded-xl border border-border bg-card px-4 text-sm font-medium transition-colors active:bg-muted"
              >
                <span className="text-2xl">{cat.emoji}</span>
                {cat.label}
              </button>
            ))}
          </div>
        </div>

        {/* Title */}
        <div className="mt-6">
          <label className="text-sm font-semibold text-foreground">
            {dict.listing.title}
          </label>
          <input
            type="text"
            className="mt-2 h-12 w-full rounded-xl border border-border bg-card px-4 text-sm outline-none focus:border-malsat-green focus:ring-1 focus:ring-malsat-green"
            placeholder={locale === "ky" ? "Мис: Арашан кочкор, 2 жашта" : "Напр: Баран Арашан, 2 года"}
          />
        </div>

        {/* Price */}
        <div className="mt-4">
          <label className="text-sm font-semibold text-foreground">
            {dict.listing.price} (сом)
          </label>
          <input
            type="number"
            className="mt-2 h-12 w-full rounded-xl border border-border bg-card px-4 text-sm outline-none focus:border-malsat-green focus:ring-1 focus:ring-malsat-green"
            placeholder="0"
          />
        </div>

        {/* Age & Weight row */}
        <div className="mt-4 grid grid-cols-2 gap-3">
          <div>
            <label className="text-sm font-semibold text-foreground">
              {dict.listing.age} ({dict.common.months})
            </label>
            <input
              type="number"
              className="mt-2 h-12 w-full rounded-xl border border-border bg-card px-4 text-sm outline-none focus:border-malsat-green focus:ring-1 focus:ring-malsat-green"
              placeholder="0"
            />
          </div>
          <div>
            <label className="text-sm font-semibold text-foreground">
              {dict.listing.weight} ({dict.common.kg})
            </label>
            <input
              type="number"
              className="mt-2 h-12 w-full rounded-xl border border-border bg-card px-4 text-sm outline-none focus:border-malsat-green focus:ring-1 focus:ring-malsat-green"
              placeholder="0"
            />
          </div>
        </div>

        {/* Description */}
        <div className="mt-4">
          <label className="text-sm font-semibold text-foreground">
            {dict.listing.description}
          </label>
          <textarea
            rows={3}
            className="mt-2 w-full rounded-xl border border-border bg-card px-4 py-3 text-sm outline-none resize-none focus:border-malsat-green focus:ring-1 focus:ring-malsat-green"
            placeholder={locale === "ky" ? "Малыңыз жөнүндө кошумча маалымат..." : "Дополнительная информация о животном..."}
          />
        </div>

        {/* Publish button */}
        <button className="mt-6 h-14 w-full rounded-xl bg-malsat-green font-semibold text-white text-base transition-colors active:bg-malsat-green-dark">
          {dict.listing.publish}
        </button>
      </div>
    </div>
  );
}
