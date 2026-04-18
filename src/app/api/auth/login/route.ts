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

    // DEMO PHONES: skip SMS — accept code "000000" on verify
    const isDemoPhone = normalizedPhone === "+996555000000" || normalizedPhone.startsWith("+996000");
    if (isDemoPhone) {
      return ok({ success: true, phone: normalizedPhone, demo: true });
    }

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
