/**
 * Demo auctions — live bidding from real bazaars across Kyrgyzstan.
 * Used as a fallback when DB has no auctions yet.
 */

const PHOTO = {
  horseAuction1:
    "https://images.unsplash.com/photo-1553284965-83fd3e82fa5a?w=800&q=85&fit=crop",
  horseKokBoru:
    "https://images.unsplash.com/photo-1534773728080-33d31da27ae5?w=800&q=85&fit=crop",
  horseStallion:
    "https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?w=800&q=85&fit=crop",
  cattleBull:
    "https://images.unsplash.com/photo-1570042225831-d98fa7577f1e?w=800&q=85&fit=crop",
  cattleHerd:
    "https://images.unsplash.com/photo-1500595046743-cd271d694d30?w=800&q=85&fit=crop",
  sheepRam:
    "https://images.unsplash.com/photo-1533318087102-b3ad366ed041?w=800&q=85&fit=crop",
  sheepFlock:
    "https://images.unsplash.com/photo-1484557985045-edf25e08da73?w=800&q=85&fit=crop",
  goatHerd:
    "https://images.unsplash.com/photo-1524024973431-2ad916746881?w=800&q=85&fit=crop",
};

type DemoAuction = {
  id: string;
  category: "HORSE" | "CATTLE" | "SHEEP" | "ARASHAN";
  subcategory: "MEAT" | "KOK_BORU" | null;
  title: string;
  description: string;
  startingPrice: number;
  currentBid: number;
  bidIncrement: number;
  bidCount: number;
  endsAt: string;
  bazaarName: string;
  bazaarLocation: string;
  village: string;
  regionNameKy: string;
  regionNameRu: string;
  sellerName: string;
  sellerPhone: string;
  trustScore: number;
  isVerifiedBreeder: boolean;
  status: "LIVE" | "ENDING_SOON" | "ENDED";
  photo: string;
  viewsCount: number;
  watcherCount: number;
};

const demoAuctions: DemoAuction[] = [
  {
    id: "demo-auction-1",
    category: "HORSE",
    subcategory: "KOK_BORU",
    title: "Көк бөрү жылкысы — чемпион",
    description:
      "Мыкты Көк бөрү жылкысы. Чоң мелдештерге катышкан, 5 жолу жеңген. Жашы 6, дени соо. Ат-Башы базарынан.",
    startingPrice: 800000,
    currentBid: 1450000,
    bidIncrement: 50000,
    bidCount: 23,
    endsAt: new Date(Date.now() + 4 * 60 * 60 * 1000).toISOString(), // 4 hours
    bazaarName: "Ат-Башы мал базары",
    bazaarLocation: "Ат-Башы шаары",
    village: "Ат-Башы",
    regionNameKy: "Нарын",
    regionNameRu: "Нарын",
    sellerName: "Бектур М.",
    sellerPhone: "+996555888777",
    trustScore: 4.9,
    isVerifiedBreeder: true,
    status: "ENDING_SOON",
    photo: PHOTO.horseKokBoru,
    viewsCount: 847,
    watcherCount: 42,
  },
  {
    id: "demo-auction-2",
    category: "CATTLE",
    subcategory: null,
    title: "Ангус бука, тукумдук, 3 жаш",
    description:
      "Таза кан Ангус. Салмагы 720 кг. Эт линиясы эң жогорку. Карта-Курган базарынан.",
    startingPrice: 350000,
    currentBid: 485000,
    bidIncrement: 10000,
    bidCount: 14,
    endsAt: new Date(Date.now() + 18 * 60 * 60 * 1000).toISOString(), // 18 hours
    bazaarName: "Кара-Балта мал базары",
    bazaarLocation: "Кара-Балта",
    village: "Кара-Балта",
    regionNameKy: "Чүй",
    regionNameRu: "Чуй",
    sellerName: "Эркин С.",
    sellerPhone: "+996700123987",
    trustScore: 4.6,
    isVerifiedBreeder: true,
    status: "LIVE",
    photo: PHOTO.cattleBull,
    viewsCount: 412,
    watcherCount: 18,
  },
  {
    id: "demo-auction-3",
    category: "SHEEP",
    subcategory: null,
    title: "Гиссар кочкору — тукум үчүн",
    description:
      "200 кг семиз кочкор. Гиссар тукуму, 3 жаш. Уругу бар. Ош базарынан.",
    startingPrice: 80000,
    currentBid: 145000,
    bidIncrement: 5000,
    bidCount: 19,
    endsAt: new Date(Date.now() + 2 * 60 * 60 * 1000).toISOString(), // 2 hours - ENDING SOON
    bazaarName: "Ош борбордук мал базары",
    bazaarLocation: "Ош шаары",
    village: "Ош",
    regionNameKy: "Ош",
    regionNameRu: "Ош",
    sellerName: "Канатбек Т.",
    sellerPhone: "+996770456789",
    trustScore: 4.5,
    isVerifiedBreeder: false,
    status: "ENDING_SOON",
    photo: PHOTO.sheepRam,
    viewsCount: 567,
    watcherCount: 31,
  },
  {
    id: "demo-auction-4",
    category: "HORSE",
    subcategory: "MEAT",
    title: "Жылкы — эт үчүн, 4 жаш",
    description:
      "Семиз жылкы, 480 кг. Жайлоодо багылган, чучук-казыга мыкты.",
    startingPrice: 180000,
    currentBid: 232000,
    bidIncrement: 5000,
    bidCount: 8,
    endsAt: new Date(Date.now() + 36 * 60 * 60 * 1000).toISOString(),
    bazaarName: "Каракол мал базары",
    bazaarLocation: "Каракол",
    village: "Каракол",
    regionNameKy: "Ысык-Көл",
    regionNameRu: "Иссык-Куль",
    sellerName: "Айбек Ж.",
    sellerPhone: "+996555234567",
    trustScore: 4.4,
    isVerifiedBreeder: false,
    status: "LIVE",
    photo: PHOTO.horseStallion,
    viewsCount: 298,
    watcherCount: 12,
  },
  {
    id: "demo-auction-5",
    category: "SHEEP",
    subcategory: null,
    title: "Кой — 20 баш топ",
    description:
      "20 баш ургаачы кой, 2-3 жаш аралыгында. Орточо салмагы 60 кг. Бардыгы баа боюнча сатылат.",
    startingPrice: 600000,
    currentBid: 780000,
    bidIncrement: 20000,
    bidCount: 11,
    endsAt: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
    bazaarName: "Талас мал базары",
    bazaarLocation: "Талас",
    village: "Талас",
    regionNameKy: "Талас",
    regionNameRu: "Талас",
    sellerName: "Самат К.",
    sellerPhone: "+996770999333",
    trustScore: 4.3,
    isVerifiedBreeder: false,
    status: "LIVE",
    photo: PHOTO.sheepFlock,
    viewsCount: 189,
    watcherCount: 9,
  },
  {
    id: "demo-auction-6",
    category: "CATTLE",
    subcategory: null,
    title: "Сүт уй — Fleckvieh, 4 жаш",
    description:
      "Күнүнө 28 литр сүт берет. Жогорку сапаттагы тукум. Жалал-Абад базарынан.",
    startingPrice: 220000,
    currentBid: 295000,
    bidIncrement: 5000,
    bidCount: 16,
    endsAt: new Date(Date.now() + 12 * 60 * 60 * 1000).toISOString(),
    bazaarName: "Жалал-Абад мал базары",
    bazaarLocation: "Жалал-Абад",
    village: "Жалал-Абад",
    regionNameKy: "Жалал-Абад",
    regionNameRu: "Джалал-Абад",
    sellerName: "Мирлан Б.",
    sellerPhone: "+996700345678",
    trustScore: 4.7,
    isVerifiedBreeder: true,
    status: "LIVE",
    photo: PHOTO.cattleHerd,
    viewsCount: 356,
    watcherCount: 24,
  },
];

function formatDemoAuction(a: DemoAuction) {
  const now = new Date();
  const endsAt = new Date(a.endsAt);
  const minutesLeft = Math.max(
    0,
    Math.floor((endsAt.getTime() - now.getTime()) / (1000 * 60))
  );
  return {
    id: a.id,
    title: a.title,
    description: a.description,
    category: a.category,
    subcategory: a.subcategory,
    startingPrice: a.startingPrice,
    currentBid: a.currentBid,
    bidIncrement: a.bidIncrement,
    bidCount: a.bidCount,
    endsAt: a.endsAt,
    minutesLeft,
    bazaarName: a.bazaarName,
    bazaarLocation: a.bazaarLocation,
    village: a.village,
    status: a.status,
    viewsCount: a.viewsCount,
    watcherCount: a.watcherCount,
    createdAt: new Date(now.getTime() - 24 * 60 * 60 * 1000).toISOString(),
    seller: {
      id: `demo-seller-${a.id}`,
      name: a.sellerName,
      phone: a.sellerPhone,
      avatarUrl: null,
      trustScore: a.trustScore,
      isVerifiedBreeder: a.isVerifiedBreeder,
    },
    region: {
      id: `demo-region-${a.regionNameKy}`,
      nameKy: a.regionNameKy,
      nameRu: a.regionNameRu,
    },
    media: [
      {
        id: `demo-media-${a.id}`,
        mediaUrl: a.photo,
        mediaType: "PHOTO",
        isPrimary: true,
        sortOrder: 0,
      },
    ],
  };
}

interface DemoAuctionFilters {
  category?: string | null;
  status?: string | null;
  sort?: string | null;
  page?: number;
  limit?: number;
}

export function getDemoAuctions(filters: DemoAuctionFilters = {}) {
  let filtered = [...demoAuctions];

  if (filters.category) {
    filtered = filtered.filter((a) => a.category === filters.category);
  }
  if (filters.status) {
    filtered = filtered.filter((a) => a.status === filters.status);
  }

  // Default sort: ending soonest first
  const sort = filters.sort || "ending_soon";
  if (sort === "ending_soon") {
    filtered.sort(
      (a, b) => new Date(a.endsAt).getTime() - new Date(b.endsAt).getTime()
    );
  } else if (sort === "highest_bid") {
    filtered.sort((a, b) => b.currentBid - a.currentBid);
  } else if (sort === "most_bids") {
    filtered.sort((a, b) => b.bidCount - a.bidCount);
  }

  const page = filters.page || 1;
  const limit = filters.limit || 20;
  const start = (page - 1) * limit;
  const paged = filtered.slice(start, start + limit);

  return {
    auctions: paged.map(formatDemoAuction),
    pagination: {
      page,
      limit,
      total: filtered.length,
      totalPages: Math.ceil(filtered.length / limit),
    },
  };
}

export function getDemoAuctionById(id: string) {
  const a = demoAuctions.find((a) => a.id === id);
  if (!a) return null;
  return formatDemoAuction(a);
}
