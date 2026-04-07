import { NextRequest } from "next/server";
import { prisma } from "@/lib/prisma";
import { requireAuth } from "@/lib/auth";
import { ok, errorResponse, handleError } from "@/lib/response";

type Ctx = { params: Promise<{ id: string }> };

// GET — fetch order detail (buyer or seller)
export async function GET(req: NextRequest, ctx: Ctx) {
  try {
    const auth = requireAuth(req);
    const { id } = await ctx.params;

    const order = await prisma.meatOrder.findUnique({
      where: { id },
      include: {
        drop: {
          select: {
            id: true,
            title: true,
            category: true,
            pricePerKg: true,
            butcherDate: true,
            pickupAddress: true,
            village: true,
            status: true,
            sellerId: true,
            seller: {
              select: {
                id: true,
                name: true,
                phone: true,
                avatarUrl: true,
                trustScore: true,
                isVerifiedBreeder: true,
                paymentQrUrl: true,
                paymentInfo: true,
              },
            },
            media: { orderBy: { sortOrder: "asc" }, take: 1 },
          },
        },
        buyer: {
          select: { id: true, name: true, phone: true },
        },
      },
    });
    if (!order) return errorResponse("Order not found", 404);

    const isSeller = order.drop.sellerId === auth.userId;
    const isBuyer = order.buyerId === auth.userId;
    if (!isSeller && !isBuyer) return errorResponse("Not authorized", 403);

    return ok(order);
  } catch (error) {
    return handleError(error);
  }
}

// PATCH — update order status
export async function PATCH(req: NextRequest, ctx: Ctx) {
  try {
    const auth = requireAuth(req);
    const { id } = await ctx.params;
    const body = await req.json();

    const order = await prisma.meatOrder.findUnique({
      where: { id },
      include: { drop: { select: { sellerId: true } } },
    });
    if (!order) return errorResponse("Order not found", 404);

    const isSeller = order.drop.sellerId === auth.userId;
    const isBuyer = order.buyerId === auth.userId;

    if (!isSeller && !isBuyer)
      return errorResponse("Not authorized", 403);

    const newStatus: string | undefined = body.status;
    const receiptUrl: string | undefined = body.receiptUrl;

    // Validate allowed status transitions
    // Buyer flow: PENDING → PAID (upload receipt) or CANCELLED
    // Seller flow: PAID → CONFIRMED → BUTCHERING → PACKAGING → DELIVERING → DELIVERED
    if (newStatus) {
      const sellerTransitions: Record<string, string[]> = {
        PAID: ["CONFIRMED", "CANCELLED"],
        CONFIRMED: ["BUTCHERING"],
        BUTCHERING: ["PACKAGING"],
        PACKAGING: ["DELIVERING"],
        DELIVERING: ["DELIVERED"],
      };
      const buyerTransitions: Record<string, string[]> = {
        PENDING: ["PAID", "CANCELLED"],
      };

      const allowed = isSeller
        ? sellerTransitions[order.status] || []
        : buyerTransitions[order.status] || [];

      if (!allowed.includes(newStatus))
        return errorResponse(
          `Cannot transition from ${order.status} to ${newStatus}`
        );

      // PAID requires a receipt
      if (newStatus === "PAID" && !receiptUrl && !order.receiptUrl)
        return errorResponse("Receipt image is required to mark as paid");
    }

    const timestampField: Record<string, string> = {
      PAID: "paidAt",
      CONFIRMED: "confirmedAt",
      BUTCHERING: "butcheringAt",
      PACKAGING: "packagingAt",
      DELIVERING: "deliveringAt",
      DELIVERED: "deliveredAt",
    };

    // Stage photo fields from seller
    const stagePhotoField: Record<string, string> = {
      BUTCHERING: "butcheringPhotoUrl",
      PACKAGING: "packagingPhotoUrl",
      DELIVERING: "deliveringPhotoUrl",
    };
    const stagePhotoUrl: string | undefined = body.stagePhotoUrl;

    const updated = await prisma.meatOrder.update({
      where: { id },
      data: {
        ...(newStatus && { status: newStatus as any }),
        ...(receiptUrl && { receiptUrl }),
        ...(newStatus && timestampField[newStatus] && {
          [timestampField[newStatus]]: new Date(),
        }),
        ...(newStatus && stagePhotoField[newStatus] && stagePhotoUrl && {
          [stagePhotoField[newStatus]]: stagePhotoUrl,
        }),
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

    // If cancelled, restore the weight back to the drop
    if (newStatus === "CANCELLED") {
      await prisma.butcherDrop.update({
        where: { id: order.dropId },
        data: {
          remainingWeightKg: { increment: order.weightKg },
          status: "OPEN",
        },
      });
    }

    return ok(updated);
  } catch (error) {
    return handleError(error);
  }
}
