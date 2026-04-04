import Image from "next/image";
import Link from "next/link";
import { ArrowRight, ShieldCheck, MapPin, Zap, BadgeCheck, TrendingUp, Search, CheckCircle2 } from "lucide-react";
import { getDictionary } from "@/i18n/get-dictionary";
import type { Locale } from "@/i18n/config";
import { Header } from "@/components/layout/header";
import { ListingCard } from "@/components/listing/listing-card";

// Stock livestock photos from Wikimedia Commons (public domain / CC-licensed)
const PHOTO = {
  horseMountains: "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a2/Biandintz_eta_zaldiak_-_modified2.jpg/1200px-Biandintz_eta_zaldiak_-_modified2.jpg",
  horseNokota: "https://upload.wikimedia.org/wikipedia/commons/thumb/d/de/Nokota_Horses_cropped.jpg/800px-Nokota_Horses_cropped.jpg",
  horsePony: "https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/Horse-and-pony.jpg/800px-Horse-and-pony.jpg",
  horseMareFoal: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4c/Mare_foal_poland.jpg/800px-Mare_foal_poland.jpg",
  horseField: "https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/Horsescd1l-095.jpg/800px-Horsescd1l-095.jpg",
  cowFleckvieh: "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8c/Cow_%28Fleckvieh_breed%29_Oeschinensee_Slaunger_2009-07-07.jpg/800px-Cow_%28Fleckvieh_breed%29_Oeschinensee_Slaunger_2009-07-07.jpg",
  cowHerd: "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d8/Cattle_Selwyn_Road_Boulia_Shire_Central_Western_Queensland_P1080822_%28cropped%29.jpg/800px-Cattle_Selwyn_Road_Boulia_Shire_Central_Western_Queensland_P1080822_%28cropped%29.jpg",
  cowAngus: "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b7/Aberdeen_Angus_im_Gadental_2.JPG/800px-Aberdeen_Angus_im_Gadental_2.JPG",
  sheepFlock: "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Flock_of_sheep.jpg/800px-Flock_of_sheep.jpg",
  sheepTurkmen: "https://upload.wikimedia.org/wikipedia/commons/thumb/b/bf/Turkmen_sheep.jpg/800px-Turkmen_sheep.jpg",
  sheepMountain: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/44/A_curious_Welsh_Mountain_sheep_%28Ovis_aries%29.jpg/800px-A_curious_Welsh_Mountain_sheep_%28Ovis_aries%29.jpg",
  goat: "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b2/Hausziege_04.jpg/800px-Hausziege_04.jpg",
};

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
    imageUrl: PHOTO.sheepTurkmen,
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
    imageUrl: PHOTO.horseField,
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
    imageUrl: PHOTO.cowHerd,
    viewsCount: 156,
    favoritesCount: 12,
    isVerifiedBreeder: false,
    createdAt: new Date(Date.now() - 86400000).toISOString(),
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
    imageUrl: PHOTO.horsePony,
    viewsCount: 312,
    favoritesCount: 28,
    isVerifiedBreeder: true,
    createdAt: new Date(Date.now() - 3600000 * 8).toISOString(),
  },
];

export default async function HomePage({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  const dict = await getDictionary(locale as Locale);
  const isKy = locale === "ky";

  const t = {
    heroTag: isKy ? "Кыргызстандын №1 мал базары" : "Рынок скота №1 в Кыргызстане",
    heroTitle: isKy ? "Мал сатуу жана сатып алуу — оңой, тез, ишенимдүү" : "Покупка и продажа скота — легко, быстро, надёжно",
    heroSubtitle: isKy
      ? "Миңдеген текшерилген малчылар. Бардык аймактардан жарыялар. Бир колуңда."
      : "Тысячи проверенных фермеров. Объявления со всех регионов. В одном месте.",
    ctaBrowse: isKy ? "Малды көрүү" : "Смотреть скот",
    ctaSell: isKy ? "Жарыя берүү" : "Разместить объявление",
    statFarmers: isKy ? "малчы" : "фермеров",
    statListings: isKy ? "активдүү жарыя" : "активных объявлений",
    statRegions: isKy ? "аймак" : "регионов",
    featuredTitle: isKy ? "Жаңы жарыялар" : "Свежие объявления",
    featuredSub: isKy ? "Бүгүн кошулган эң жакшы сунуштар" : "Лучшие предложения, добавленные сегодня",
    benefitsTag: isKy ? "Эмне үчүн MalSat?" : "Почему MalSat?",
    benefitsTitle: isKy ? "Базардагы эң жакшы шарттар" : "Лучшие условия на рынке",
    b1Title: isKy ? "Текшерилген малчылар" : "Проверенные фермеры",
    b1Desc: isKy ? "Ар бир малчы идентификациядан өтөт" : "Каждый продавец проходит верификацию",
    b2Title: isKy ? "Бардык аймактар" : "Все регионы",
    b2Desc: isKy ? "7 областтагы малчылар менен байланышыңыз" : "Связь с фермерами из 7 областей",
    b3Title: isKy ? "Тез сатуу" : "Быстрая продажа",
    b3Desc: isKy ? "Орточо 3 күндө сатылат" : "В среднем продаётся за 3 дня",
    b4Title: isKy ? "Акысыз жарыя" : "Бесплатное размещение",
    b4Desc: isKy ? "Биринчи 10 жарыя акысыз" : "Первые 10 объявлений бесплатно",
    howTitle: isKy ? "3 кадамда сатуу" : "Продать за 3 шага",
    step1: isKy ? "Сүрөт тарт" : "Сделай фото",
    step1Desc: isKy ? "Малыңыздын сүрөтүн жүктөңүз" : "Загрузите фото вашего скота",
    step2: isKy ? "Баа кой" : "Укажи цену",
    step2Desc: isKy ? "Баа жана сыпаттама кошуңуз" : "Добавьте цену и описание",
    step3: isKy ? "Сатуу" : "Получи звонок",
    step3Desc: isKy ? "Сатып алуучулардан чалуу күтүңүз" : "Покупатели свяжутся с вами",
    storyTag: isKy ? "Ийгилик окуясы" : "История успеха",
    storyTitle: isKy ? "Жаңы эле MalSat аркылуу сатылды" : "Недавно продано через MalSat",
    storySold: isKy ? "Сатылды" : "Продано",
    storyHorseTitle: isKy ? "Кара жылкы, 1.5 жаш" : "Чёрный конь, 1.5 года",
    storyBreed: isKy ? "Жергиликтүү тукум" : "Местная порода",
    storyLocation: isKy ? "Нарын областы" : "Нарынская область",
    storyPrice: isKy ? "Сатылган баасы" : "Продано за",
    storyDays: isKy ? "5 күндө сатылды" : "Продано за 5 дней",
    storyViews: isKy ? "247 көрүү" : "247 просмотров",
    storyContacts: isKy ? "12 байланыш" : "12 контактов",
    ctaFinalTitle: isKy ? "Бүгүн малыңызды сатыңыз" : "Продайте свой скот сегодня",
    ctaFinalSub: isKy ? "Бекер катталыңыз жана миңдеген сатып алуучуларга жетиңиз" : "Бесплатная регистрация и доступ к тысячам покупателей",
  };

  const categories = [
    { key: "horse", photo: PHOTO.horseMareFoal, labelKy: "Жылкы", labelRu: "Лошади", count: "1,240" },
    { key: "cattle", photo: PHOTO.cowAngus, labelKy: "Бодо мал", labelRu: "КРС", count: "2,180" },
    { key: "sheep", photo: PHOTO.sheepFlock, labelKy: "Кой", labelRu: "Овцы", count: "3,450" },
    { key: "arashan", photo: PHOTO.goat, labelKy: "Арашан", labelRu: "Арашан", count: "890" },
  ];

  return (
    <div className="flex flex-col">
      <Header locale={locale} dict={dict} />

      {/* ============== HERO ============== */}
      <section className="relative overflow-hidden bg-gradient-to-br from-malsat-cream via-background to-background">
        {/* Decorative blobs */}
        <div className="pointer-events-none absolute -left-24 -top-24 h-72 w-72 rounded-full bg-malsat-green/10 blur-3xl" />
        <div className="pointer-events-none absolute -right-24 top-32 h-96 w-96 rounded-full bg-malsat-gold/10 blur-3xl" />

        <div className="relative mx-auto grid max-w-6xl gap-10 px-4 py-12 md:grid-cols-2 md:gap-12 md:py-20 md:items-center">
          {/* Copy */}
          <div>
            <span className="inline-flex items-center gap-2 rounded-full border border-malsat-green/20 bg-malsat-green/5 px-3 py-1 text-xs font-semibold text-malsat-green">
              <span className="h-1.5 w-1.5 rounded-full bg-malsat-green" />
              {t.heroTag}
            </span>
            <h1 className="mt-4 text-3xl font-bold leading-[1.1] tracking-tight text-foreground md:text-5xl">
              {t.heroTitle}
            </h1>
            <p className="mt-4 max-w-md text-base text-muted-foreground md:text-lg">
              {t.heroSubtitle}
            </p>

            <div className="mt-7 flex flex-wrap gap-3">
              <Link
                href={`/${locale}/search`}
                className="inline-flex items-center gap-2 rounded-xl bg-malsat-green px-5 py-3 text-sm font-semibold text-white shadow-sm transition-all hover:bg-malsat-green-dark hover:shadow-md active:scale-[0.98]"
              >
                <Search className="h-4 w-4" />
                {t.ctaBrowse}
              </Link>
              <Link
                href={`/${locale}/sell`}
                className="inline-flex items-center gap-2 rounded-xl border border-border bg-white px-5 py-3 text-sm font-semibold text-foreground transition-all hover:border-malsat-green hover:text-malsat-green active:scale-[0.98]"
              >
                {t.ctaSell}
                <ArrowRight className="h-4 w-4" />
              </Link>
            </div>

            {/* Stats */}
            <div className="mt-8 grid max-w-md grid-cols-3 gap-4 border-t border-border pt-6">
              <div>
                <p className="text-2xl font-bold text-foreground">12K+</p>
                <p className="text-xs text-muted-foreground">{t.statFarmers}</p>
              </div>
              <div>
                <p className="text-2xl font-bold text-foreground">7.7K</p>
                <p className="text-xs text-muted-foreground">{t.statListings}</p>
              </div>
              <div>
                <p className="text-2xl font-bold text-foreground">7</p>
                <p className="text-xs text-muted-foreground">{t.statRegions}</p>
              </div>
            </div>
          </div>

          {/* Hero visual — layered livestock photo cards */}
          <div className="relative h-[380px] md:h-[460px]">
            {/* Back card — horses */}
            <div className="absolute right-0 top-6 h-56 w-44 overflow-hidden rotate-6 rounded-3xl shadow-xl ring-1 ring-black/5 md:h-72 md:w-56">
              <Image
                src={PHOTO.horseNokota}
                alt="Horses on pasture"
                fill
                className="object-cover"
                sizes="(max-width: 768px) 176px, 224px"
              />
              <div className="absolute inset-x-0 bottom-0 h-24 bg-gradient-to-t from-black/70 to-transparent" />
              <div className="absolute bottom-3 left-3 right-3 rounded-xl bg-white/15 px-3 py-2 backdrop-blur-sm">
                <p className="text-[10px] font-medium text-white/90">{isKy ? "Жылкы" : "Лошади"}</p>
                <p className="text-sm font-bold text-white">120 000 сом</p>
              </div>
            </div>

            {/* Mid card — cattle */}
            <div className="absolute left-4 top-20 h-56 w-44 overflow-hidden -rotate-3 rounded-3xl shadow-xl ring-1 ring-black/5 md:h-72 md:w-56">
              <Image
                src={PHOTO.cowFleckvieh}
                alt="Cow in mountains"
                fill
                className="object-cover"
                sizes="(max-width: 768px) 176px, 224px"
              />
              <div className="absolute inset-x-0 bottom-0 h-24 bg-gradient-to-t from-black/70 to-transparent" />
              <div className="absolute bottom-3 left-3 right-3 rounded-xl bg-white/15 px-3 py-2 backdrop-blur-sm">
                <p className="text-[10px] font-medium text-white/90">{isKy ? "Бодо мал" : "КРС"}</p>
                <p className="text-sm font-bold text-white">250 000 сом</p>
              </div>
            </div>

            {/* Front card — sheep */}
            <div className="absolute bottom-0 right-8 h-60 w-48 rotate-2 rounded-3xl bg-white p-3 shadow-2xl ring-1 ring-border md:h-80 md:w-60">
              <div className="relative h-40 overflow-hidden rounded-2xl md:h-56">
                <Image
                  src={PHOTO.sheepTurkmen}
                  alt="Central Asian sheep"
                  fill
                  className="object-cover"
                  sizes="(max-width: 768px) 192px, 240px"
                />
              </div>
              <div className="mt-3 flex items-start justify-between">
                <div>
                  <p className="text-xs font-semibold text-malsat-green">
                    <BadgeCheck className="mr-0.5 inline h-3 w-3" />
                    {isKy ? "Текшерилген" : "Проверен"}
                  </p>
                  <p className="mt-0.5 text-sm font-bold text-foreground">850 000 сом</p>
                </div>
                <span className="rounded-full bg-malsat-green/10 px-2 py-0.5 text-[10px] font-semibold text-malsat-green">
                  ⭐ 4.9
                </span>
              </div>
            </div>

            {/* Floating badge */}
            <div className="absolute left-0 top-0 flex items-center gap-2 rounded-2xl bg-white px-3 py-2 shadow-lg ring-1 ring-border">
              <div className="flex h-8 w-8 items-center justify-center rounded-full bg-malsat-green/10">
                <ShieldCheck className="h-4 w-4 text-malsat-green" />
              </div>
              <div>
                <p className="text-[10px] font-medium text-muted-foreground">{isKy ? "Коопсуз бүтүм" : "Безопасная сделка"}</p>
                <p className="text-xs font-bold text-foreground">{isKy ? "100% кепилдик" : "100% гарантия"}</p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ============== SUCCESS STORY / REAL CASE ============== */}
      <section className="mx-auto w-full max-w-6xl px-4 py-10 md:py-14">
        <div className="grid gap-8 md:grid-cols-[1.1fr_1fr] md:items-center md:gap-12">
          {/* Photo gallery */}
          <div className="grid grid-cols-2 gap-3">
            <div className="relative aspect-[3/4] overflow-hidden rounded-2xl bg-muted shadow-lg ring-1 ring-border">
              <Image
                src={PHOTO.horseMountains}
                alt="Black horse Naryn"
                fill
                className="object-cover"
                sizes="(max-width: 768px) 50vw, 25vw"
              />
              {/* SOLD overlay */}
              <div className="absolute inset-0 bg-black/25" />
              <div className="absolute left-3 top-3 rounded-full bg-red-600 px-3 py-1 text-xs font-bold text-white shadow-lg">
                {t.storySold}
              </div>
            </div>
            <div className="relative mt-8 aspect-[3/4] overflow-hidden rounded-2xl bg-muted shadow-lg ring-1 ring-border">
              <Image
                src={PHOTO.horseMareFoal}
                alt="Black horse Naryn"
                fill
                className="object-cover"
                sizes="(max-width: 768px) 50vw, 25vw"
              />
              <div className="absolute inset-0 bg-black/25" />
            </div>
          </div>

          {/* Story copy */}
          <div>
            <span className="inline-flex items-center gap-2 rounded-full bg-red-50 px-3 py-1 text-xs font-semibold text-red-600">
              <CheckCircle2 className="h-3.5 w-3.5" />
              {t.storyTag}
            </span>
            <h2 className="mt-3 text-2xl font-bold text-foreground md:text-3xl">
              {t.storyTitle}
            </h2>

            <div className="mt-6 rounded-2xl border border-border bg-white p-5 shadow-sm">
              <div className="flex items-start justify-between gap-3">
                <div>
                  <h3 className="text-lg font-bold text-foreground">{t.storyHorseTitle}</h3>
                  <p className="mt-0.5 text-sm text-muted-foreground">{t.storyBreed}</p>
                </div>
                <span className="whitespace-nowrap rounded-full bg-muted px-2.5 py-1 text-[11px] font-semibold text-muted-foreground">
                  {t.storyPrice}
                </span>
              </div>

              <p className="mt-3 text-3xl font-bold text-malsat-green">
                160 000 <span className="text-lg font-normal">сом</span>
              </p>

              <div className="mt-4 flex items-center gap-1.5 text-sm text-muted-foreground">
                <MapPin className="h-4 w-4 text-malsat-green" />
                <span>{t.storyLocation}</span>
              </div>

              <div className="mt-4 grid grid-cols-3 gap-3 border-t border-border pt-4">
                <div>
                  <p className="text-xs text-muted-foreground">{isKy ? "Мөөнөтү" : "Срок"}</p>
                  <p className="mt-0.5 text-sm font-bold text-foreground">{t.storyDays}</p>
                </div>
                <div>
                  <p className="text-xs text-muted-foreground">{isKy ? "Көрүүлөр" : "Просмотры"}</p>
                  <p className="mt-0.5 text-sm font-bold text-foreground">{t.storyViews}</p>
                </div>
                <div>
                  <p className="text-xs text-muted-foreground">{isKy ? "Байланыштар" : "Контакты"}</p>
                  <p className="mt-0.5 text-sm font-bold text-foreground">{t.storyContacts}</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ============== CATEGORY PILLS ============== */}
      <section className="border-y border-border bg-white">
        <div className="mx-auto max-w-6xl px-4 py-6">
          <div className="grid grid-cols-2 gap-3 md:grid-cols-4">
            {categories.map((cat) => (
              <Link
                key={cat.key}
                href={`/${locale}/search?category=${cat.key}`}
                className="group flex items-center gap-3 rounded-2xl border border-border bg-background p-3 transition-all hover:border-malsat-green hover:shadow-md"
              >
                <div className="relative h-14 w-14 flex-shrink-0 overflow-hidden rounded-xl ring-1 ring-border">
                  <Image
                    src={cat.photo}
                    alt={cat.labelRu}
                    fill
                    className="object-cover transition-transform group-hover:scale-110"
                    sizes="56px"
                  />
                </div>
                <div className="min-w-0 flex-1">
                  <p className="truncate text-sm font-semibold text-foreground">
                    {isKy ? cat.labelKy : cat.labelRu}
                  </p>
                  <p className="text-xs text-muted-foreground">
                    {cat.count} {isKy ? "жарыя" : "объявл."}
                  </p>
                </div>
              </Link>
            ))}
          </div>
        </div>
      </section>

      {/* ============== FEATURED LIVESTOCK ============== */}
      <section className="mx-auto w-full max-w-6xl px-4 py-12">
        <div className="mb-6 flex items-end justify-between">
          <div>
            <h2 className="text-2xl font-bold text-foreground md:text-3xl">
              {t.featuredTitle}
            </h2>
            <p className="mt-1 text-sm text-muted-foreground">{t.featuredSub}</p>
          </div>
          <Link
            href={`/${locale}/search`}
            className="hidden items-center gap-1 text-sm font-semibold text-malsat-green hover:text-malsat-green-dark md:flex"
          >
            {dict.common.seeAll}
            <ArrowRight className="h-4 w-4" />
          </Link>
        </div>

        <div className="grid grid-cols-2 gap-3 md:grid-cols-4 md:gap-5">
          {demoListings.map((listing) => (
            <ListingCard key={listing.id} locale={locale} {...listing} />
          ))}
        </div>

        <Link
          href={`/${locale}/search`}
          className="mt-6 flex items-center justify-center gap-1 text-sm font-semibold text-malsat-green md:hidden"
        >
          {dict.common.seeAll}
          <ArrowRight className="h-4 w-4" />
        </Link>
      </section>

      {/* ============== BENEFITS ============== */}
      <section className="bg-gradient-to-b from-background to-malsat-cream/40">
        <div className="mx-auto max-w-6xl px-4 py-14 md:py-20">
          <div className="mx-auto max-w-2xl text-center">
            <span className="inline-block rounded-full bg-malsat-gold/10 px-3 py-1 text-xs font-semibold text-malsat-gold-light">
              {t.benefitsTag}
            </span>
            <h2 className="mt-3 text-2xl font-bold text-foreground md:text-4xl">
              {t.benefitsTitle}
            </h2>
          </div>

          <div className="mt-10 grid gap-4 md:grid-cols-4">
            {[
              { icon: ShieldCheck, title: t.b1Title, desc: t.b1Desc, bg: "bg-malsat-green/10", fg: "text-malsat-green" },
              { icon: MapPin, title: t.b2Title, desc: t.b2Desc, bg: "bg-malsat-gold/10", fg: "text-malsat-gold-light" },
              { icon: Zap, title: t.b3Title, desc: t.b3Desc, bg: "bg-malsat-green-light/10", fg: "text-malsat-green-light" },
              { icon: TrendingUp, title: t.b4Title, desc: t.b4Desc, bg: "bg-malsat-brown/10", fg: "text-malsat-brown" },
            ].map((b, i) => (
              <div
                key={i}
                className="rounded-2xl border border-border bg-white p-6 transition-all hover:-translate-y-1 hover:shadow-lg"
              >
                <div className={`mb-4 flex h-12 w-12 items-center justify-center rounded-xl ${b.bg}`}>
                  <b.icon className={`h-6 w-6 ${b.fg}`} />
                </div>
                <h3 className="text-base font-bold text-foreground">{b.title}</h3>
                <p className="mt-1.5 text-sm leading-relaxed text-muted-foreground">{b.desc}</p>
              </div>
            ))}
          </div>

          {/* How it works diagram */}
          <div className="mt-14 rounded-3xl border border-border bg-white p-6 md:p-10">
            <h3 className="text-center text-xl font-bold text-foreground md:text-2xl">
              {t.howTitle}
            </h3>

            <div className="mt-8 grid gap-6 md:grid-cols-3 md:gap-0">
              {[
                { num: "1", title: t.step1, desc: t.step1Desc, emoji: "📸" },
                { num: "2", title: t.step2, desc: t.step2Desc, emoji: "💰" },
                { num: "3", title: t.step3, desc: t.step3Desc, emoji: "📞" },
              ].map((s, i, arr) => (
                <div key={s.num} className="relative flex flex-col items-center text-center">
                  {/* Connector */}
                  {i < arr.length - 1 && (
                    <div className="absolute left-1/2 top-8 hidden h-px w-full bg-gradient-to-r from-malsat-green/40 to-transparent md:block" />
                  )}
                  <div className="relative z-10 flex h-16 w-16 items-center justify-center rounded-2xl bg-gradient-to-br from-malsat-green to-malsat-green-dark text-3xl shadow-lg">
                    {s.emoji}
                  </div>
                  <div className="mt-3 flex h-6 w-6 items-center justify-center rounded-full bg-malsat-gold/20 text-xs font-bold text-malsat-gold-light">
                    {s.num}
                  </div>
                  <h4 className="mt-2 text-base font-bold text-foreground">{s.title}</h4>
                  <p className="mt-1 max-w-xs text-sm text-muted-foreground">{s.desc}</p>
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* ============== FINAL CTA ============== */}
      <section className="mx-auto w-full max-w-6xl px-4 py-12 md:py-16">
        <div className="relative overflow-hidden rounded-3xl bg-gradient-to-br from-malsat-green to-malsat-green-dark p-8 md:p-12">
          <div className="pointer-events-none absolute -right-20 -top-20 h-64 w-64 rounded-full bg-white/5 blur-2xl" />
          <div className="pointer-events-none absolute -bottom-16 -left-16 h-56 w-56 rounded-full bg-malsat-gold/10 blur-2xl" />
          <div className="relative flex flex-col items-start justify-between gap-6 md:flex-row md:items-center">
            <div>
              <h2 className="text-2xl font-bold text-white md:text-3xl">
                {t.ctaFinalTitle}
              </h2>
              <p className="mt-2 max-w-lg text-sm text-white/80 md:text-base">
                {t.ctaFinalSub}
              </p>
            </div>
            <Link
              href={`/${locale}/sell`}
              className="inline-flex items-center gap-2 rounded-xl bg-white px-6 py-3.5 text-sm font-bold text-malsat-green shadow-lg transition-all hover:bg-malsat-cream active:scale-[0.98]"
            >
              {t.ctaSell}
              <ArrowRight className="h-4 w-4" />
            </Link>
          </div>
        </div>
      </section>
    </div>
  );
}
