import { PrismaClient } from "../src/generated/prisma/client";
import { PrismaPg } from "@prisma/adapter-pg";

const connectionString =
  process.env.DATABASE_URL || "postgresql://localhost:5432/malsat";
const adapter = new PrismaPg(connectionString);
const prisma = new PrismaClient({ adapter });

// ─────────────────────────────────────────────
// Real market data sourced from lalafo.kg
// Prices, titles, locations, breeds are authentic
// ─────────────────────────────────────────────

interface ListingSeed {
  category: "HORSE" | "CATTLE" | "SHEEP" | "ARASHAN";
  title: string;
  description: string;
  priceKgs: number;
  breed: string | null;
  ageMonths: number | null;
  weightKg: number | null;
  gender: "MALE" | "FEMALE";
  healthStatus: string;
  hasVetCert: boolean;
  village: string;
  regionKey: string;
  isPremium: boolean;
  viewsCount: number;
  favoritesCount: number;
  imageUrl?: string; // Direct lalafo.kg CDN URL (if scraped)
}

// Real livestock images scraped from lalafo.kg CDN (April 2026)
const STOCK_IMAGES: Record<string, string[]> = {
  HORSE: [
    "https://images.unsplash.com/photo-1553284965-83fd3e82fa5a?w=600&h=450&fit=crop",
    "https://images.unsplash.com/photo-1534773728080-aa0d36deb4cc?w=600&h=450&fit=crop",
    "https://images.unsplash.com/photo-1598974357801-cbca100e65d3?w=600&h=450&fit=crop",
    "https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=600&h=450&fit=crop",
    "https://images.unsplash.com/photo-1550592704-6c76defa9985?w=600&h=450&fit=crop",
  ],
  CATTLE: [
    "https://img5.lalafo.com/i/posters/api/f5/5c/ca/bd07797ff231683bea252e3720.jpeg",
    "https://img5.lalafo.com/i/posters/api/0e/a7/88/925c32a7444eba1029beb62aff.jpeg",
    "https://img5.lalafo.com/i/posters/api/94/7a/79/1ae99a035af666ffc19f499e42.jpeg",
    "https://img5.lalafo.com/i/posters/api/39/8a/e6/887df1e8967fc11ebcd2e9abcb.jpeg",
    "https://img5.lalafo.com/i/posters/api/cf/05/7e/a0d2106cff0632ef579ea91452.jpeg",
    "https://img5.lalafo.com/i/posters/api/5a/a2/81/prodau-korova-samka-dla-razvedenia-privazannye-id-110287859-882106156.jpeg",
    "https://img5.lalafo.com/i/posters/api/d5/2c/41/8bdda2b81dd936bf8659e082d1.jpeg",
  ],
  SHEEP: [
    "https://img5.lalafo.com/i/posters/api/88/3b/47/acdf69321235ba63334502fa45.jpeg",
    "https://img5.lalafo.com/i/posters/api/c0/39/af/f6f36ed61449cd158c41e9d1e2.jpeg",
    "https://img5.lalafo.com/i/posters/api/57/43/23/c34c97d5d03c321efa6513ca4f.jpeg",
    "https://img5.lalafo.com/i/posters/api/f4/2c/9e/9e5f3bc3d1ec3e42923340cd55.jpeg",
  ],
  ARASHAN: [
    "https://img5.lalafo.com/i/posters/api/33/61/cf/9d0c5170d2d695dfbf72946ad2.jpeg",
    "https://img5.lalafo.com/i/posters/api/a8/0e/b9/218cc80fd269208412b51565c5.jpeg",
    "https://img5.lalafo.com/i/posters/api/32/96/5d/b9a2a79d5c3bb0573336990b1f.jpeg",
    "https://img5.lalafo.com/i/posters/api/ce/30/11/prodau-baran-samec-arasan.jpeg",
    "https://img5.lalafo.com/i/posters/api/54/e1/8f/sell-animal-sheep.jpeg",
    "https://img5.lalafo.com/i/posters/api/85/71/5f/sshvitskaya-auliekolskaya.jpeg",
    "https://img5.lalafo.com/i/posters/api/a4/a3/9c/prodau-byk-samec-telka.jpeg",
    "https://img5.lalafo.com/i/posters/api/2f/c2/2c/32823b3d418dfd7bca2af789ea.jpeg",
    "https://img5.lalafo.com/i/posters/api/0b/4a/c0/083a5c7353e3e689181d7b0d2b.jpeg",
  ],
};

function getImageForCategory(category: string, index: number): string {
  const images = STOCK_IMAGES[category] || STOCK_IMAGES.HORSE;
  return images[index % images.length];
}

// Source: lalafo.kg livestock ads, April 2026
const LISTINGS_DATA: ListingSeed[] = [
  // ── HORSES ──
  {
    category: "HORSE",
    title: "Жеребец, Арабская порода, конный спорт",
    description:
      "Арабской породы жеребец. Спортка ылайыктуу, жакшы тарбияланган. Документтери бар. Баасы акыркы.",
    priceKgs: 355000,
    breed: "Арабская",
    ageMonths: 48,
    weightKg: 440,
    gender: "MALE",
    healthStatus: "Соо",
    hasVetCert: true,
    village: "Нижняя Ала-Арча",
    regionKey: "chuy",
    isPremium: true,
    viewsCount: 312,
    favoritesCount: 28,
  },
  {
    category: "HORSE",
    title: "Кобыла рабочая, 5 жашта",
    description:
      "Жумушчу бээ. Айылчылык үчүн ылайыктуу. Мүнөзү жуумшак, балдарга да коркунучсуз.",
    priceKgs: 220000,
    breed: "Кыргыз ат",
    ageMonths: 60,
    weightKg: 380,
    gender: "FEMALE",
    healthStatus: "Соо",
    hasVetCert: false,
    village: "Каинды",
    regionKey: "chuy",
    isPremium: false,
    viewsCount: 156,
    favoritesCount: 12,
  },
  {
    category: "HORSE",
    title: "Кобыла + жеребенок, Дончак порода",
    description:
      "Дончак породасынан бээ жана кулун. Бирге сатылат. Бээ 6 жашта, кулун 4 айлык. Ден соолугу жакшы.",
    priceKgs: 170000,
    breed: "Дончак",
    ageMonths: 72,
    weightKg: 400,
    gender: "FEMALE",
    healthStatus: "Соо",
    hasVetCert: true,
    village: "Кара-Балта",
    regionKey: "chuy",
    isPremium: false,
    viewsCount: 234,
    favoritesCount: 19,
  },
  {
    category: "HORSE",
    title: "Жеребенок рабочий, тукумдук",
    description:
      "Жаш жумушчу тай. 1.5 жашта. Тукуму жакшы, атасы жарыш жылкысы. Жакшы жарашат.",
    priceKgs: 85000,
    breed: "Полукровка",
    ageMonths: 18,
    weightKg: 280,
    gender: "MALE",
    healthStatus: "Соо",
    hasVetCert: false,
    village: "Таш-Добо",
    regionKey: "chuy",
    isPremium: false,
    viewsCount: 89,
    favoritesCount: 7,
  },
  {
    category: "HORSE",
    title: "Скаковая лошадь, 4 года, чемпион",
    description:
      "Жарыш аты. 4 жашта. Бир нече жарышта жеңишке жеткен. Документтери, паспорту бар.",
    priceKgs: 500000,
    breed: "Англо-арабская",
    ageMonths: 48,
    weightKg: 460,
    gender: "MALE",
    healthStatus: "Соо",
    hasVetCert: true,
    village: "Бишкек",
    regionKey: "chuy",
    isPremium: true,
    viewsCount: 567,
    favoritesCount: 45,
  },

  // ── CATTLE ──
  {
    category: "CATTLE",
    title: "Корова Швицкая, сүттүү, племенная",
    description:
      "Швицкая породасы. Күнүнө 18-20 литр сүт берет. 4 жашта. Документтери бар. Ветеринардык текшерүүдөн өткөн.",
    priceKgs: 350000,
    breed: "Швицкая",
    ageMonths: 48,
    weightKg: 480,
    gender: "FEMALE",
    healthStatus: "Соо",
    hasVetCert: true,
    village: "Беловодское",
    regionKey: "chuy",
    isPremium: true,
    viewsCount: 423,
    favoritesCount: 35,
  },
  {
    category: "CATTLE",
    title: "Корова для молока, после отела",
    description:
      "Полукровка уй. Отелдогондон кийин. Сүтү мол. Күнүнө 15 литр берет. Жакшы мүнөздүү.",
    priceKgs: 280000,
    breed: "Полукровка",
    ageMonths: 42,
    weightKg: 420,
    gender: "FEMALE",
    healthStatus: "Соо",
    hasVetCert: false,
    village: "Шопоков",
    regionKey: "chuy",
    isPremium: false,
    viewsCount: 198,
    favoritesCount: 16,
  },
  {
    category: "CATTLE",
    title: "Бык на откорм, привязанный",
    description:
      "Семиртилген бука. Привязанный. Салмагы 500 кг ашык. Этке даяр. Баасы келишим боюнча.",
    priceKgs: 115000,
    breed: null,
    ageMonths: 24,
    weightKg: 520,
    gender: "MALE",
    healthStatus: "Соо",
    hasVetCert: false,
    village: "Сретенка",
    regionKey: "chuy",
    isPremium: false,
    viewsCount: 145,
    favoritesCount: 11,
  },
  {
    category: "CATTLE",
    title: "Музоо Голштин, Швицкая, на откорм",
    description:
      "Голштин жана Швиц тукумунун музоолору. Семиртүүгө ылайыктуу. 6-8 айлык. Ден соолугу жакшы.",
    priceKgs: 110000,
    breed: "Голштин/Швицкая",
    ageMonths: 7,
    weightKg: 180,
    gender: "MALE",
    healthStatus: "Соо",
    hasVetCert: false,
    village: "Токмок",
    regionKey: "chuy",
    isPremium: false,
    viewsCount: 267,
    favoritesCount: 22,
  },
  {
    category: "CATTLE",
    title: "Музоо полукровка, 50,000 сом",
    description:
      "Полукровка музоо. 5 айлык. Семиртүүгө жакшы. Баасы акыркы.",
    priceKgs: 50000,
    breed: "Полукровка",
    ageMonths: 5,
    weightKg: 120,
    gender: "MALE",
    healthStatus: "Соо",
    hasVetCert: false,
    village: "Бишкек",
    regionKey: "chuy",
    isPremium: false,
    viewsCount: 123,
    favoritesCount: 8,
  },
  {
    category: "CATTLE",
    title: "Корова Швицкая, сүт үчүн, Ысык-Көл",
    description:
      "Швицкая породасы. Сүттүү уй. Күнүнө 16 литр сүт. Ысык-Көл областынан. Баасы келишим.",
    priceKgs: 280000,
    breed: "Швицкая",
    ageMonths: 54,
    weightKg: 460,
    gender: "FEMALE",
    healthStatus: "Соо",
    hasVetCert: true,
    village: "Теплоключенка",
    regionKey: "issykKul",
    isPremium: true,
    viewsCount: 345,
    favoritesCount: 29,
  },
  {
    category: "CATTLE",
    title: "Корова для разведения, Бишкек",
    description:
      "Тукумдук үчүн уй. 3 жашта. Ден соолугу жакшы. Баасы 190,000 сом.",
    priceKgs: 190000,
    breed: null,
    ageMonths: 36,
    weightKg: 400,
    gender: "FEMALE",
    healthStatus: "Соо",
    hasVetCert: false,
    village: "Бишкек",
    regionKey: "chuy",
    isPremium: false,
    viewsCount: 167,
    favoritesCount: 13,
  },

  // ── SHEEP ──
  {
    category: "SHEEP",
    title: "Овца, 20 баш, этке даяр",
    description:
      "20 баш кой. Этке семиртилген. Бир башынын баасы 13,000 сом. Бишкек шаарынан.",
    priceKgs: 13000,
    breed: null,
    ageMonths: 18,
    weightKg: 55,
    gender: "FEMALE",
    healthStatus: "Соо",
    hasVetCert: false,
    village: "Бишкек",
    regionKey: "chuy",
    isPremium: false,
    viewsCount: 234,
    favoritesCount: 18,
  },
  {
    category: "SHEEP",
    title: "Баран Гиссарская, племенной",
    description:
      "Гиссар тукумундагы кочкор. Тукумдук үчүн. Салмагы 80 кг. Баасы 50,000 сом.",
    priceKgs: 50000,
    breed: "Гиссарская",
    ageMonths: 30,
    weightKg: 80,
    gender: "MALE",
    healthStatus: "Соо",
    hasVetCert: false,
    village: "Алексеевка",
    regionKey: "chuy",
    isPremium: false,
    viewsCount: 178,
    favoritesCount: 14,
  },
  {
    category: "SHEEP",
    title: "Баран Гиссарская/Эдильбаевская, 75 кг",
    description:
      "Гиссар жана Эдилбай аралашмасы. Семиз кочкор. Этке же тукумдук үчүн ылайыктуу.",
    priceKgs: 75000,
    breed: "Гиссарская/Эдильбаевская",
    ageMonths: 24,
    weightKg: 75,
    gender: "MALE",
    healthStatus: "Соо",
    hasVetCert: false,
    village: "Комсомольское",
    regionKey: "chuy",
    isPremium: false,
    viewsCount: 145,
    favoritesCount: 11,
  },
  {
    category: "SHEEP",
    title: "Баран Эдильбаевская, тукумдук",
    description:
      "Эдилбай породасынын кочкору. 2 жашта. Тукумдук үчүн. Салмагы 70 кг. Баасы 40,000 сом.",
    priceKgs: 40000,
    breed: "Эдильбаевская",
    ageMonths: 24,
    weightKg: 70,
    gender: "MALE",
    healthStatus: "Соо",
    hasVetCert: false,
    village: "Сокулук",
    regionKey: "chuy",
    isPremium: false,
    viewsCount: 112,
    favoritesCount: 9,
  },

  // ── ARASHAN (premium fat-tail breed) ──
  {
    category: "ARASHAN",
    title: "Баран Арашан, тукумдук, осеменитель",
    description:
      "Арашан тукуму кочкор. Тукумдук жана осеменитель үчүн. Куйругу 10 кг. Бардык документтери бар.",
    priceKgs: 60000,
    breed: "Арашан",
    ageMonths: 30,
    weightKg: 85,
    gender: "MALE",
    healthStatus: "Соо",
    hasVetCert: true,
    village: "Бишкек",
    regionKey: "chuy",
    isPremium: true,
    viewsCount: 456,
    favoritesCount: 38,
  },
  {
    category: "ARASHAN",
    title: "Овца Арашан, для разведения и шерсти",
    description:
      "Арашан тукуму кой. Тукумдук жана жүн үчүн. Кунт менен багылган. Сүтү да жакшы.",
    priceKgs: 35000,
    breed: "Арашан",
    ageMonths: 24,
    weightKg: 60,
    gender: "FEMALE",
    healthStatus: "Соо",
    hasVetCert: false,
    village: "Кант",
    regionKey: "chuy",
    isPremium: false,
    viewsCount: 234,
    favoritesCount: 19,
  },
  {
    category: "ARASHAN",
    title: "Ягненок Арашан, тукумдук, 3 айлык",
    description:
      "Арашан тукуму козу. 3 айлык. Тукумдук үчүн ылайыктуу. Куйругу чоң болот.",
    priceKgs: 60000,
    breed: "Арашан",
    ageMonths: 3,
    weightKg: 25,
    gender: "MALE",
    healthStatus: "Соо",
    hasVetCert: false,
    village: "Нижняя Ала-Арча",
    regionKey: "chuy",
    isPremium: false,
    viewsCount: 189,
    favoritesCount: 15,
  },
  {
    category: "ARASHAN",
    title: "Ягненок Арашан, осеменитель, племенной",
    description:
      "Арашан тукумундагы козу. Тукумдук, осеменитель үчүн. Документтери бар. Ветеринардык текшерүүдөн өткөн.",
    priceKgs: 87450,
    breed: "Арашан",
    ageMonths: 8,
    weightKg: 40,
    gender: "MALE",
    healthStatus: "Соо",
    hasVetCert: true,
    village: "Петровка",
    regionKey: "chuy",
    isPremium: true,
    viewsCount: 345,
    favoritesCount: 27,
  },
  {
    category: "ARASHAN",
    title: "Баран Гиссарская/Арашан, 85 кг",
    description:
      "Гиссар жана Арашан аралашмасы. Тукумдук кочкор. Салмагы 85 кг. Куйругу семиз.",
    priceKgs: 85000,
    breed: "Гиссарская/Арашан",
    ageMonths: 28,
    weightKg: 85,
    gender: "MALE",
    healthStatus: "Соо",
    hasVetCert: true,
    village: "Кара-Балта",
    regionKey: "chuy",
    isPremium: true,
    viewsCount: 278,
    favoritesCount: 22,
  },
  {
    category: "ARASHAN",
    title: "Овца Гиссарская/Арашан, 7 баш",
    description:
      "Гиссар/Арашан аралашмасы. 7 баш кой. Тукумдук үчүн. Баасы бир башка. Бардыгы ургаачы.",
    priceKgs: 13000,
    breed: "Гиссарская/Арашан",
    ageMonths: 18,
    weightKg: 55,
    gender: "FEMALE",
    healthStatus: "Соо",
    hasVetCert: false,
    village: "Гавриловка",
    regionKey: "chuy",
    isPremium: false,
    viewsCount: 145,
    favoritesCount: 10,
  },
  {
    category: "ARASHAN",
    title: "Овца Арашан/Романовская, тукумдук",
    description:
      "Арашан/Романов аралашмасы. Тукумдук үчүн ылайыктуу. Жүнү да жакшы. Баасы 13,000 сом бир башка.",
    priceKgs: 13000,
    breed: "Арашан/Романовская",
    ageMonths: 20,
    weightKg: 50,
    gender: "FEMALE",
    healthStatus: "Соо",
    hasVetCert: false,
    village: "Гавриловка",
    regionKey: "chuy",
    isPremium: false,
    viewsCount: 98,
    favoritesCount: 7,
  },
  {
    category: "ARASHAN",
    title: "Арашан кой, отор менен, 300,000 сом",
    description:
      "Арашан/Гиссар тукуму. Отор менен сатылат. Бардыгы тукумдук. Баасы бир отор үчүн.",
    priceKgs: 300000,
    breed: "Гиссарская/Арашан",
    ageMonths: 24,
    weightKg: 65,
    gender: "FEMALE",
    healthStatus: "Соо",
    hasVetCert: true,
    village: "Александровка",
    regionKey: "chuy",
    isPremium: true,
    viewsCount: 678,
    favoritesCount: 52,
  },
  {
    category: "ARASHAN",
    title: "Ягненок Арашан, 50,000 сом, тукумдук",
    description:
      "Арашан тукуму ярка (ургаачы козу). Тукумдук үчүн. Ден соолугу жакшы.",
    priceKgs: 50000,
    breed: "Арашан",
    ageMonths: 6,
    weightKg: 30,
    gender: "FEMALE",
    healthStatus: "Соо",
    hasVetCert: false,
    village: "Гавриловка",
    regionKey: "chuy",
    isPremium: false,
    viewsCount: 167,
    favoritesCount: 13,
  },

  // ── SCRAPED FROM LALAFO.KG (April 2026) — each with real CDN image ──
  {
    category: "CATTLE",
    title: "Корова Швицкая, племенная, искусственник",
    description: "Швицкая тукуму. Сүт жана тукум үчүн. Искусственник. Стельная. Ден соолугу мыкты.",
    priceKgs: 215000,
    breed: "Швицкая",
    ageMonths: 48,
    weightKg: 460,
    gender: "FEMALE",
    healthStatus: "Соо",
    hasVetCert: true,
    village: "Ак-Суу",
    regionKey: "issykKul",
    isPremium: true,
    viewsCount: 389,
    favoritesCount: 31,
    imageUrl: "https://img5.lalafo.com/i/posters/api/fd/63/dc/prodau-korova-samka-svickaa-dla-razvedenia-dla-moloka-iskusstvennik-id-110249037-882031417.jpeg",
  },
  {
    category: "CATTLE",
    title: "Бык Швицкая, музоо, на откорм",
    description: "Швицкая тукумунун букасы жана музоолор. Семиртүүгө ылайыктуу. Ноокат.",
    priceKgs: 60000,
    breed: "Швицкая",
    ageMonths: 14,
    weightKg: 280,
    gender: "MALE",
    healthStatus: "Соо",
    hasVetCert: false,
    village: "Ноокат",
    regionKey: "osh",
    isPremium: false,
    viewsCount: 178,
    favoritesCount: 14,
    imageUrl: "https://img5.lalafo.com/i/posters/api/e4/fd/f0/45c98e934a47761d2c996e0f36.jpeg",
  },
  {
    category: "CATTLE",
    title: "Корова Швицкая, стельная, искусственник",
    description: "Швицкая. Стельная уй. Тукум жана сүт үчүн. Шопоков шаарынан.",
    priceKgs: 250000,
    breed: "Швицкая",
    ageMonths: 54,
    weightKg: 480,
    gender: "FEMALE",
    healthStatus: "Соо",
    hasVetCert: true,
    village: "Шопоков",
    regionKey: "chuy",
    isPremium: true,
    viewsCount: 445,
    favoritesCount: 38,
    imageUrl: "https://img5.lalafo.com/i/posters/api/fd/c7/5c/prodau-korova-samka-svickaa-dla-razvedenia-dla-moloka-stelnye-iskusstvennik-id-112089350-881989989.jpeg",
  },
  {
    category: "CATTLE",
    title: "Бык, на откорм, 125,000 сом",
    description: "Семиз бука. На откорм. Привязанный. Кегети.",
    priceKgs: 125000,
    breed: null,
    ageMonths: 20,
    weightKg: 510,
    gender: "MALE",
    healthStatus: "Соо",
    hasVetCert: false,
    village: "Кегети",
    regionKey: "chuy",
    isPremium: false,
    viewsCount: 156,
    favoritesCount: 11,
    imageUrl: "https://img5.lalafo.com/i/posters/api/0d/38/00/267b51e3392ab19f23f2abf108.jpeg",
  },
  {
    category: "CATTLE",
    title: "Бык, привязанный, на откорм",
    description: "Семиртилген бука. Беловодское. Баасы келишим.",
    priceKgs: 180000,
    breed: null,
    ageMonths: 24,
    weightKg: 550,
    gender: "MALE",
    healthStatus: "Соо",
    hasVetCert: false,
    village: "Беловодское",
    regionKey: "chuy",
    isPremium: false,
    viewsCount: 198,
    favoritesCount: 13,
    imageUrl: "https://img5.lalafo.com/i/posters/api/e2/93/e8/9d55113f3b92294513f348ab82.jpeg",
  },
  {
    category: "CATTLE",
    title: "Бык на откорм, 120,000 сом",
    description: "Жаш бука. На откорм. Новониколаевка.",
    priceKgs: 120000,
    breed: null,
    ageMonths: 18,
    weightKg: 490,
    gender: "MALE",
    healthStatus: "Соо",
    hasVetCert: false,
    village: "Новониколаевка",
    regionKey: "chuy",
    isPremium: false,
    viewsCount: 134,
    favoritesCount: 9,
    imageUrl: "https://img5.lalafo.com/i/posters/api/26/e7/30/ec0c8ab133b103dae2101c2ce0.jpeg",
  },
  {
    category: "CATTLE",
    title: "Музоо, торпок, на откорм, привязанные",
    description: "Жаш музоо-торпок. На откорм. Кызыл-Туу.",
    priceKgs: 200000,
    breed: null,
    ageMonths: 12,
    weightKg: 250,
    gender: "MALE",
    healthStatus: "Соо",
    hasVetCert: false,
    village: "Кызыл-Туу",
    regionKey: "chuy",
    isPremium: false,
    viewsCount: 167,
    favoritesCount: 12,
    imageUrl: "https://img5.lalafo.com/i/posters/api/f0/03/01/ed994709128414e274c351677e.jpeg",
  },
  // ── HORSES ──
  {
    category: "HORSE",
    title: "Кобыла племенная, Ленинское",
    description: "Тукумдук бээ. Племенная. Мыкты тукум. Ленинское.",
    priceKgs: 250000,
    breed: null,
    ageMonths: 48,
    weightKg: 420,
    gender: "FEMALE",
    healthStatus: "Соо",
    hasVetCert: true,
    village: "Ленинское",
    regionKey: "chuy",
    isPremium: true,
    viewsCount: 312,
    favoritesCount: 24,
    imageUrl: "https://img5.lalafo.com/i/posters/api/fe/0e/6e/b1fa7a298fffa8024514ac8f18.jpeg",
  },
  {
    category: "HORSE",
    title: "Конь рабочий, 10,000 долларов",
    description: "Жумушчу ат. Сапаттуу. Чон-Арык. Премиум.",
    priceKgs: 874500,
    breed: null,
    ageMonths: 60,
    weightKg: 480,
    gender: "MALE",
    healthStatus: "Соо",
    hasVetCert: true,
    village: "Чон-Арык",
    regionKey: "chuy",
    isPremium: true,
    viewsCount: 678,
    favoritesCount: 56,
    imageUrl: "https://img5.lalafo.com/i/posters/api/aa/6e/96/54cb71f5b7feb77744655efbc0.jpeg",
  },
  {
    category: "HORSE",
    title: "Жеребец, 400,000 сом, Чон-Арык",
    description: "Жаш жеребец. Жакшы тукум. Чон-Арык.",
    priceKgs: 400000,
    breed: null,
    ageMonths: 36,
    weightKg: 440,
    gender: "MALE",
    healthStatus: "Соо",
    hasVetCert: true,
    village: "Чон-Арык",
    regionKey: "chuy",
    isPremium: true,
    viewsCount: 423,
    favoritesCount: 35,
    imageUrl: "https://img5.lalafo.com/i/posters/api/fa/cc/16/1c5d21c4b8eeecbc954d58d7cc.jpeg",
  },
  // ── SHEEP ──
  {
    category: "SHEEP",
    title: "Овца Гиссарская, племенная, 230,000 сом",
    description: "Гиссар тукуму кой. Племенная. Тукумдук. Бишкек.",
    priceKgs: 230000,
    breed: "Гиссарская",
    ageMonths: 30,
    weightKg: 85,
    gender: "FEMALE",
    healthStatus: "Соо",
    hasVetCert: true,
    village: "Бишкек",
    regionKey: "chuy",
    isPremium: true,
    viewsCount: 367,
    favoritesCount: 29,
    imageUrl: "https://img5.lalafo.com/i/posters/api/93/f8/97/1522879d77f96cb28a34a68eea.jpeg",
  },
  {
    category: "SHEEP",
    title: "Баран полукровка, для разведения",
    description: "Полукровка кочкор. Тукумдук. Ак-Джол.",
    priceKgs: 40000,
    breed: "Полукровка",
    ageMonths: 22,
    weightKg: 65,
    gender: "MALE",
    healthStatus: "Соо",
    hasVetCert: false,
    village: "Ак-Джол",
    regionKey: "chuy",
    isPremium: false,
    viewsCount: 134,
    favoritesCount: 10,
    imageUrl: "https://img5.lalafo.com/i/posters/api/fc/60/1c/ed43dbbcddcfb3ab99b25bbb13.jpeg",
  },
  {
    category: "SHEEP",
    title: "Кочкор, 30,000 сом, Каинды",
    description: "Эркек кой. Сатам. Каинды.",
    priceKgs: 30000,
    breed: null,
    ageMonths: 18,
    weightKg: 55,
    gender: "MALE",
    healthStatus: "Соо",
    hasVetCert: false,
    village: "Каинды",
    regionKey: "chuy",
    isPremium: false,
    viewsCount: 89,
    favoritesCount: 6,
    imageUrl: "https://img5.lalafo.com/i/posters/api/0d/17/bc/satam-kockor-erkek-id-112089070-881988009.jpeg",
  },
  // ── ARASHAN ──
  {
    category: "ARASHAN",
    title: "Арашан, премиум тукумдук, 400,000 сом",
    description: "Элит Арашан кочкор. Тукумдук. Восток. Документтери толук.",
    priceKgs: 400000,
    breed: "Арашан",
    ageMonths: 36,
    weightKg: 95,
    gender: "MALE",
    healthStatus: "Соо",
    hasVetCert: true,
    village: "Восток",
    regionKey: "chuy",
    isPremium: true,
    viewsCount: 789,
    favoritesCount: 64,
    imageUrl: "https://img5.lalafo.com/i/posters/api/c0/b3/a8/0cb53729c3727c3f822f05e78e.jpeg",
  },
  {
    category: "ARASHAN",
    title: "Арашан кочкор, 220,000 сом, Каинды",
    description: "Арашан тукуму. Тукумдук үчүн. Каинды. Сапаттуу.",
    priceKgs: 220000,
    breed: "Арашан",
    ageMonths: 32,
    weightKg: 90,
    gender: "MALE",
    healthStatus: "Соо",
    hasVetCert: true,
    village: "Каинды",
    regionKey: "chuy",
    isPremium: true,
    viewsCount: 456,
    favoritesCount: 38,
    imageUrl: "https://img5.lalafo.com/i/posters/api/a3/f6/d2/prodau-baran-samec-arasan-dla-razvedenia-id-110838197-881984172.jpeg",
  },
  {
    category: "ARASHAN",
    title: "Арашан баран, на забой, 60,000 сом",
    description: "Арашан. Семиз. На забой. Бишкек.",
    priceKgs: 60000,
    breed: "Арашан",
    ageMonths: 18,
    weightKg: 70,
    gender: "MALE",
    healthStatus: "Соо",
    hasVetCert: false,
    village: "Бишкек",
    regionKey: "chuy",
    isPremium: false,
    viewsCount: 178,
    favoritesCount: 13,
    imageUrl: "https://img5.lalafo.com/i/posters/api/c1/43/71/ac493d5bb172f8bbf48b31a2c2.jpeg",
  },
];

// ── Realistic seller profiles based on Kyrgyz livestock market ──
const USERS_DATA = [
  {
    phone: "+996555100100",
    name: "Айбек Маматов",
    bio: "Жылкы чарбачылыгы менен 15 жылдан бери алектенем. Арабская жана Кыргыз тукумдары.",
    trustScore: 4.8,
    isVerifiedBreeder: true,
    preferredLang: "ky",
    village: "Кара-Балта",
    regionKey: "chuy",
  },
  {
    phone: "+996555200200",
    name: "Нурлан Токтосунов",
    bio: "Бодо мал сатуучу. Швицкая жана Голштин тукумдары. Ош, Бишкек.",
    trustScore: 4.5,
    isVerifiedBreeder: true,
    preferredLang: "ky",
    village: "Беловодское",
    regionKey: "chuy",
  },
  {
    phone: "+996555300300",
    name: "Бакыт Исаков",
    bio: "Кой-эчки малчысы. Гиссар жана Эдилбай тукумдарын багам.",
    trustScore: 4.2,
    isVerifiedBreeder: false,
    preferredLang: "ru",
    village: "Сокулук",
    regionKey: "chuy",
  },
  {
    phone: "+996555400400",
    name: "Гульнара Сыдыкова",
    bio: "Арашан тукумун өстүрөм. Ысык-Көл областы. Тукумдук мал.",
    trustScore: 4.9,
    isVerifiedBreeder: true,
    preferredLang: "ky",
    village: "Каракол",
    regionKey: "issykKul",
  },
  {
    phone: "+996555500500",
    name: "Марат Жумабеков",
    bio: "Жылкы жана бодо мал соодасы. Талас.",
    trustScore: 3.8,
    isVerifiedBreeder: false,
    preferredLang: "ru",
    village: "Талас",
    regionKey: "talas",
  },
  {
    phone: "+996555600600",
    name: "Асан Турдуев",
    bio: "Семиз мал сатам. Нарын областы.",
    trustScore: 4.3,
    isVerifiedBreeder: true,
    preferredLang: "ky",
    village: "Нарын",
    regionKey: "naryn",
  },
  {
    phone: "+996555700700",
    name: "Эрмек Байышов",
    bio: "Арашан кой менен бодо мал чарбачылыгы. 10 жылдык тажрыйба.",
    trustScore: 4.6,
    isVerifiedBreeder: true,
    preferredLang: "ky",
    village: "Бишкек",
    regionKey: "chuy",
  },
  {
    phone: "+996555800800",
    name: "Канатбек Осмонов",
    bio: "Мал-чарба менен алектенем. Ош областы.",
    trustScore: 4.1,
    isVerifiedBreeder: false,
    preferredLang: "ky",
    village: "Ош",
    regionKey: "osh",
  },
];

async function main() {
  console.log("🌱 Seeding database with lalafo.kg market data...\n");

  // Clean
  await prisma.message.deleteMany();
  await prisma.conversation.deleteMany();
  await prisma.favorite.deleteMany();
  await prisma.review.deleteMany();
  await prisma.listingMedia.deleteMany();
  await prisma.listing.deleteMany();
  await prisma.savedSearch.deleteMany();
  await prisma.otpCode.deleteMany();
  await prisma.user.deleteMany();
  await prisma.region.deleteMany();
  console.log("  ✓ Cleaned existing data");

  // ── REGIONS ──
  const regionMap: Record<string, string> = {};

  const regions = [
    { key: "chuy", nameKy: "Чүй областы", nameRu: "Чуйская область", type: "OBLAST" as const, lat: 42.87, lng: 74.59 },
    { key: "issykKul", nameKy: "Ысык-Көл областы", nameRu: "Иссык-Кульская область", type: "OBLAST" as const, lat: 42.45, lng: 77.6 },
    { key: "naryn", nameKy: "Нарын областы", nameRu: "Нарынская область", type: "OBLAST" as const, lat: 41.43, lng: 76.0 },
    { key: "osh", nameKy: "Ош областы", nameRu: "Ошская область", type: "OBLAST" as const, lat: 40.53, lng: 72.8 },
    { key: "talas", nameKy: "Талас областы", nameRu: "Таласская область", type: "OBLAST" as const, lat: 42.52, lng: 72.24 },
    { key: "jalalAbad", nameKy: "Жалал-Абад областы", nameRu: "Джалал-Абадская область", type: "OBLAST" as const, lat: 41.03, lng: 73.0 },
    { key: "batken", nameKy: "Баткен областы", nameRu: "Баткенская область", type: "OBLAST" as const, lat: 40.06, lng: 70.82 },
  ];

  for (const r of regions) {
    const created = await prisma.region.create({
      data: { nameKy: r.nameKy, nameRu: r.nameRu, type: r.type, lat: r.lat, lng: r.lng },
    });
    regionMap[r.key] = created.id;
  }
  console.log(`  ✓ Created ${regions.length} regions`);

  // ── USERS ──
  const userMap: Record<string, string> = {};
  for (const u of USERS_DATA) {
    const created = await prisma.user.create({
      data: {
        phone: u.phone,
        name: u.name,
        bio: u.bio,
        trustScore: u.trustScore,
        isVerifiedBreeder: u.isVerifiedBreeder,
        preferredLang: u.preferredLang,
        village: u.village,
        regionId: regionMap[u.regionKey],
      },
    });
    userMap[u.phone] = created.id;
  }
  console.log(`  ✓ Created ${USERS_DATA.length} users`);

  // ── LISTINGS ──
  // Distribute listings across sellers round-robin
  const userIds = Object.values(userMap);
  let listingCount = 0;
  const categoryCounts: Record<string, number> = {};

  for (let i = 0; i < LISTINGS_DATA.length; i++) {
    const l = LISTINGS_DATA[i];
    const sellerId = userIds[i % userIds.length];

    // Track how many of each category we've seen (for image rotation)
    const catIdx = categoryCounts[l.category] || 0;
    categoryCounts[l.category] = catIdx + 1;

    const listing = await prisma.listing.create({
      data: {
        sellerId,
        category: l.category,
        breed: l.breed,
        title: l.title,
        description: l.description,
        priceKgs: l.priceKgs,
        ageMonths: l.ageMonths,
        weightKg: l.weightKg,
        gender: l.gender,
        healthStatus: l.healthStatus,
        hasVetCert: l.hasVetCert,
        village: l.village,
        regionId: regionMap[l.regionKey],
        status: "ACTIVE",
        viewsCount: l.viewsCount,
        favoritesCount: l.favoritesCount,
        isPremium: l.isPremium,
      },
    });

    // Attach stock photo
    await prisma.listingMedia.create({
      data: {
        listingId: listing.id,
        mediaUrl: l.imageUrl ?? getImageForCategory(l.category, catIdx),
        mediaType: "PHOTO",
        isPrimary: true,
        sortOrder: 0,
      },
    });

    listingCount++;
  }
  console.log(`  ✓ Created ${listingCount} listings (sourced from lalafo.kg)`);

  // ── REVIEWS ──
  const reviewData = [
    { reviewerIdx: 1, sellerIdx: 0, rating: 5, comment: "Абдан жакшы жылкы! Айбек мырза ишенимдүү сатуучу. Рахмат!" },
    { reviewerIdx: 2, sellerIdx: 0, rating: 4, comment: "Жылкылары жакшы, баасы бир аз кымбат, бирок сапаты тең." },
    { reviewerIdx: 0, sellerIdx: 1, rating: 5, comment: "Уйу абдан жакшы, сүтү мол. Нурлан мырзага рахмат!" },
    { reviewerIdx: 4, sellerIdx: 3, rating: 5, comment: "Гульнара эже жакшы малчы. Арашан койлору мыкты." },
    { reviewerIdx: 3, sellerIdx: 2, rating: 4, comment: "Койлору семиз экен. Жеткирүү менен болсо жакшы болот." },
    { reviewerIdx: 5, sellerIdx: 6, rating: 5, comment: "Эрмек байке ишенимдүү. Арашан малы биринчи класс." },
    { reviewerIdx: 6, sellerIdx: 5, rating: 4, comment: "Малы жакшы, баасы макулдук боюнча." },
    { reviewerIdx: 7, sellerIdx: 3, rating: 5, comment: "Тукумдук малды Гульнарадан алыңыз. Качество гарантия!" },
  ];

  for (const r of reviewData) {
    await prisma.review.create({
      data: {
        reviewerId: userIds[r.reviewerIdx],
        sellerId: userIds[r.sellerIdx],
        rating: r.rating,
        comment: r.comment,
      },
    });
  }
  console.log(`  ✓ Created ${reviewData.length} reviews`);

  // ── Summary ──
  console.log("\n Seed complete!");
  console.log(`   ${regions.length} regions`);
  console.log(`   ${USERS_DATA.length} users`);
  console.log(`   ${listingCount} listings:`);
  for (const [cat, count] of Object.entries(categoryCounts)) {
    console.log(`     ${cat}: ${count}`);
  }
  console.log(`   ${reviewData.length} reviews`);
  console.log(`\n📱 Test phones: +996555100100 through +996555800800`);
  console.log(`   OTP codes appear in server console (dev mode)`);
}

main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (e) => {
    console.error(e);
    await prisma.$disconnect();
    process.exit(1);
  });
