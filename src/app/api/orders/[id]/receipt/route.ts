import { NextRequest } from "next/server";
import { randomUUID } from "crypto";
import { mkdir, writeFile } from "fs/promises";
import path from "path";
import sharp from "sharp";
import { prisma } from "@/lib/prisma";
import { requireAuth } from "@/lib/auth";
import { ok, errorResponse, handleError } from "@/lib/response";

type Ctx = { params: Promise<{ id: string }> };

const MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB
const ALLOWED_TYPES = ["image/jpeg", "image/png", "image/webp"];
const RECEIPTS_DIR = path.join(process.cwd(), "public", "uploads", "receipts");
const PUBLIC_BASE_URL = process.env.PUBLIC_BASE_URL ?? "";

export async function POST(req: NextRequest, ctx: Ctx) {
  try {
    const auth = requireAuth(req);
    const { id } = await ctx.params;

    const order = await prisma.meatOrder.findUnique({
      where: { id },
      include: { drop: { select: { sellerId: true } } },
    });
    if (!order) return errorResponse("Order not found", 404);
    if (order.buyerId !== auth.userId)
      return errorResponse("Only the buyer can upload a receipt", 403);
    if (order.status !== "PENDING")
      return errorResponse("Receipt can only be uploaded for pending orders");

    const formData = await req.formData();
    const file = formData.get("file") as File | null;
    if (!file) return errorResponse("No file provided");
    if (!ALLOWED_TYPES.includes(file.type))
      return errorResponse("Only JPEG, PNG, WebP images are allowed");
    if (file.size > MAX_FILE_SIZE)
      return errorResponse("File too large (max 10MB)");

    const buffer = Buffer.from(await file.arrayBuffer());

    // Compress to WebP
    const compressed = await sharp(buffer)
      .resize(1200, 1600, { fit: "inside", withoutEnlargement: true })
      .webp({ quality: 80 })
      .toBuffer();

    const filename = `${randomUUID()}.webp`;
    await mkdir(RECEIPTS_DIR, { recursive: true });
    await writeFile(path.join(RECEIPTS_DIR, filename), compressed);
    const relPath = `/uploads/receipts/${filename}`;
    const receiptUrl = PUBLIC_BASE_URL ? `${PUBLIC_BASE_URL}${relPath}` : relPath;

    const updated = await prisma.meatOrder.update({
      where: { id },
      data: {
        receiptUrl,
        status: "PAID",
        paidAt: new Date(),
      },
      include: {
        drop: {
          select: {
            id: true,
            title: true,
            category: true,
            breed: true,
            pricePerKg: true,
            butcherDate: true,
            pickupAddress: true,
            village: true,
            status: true,
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

    return ok(updated, 201);
  } catch (error) {
    return handleError(error);
  }
}
