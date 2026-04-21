import { NextRequest } from "next/server";
import { ok } from "@/lib/response";

// Auctions have no DB model yet — return an empty list until implemented.
export async function GET(req: NextRequest) {
  const url = new URL(req.url);
  const page = parseInt(url.searchParams.get("page") || "1");
  const limit = Math.min(parseInt(url.searchParams.get("limit") || "20"), 50);
  return ok({
    auctions: [],
    pagination: { page, limit, total: 0, totalPages: 0 },
  });
}
