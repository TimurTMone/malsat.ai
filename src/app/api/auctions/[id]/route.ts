import { NextRequest } from "next/server";
import { ok, errorResponse } from "@/lib/response";
import { getDemoAuctionById } from "@/lib/demo-auctions";

export async function GET(
  _req: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params;
  const auction = getDemoAuctionById(id);
  if (!auction) return errorResponse("Auction not found", 404);
  return ok(auction);
}
