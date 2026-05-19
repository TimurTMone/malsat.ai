import { NextRequest } from "next/server";
import { prisma } from "@/lib/prisma";
import { signAccessToken, signRefreshToken } from "@/lib/auth";
import { ok, errorResponse, handleError } from "@/lib/response";

// Mirrors the flag in /api/auth/login. While open, any 4-6 digit code unlocks
// the supplied phone; the user is still upserted with their real phone number
// so all downstream data is real. Disable with DEMO_AUTH_OPEN=false.
const DEMO_AUTH_OPEN = process.env.DEMO_AUTH_OPEN !== "false";

export async function POST(req: NextRequest) {
  try {
    const { phone, code } = await req.json();

    if (!phone || !code) {
      return errorResponse("Phone and code are required", 400);
    }

    // Normalize phone to match how /login stores it.
    const normalizedPhone =
      typeof phone === "string"
        ? phone.replace(/\s/g, "").replace(/^0/, "+996")
        : phone;

    const isDemoCode = code === "000000";
    const isOpenDemoCode =
      DEMO_AUTH_OPEN && typeof code === "string" && /^\d{4,6}$/.test(code);

    if (!isDemoCode && !isOpenDemoCode) {
      // Real OTP path — verify the code stored at /login time.
      const otpRecord = await prisma.otpCode.findFirst({
        where: {
          phone: normalizedPhone,
          code,
          used: false,
          expiresAt: { gt: new Date() },
        },
        orderBy: { createdAt: "desc" },
      });

      if (!otpRecord) {
        return errorResponse("Invalid or expired code", 401);
      }

      await prisma.otpCode.update({
        where: { id: otpRecord.id },
        data: { used: true },
      });
    }

    // Find or create user with the real phone — same record on subsequent logins.
    let user = await prisma.user.findUnique({ where: { phone: normalizedPhone } });

    if (!user) {
      user = await prisma.user.create({
        data: {
          phone: normalizedPhone,
          // Only the legacy hardcoded demo phone gets a placeholder name;
          // open-demo users are anonymous until they set a name themselves.
          name: normalizedPhone === "+996555000000" ? "Демо колдонуучу" : null,
        },
      });
    }

    const payload = { userId: user.id, phone: user.phone };
    const accessToken = signAccessToken(payload);
    const refreshToken = signRefreshToken(payload);

    return ok({
      accessToken,
      refreshToken,
      user: {
        id: user.id,
        phone: user.phone,
        name: user.name,
        avatarUrl: user.avatarUrl,
        isVerifiedBreeder: user.isVerifiedBreeder,
      },
    });
  } catch (error) {
    return handleError(error);
  }
}
