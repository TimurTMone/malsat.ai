import { NextRequest } from "next/server";
import { randomUUID } from "crypto";
import { mkdir, writeFile } from "fs/promises";
import path from "path";
import sharp from "sharp";
import { requireAuth } from "@/lib/auth";
import { ok, errorResponse, handleError } from "@/lib/response";
import { prisma } from "@/lib/prisma";

const MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB
const ALLOWED_TYPES = [
  "image/jpeg",
  "image/png",
  "image/webp",
  "video/mp4",
  "video/quicktime",
];

const IMAGE_SIZES = {
  full: { width: 1200, height: 900, quality: 80 },
  thumb: { width: 400, height: 300, quality: 70 },
};

const UPLOADS_DIR = path.join(process.cwd(), "public", "uploads", "listings");
const PUBLIC_BASE_URL = process.env.PUBLIC_BASE_URL ?? "";

function publicUrl(relPath: string): string {
  const rel = `/uploads/listings/${relPath}`;
  return PUBLIC_BASE_URL ? `${PUBLIC_BASE_URL}${rel}` : rel;
}

async function saveBuffer(filename: string, buffer: Buffer): Promise<string> {
  await mkdir(UPLOADS_DIR, { recursive: true });
  await writeFile(path.join(UPLOADS_DIR, filename), buffer);
  return publicUrl(filename);
}

async function processImage(
  buffer: Buffer,
  id: string
): Promise<{ fullUrl: string; thumbUrl: string }> {
  const fullBuffer = await sharp(buffer)
    .resize(IMAGE_SIZES.full.width, IMAGE_SIZES.full.height, {
      fit: "inside",
      withoutEnlargement: true,
    })
    .webp({ quality: IMAGE_SIZES.full.quality })
    .toBuffer();

  const thumbBuffer = await sharp(buffer)
    .resize(IMAGE_SIZES.thumb.width, IMAGE_SIZES.thumb.height, {
      fit: "cover",
    })
    .webp({ quality: IMAGE_SIZES.thumb.quality })
    .toBuffer();

  const [fullUrl, thumbUrl] = await Promise.all([
    saveBuffer(`${id}.webp`, fullBuffer),
    saveBuffer(`${id}_thumb.webp`, thumbBuffer),
  ]);

  return { fullUrl, thumbUrl };
}

export async function POST(req: NextRequest) {
  try {
    const user = requireAuth(req);

    const formData = await req.formData();
    const file = formData.get("file") as File | null;
    const listingId = formData.get("listingId") as string | null;
    const isPrimary = formData.get("isPrimary") === "true";

    if (!file) {
      return errorResponse("No file provided", 400);
    }

    if (!ALLOWED_TYPES.includes(file.type)) {
      return errorResponse(
        `Invalid file type. Allowed: ${ALLOWED_TYPES.join(", ")}`,
        400
      );
    }

    if (file.size > MAX_FILE_SIZE) {
      return errorResponse("File too large. Max 10MB", 400);
    }

    // Verify listing ownership if provided
    if (listingId) {
      const listing = await prisma.listing.findUnique({
        where: { id: listingId },
        select: { sellerId: true },
      });
      if (!listing) return errorResponse("Listing not found", 404);
      if (listing.sellerId !== user.userId)
        return errorResponse("Forbidden", 403);
    }

    const bytes = await file.arrayBuffer();
    const buffer = Buffer.from(bytes);
    const id = randomUUID();
    const isVideo = file.type.startsWith("video/");

    let mediaUrl: string;
    let thumbUrl: string | null = null;

    if (isVideo) {
      const ext = file.name.split(".").pop() || "mp4";
      mediaUrl = await saveBuffer(`${id}.${ext}`, buffer);
    } else {
      const processed = await processImage(buffer, id);
      mediaUrl = processed.fullUrl;
      thumbUrl = processed.thumbUrl;
    }

    const mediaType = isVideo ? "VIDEO" : "PHOTO";

    // Attach to listing if provided
    if (listingId) {
      if (isPrimary) {
        await prisma.listingMedia.updateMany({
          where: { listingId, isPrimary: true },
          data: { isPrimary: false },
        });
      }

      const count = await prisma.listingMedia.count({
        where: { listingId },
      });

      const media = await prisma.listingMedia.create({
        data: {
          listingId,
          mediaUrl,
          mediaType,
          isPrimary: isPrimary || count === 0,
          sortOrder: count,
        },
      });

      return ok(
        {
          id: media.id,
          mediaUrl,
          thumbUrl,
          mediaType,
          isPrimary: media.isPrimary,
          sortOrder: media.sortOrder,
        },
        201
      );
    }

    return ok({ mediaUrl, thumbUrl, mediaType }, 201);
  } catch (error) {
    return handleError(error);
  }
}
