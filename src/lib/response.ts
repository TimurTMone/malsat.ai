import { NextResponse } from "next/server";
import { AuthError } from "./auth";

export function ok<T>(data: T, status = 200) {
  return NextResponse.json(data, { status });
}

export function errorResponse(message: string, status = 400) {
  return NextResponse.json({ error: message }, { status });
}

export function handleError(error: unknown) {
  if (error instanceof AuthError) {
    return errorResponse("Unauthorized", 401);
  }
  console.error("API Error:", error);
  return errorResponse("Internal server error", 500);
}
