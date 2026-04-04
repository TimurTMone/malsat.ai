import { NextRequest } from "next/server";
import { ok, handleError } from "@/lib/response";
import { getDemoCaretakers } from "@/lib/demo-herd";

// GET /api/caretakers?category=SHEEP&region=Нарын
export async function GET(req: NextRequest) {
  try {
    const url = new URL(req.url);
    const category = url.searchParams.get("category");
    const region = url.searchParams.get("region");
    return ok({ caretakers: getDemoCaretakers({ category, region }) });
  } catch (error) {
    return handleError(error);
  }
}
