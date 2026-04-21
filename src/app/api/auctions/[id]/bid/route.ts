import { NextRequest } from "next/server";
import { errorResponse } from "@/lib/response";

// Auctions have no DB model yet — bidding is unavailable.
export async function POST(
  _req: NextRequest,
  _ctx: { params: Promise<{ id: string }> }
) {
  return errorResponse("Auctions are not yet available", 503);
}
