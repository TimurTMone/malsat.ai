/**
 * Demo butcher drops served as a fallback when the database is empty or unreachable.
 * Replaced by real DB data once drops exist and migrations are applied.
 */

const PHOTO = {
  lambFresh:
    "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Flock_of_sheep.jpg/800px-Flock_of_sheep.jpg",
  beefCow:
    "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8c/Cow_%28Fleckvieh_breed%29_Oeschinensee_Slaunger_2009-07-07.jpg/800px-Cow_%28Fleckvieh_breed%29_Oeschinensee_Slaunger_2009-07-07.jpg",
  beefAngus:
    "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b7/Aberdeen_Angus_im_Gadental_2.JPG/800px-Aberdeen_Angus_im_Gadental_2.JPG",
  horseMeat:
    "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a2/Biandintz_eta_zaldiak_-_modified2.jpg/1200px-Biandintz_eta_zaldiak_-_modified2.jpg",
  horseNokota:
    "https://upload.wikimedia.org/wikipedia/commons/thumb/d/de/Nokota_Horses_cropped.jpg/800px-Nokota_Horses_cropped.jpg",
  sheepMountain:
    "https://upload.wikimedia.org/wikipedia/commons/thumb/4/44/A_curious_Welsh_Mountain_sheep_%28Ovis_aries%29.jpg/800px-A_curious_Welsh_Mountain_sheep_%28Ovis_aries%29.jpg",
  sheepTurkmen:
    "https://upload.wikimedia.org/wikipedia/commons/thumb/b/bf/Turkmen_sheep.jpg/800px-Turkmen_sheep.jpg",
  goat:
    "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b2/Hausziege_04.jpg/800px-Hausziege_04.jpg",
};

type DemoDrop = {
  id: string;
  category: "HORSE" | "CATTLE" | "SHEEP" | "ARASHAN";
  title: string;
  description: string;
  breed: string | null;
  totalWeightKg: number;
  remainingWeightKg: number;
  pricePerKg: number;
  minOrderKg: number;
  maxOrderKg: number | null;
  portionPresets: number[];
  butcherDate: string;
  pickupAddress: string;
  village: string | null;
  regionNameKy: string;
  regionNameRu: string;
  sellerName: string;
  sellerPhone: string;
  trustScore: number;
  isVerifiedBreeder: boolean;
  status: "UPCOMING" | "OPEN" | "SOLD_OUT" | "FULFILLED";
  photo: string;
  viewsCount: number;
  orderCount: number;
};

const demoDrops: DemoDrop[] = [
  {
    id: "demo-drop-1",
    category: "SHEEP",
    title: "Жаңы союлган козу эти — Ысык-Көл",
    description:
      "Тоолук козу, 8 айлык, жашыл чөп менен багылган. Союу 12-апрелде. Жумшак, таза эт.",
    breed: "Кыргыз тоолук",
    totalWeightKg: 35,
    remainingWeightKg: 15,
    pricePerKg: 650,
    minOrderKg: 3,
    maxOrderKg: 15,
    portionPresets: [5, 10, 15],
    butcherDate: new Date(Date.now() + 6 * 24 * 60 * 60 * 1000).toISOString(),
    pickupAddress: "Каракол шаарынын чоң базары",
    village: "Каракол",
    regionNameKy: "Ысык-Көл",
    regionNameRu: "Иссык-Куль",
    sellerName: "Азамат Б.",
    sellerPhone: "+996555123456",
    trustScore: 4.7,
    isVerifiedBreeder: true,
    status: "OPEN",
    photo: PHOTO.lambFresh,
    viewsCount: 89,
    orderCount: 4,
  },
  {
    id: "demo-drop-2",
    category: "CATTLE",
    title: "Уй эти — Чүй өрөөнү",
    description:
      "2 жашар бука, 280 кг тирүү салмак. Таза жайыт, ветеринардык текшерүү өтүлгөн.",
    breed: "Алатоо",
    totalWeightKg: 140,
    remainingWeightKg: 80,
    pricePerKg: 580,
    minOrderKg: 5,
    maxOrderKg: 30,
    portionPresets: [5, 10, 15, 20],
    butcherDate: new Date(Date.now() + 3 * 24 * 60 * 60 * 1000).toISOString(),
    pickupAddress: "Токмок, Борбордук базар",
    village: "Токмок",
    regionNameKy: "Чүй",
    regionNameRu: "Чуй",
    sellerName: "Бакыт К.",
    sellerPhone: "+996700654321",
    trustScore: 4.2,
    isVerifiedBreeder: false,
    status: "OPEN",
    photo: PHOTO.beefCow,
    viewsCount: 142,
    orderCount: 6,
  },
  {
    id: "demo-drop-3",
    category: "HORSE",
    title: "Казы / Карта — Нарын",
    description:
      "Жылкы эти. Казы, карта, жал даярдалат. Кыргыздын салттуу тамактары үчүн.",
    breed: "Кыргыз жылкысы",
    totalWeightKg: 60,
    remainingWeightKg: 60,
    pricePerKg: 900,
    minOrderKg: 3,
    maxOrderKg: 20,
    portionPresets: [5, 10, 15],
    butcherDate: new Date(Date.now() + 10 * 24 * 60 * 60 * 1000).toISOString(),
    pickupAddress: "Нарын шаары, мал базар жаны",
    village: "Нарын",
    regionNameKy: "Нарын",
    regionNameRu: "Нарын",
    sellerName: "Нурбек Т.",
    sellerPhone: "+996770111222",
    trustScore: 4.9,
    isVerifiedBreeder: true,
    status: "UPCOMING",
    photo: PHOTO.horseMeat,
    viewsCount: 56,
    orderCount: 0,
  },
  {
    id: "demo-drop-4",
    category: "SHEEP",
    title: "Кой эти — Ош",
    description:
      "Жайлоодо багылган семиз кой. Бүт кой же бөлүп сатылат. Таза, экологиялык.",
    breed: "Гиссар",
    totalWeightKg: 42,
    remainingWeightKg: 0,
    pricePerKg: 620,
    minOrderKg: 5,
    maxOrderKg: null,
    portionPresets: [5, 10, 15],
    butcherDate: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000).toISOString(),
    pickupAddress: "Ош шаарынын борбордук базары",
    village: "Ош",
    regionNameKy: "Ош",
    regionNameRu: "Ош",
    sellerName: "Жаныбек А.",
    sellerPhone: "+996550333444",
    trustScore: 3.8,
    isVerifiedBreeder: false,
    status: "SOLD_OUT",
    photo: PHOTO.sheepMountain,
    viewsCount: 210,
    orderCount: 8,
  },
  {
    id: "demo-drop-5",
    category: "ARASHAN",
    title: "Эчки эти — Талас",
    description:
      "Аарашан текеси, 1.5 жашта, 45 кг. Диеталык эт, табигый жайытта багылган.",
    breed: "Аарашан",
    totalWeightKg: 22,
    remainingWeightKg: 12,
    pricePerKg: 700,
    minOrderKg: 3,
    maxOrderKg: 10,
    portionPresets: [3, 5, 10],
    butcherDate: new Date(Date.now() + 5 * 24 * 60 * 60 * 1000).toISOString(),
    pickupAddress: "Талас, ата-тоо базары",
    village: "Талас",
    regionNameKy: "Талас",
    regionNameRu: "Талас",
    sellerName: "Эрлан М.",
    sellerPhone: "+996709555666",
    trustScore: 4.5,
    isVerifiedBreeder: true,
    status: "OPEN",
    photo: PHOTO.goat,
    viewsCount: 67,
    orderCount: 2,
  },
  // ── Extra beef drops ──
  {
    id: "demo-drop-6",
    category: "CATTLE",
    title: "Ангус уй эти — Нарын",
    description:
      "Ангус тукуму бука, 2.5 жашта, 320 кг тирүү салмак. Тоолук жайытта багылган, эт сапаты эң жогору.",
    breed: "Aberdeen Angus",
    totalWeightKg: 160,
    remainingWeightKg: 110,
    pricePerKg: 620,
    minOrderKg: 5,
    maxOrderKg: 40,
    portionPresets: [5, 10, 20, 30],
    butcherDate: new Date(Date.now() + 4 * 24 * 60 * 60 * 1000).toISOString(),
    pickupAddress: "Нарын, борбордук базар",
    village: "Нарын",
    regionNameKy: "Нарын",
    regionNameRu: "Нарын",
    sellerName: "Кубат Ж.",
    sellerPhone: "+996555777888",
    trustScore: 4.8,
    isVerifiedBreeder: true,
    status: "OPEN",
    photo: PHOTO.beefAngus,
    viewsCount: 178,
    orderCount: 3,
  },
  // ── Extra horse meat drops ──
  {
    id: "demo-drop-7",
    category: "HORSE",
    title: "Жылкы эти — Ысык-Көл",
    description:
      "Кыргыз жылкысы, 4 жашта. Чучук, казы, жал, карта — бардыгы бар. Жайлоодо багылган.",
    breed: "Кыргыз жылкысы",
    totalWeightKg: 80,
    remainingWeightKg: 55,
    pricePerKg: 850,
    minOrderKg: 3,
    maxOrderKg: 25,
    portionPresets: [5, 10, 15, 20],
    butcherDate: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString(),
    pickupAddress: "Каракол, мал базар",
    village: "Каракол",
    regionNameKy: "Ысык-Көл",
    regionNameRu: "Иссык-Куль",
    sellerName: "Айдар Т.",
    sellerPhone: "+996770222333",
    trustScore: 4.6,
    isVerifiedBreeder: true,
    status: "OPEN",
    photo: PHOTO.horseNokota,
    viewsCount: 94,
    orderCount: 2,
  },
  // ── Extra sheep meat drop ──
  {
    id: "demo-drop-8",
    category: "SHEEP",
    title: "Арашан кой эти — Чүй",
    description:
      "Арашан тукуму семиз кой, 1.5 жашта. Майлуу, жумшак эт. Курман айтка же тойго ылайыктуу.",
    breed: "Арашан",
    totalWeightKg: 50,
    remainingWeightKg: 35,
    pricePerKg: 680,
    minOrderKg: 5,
    maxOrderKg: 25,
    portionPresets: [5, 10, 15, 25],
    butcherDate: new Date(Date.now() + 2 * 24 * 60 * 60 * 1000).toISOString(),
    pickupAddress: "Бишкек, Ош базар жаны",
    village: "Бишкек",
    regionNameKy: "Чүй",
    regionNameRu: "Чуй",
    sellerName: "Марат С.",
    sellerPhone: "+996500444555",
    trustScore: 4.4,
    isVerifiedBreeder: false,
    status: "OPEN",
    photo: PHOTO.sheepTurkmen,
    viewsCount: 132,
    orderCount: 5,
  },
];

function formatDemoDrop(d: DemoDrop) {
  const now = new Date();
  return {
    id: d.id,
    title: d.title,
    description: d.description,
    category: d.category,
    breed: d.breed,
    totalWeightKg: d.totalWeightKg,
    remainingWeightKg: d.remainingWeightKg,
    pricePerKg: d.pricePerKg,
    minOrderKg: d.minOrderKg,
    maxOrderKg: d.maxOrderKg,
    portionPresets: d.portionPresets,
    butcherDate: d.butcherDate,
    pickupAddress: d.pickupAddress,
    village: d.village,
    status: d.status,
    viewsCount: d.viewsCount,
    orderCount: d.orderCount,
    claimedWeightKg: d.totalWeightKg - d.remainingWeightKg,
    progressPercent: Math.round(
      ((d.totalWeightKg - d.remainingWeightKg) / d.totalWeightKg) * 100
    ),
    createdAt: new Date(now.getTime() - 2 * 24 * 60 * 60 * 1000).toISOString(),
    seller: {
      id: `demo-seller-${d.id}`,
      name: d.sellerName,
      phone: d.sellerPhone,
      avatarUrl: null,
      trustScore: d.trustScore,
      isVerifiedBreeder: d.isVerifiedBreeder,
    },
    region: {
      id: `demo-region-${d.regionNameKy}`,
      nameKy: d.regionNameKy,
      nameRu: d.regionNameRu,
    },
    media: [
      {
        id: `demo-media-${d.id}`,
        mediaUrl: d.photo,
        mediaType: "PHOTO",
        isPrimary: true,
        sortOrder: 0,
      },
    ],
  };
}

interface DemoDropFilters {
  category?: string | null;
  status?: string | null;
  sort?: string | null;
  page?: number;
  limit?: number;
}

export function getDemoDrops(filters: DemoDropFilters = {}) {
  let filtered = [...demoDrops];

  if (filters.category) {
    filtered = filtered.filter((d) => d.category === filters.category);
  }
  if (filters.status) {
    filtered = filtered.filter((d) => d.status === filters.status);
  }

  // Default sort: open first, then by butcher date ascending
  const sort = filters.sort || "soonest";
  if (sort === "soonest") {
    filtered.sort(
      (a, b) =>
        new Date(a.butcherDate).getTime() - new Date(b.butcherDate).getTime()
    );
  } else if (sort === "price_asc") {
    filtered.sort((a, b) => a.pricePerKg - b.pricePerKg);
  } else if (sort === "price_desc") {
    filtered.sort((a, b) => b.pricePerKg - a.pricePerKg);
  } else if (sort === "newest") {
    filtered.reverse();
  }

  const page = filters.page || 1;
  const limit = filters.limit || 20;
  const start = (page - 1) * limit;
  const paged = filtered.slice(start, start + limit);

  return {
    drops: paged.map(formatDemoDrop),
    pagination: {
      page,
      limit,
      total: filtered.length,
      totalPages: Math.ceil(filtered.length / limit),
    },
  };
}

export function getDemoDropById(id: string) {
  const d = demoDrops.find((d) => d.id === id);
  if (!d) return null;
  return formatDemoDrop(d);
}
