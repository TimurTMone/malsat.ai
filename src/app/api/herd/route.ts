import { NextRequest } from "next/server";
import { ok, handleError } from "@/lib/response";
import { getDemoHerd } from "@/lib/demo-herd";

// GET /api/herd — the authed user's owned animals + portfolio summary.
// Demo: returns hardcoded portfolio regardless of auth.
export async function GET(_req: NextRequest) {
  try {
    return ok(getDemoHerd());
  } catch (error) {
    return handleError(error);
  }
}
