import { NextRequest } from "next/server";
import { requireAuth } from "@/lib/auth";
import { ok, errorResponse, handleError } from "@/lib/response";
import { getDemoAuctionById } from "@/lib/demo-auctions";

export async function POST(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const auth = requireAuth(req);
    const { id } = await params;
    const { amount } = await req.json();

    const auction = getDemoAuctionById(id);
    if (!auction) return errorResponse("Auction not found", 404);

    if (typeof amount !== "number" || amount < auction.currentBid + auction.bidIncrement) {
      return errorResponse(
        `Bid must be at least ${auction.currentBid + auction.bidIncrement} сом`,
        400
      );
    }

    if (auction.minutesLeft <= 0) {
      return errorResponse("Auction has ended", 400);
    }

    // Demo: just return success — in real DB we'd insert a Bid record
    return ok({
      success: true,
      bid: {
        id: `bid-${Date.now()}`,
        auctionId: id,
        bidderId: auth.userId,
        amount,
        placedAt: new Date().toISOString(),
      },
      auction: {
        ...auction,
        currentBid: amount,
        bidCount: auction.bidCount + 1,
      },
    });
  } catch (error) {
    return handleError(error);
  }
}
