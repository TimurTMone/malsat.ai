import { NextRequest } from "next/server";
import { requireAuth } from "@/lib/auth";
import { ok, errorResponse, handleError } from "@/lib/response";
import { getAnthropicClient } from "@/lib/anthropic";
import { prisma } from "@/lib/prisma";

const SYSTEM_PROMPT = `You are an expert livestock appraiser in Kyrgyzstan.
Analyze the photo of a farm animal and return a JSON object with these fields:

{
  "category": "HORSE" | "CATTLE" | "SHEEP" | "ARASHAN",
  "breed": "breed name in Russian/Kyrgyz (e.g. Арабская, Швицкая, Гиссарская, Арашан)",
  "gender": "MALE" | "FEMALE" | null,
  "estimatedAgeMonths": number or null,
  "estimatedWeightKg": number or null,
  "healthStatus": "Соо" or description,
  "titleKy": "listing title in Kyrgyz language, concise, max 50 chars",
  "titleRu": "listing title in Russian language, concise, max 50 chars",
  "descriptionKy": "2-3 sentence description in Kyrgyz, highlighting selling points",
  "descriptionRu": "2-3 sentence description in Russian, highlighting selling points",
  "suggestedPriceKgs": number (estimated market price in Kyrgyz som based on breed, age, condition),
  "confidence": "high" | "medium" | "low"
}

Rules:
- ARASHAN category is for Arashan breed fat-tail sheep specifically
- SHEEP is for regular sheep breeds (Гиссарская, Эдильбаевская, Мериноc, etc.)
- If you can't determine something, use null
- Price estimates should be realistic for Kyrgyz livestock market (2026 prices)
- Typical ranges: horses 85K-500K, cattle 50K-350K, sheep 13K-75K, arashan 35K-300K сом
- Return ONLY valid JSON, no markdown or explanation`;

export async function POST(req: NextRequest) {
  try {
    requireAuth(req);

    const formData = await req.formData();
    const file = formData.get("file") as File | null;
    const lang = (formData.get("lang") as string) || "ky";

    if (!file) {
      return errorResponse("No photo provided", 400);
    }

    if (!file.type.startsWith("image/")) {
      return errorResponse("File must be an image", 400);
    }

    // Convert to base64 for Claude Vision
    const bytes = await file.arrayBuffer();
    const base64 = Buffer.from(bytes).toString("base64");
    const mediaType = file.type as
      | "image/jpeg"
      | "image/png"
      | "image/webp"
      | "image/gif";

    const client = getAnthropicClient();

    const response = await client.messages.create({
      model: "claude-sonnet-4-20250514",
      max_tokens: 1024,
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
              text: "Analyze this livestock photo. Return JSON only.",
            },
          ],
        },
      ],
      system: SYSTEM_PROMPT,
    });

    // Extract JSON from response
    const textBlock = response.content.find((b) => b.type === "text");
    if (!textBlock || textBlock.type !== "text") {
      return errorResponse("AI analysis failed", 500);
    }

    let analysis;
    try {
      // Clean potential markdown wrapping
      let jsonStr = textBlock.text.trim();
      if (jsonStr.startsWith("```")) {
        jsonStr = jsonStr.replace(/^```json?\n?/, "").replace(/\n?```$/, "");
      }
      analysis = JSON.parse(jsonStr);
    } catch {
      return errorResponse("Failed to parse AI response", 500);
    }

    // Pick title/description based on user language
    const result = {
      category: analysis.category,
      breed: analysis.breed,
      gender: analysis.gender,
      estimatedAgeMonths: analysis.estimatedAgeMonths,
      estimatedWeightKg: analysis.estimatedWeightKg,
      healthStatus: analysis.healthStatus,
      title: lang === "ru" ? analysis.titleRu : analysis.titleKy,
      description:
        lang === "ru" ? analysis.descriptionRu : analysis.descriptionKy,
      suggestedPriceKgs: analysis.suggestedPriceKgs,
      confidence: analysis.confidence,
    };

    return ok(result);
  } catch (error) {
    return handleError(error);
  }
}
