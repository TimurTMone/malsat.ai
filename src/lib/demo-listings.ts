/**
 * Demo listings served as a fallback when the database is empty or unreachable.
 * Replaced by real DB data once listings exist and migrations are applied.
 *
 * Photos are from Wikimedia Commons (public domain / CC-licensed).
 */

// High-quality real photos from Unsplash (free commercial use, no attribution required)
const PHOTO = {
  // HORSES — variety of breeds, traditional & modern
  horseBlackMountain:
    "https://images.unsplash.com/photo-1553284965-83fd3e82fa5a?w=800&q=85&fit=crop",
  horseNokotaHerd:
    "https://images.unsplash.com/photo-1534773728080-33d31da27ae5?w=800&q=85&fit=crop",
  horseMareFoal:
    "https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?w=800&q=85&fit=crop",
  horseField:
    "https://images.unsplash.com/photo-1518187304541-9bcb7d4d2c0d?w=800&q=85&fit=crop",
  horsePony:
    "https://images.unsplash.com/photo-1598974357801-cbca100e65d3?w=800&q=85&fit=crop",
  // CATTLE — beef & dairy
  cowFleckvieh:
    "https://images.unsplash.com/photo-1546445317-29f4545e9d53?w=800&q=85&fit=crop",
  cowHerd:
    "https://images.unsplash.com/photo-1500595046743-cd271d694d30?w=800&q=85&fit=crop",
  cowAngus:
    "https://images.unsplash.com/photo-1570042225831-d98fa7577f1e?w=800&q=85&fit=crop",
  // SHEEP — flocks & individual rams
  sheepFlock:
    "https://images.unsplash.com/photo-1484557985045-edf25e08da73?w=800&q=85&fit=crop",
  sheepTurkmen:
    "https://images.unsplash.com/photo-1533318087102-b3ad366ed041?w=800&q=85&fit=crop",
  sheepMountain:
    "https://images.unsplash.com/photo-1593179357196-705d7578ff48?w=800&q=85&fit=crop",
  // GOATS
  goat:
    "https://images.unsplash.com/photo-1524024973431-2ad916746881?w=800&q=85&fit=crop",
};

type Demo = {
  id: string;
  category: "HORSE" | "CATTLE" | "SHEEP" | "ARASHAN";
  title: string;
  description: string;
  priceKgs: number;
  breed: string | null;
  ageMonths: number | null;
  weightKg: number | null;
  gender: "MALE" | "FEMALE" | null;
  healthStatus: string | null;
  hasVetCert: boolean;
  village: string | null;
  regionNameKy: string;
  regionNameRu: string;
  sellerName: string;
  isVerifiedBreeder: boolean;
  trustScore: number;
  photo: string;
  viewsCount: number;
  favoritesCount: number;
  hoursAgo: number;
  // Mode B (invest + caretaker raises it) fields — null when not eligible
  modeBEligible?: boolean;
  modeBMinInvestmentKgs?: number;
  modeBExpectedReturnPercent?: number;
  modeBDurationMonths?: number;
  modeBCaretakerName?: string;
};

const DEMOS: Demo[] = [
  {
    id: "demo-1",
    category: "HORSE",
    title: "Кара жылкы, 1.5 жашта, Нарын",
    description:
      "Саламатчылыгы мыкты, жоош, жумушка үйрөтүлгөн. Нарындын жайлоосунда өскөн. Ветеринардык күбөлүгү бар.",
    priceKgs: 160000,
    breed: "Жергиликтүү тукум",
    ageMonths: 18,
    weightKg: 280,
    gender: "MALE",
    healthStatus: "Соо",
    hasVetCert: true,
    village: "Ат-Башы",
    regionNameKy: "Нарын",
    regionNameRu: "Нарынская",
    sellerName: "Асылбек",
    isVerifiedBreeder: true,
    trustScore: 4.8,
    photo: PHOTO.horseBlackMountain,
    viewsCount: 247,
    favoritesCount: 18,
    hoursAgo: 3,
    modeBEligible: true,
    modeBMinInvestmentKgs: 40000,
    modeBExpectedReturnPercent: 18,
    modeBDurationMonths: 6,
    modeBCaretakerName: "Асылбек Жолдошев",
  },
  {
    id: "demo-2",
    category: "SHEEP",
    title: "Арашан кочкор, тукумдук, 2 жашта",
    description:
      "Салмагы 180 кг. Эт-май линиясы жакшы. Энеси да ушул чарбадан. Эң мыкты кочкорлордун бири.",
    priceKgs: 85000,
    breed: "Арашан",
    ageMonths: 24,
    weightKg: 180,
    gender: "MALE",
    healthStatus: "Соо",
    hasVetCert: true,
    village: "Ак-Суу",
    regionNameKy: "Ысык-Көл",
    regionNameRu: "Иссык-Кульская",
    sellerName: "Нурлан",
    isVerifiedBreeder: true,
    trustScore: 4.9,
    photo: PHOTO.sheepTurkmen,
    viewsCount: 312,
    favoritesCount: 28,
    hoursAgo: 2,
    modeBEligible: true,
    modeBMinInvestmentKgs: 20000,
    modeBExpectedReturnPercent: 22,
    modeBDurationMonths: 3,
    modeBCaretakerName: "Нурлан Осмонов",
  },
  {
    id: "demo-3",
    category: "CATTLE",
    title: "Алатоо сүт уй, 3 баш",
    description:
      "Күнүнө 18-22 литр сүт берет. Жашы 3-4. Эмчектери дурус, ооруга чалдыкпаган. Баасы 3 башка.",
    priceKgs: 250000,
    breed: "Алатоо",
    ageMonths: 36,
    weightKg: 500,
    gender: "FEMALE",
    healthStatus: "Соо",
    hasVetCert: true,
    village: "Кара-Балта",
    regionNameKy: "Чүй",
    regionNameRu: "Чуйская",
    sellerName: "Эркин",
    isVerifiedBreeder: false,
    trustScore: 4.5,
    photo: PHOTO.cowHerd,
    viewsCount: 156,
    favoritesCount: 12,
    hoursAgo: 24,
  },
  {
    id: "demo-4",
    category: "HORSE",
    title: "Жарыш жылкы, англис тукуму, 4 жаш",
    description:
      "Чон жарыштарга катышкан. Ат мектебинде үйрөтүлгөн. Документтери толук. Шолпон-Атада турат.",
    priceKgs: 450000,
    breed: "Англис тукуму",
    ageMonths: 48,
    weightKg: 480,
    gender: "MALE",
    healthStatus: "Соо",
    hasVetCert: true,
    village: "Чолпон-Ата",
    regionNameKy: "Ысык-Көл",
    regionNameRu: "Иссык-Кульская",
    sellerName: "Чынгыз",
    isVerifiedBreeder: true,
    trustScore: 5.0,
    photo: PHOTO.horsePony,
    viewsCount: 512,
    favoritesCount: 47,
    hoursAgo: 8,
    modeBEligible: true,
    modeBMinInvestmentKgs: 90000,
    modeBExpectedReturnPercent: 15,
    modeBDurationMonths: 8,
    modeBCaretakerName: "Эркин Мамбетов",
  },
  {
    id: "demo-5",
    category: "SHEEP",
    title: "Семиз кой, 10 баш, Нарын",
    description:
      "Жайлоодо өскөн, курман айтка даяр. Ар бири 65-75 кг. Бир башы 45 000 сом.",
    priceKgs: 450000,
    breed: null,
    ageMonths: 18,
    weightKg: 70,
    gender: null,
    healthStatus: "Соо",
    hasVetCert: false,
    village: "Нарын шаары",
    regionNameKy: "Нарын",
    regionNameRu: "Нарынская",
    sellerName: "Данияр",
    isVerifiedBreeder: false,
    trustScore: 4.3,
    photo: PHOTO.sheepFlock,
    viewsCount: 89,
    favoritesCount: 6,
    hoursAgo: 48,
    modeBEligible: true,
    modeBMinInvestmentKgs: 45000,
    modeBExpectedReturnPercent: 25,
    modeBDurationMonths: 2,
    modeBCaretakerName: "Самат Абдыев",
  },
  {
    id: "demo-6",
    category: "CATTLE",
    title: "Ангус бука, тукумдук, 2 жаш",
    description:
      "Эт тукуму, таза канныгы. Салмагы 650 кг. Чыйырчыкта турат, көрүп баа берсеңиз болот.",
    priceKgs: 380000,
    breed: "Aberdeen Angus",
    ageMonths: 24,
    weightKg: 650,
    gender: "MALE",
    healthStatus: "Соо",
    hasVetCert: true,
    village: "Токмок",
    regionNameKy: "Чүй",
    regionNameRu: "Чуйская",
    sellerName: "Азамат",
    isVerifiedBreeder: true,
    trustScore: 4.7,
    photo: PHOTO.cowAngus,
    viewsCount: 203,
    favoritesCount: 22,
    hoursAgo: 5,
    modeBEligible: true,
    modeBMinInvestmentKgs: 95000,
    modeBExpectedReturnPercent: 20,
    modeBDurationMonths: 6,
    modeBCaretakerName: "Эркин Мамбетов",
  },
  {
    id: "demo-7",
    category: "HORSE",
    title: "Жумушчу жылкы, 5 жаш, Чүй",
    description:
      "Күчтүү, арабага үйрөнгөн. Жумушка жарайт. Документтери бар. Токмокто.",
    priceKgs: 120000,
    breed: null,
    ageMonths: 60,
    weightKg: 450,
    gender: "MALE",
    healthStatus: "Соо",
    hasVetCert: false,
    village: "Токмок",
    regionNameKy: "Чүй",
    regionNameRu: "Чуйская",
    sellerName: "Бакыт",
    isVerifiedBreeder: false,
    trustScore: 4.2,
    photo: PHOTO.horseField,
    viewsCount: 134,
    favoritesCount: 9,
    hoursAgo: 6,
  },
  {
    id: "demo-8",
    category: "ARASHAN",
    title: "Эчки, сүт бериши мыкты, 2 жаш",
    description:
      "Күнүнө 3 литр сүт берет. Эч оорбогон. Ошто турат.",
    priceKgs: 18000,
    breed: null,
    ageMonths: 24,
    weightKg: 45,
    gender: "FEMALE",
    healthStatus: "Соо",
    hasVetCert: false,
    village: "Ош",
    regionNameKy: "Ош",
    regionNameRu: "Ош",
    sellerName: "Мирлан",
    isVerifiedBreeder: false,
    trustScore: 4.1,
    photo: PHOTO.goat,
    viewsCount: 67,
    favoritesCount: 4,
    hoursAgo: 12,
    modeBEligible: true,
    modeBMinInvestmentKgs: 9000,
    modeBExpectedReturnPercent: 30,
    modeBDurationMonths: 4,
    modeBCaretakerName: "Мирлан Керимов",
  },
  {
    id: "demo-9",
    category: "HORSE",
    title: "Жылкы бээ, тукумдуу, 6 жаш",
    description:
      "Таза каны, 3 кулун тапкан. Жашы 6, дени соо. Нарындын жайлоосунан.",
    priceKgs: 220000,
    breed: null,
    ageMonths: 72,
    weightKg: 420,
    gender: "FEMALE",
    healthStatus: "Соо",
    hasVetCert: true,
    village: "Нарын",
    regionNameKy: "Нарын",
    regionNameRu: "Нарынская",
    sellerName: "Айбек",
    isVerifiedBreeder: true,
    trustScore: 4.6,
    photo: PHOTO.horseMareFoal,
    viewsCount: 189,
    favoritesCount: 15,
    hoursAgo: 16,
    modeBEligible: true,
    modeBMinInvestmentKgs: 55000,
    modeBExpectedReturnPercent: 16,
    modeBDurationMonths: 8,
    modeBCaretakerName: "Асылбек Жолдошев",
  },
  {
    id: "demo-10",
    category: "CATTLE",
    title: "Fleckvieh уй, сүт-эт тукуму",
    description:
      "Күнүнө 25 литр сүт берет. Тоо жайлоосунда өскөн. Таза канныгы.",
    priceKgs: 195000,
    breed: "Fleckvieh",
    ageMonths: 42,
    weightKg: 580,
    gender: "FEMALE",
    healthStatus: "Соо",
    hasVetCert: true,
    village: "Ак-Талаа",
    regionNameKy: "Нарын",
    regionNameRu: "Нарынская",
    sellerName: "Мелис",
    isVerifiedBreeder: true,
    trustScore: 4.9,
    photo: PHOTO.cowFleckvieh,
    viewsCount: 178,
    favoritesCount: 19,
    hoursAgo: 20,
    modeBEligible: true,
    modeBMinInvestmentKgs: 50000,
    modeBExpectedReturnPercent: 14,
    modeBDurationMonths: 12,
    modeBCaretakerName: "Мелис Токтогулов",
  },
  {
    id: "demo-11",
    category: "SHEEP",
    title: "Тоо кою, 5 баш, жайлоодон",
    description:
      "Бардыгы ургаачы, 2-3 жаш. Куюшкаракта.",
    priceKgs: 175000,
    breed: null,
    ageMonths: 30,
    weightKg: 55,
    gender: "FEMALE",
    healthStatus: "Соо",
    hasVetCert: false,
    village: "Кочкор",
    regionNameKy: "Нарын",
    regionNameRu: "Нарынская",
    sellerName: "Самат",
    isVerifiedBreeder: false,
    trustScore: 4.4,
    photo: PHOTO.sheepMountain,
    viewsCount: 92,
    favoritesCount: 7,
    hoursAgo: 30,
    modeBEligible: true,
    modeBMinInvestmentKgs: 40000,
    modeBExpectedReturnPercent: 18,
    modeBDurationMonths: 5,
    modeBCaretakerName: "Самат Абдыев",
  },
  {
    id: "demo-12",
    category: "HORSE",
    title: "Жылкы, таза сулуу, 3 жаш",
    description:
      "Сулуу чуу, жылкы кимге баа берсе берет. Иссык-Көлдүн жагасында.",
    priceKgs: 180000,
    breed: null,
    ageMonths: 36,
    weightKg: 400,
    gender: "MALE",
    healthStatus: "Соо",
    hasVetCert: false,
    village: "Каракол",
    regionNameKy: "Ысык-Көл",
    regionNameRu: "Иссык-Кульская",
    sellerName: "Талгат",
    isVerifiedBreeder: false,
    trustScore: 4.5,
    photo: PHOTO.horseNokotaHerd,
    viewsCount: 143,
    favoritesCount: 11,
    hoursAgo: 10,
    modeBEligible: true,
    modeBMinInvestmentKgs: 60000,
    modeBExpectedReturnPercent: 17,
    modeBDurationMonths: 7,
    modeBCaretakerName: "Талгат Сулайманов",
  },
];

export function getDemoListings(opts?: {
  category?: string | null;
  minPrice?: string | null;
  maxPrice?: string | null;
  sort?: string | null;
  page?: number;
  limit?: number;
}) {
  let filtered = [...DEMOS];

  if (opts?.category) {
    filtered = filtered.filter((d) => d.category === opts.category);
  }
  if (opts?.minPrice) {
    const min = parseInt(opts.minPrice);
    filtered = filtered.filter((d) => d.priceKgs >= min);
  }
  if (opts?.maxPrice) {
    const max = parseInt(opts.maxPrice);
    filtered = filtered.filter((d) => d.priceKgs <= max);
  }
  if (opts?.sort === "price_asc") {
    filtered.sort((a, b) => a.priceKgs - b.priceKgs);
  } else if (opts?.sort === "price_desc") {
    filtered.sort((a, b) => b.priceKgs - a.priceKgs);
  } else {
    filtered.sort((a, b) => a.hoursAgo - b.hoursAgo);
  }

  const page = opts?.page || 1;
  const limit = opts?.limit || 20;
  const start = (page - 1) * limit;
  const pageItems = filtered.slice(start, start + limit);

  const now = Date.now();
  return {
    listings: pageItems.map((d) => ({
      id: d.id,
      sellerId: `demo-seller-${d.id}`,
      category: d.category,
      subcategory: null,
      breed: d.breed,
      title: d.title,
      description: d.description,
      priceKgs: d.priceKgs,
      ageMonths: d.ageMonths,
      weightKg: d.weightKg,
      gender: d.gender,
      healthStatus: d.healthStatus,
      hasVetCert: d.hasVetCert,
      locationLat: null,
      locationLng: null,
      regionId: null,
      village: d.village,
      status: "ACTIVE",
      viewsCount: d.viewsCount,
      favoritesCount: d.favoritesCount,
      isPremium: d.isVerifiedBreeder,
      createdAt: new Date(now - d.hoursAgo * 3600000).toISOString(),
      updatedAt: new Date(now - d.hoursAgo * 3600000).toISOString(),
      expiresAt: new Date(now + 30 * 24 * 3600000).toISOString(),
      media: [
        {
          id: `demo-media-${d.id}`,
          listingId: d.id,
          mediaUrl: d.photo,
          mediaType: "PHOTO",
          isPrimary: true,
          sortOrder: 0,
          createdAt: new Date(now - d.hoursAgo * 3600000).toISOString(),
        },
      ],
      seller: {
        id: `demo-seller-${d.id}`,
        name: d.sellerName,
        avatarUrl: null,
        phone: "+996 555 000 000",
        trustScore: d.trustScore,
        isVerifiedBreeder: d.isVerifiedBreeder,
      },
      region: {
        id: `demo-region-${d.regionNameKy}`,
        nameKy: d.regionNameKy,
        nameRu: d.regionNameRu,
      },
      modeBEligible: d.modeBEligible ?? false,
      modeBMinInvestmentKgs: d.modeBMinInvestmentKgs ?? null,
      modeBExpectedReturnPercent: d.modeBExpectedReturnPercent ?? null,
      modeBDurationMonths: d.modeBDurationMonths ?? null,
      modeBCaretakerName: d.modeBCaretakerName ?? null,
    })),
    pagination: {
      page,
      limit,
      total: filtered.length,
      totalPages: Math.ceil(filtered.length / limit),
    },
  };
}
