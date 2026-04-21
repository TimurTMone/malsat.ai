import { NextRequest } from "next/server";
import { errorResponse } from "@/lib/response";

// Herd is not yet wired to DB.
export async function GET(
  _req: NextRequest,
  _ctx: { params: Promise<{ id: string }> }
) {
  return errorResponse("Animal not found", 404);
}
