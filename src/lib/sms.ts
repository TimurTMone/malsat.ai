// SMS OTP provider
// In production, integrate with Nikita.kg, Infobip, or similar KG SMS provider
// For development, OTP codes are logged to console

export function generateOtp(): string {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

export async function sendOtp(phone: string, code: string): Promise<boolean> {
  if (process.env.NODE_ENV === "development") {
    console.log(`[DEV SMS] OTP for ${phone}: ${code}`);
    return true;
  }

  // Production: integrate with SMS provider
  // Example with Nikita.kg API:
  // const response = await fetch('https://smspro.nikita.kg/api/message', {
  //   method: 'POST',
  //   headers: { 'Content-Type': 'application/json' },
  //   body: JSON.stringify({
  //     login: process.env.SMS_LOGIN,
  //     pwd: process.env.SMS_PASSWORD,
  //     sender: 'MalSat',
  //     text: `MalSat код: ${code}`,
  //     phones: [phone],
  //   }),
  // });
  // return response.ok;

  console.log(`[SMS] OTP for ${phone}: ${code}`);
  return true;
}
