import { NextRequest } from "next/server";
import { writeFile, mkdir } from "fs/promises";
import path from "path";
import { randomUUID } from "crypto";
import sharp from "sharp";
import { requireAuth } from "@/lib/auth";
import { ok, errorResponse, handleError } from "@/lib/response";
import { prisma } from "@/lib/prisma";

const UPLOAD_DIR = path.join(process.cwd(), "public", "uploads");
const MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB
const ALLOWED_TYPES = [
  "image/jpeg",
  "image/png",
  "image/webp",
  "video/mp4",
  "video/quicktime",
];

// Image compression settings
const IMAGE_SIZES = {
  full: { width: 1200, height: 900, quality: 80 },    // Detail view
  thumb: { width: 400, height: 300, quality: 70 },     // Card thumbnail
};

async function processImage(
  buffer: Buffer,
  id: string
): Promise<{ fullUrl: string; thumbUrl: string }> {
  await mkdir(UPLOAD_DIR, { recursive: true });

  const fullFilename = `${id}.webp`;
  const thumbFilename = `${id}_thumb.webp`;

  // Full size — optimized for detail view
  await sharp(buffer)
    .resize(IMAGE_SIZES.full.width, IMAGE_SIZES.full.height, {
      fit: "inside",
      withoutEnlargement: true,
    })
    .webp({ quality: IMAGE_SIZES.full.quality })
    .toFile(path.join(UPLOAD_DIR, fullFilename));

  // Thumbnail — optimized for listing cards
  await sharp(buffer)
    .resize(IMAGE_SIZES.thumb.width, IMAGE_SIZES.thumb.height, {
      fit: "cover",
    })
    .webp({ quality: IMAGE_SIZES.thumb.quality })
    .toFile(path.join(UPLOAD_DIR, thumbFilename));

  return {
    fullUrl: `/uploads/${fullFilename}`,
    thumbUrl: `/uploads/${thumbFilename}`,
  };
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
      // Videos: save as-is (no compression for now)
      await mkdir(UPLOAD_DIR, { recursive: true });
      const ext = file.name.split(".").pop() || "mp4";
      const filename = `${id}.${ext}`;
      await writeFile(path.join(UPLOAD_DIR, filename), buffer);
      mediaUrl = `/uploads/${filename}`;
    } else {
      // Images: compress + generate thumbnail
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
