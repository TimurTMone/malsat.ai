import { getDictionary } from "@/i18n/get-dictionary";
import type { Locale } from "@/i18n/config";
import { Header } from "@/components/layout/header";
import { CategoryIcons } from "@/components/listing/category-icons";
import { Search } from "lucide-react";

export default async function SearchPage({
  params,
  searchParams,
}: {
  params: Promise<{ locale: string }>;
  searchParams: Promise<{ category?: string }>;
}) {
  const { locale } = await params;
  const { category } = await searchParams;
  const dict = await getDictionary(locale as Locale);

  return (
    <div className="flex flex-col">
      <Header locale={locale} dict={dict} />

      {/* Search bar */}
      <div className="px-4 pt-4">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 h-5 w-5 -translate-y-1/2 text-muted-foreground" />
          <input
            type="text"
            placeholder={dict.search.searchPlaceholder}
            className="h-12 w-full rounded-xl border border-border bg-card pl-11 pr-4 text-sm outline-none transition-colors focus:border-malsat-green focus:ring-1 focus:ring-malsat-green"
          />
        </div>
      </div>

      {/* Categories */}
      <div className="py-4">
        <CategoryIcons locale={locale} dict={dict} activeCategory={category} />
      </div>

      {/* Results placeholder */}
      <div className="flex flex-1 flex-col items-center justify-center px-4 py-12 text-center">
        <Search className="h-12 w-12 text-muted-foreground/30" />
        <p className="mt-3 text-sm text-muted-foreground">
          {dict.common.noResults}
        </p>
      </div>
    </div>
  );
}
