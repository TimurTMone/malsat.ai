import { NextRequest } from "next/server";
import { errorResponse } from "@/lib/response";

// Auctions have no DB model yet.
export async function GET(
  _req: NextRequest,
  _ctx: { params: Promise<{ id: string }> }
) {
  return errorResponse("Auction not found", 404);
}
