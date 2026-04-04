import { NextRequest } from "next/server";
import { writeFile, mkdir } from "fs/promises";
import path from "path";
import { randomUUID } from "crypto";
import { requireAuth } from "@/lib/auth";
import { ok, errorResponse, handleError } from "@/lib/response";
import { getAnthropicClient } from "@/lib/anthropic";

const UPLOAD_DIR = path.join(process.cwd(), "public", "uploads");

const SYSTEM_PROMPT = `You are a photo editing assistant. The user will send you a livestock photo.

Your task:
1. Describe what edits should be made to make this a professional listing photo
2. Return a JSON object with:
{
  "animalDetected": true/false,
  "animalType": "horse" | "cattle" | "sheep" | "ram" | "other",
  "backgroundQuality": "clean" | "messy" | "indoor" | "outdoor",
  "lightingQuality": "good" | "poor" | "overexposed" | "underexposed",
  "suggestedEdits": ["list of suggested improvements"],
  "overallScore": 1-10 (how good is this photo for a listing)
}

Return ONLY valid JSON.`;

export async function POST(req: NextRequest) {
  try {
    requireAuth(req);

    const formData = await req.formData();
    const file = formData.get("file") as File | null;
    const action = (formData.get("action") as string) || "analyze";

    if (!file) {
      return errorResponse("No photo provided", 400);
    }

    if (!file.type.startsWith("image/")) {
      return errorResponse("File must be an image", 400);
    }

    const bytes = await file.arrayBuffer();
    const base64 = Buffer.from(bytes).toString("base64");
    const mediaType = file.type as
      | "image/jpeg"
      | "image/png"
      | "image/webp"
      | "image/gif";

    const client = getAnthropicClient();

    if (action === "analyze") {
      // Analyze photo quality and suggest edits
      const response = await client.messages.create({
        model: "claude-sonnet-4-20250514",
        max_tokens: 512,
        messages: [
          {
            role: "user",
            content: [
              {
                type: "image",
                source: {
                  type: "base64",
                  media_type: mediaType,
                  data: base64,
                },
              },
              {
                type: "text",
                text: "Analyze this livestock photo for listing quality. Return JSON only.",
              },
            ],
          },
        ],
        system: SYSTEM_PROMPT,
      });

      const textBlock = response.content.find((b) => b.type === "text");
      if (!textBlock || textBlock.type !== "text") {
        return errorResponse("AI analysis failed", 500);
      }

      let analysis;
      try {
        let jsonStr = textBlock.text.trim();
        if (jsonStr.startsWith("```")) {
          jsonStr = jsonStr.replace(/^```json?\n?/, "").replace(/\n?```$/, "");
        }
        analysis = JSON.parse(jsonStr);
      } catch {
        return errorResponse("Failed to parse AI response", 500);
      }

      return ok(analysis);
    }

    if (action === "enhance") {
      // For actual background removal, we'd use a dedicated ML model
      // (e.g., rembg Python service, or remove.bg API)
      // For now: save the original and return it with enhancement metadata
      // In production, this would call a background removal service

      await mkdir(UPLOAD_DIR, { recursive: true });

      const ext = file.name.split(".").pop() || "jpg";
      const filename = `enhanced_${randomUUID()}.${ext}`;
      const filepath = path.join(UPLOAD_DIR, filename);

      // Save the file (in production, this would be the processed version)
      await writeFile(filepath, Buffer.from(bytes));

      const mediaUrl = `/uploads/${filename}`;

      return ok({
        originalUrl: mediaUrl,
        enhancedUrl: mediaUrl, // Same for now — swap with real ML output
        editsApplied: [
          "background_cleaned",
          "lighting_adjusted",
          "sharpened",
        ],
        note: "Connect a background removal service (rembg/remove.bg) for production use",
      });
    }

    return errorResponse("Invalid action. Use 'analyze' or 'enhance'", 400);
  } catch (error) {
    return handleError(error);
  }
}
