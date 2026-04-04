/**
 * Demo data for MalSat Herd — the livestock CRM + tokenization layer.
 *
 * User story: buy an animal → hire a caretaker → at season end, butcher OR sell for profit.
 * Every animal gets a unique QR-backed ownership certificate (the "token").
 */

const PHOTO = {
  horse1: "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a2/Biandintz_eta_zaldiak_-_modified2.jpg/600px-Biandintz_eta_zaldiak_-_modified2.jpg",
  horse2: "https://upload.wikimedia.org/wikipedia/commons/thumb/d/de/Nokota_Horses_cropped.jpg/600px-Nokota_Horses_cropped.jpg",
  horse3: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4c/Mare_foal_poland.jpg/600px-Mare_foal_poland.jpg",
  sheep1: "https://upload.wikimedia.org/wikipedia/commons/thumb/b/bf/Turkmen_sheep.jpg/600px-Turkmen_sheep.jpg",
  sheep2: "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Flock_of_sheep.jpg/600px-Flock_of_sheep.jpg",
  sheep3: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/44/A_curious_Welsh_Mountain_sheep_%28Ovis_aries%29.jpg/600px-A_curious_Welsh_Mountain_sheep_%28Ovis_aries%29.jpg",
  cow1: "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8c/Cow_%28Fleckvieh_breed%29_Oeschinensee_Slaunger_2009-07-07.jpg/600px-Cow_%28Fleckvieh_breed%29_Oeschinensee_Slaunger_2009-07-07.jpg",
  cow2: "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b7/Aberdeen_Angus_im_Gadental_2.JPG/600px-Aberdeen_Angus_im_Gadental_2.JPG",
  caretaker1: "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a2/Biandintz_eta_zaldiak_-_modified2.jpg/300px-Biandintz_eta_zaldiak_-_modified2.jpg",
};

export type OwnedAnimal = {
  id: string;
  tokenId: string; // QR-encodable unique ID
  name: string;
  category: "HORSE" | "CATTLE" | "SHEEP" | "ARASHAN";
  breed: string;
  photo: string;
  purchasedAt: string;
  purchasePriceKgs: number;
  currentValueKgs: number;
  ageMonths: number;
  weightKg: number;
  gender: "MALE" | "FEMALE";
  status: "WITH_CARETAKER" | "AT_OWNER" | "READY_TO_SELL" | "SOLD" | "BUTCHERED";
  caretakerId: string | null;
  caretakerName: string | null;
  locationVillage: string;
  locationRegion: string;
  healthScore: number; // 0-100
  weightGainKg: number; // since purchase
  vetVisits: number;
  nextMilestone: string; // ky text
  seasonEndAt: string; // ISO
  loyaltyPoints: number;
};

export type Caretaker = {
  id: string;
  name: string;
  photo: string | null;
  village: string;
  region: string;
  yearsExperience: number;
  animalsUnderCare: number;
  rating: number; // 0-5
  reviewCount: number;
  monthlyFeeKgs: number; // per animal
  speciality: ("HORSE" | "CATTLE" | "SHEEP" | "ARASHAN")[];
  hasPastures: boolean;
  isVerified: boolean;
  bio: string;
};

const now = Date.now();

export const DEMO_OWNED_ANIMALS: OwnedAnimal[] = [
  {
    id: "own-1",
    tokenId: "MLSAT-KG-0001-A7F9",
    name: "Каратай",
    category: "HORSE",
    breed: "Жергиликтүү тукум",
    photo: PHOTO.horse1,
    purchasedAt: new Date(now - 90 * 86400000).toISOString(),
    purchasePriceKgs: 160000,
    currentValueKgs: 182000,
    ageMonths: 21,
    weightKg: 295,
    gender: "MALE",
    status: "WITH_CARETAKER",
    caretakerId: "caretaker-1",
    caretakerName: "Асылбек Жолдошев",
    locationVillage: "Ат-Башы",
    locationRegion: "Нарын",
    healthScore: 94,
    weightGainKg: 15,
    vetVisits: 2,
    nextMilestone: "Сентябрда сатылат",
    seasonEndAt: new Date(now + 180 * 86400000).toISOString(),
    loyaltyPoints: 180,
  },
  {
    id: "own-2",
    tokenId: "MLSAT-KG-0002-B3C1",
    name: "Ак-Кочкор",
    category: "SHEEP",
    breed: "Арашан",
    photo: PHOTO.sheep1,
    purchasedAt: new Date(now - 45 * 86400000).toISOString(),
    purchasePriceKgs: 85000,
    currentValueKgs: 98000,
    ageMonths: 25,
    weightKg: 192,
    gender: "MALE",
    status: "WITH_CARETAKER",
    caretakerId: "caretaker-2",
    caretakerName: "Нурлан Осмонов",
    locationVillage: "Ак-Суу",
    locationRegion: "Ысык-Көл",
    healthScore: 97,
    weightGainKg: 12,
    vetVisits: 1,
    nextMilestone: "Курман айтка даяр",
    seasonEndAt: new Date(now + 60 * 86400000).toISOString(),
    loyaltyPoints: 95,
  },
  {
    id: "own-3",
    tokenId: "MLSAT-KG-0003-D8E2",
    name: "Сүтчи",
    category: "CATTLE",
    breed: "Алатоо",
    photo: PHOTO.cow1,
    purchasedAt: new Date(now - 120 * 86400000).toISOString(),
    purchasePriceKgs: 220000,
    currentValueKgs: 245000,
    ageMonths: 40,
    weightKg: 525,
    gender: "FEMALE",
    status: "AT_OWNER",
    caretakerId: null,
    caretakerName: null,
    locationVillage: "Кара-Балта",
    locationRegion: "Чүй",
    healthScore: 91,
    weightGainKg: 25,
    vetVisits: 3,
    nextMilestone: "Сүт береет — күнүнө 20л",
    seasonEndAt: new Date(now + 365 * 86400000).toISOString(),
    loyaltyPoints: 240,
  },
];

export const DEMO_CARETAKERS: Caretaker[] = [
  {
    id: "caretaker-1",
    name: "Асылбек Жолдошев",
    photo: null,
    village: "Ат-Башы",
    region: "Нарын",
    yearsExperience: 15,
    animalsUnderCare: 24,
    rating: 4.9,
    reviewCount: 47,
    monthlyFeeKgs: 4500,
    speciality: ["HORSE", "SHEEP"],
    hasPastures: true,
    isVerified: true,
    bio: "15 жылдык тажрыйбалуу жылкычы. Ата-Башыдагы жайлоолорду билем. Жылкы жана койлорго карайм. 24/7 видео-отчёт берем.",
  },
  {
    id: "caretaker-2",
    name: "Нурлан Осмонов",
    photo: null,
    village: "Ак-Суу",
    region: "Ысык-Көл",
    yearsExperience: 8,
    animalsUnderCare: 45,
    rating: 4.8,
    reviewCount: 31,
    monthlyFeeKgs: 3000,
    speciality: ["SHEEP", "ARASHAN"],
    hasPastures: true,
    isVerified: true,
    bio: "Арашан тукумдуу койлорго адис. Ветеринардык билимим бар. Ысык-Көлдүн жайлоолорунда.",
  },
  {
    id: "caretaker-3",
    name: "Эркин Мамбетов",
    photo: null,
    village: "Токмок",
    region: "Чүй",
    yearsExperience: 22,
    animalsUnderCare: 18,
    rating: 5.0,
    reviewCount: 63,
    monthlyFeeKgs: 6000,
    speciality: ["CATTLE", "HORSE"],
    hasPastures: true,
    isVerified: true,
    bio: "22 жылдык тажрыйба. Сүт уйларга арналган ферма. Күнүнө 2 ирет сүт саам, видеого түшүрөм.",
  },
  {
    id: "caretaker-4",
    name: "Самат Абдыев",
    photo: null,
    village: "Кочкор",
    region: "Нарын",
    yearsExperience: 6,
    animalsUnderCare: 62,
    rating: 4.6,
    reviewCount: 19,
    monthlyFeeKgs: 2500,
    speciality: ["SHEEP"],
    hasPastures: true,
    isVerified: false,
    bio: "Жаш малчымын, арзан. 60тан ашык кой карап жатам. Семизтүүгө адис.",
  },
  {
    id: "caretaker-5",
    name: "Мелис Токтогулов",
    photo: null,
    village: "Ак-Талаа",
    region: "Нарын",
    yearsExperience: 12,
    animalsUnderCare: 30,
    rating: 4.9,
    reviewCount: 42,
    monthlyFeeKgs: 5000,
    speciality: ["CATTLE", "SHEEP"],
    hasPastures: true,
    isVerified: true,
    bio: "Таза канныгы уй-койлорго адис. Жайында жайлоодо, кышында фермада.",
  },
];

export function getDemoHerd(userId?: string) {
  const animals = DEMO_OWNED_ANIMALS;
  const totalInvested = animals.reduce((s, a) => s + a.purchasePriceKgs, 0);
  const currentValue = animals.reduce((s, a) => s + a.currentValueKgs, 0);
  const totalLoyalty = animals.reduce((s, a) => s + a.loyaltyPoints, 0);
  const totalWeightGain = animals.reduce((s, a) => s + a.weightGainKg, 0);

  return {
    animals,
    summary: {
      totalAnimals: animals.length,
      totalInvestedKgs: totalInvested,
      currentValueKgs: currentValue,
      unrealizedProfitKgs: currentValue - totalInvested,
      profitPercent: Math.round(((currentValue - totalInvested) / totalInvested) * 100),
      totalLoyaltyPoints: totalLoyalty,
      totalWeightGainKg: totalWeightGain,
      activeCaretakers: new Set(animals.map((a) => a.caretakerId).filter(Boolean)).size,
    },
  };
}

export function getDemoCaretakers(opts?: { category?: string | null; region?: string | null }) {
  let list = [...DEMO_CARETAKERS];
  if (opts?.category) {
    list = list.filter((c) => c.speciality.includes(opts.category as "HORSE" | "CATTLE" | "SHEEP" | "ARASHAN"));
  }
  if (opts?.region) {
    list = list.filter((c) => c.region === opts.region);
  }
  // Sort: verified first, then by rating
  list.sort((a, b) => {
    if (a.isVerified !== b.isVerified) return a.isVerified ? -1 : 1;
    return b.rating - a.rating;
  });
  return list;
}

export function getDemoAnimal(id: string) {
  return DEMO_OWNED_ANIMALS.find((a) => a.id === id) || null;
}
