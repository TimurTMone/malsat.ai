import { NextRequest } from "next/server";
import { ok } from "@/lib/response";

// Herd is not yet wired to DB — return an empty portfolio.
export async function GET(_req: NextRequest) {
  return ok({
    animals: [],
    summary: { totalAnimals: 0, totalValue: 0 },
  });
}
