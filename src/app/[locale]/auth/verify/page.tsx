"use client";

import { useState, useEffect, useRef, Suspense } from "react";
import { useParams, useRouter, useSearchParams } from "next/navigation";
import { ArrowLeft } from "lucide-react";
import Link from "next/link";

export default function VerifyPage() {
  return (
    <Suspense fallback={<div className="flex min-h-screen items-center justify-center">...</div>}>
      <VerifyContent />
    </Suspense>
  );
}

function VerifyContent() {
  const params = useParams();
  const router = useRouter();
  const searchParams = useSearchParams();
  const locale = params.locale as string;
  const phone = searchParams.get("phone") || "";
  const isKy = locale === "ky";

  const [code, setCode] = useState(["", "", "", "", "", ""]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [resendTimer, setResendTimer] = useState(60);
  const inputRefs = useRef<(HTMLInputElement | null)[]>([]);

  useEffect(() => {
    if (resendTimer > 0) {
      const timer = setTimeout(() => setResendTimer(resendTimer - 1), 1000);
      return () => clearTimeout(timer);
    }
  }, [resendTimer]);

  const handleChange = (index: number, value: string) => {
    if (!/^\d*$/.test(value)) return;

    const newCode = [...code];
    newCode[index] = value.slice(-1);
    setCode(newCode);

    if (value && index < 5) {
      inputRefs.current[index + 1]?.focus();
    }

    // Auto-submit when all digits entered
    if (newCode.every((d) => d) && newCode.join("").length === 6) {
      handleVerify(newCode.join(""));
    }
  };

  const handleKeyDown = (index: number, e: React.KeyboardEvent) => {
    if (e.key === "Backspace" && !code[index] && index > 0) {
      inputRefs.current[index - 1]?.focus();
    }
  };

  const handleVerify = async (otpCode: string) => {
    setError("");
    setLoading(true);

    try {
      const res = await fetch("/api/auth/verify", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ phone, code: otpCode }),
      });

      const data = await res.json();

      if (!res.ok) {
        throw new Error(data.error || "Failed");
      }

      // Store tokens
      document.cookie = `auth_token=${data.accessToken}; path=/; max-age=${60 * 60 * 24 * 30}`;
      localStorage.setItem("refresh_token", data.refreshToken);

      router.push(`/${locale}`);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Error");
      setCode(["", "", "", "", "", ""]);
      inputRefs.current[0]?.focus();
    } finally {
      setLoading(false);
    }
  };

  const handleResend = async () => {
    if (resendTimer > 0) return;
    setResendTimer(60);
    await fetch("/api/auth/login", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ phone }),
    });
  };

  return (
    <div className="flex min-h-screen flex-col bg-background">
      <div className="flex h-14 items-center px-4">
        <Link
          href={`/${locale}/auth/login`}
          className="flex h-10 w-10 items-center justify-center rounded-full transition-colors active:bg-muted"
        >
          <ArrowLeft className="h-5 w-5" />
        </Link>
      </div>

      <div className="flex flex-1 flex-col px-6 pt-8">
        <h1 className="text-2xl font-bold">
          {isKy ? "Кодду киргизиңиз" : "Введите код"}
        </h1>
        <p className="mt-2 text-sm text-muted-foreground">
          {isKy
            ? `SMS код ${phone} номерине жөнөтүлдү`
            : `SMS-код отправлен на ${phone}`}
        </p>

        {/* OTP Input */}
        <div className="mt-8 flex justify-center gap-2">
          {code.map((digit, index) => (
            <input
              key={index}
              ref={(el) => { inputRefs.current[index] = el; }}
              type="text"
              inputMode="numeric"
              maxLength={1}
              value={digit}
              onChange={(e) => handleChange(index, e.target.value)}
              onKeyDown={(e) => handleKeyDown(index, e)}
              className="h-14 w-12 rounded-xl border border-border bg-card text-center text-xl font-bold outline-none transition-colors focus:border-malsat-green focus:ring-1 focus:ring-malsat-green"
              autoFocus={index === 0}
            />
          ))}
        </div>

        {error && (
          <p className="mt-4 text-center text-sm text-destructive">{error}</p>
        )}

        {loading && (
          <p className="mt-4 text-center text-sm text-muted-foreground">
            {isKy ? "Текшерилүүдө..." : "Проверка..."}
          </p>
        )}

        {/* Resend */}
        <div className="mt-6 text-center">
          {resendTimer > 0 ? (
            <p className="text-sm text-muted-foreground">
              {isKy
                ? `${resendTimer} секунддан кийин кайра жөнөтүү`
                : `Повторная отправка через ${resendTimer} сек`}
            </p>
          ) : (
            <button
              onClick={handleResend}
              className="text-sm font-medium text-malsat-green"
            >
              {isKy ? "Кодду кайра жөнөтүү" : "Отправить код повторно"}
            </button>
          )}
        </div>
      </div>
    </div>
  );
}
