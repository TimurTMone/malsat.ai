import { NextRequest } from "next/server";
import { ok } from "@/lib/response";

// Caretakers are not yet wired to DB.
export async function GET(_req: NextRequest) {
  return ok({ caretakers: [] });
}
