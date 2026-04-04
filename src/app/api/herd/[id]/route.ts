import { NextRequest } from "next/server";
import { ok, errorResponse, handleError } from "@/lib/response";
import { getDemoAnimal } from "@/lib/demo-herd";

export async function GET(
  _req: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    const animal = getDemoAnimal(id);
    if (!animal) return errorResponse("Animal not found", 404);
    return ok(animal);
  } catch (error) {
    return handleError(error);
  }
}
