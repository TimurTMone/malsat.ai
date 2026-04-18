import { NextRequest } from "next/server";
import { ok } from "@/lib/response";
import { getDemoAuctions } from "@/lib/demo-auctions";

export async function GET(req: NextRequest) {
  const url = new URL(req.url);
  const category = url.searchParams.get("category");
  const status = url.searchParams.get("status");
  const sort = url.searchParams.get("sort") || "ending_soon";
  const page = parseInt(url.searchParams.get("page") || "1");
  const limit = Math.min(parseInt(url.searchParams.get("limit") || "20"), 50);

  return ok(getDemoAuctions({ category, status, sort, page, limit }));
}
