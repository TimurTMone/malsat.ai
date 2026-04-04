export type { AnimalCategory, AnimalGender, ListingStatus, MediaType, RegionType } from "@/generated/prisma/client";

export interface ListingWithMedia {
  id: string;
  sellerId: string;
  category: string;
  subcategory: string | null;
  breed: string | null;
  title: string;
  description: string | null;
  priceKgs: number;
  ageMonths: number | null;
  weightKg: number | null;
  gender: string | null;
  healthStatus: string | null;
  hasVetCert: boolean;
  locationLat: number | null;
  locationLng: number | null;
  regionId: string | null;
  village: string | null;
  status: string;
  viewsCount: number;
  favoritesCount: number;
  isPremium: boolean;
  createdAt: string;
  media: {
    id: string;
    mediaUrl: string;
    mediaType: string;
    isPrimary: boolean;
    sortOrder: number;
  }[];
  seller: {
    id: string;
    name: string | null;
    avatarUrl: string | null;
    phone: string;
    trustScore: number;
    isVerifiedBreeder: boolean;
  };
  region: {
    id: string;
    nameKy: string;
    nameRu: string;
  } | null;
}

export interface SearchFilters {
  category?: string;
  subcategory?: string;
  minPrice?: number;
  maxPrice?: number;
  regionId?: string;
  breed?: string;
  minAge?: number;
  maxAge?: number;
  minWeight?: number;
  maxWeight?: number;
  gender?: string;
  sort?: "newest" | "price_asc" | "price_desc";
  page?: number;
  limit?: number;
}

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
}
