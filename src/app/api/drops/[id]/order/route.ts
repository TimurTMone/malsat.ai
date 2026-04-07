import { NextRequest } from "next/server";
import { prisma } from "@/lib/prisma";
import { requireAuth } from "@/lib/auth";
import { ok, errorResponse, handleError } from "@/lib/response";

type Ctx = { params: Promise<{ id: string }> };

export async function POST(req: NextRequest, ctx: Ctx) {
  try {
    const auth = requireAuth(req);
    const { id: dropId } = await ctx.params;
    const body = await req.json();

    const weightKg: number = body.weightKg;
    if (!weightKg || weightKg <= 0)
      return errorResponse("weightKg is required and must be positive");

    const deliveryMethod: string = body.deliveryMethod || "pickup";

    // Fetch the drop with seller payment info
    const drop = await prisma.butcherDrop.findUnique({
      where: { id: dropId },
      include: {
        seller: {
          select: {
            id: true,
            name: true,
            phone: true,
            paymentQrUrl: true,
            paymentInfo: true,
          },
        },
      },
    });
    if (!drop) return errorResponse("Drop not found", 404);

    if (drop.sellerId === auth.userId)
      return errorResponse("Cannot order your own drop");

    if (drop.status !== "OPEN")
      return errorResponse(
        `Drop is ${drop.status.toLowerCase()}, not accepting orders`
      );

    if (weightKg < drop.minOrderKg)
      return errorResponse(`Minimum order is ${drop.minOrderKg} kg`);
    if (drop.maxOrderKg && weightKg > drop.maxOrderKg)
      return errorResponse(`Maximum order is ${drop.maxOrderKg} kg`);
    if (weightKg > drop.remainingWeightKg)
      return errorResponse(`Only ${drop.remainingWeightKg} kg remaining`);

    // Delivery validation
    if (deliveryMethod === "delivery") {
      if (!drop.deliveryAvailable)
        return errorResponse("This seller does not offer delivery");
      if (!body.deliveryAddress)
        return errorResponse("Delivery address is required");
    }

    const deliveryFee =
      deliveryMethod === "delivery" ? drop.deliveryFee : 0;
    const totalPriceKgs =
      Math.round(weightKg * drop.pricePerKg) + deliveryFee;

    // Save address to buyer's profile for next time
    if (deliveryMethod === "delivery" && body.deliveryAddress) {
      await prisma.user.update({
        where: { id: auth.userId },
        data: {
          savedAddress: body.deliveryAddress,
          savedAddressLat: body.deliveryLat ?? null,
          savedAddressLng: body.deliveryLng ?? null,
        },
      });
    }

    const [order] = await prisma.$transaction([
      prisma.meatOrder.create({
        data: {
          dropId,
          buyerId: auth.userId,
          weightKg,
          totalPriceKgs,
          deliveryMethod,
          deliveryAddress: body.deliveryAddress,
          deliveryLat: body.deliveryLat,
          deliveryLng: body.deliveryLng,
          deliveryFee,
          buyerPhone: body.buyerPhone,
          buyerNote: body.buyerNote,
        },
        include: {
          drop: {
            select: {
              id: true,
              title: true,
              pricePerKg: true,
              butcherDate: true,
              pickupAddress: true,
              deliveryAvailable: true,
              deliveryFee: true,
              seller: {
                select: {
                  id: true,
                  name: true,
                  phone: true,
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
      }),
      prisma.butcherDrop.update({
        where: { id: dropId },
        data: {
          remainingWeightKg: { decrement: weightKg },
          ...(drop.remainingWeightKg - weightKg <= 0 && {
            status: "SOLD_OUT",
          }),
        },
      }),
    ]);

    return ok(order, 201);
  } catch (error) {
    return handleError(error);
  }
}
