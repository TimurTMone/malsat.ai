import { NextRequest } from "next/server";
import { prisma } from "@/lib/prisma";
import { requireAuth } from "@/lib/auth";
import { ok, errorResponse, handleError } from "@/lib/response";

// POST /api/butcher-service
// Creates a BUTCHER_SERVICE MeatOrder. The customer brings (or describes)
// a live animal; the partner butchers it halal and delivers the meat.
//
// Body:
//   partnerId         string  (required)
//   animalCategory    AnimalCategory (required)
//   animalWeightKg    number  (required, > 0)
//   animalDescription string?
//   animalPhotoUrl    string?
//   occasionType      OccasionType (required)
//   imamRequested     boolean
//   cuttingPreset     string[]  (JSON-stringified server-side)
//   specialDua        string?
//   deliveryAddress   string  (required)
//   deliveryLat       number?
//   deliveryLng       number?
//   deliveryDate      string  ISO date (required) — when slaughter happens
//   buyerPhone        string  (required)
//   buyerNote         string?
//   sourceListingId   string?  (P1)
export async function POST(req: NextRequest) {
  try {
    const auth = requireAuth(req);
    const body = await req.json();

    const partnerId: string | undefined = body.partnerId;
    const animalCategory: string | undefined = body.animalCategory;
    const animalWeightKg: number | undefined = body.animalWeightKg;
    const occasionType: string | undefined = body.occasionType;
    const deliveryAddress: string | undefined = body.deliveryAddress;
    const deliveryDateRaw: string | undefined = body.deliveryDate;
    const buyerPhone: string | undefined = body.buyerPhone;

    if (!partnerId) return errorResponse("partnerId is required");
    if (!animalCategory) return errorResponse("animalCategory is required");
    if (!animalWeightKg || animalWeightKg <= 0)
      return errorResponse("animalWeightKg must be > 0");
    if (!occasionType) return errorResponse("occasionType is required");
    if (!deliveryAddress) return errorResponse("deliveryAddress is required");
    if (!deliveryDateRaw) return errorResponse("deliveryDate is required");
    if (!buyerPhone) return errorResponse("buyerPhone is required");

    const validCategories = ["HORSE", "CATTLE", "SHEEP", "ARASHAN"];
    if (!validCategories.includes(animalCategory))
      return errorResponse(`Invalid animalCategory: ${animalCategory}`);
    const validOccasions = [
      "JANAZA",
      "TOI",
      "TUSHOO_TOI",
      "KUDAI_TAMAK",
      "OTHER",
    ];
    if (!validOccasions.includes(occasionType))
      return errorResponse(`Invalid occasionType: ${occasionType}`);

    // No-same-day floor: butcher needs at least a few hours' lead time.
    const deliveryDate = new Date(deliveryDateRaw);
    if (Number.isNaN(deliveryDate.getTime()))
      return errorResponse("deliveryDate must be a valid ISO date");
    const minLeadHours = 4;
    if (deliveryDate.getTime() < Date.now() + minLeadHours * 60 * 60 * 1000)
      return errorResponse(
        `deliveryDate must be at least ${minLeadHours} hours in the future`
      );

    // 48h ceiling — animal welfare guard (see plan, risk #2).
    const maxLeadHours = 48;
    if (deliveryDate.getTime() > Date.now() + maxLeadHours * 60 * 60 * 1000)
      return errorResponse(
        `deliveryDate must be within ${maxLeadHours} hours`
      );

    const partner = await prisma.butcherPartner.findUnique({
      where: { id: partnerId },
    });
    if (!partner) return errorResponse("Butcher partner not found", 404);
    if (!partner.isActive)
      return errorResponse("Butcher partner is not accepting orders");

    // Price computation
    const pricesByCategory = JSON.parse(partner.pricePerKgByCategory) as Record<
      string,
      number
    >;
    const pricePerKg = pricesByCategory[animalCategory];
    if (!pricePerKg)
      return errorResponse(
        `Partner does not service ${animalCategory.toLowerCase()}`
      );

    const imamRequested: boolean = body.imamRequested === true;
    const butcheringSubtotal = Math.round(animalWeightKg * pricePerKg);
    const imamFee = imamRequested ? partner.imamFeeKgs : 0;
    const deliveryFee = partner.deliveryFeeKgs;
    const totalPriceKgs = butcheringSubtotal + imamFee + deliveryFee;

    // cuttingPreset stored as JSON string (matches `priceHistory` pattern).
    const cuttingPresetRaw = body.cuttingPreset;
    const cuttingPreset =
      Array.isArray(cuttingPresetRaw) && cuttingPresetRaw.length > 0
        ? JSON.stringify(cuttingPresetRaw)
        : null;

    const order = await prisma.meatOrder.create({
      data: {
        dropId: partner.syntheticDropId,
        buyerId: auth.userId,
        kind: "BUTCHER_SERVICE",
        weightKg: animalWeightKg,
        totalPriceKgs,
        deliveryMethod: "delivery",
        deliveryAddress,
        deliveryLat: body.deliveryLat ?? null,
        deliveryLng: body.deliveryLng ?? null,
        deliveryFee,
        // P0 ships without payment screen — order opens already CONFIRMED.
        status: "CONFIRMED",
        confirmedAt: new Date(),
        buyerPhone,
        buyerNote: body.buyerNote ?? null,
        occasionType: occasionType as
          | "JANAZA"
          | "TOI"
          | "TUSHOO_TOI"
          | "KUDAI_TAMAK"
          | "OTHER",
        imamRequested,
        cuttingPreset,
        specialDua: body.specialDua ?? null,
        animalCategory: animalCategory as
          | "HORSE"
          | "CATTLE"
          | "SHEEP"
          | "ARASHAN",
        animalWeightKg,
        animalDescription: body.animalDescription ?? null,
        animalPhotoUrl: body.animalPhotoUrl ?? null,
        sourceListingId: body.sourceListingId ?? null,
      },
      include: {
        drop: {
          select: {
            id: true,
            title: true,
            pricePerKg: true,
            butcherDate: true,
            pickupAddress: true,
            seller: {
              select: {
                id: true,
                name: true,
                phone: true,
                avatarUrl: true,
                paymentQrUrl: true,
                paymentInfo: true,
              },
            },
          },
        },
        buyer: {
          select: { id: true, name: true, phone: true },
        },
      },
    });

    // Update the partner's synthetic drop butcherDate so the partner-side
    // SellerOrdersScreen surfaces this order with the correct slaughter time.
    await prisma.butcherDrop.update({
      where: { id: partner.syntheticDropId },
      data: { butcherDate: deliveryDate },
    });

    // Save the buyer's address for next time.
    await prisma.user.update({
      where: { id: auth.userId },
      data: {
        savedAddress: deliveryAddress,
        savedAddressLat: body.deliveryLat ?? null,
        savedAddressLng: body.deliveryLng ?? null,
      },
    });

    return ok(
      {
        order,
        breakdown: {
          butcheringSubtotal,
          imamFee,
          deliveryFee,
          totalPriceKgs,
          pricePerKg,
        },
      },
      201
    );
  } catch (error) {
    return handleError(error);
  }
}
