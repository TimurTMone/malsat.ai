import { NextRequest } from "next/server";
import { prisma } from "@/lib/prisma";
import { generateOtp, sendOtp } from "@/lib/sms";
import { ok, errorResponse, handleError } from "@/lib/response";

export async function POST(req: NextRequest) {
  try {
    const { phone } = await req.json();

    if (!phone || typeof phone !== "string") {
      return errorResponse("Phone number is required", 400);
    }

    // Normalize phone
    const normalizedPhone = phone.replace(/\s/g, "").replace(/^0/, "+996");

    // Generate and store OTP
    const code = generateOtp();
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000); // 5 minutes

    await prisma.otpCode.create({
      data: {
        phone: normalizedPhone,
        code,
        expiresAt,
      },
    });

    // Send SMS
    await sendOtp(normalizedPhone, code);

    return ok({ success: true, phone: normalizedPhone });
  } catch (error) {
    return handleError(error);
  }
}
