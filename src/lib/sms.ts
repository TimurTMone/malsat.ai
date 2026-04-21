import { randomBytes } from "crypto";

export function generateOtp(): string {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

/** Normalize "+996 555 12 34 56" / "0555123456" to "996555123456". */
function normalizeForNikita(phone: string): string {
  const digits = phone.replace(/\D/g, "");
  if (digits.startsWith("996")) return digits;
  if (digits.startsWith("0")) return "996" + digits.slice(1);
  return digits;
}

function escapeXml(s: string): string {
  return s
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&apos;");
}

/**
 * Send an OTP SMS via smspro.nikita.kg.
 *
 * Env vars (set in .env.production):
 *   SMS_LOGIN     — Nikita account login
 *   SMS_PASSWORD  — Nikita account password
 *   SMS_SENDER    — approved sender name (e.g. "malsat.kg")
 *   SMS_TEMPLATE  — approved service-traffic template. Use `{CODE}` as the
 *                   placeholder. Example:
 *                     "MalSat" kyzmatyna kattaluu uchun sms code: {CODE}
 *                   The rendered text must match the registered template
 *                   byte-for-byte (no leading/trailing whitespace) or it
 *                   is billed as advertising traffic.
 *
 * If SMS_LOGIN / SMS_PASSWORD / SMS_SENDER is missing the code is logged
 * to stdout and the function returns true — useful for local dev without
 * burning SMS credits.
 */
export async function sendOtp(phone: string, code: string): Promise<boolean> {
  const login = process.env.SMS_LOGIN;
  const password = process.env.SMS_PASSWORD;
  const sender = process.env.SMS_SENDER;
  const template =
    process.env.SMS_TEMPLATE ??
    `"MalSat" kyzmatyna kattaluu uchun sms code: {CODE}`;

  if (!login || !password || !sender) {
    console.log(`[SMS dev-mode] OTP for ${phone}: ${code}`);
    return true;
  }

  const normalized = normalizeForNikita(phone);
  const transactionId = randomBytes(6).toString("hex");
  // .trim() guards against accidental spaces pulled in from .env quoting.
  const text = template.replace(/\{CODE\}/g, code).trim();

  const xml = `<?xml version="1.0" encoding="UTF-8"?>
<message>
  <login>${escapeXml(login)}</login>
  <pwd>${escapeXml(password)}</pwd>
  <id>${transactionId}</id>
  <sender>${escapeXml(sender)}</sender>
  <text>${escapeXml(text)}</text>
  <phones>
    <phone>${normalized}</phone>
  </phones>
</message>`;

  try {
    const res = await fetch("https://smspro.nikita.kg/api/message", {
      method: "POST",
      headers: { "Content-Type": "application/xml" },
      body: xml,
    });
    const body = await res.text();

    // Nikita responds with <response><status>0</status>...</response>
    // status=0 means "accepted for delivery". Anything else is a failure.
    const match = body.match(/<status>(\d+)<\/status>/);
    const statusCode = match ? match[1] : null;

    if (!res.ok || statusCode !== "0") {
      console.error(
        `[SMS] Nikita rejected ${normalized} (http=${res.status}, status=${statusCode}): ${body}`
      );
      return false;
    }
    return true;
  } catch (err) {
    console.error(`[SMS] Nikita request failed for ${normalized}:`, err);
    return false;
  }
}
