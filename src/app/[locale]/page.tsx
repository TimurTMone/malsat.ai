import { getDictionary } from "@/i18n/get-dictionary";
import type { Locale } from "@/i18n/config";
import { Header } from "@/components/layout/header";
import { CategoryIcons } from "@/components/listing/category-icons";
import { ListingCard } from "@/components/listing/listing-card";

// Demo listings for initial UI (replaced by DB data later)
const demoListings = [
  {
    id: "1",
    title: "Арашан кочкор, 2 жашта",
    priceKgs: 850000,
    category: "SHEEP",
    breed: "Арашан",
    ageMonths: 24,
    weightKg: 180,
    village: "Ак-Суу",
    regionNameKy: "Ысык-Көл",
    regionNameRu: "Иссык-Кульская",
    imageUrl: "",
    viewsCount: 234,
    favoritesCount: 18,
    isVerifiedBreeder: true,
    createdAt: new Date(Date.now() - 3600000 * 2).toISOString(),
  },
  {
    id: "2",
    title: "Жылкы, жумушчу, 5 жаш",
    priceKgs: 120000,
    category: "HORSE",
    breed: null,
    ageMonths: 60,
    weightKg: 450,
    village: "Токмок",
    regionNameKy: "Чүй",
    regionNameRu: "Чуйская",
    imageUrl: "",
    viewsCount: 89,
    favoritesCount: 5,
    isVerifiedBreeder: false,
    createdAt: new Date(Date.now() - 3600000 * 5).toISOString(),
  },
  {
    id: "3",
    title: "Сүт уйлар, 3 баш",
    priceKgs: 250000,
    category: "CATTLE",
    breed: "Алатоо",
    ageMonths: 36,
    weightKg: 500,
    village: "Кара-Балта",
    regionNameKy: "Чүй",
    regionNameRu: "Чуйская",
    imageUrl: "",
    viewsCount: 156,
    favoritesCount: 12,
    isVerifiedBreeder: false,
    createdAt: new Date(Date.now() - 86400000).toISOString(),
  },
  {
    id: "4",
    title: "Семиз кой, 10 баш",
    priceKgs: 65000,
    category: "SHEEP",
    breed: null,
    ageMonths: 18,
    weightKg: 70,
    village: "Нарын",
    regionNameKy: "Нарын",
    regionNameRu: "Нарынская",
    imageUrl: "",
    viewsCount: 45,
    favoritesCount: 3,
    isVerifiedBreeder: false,
    createdAt: new Date(Date.now() - 86400000 * 2).toISOString(),
  },
  {
    id: "5",
    title: "Жарыш жылкы, тукумдуу",
    priceKgs: 450000,
    category: "HORSE",
    breed: "Англис тукуму",
    ageMonths: 48,
    weightKg: 480,
    village: "Чолпон-Ата",
    regionNameKy: "Ысык-Көл",
    regionNameRu: "Иссык-Кульская",
    imageUrl: "",
    viewsCount: 312,
    favoritesCount: 28,
    isVerifiedBreeder: true,
    createdAt: new Date(Date.now() - 3600000 * 8).toISOString(),
  },
  {
    id: "6",
    title: "Эчки, сүт, 2 жаш",
    priceKgs: 18000,
    category: "GOAT",
    breed: null,
    ageMonths: 24,
    weightKg: 45,
    village: "Ош",
    regionNameKy: "Ош",
    regionNameRu: "Ош",
    imageUrl: "",
    viewsCount: 23,
    favoritesCount: 1,
    isVerifiedBreeder: false,
    createdAt: new Date(Date.now() - 86400000 * 3).toISOString(),
  },
];

export default async function HomePage({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  const dict = await getDictionary(locale as Locale);

  return (
    <div className="flex flex-col">
      <Header locale={locale} dict={dict} />

      {/* Hero banner */}
      <div className="bg-gradient-to-br from-malsat-green to-malsat-green-dark px-4 py-6">
        <h1 className="text-xl font-bold text-white">
          {locale === "ky"
            ? "Мал сатуу жана сатып алуу"
            : "Купля-продажа скота"}
        </h1>
        <p className="mt-1 text-sm text-white/80">
          {locale === "ky"
            ? "Кыргызстандын биринчи мал базары онлайн"
            : "Первый онлайн рынок скота в Кыргызстане"}
        </p>
      </div>

      {/* Categories */}
      <div className="py-4">
        <CategoryIcons locale={locale} dict={dict} />
      </div>

      {/* Latest listings */}
      <div className="px-4 pb-6">
        <div className="mb-3 flex items-center justify-between">
          <h2 className="text-base font-semibold">
            {locale === "ky" ? "Жаңы жарыялар" : "Новые объявления"}
          </h2>
          <a
            href={`/${locale}/search`}
            className="text-sm font-medium text-malsat-green"
          >
            {dict.common.seeAll}
          </a>
        </div>

        <div className="grid grid-cols-2 gap-3">
          {demoListings.map((listing) => (
            <ListingCard
              key={listing.id}
              locale={locale}
              {...listing}
            />
          ))}
        </div>
      </div>
    </div>
  );
}
