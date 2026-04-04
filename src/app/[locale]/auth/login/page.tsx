"use client";

import { useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { ArrowLeft, Phone } from "lucide-react";
import Link from "next/link";

export default function LoginPage() {
  const params = useParams();
  const router = useRouter();
  const locale = params.locale as string;
  const [phone, setPhone] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const isKy = locale === "ky";

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    setLoading(true);

    try {
      const res = await fetch("/api/auth/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ phone: phone.replace(/\s/g, "") }),
      });

      if (!res.ok) {
        const data = await res.json();
        throw new Error(data.error || "Failed");
      }

      router.push(`/${locale}/auth/verify?phone=${encodeURIComponent(phone.replace(/\s/g, ""))}`);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Error");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex min-h-screen flex-col bg-background">
      {/* Back button */}
      <div className="flex h-14 items-center px-4">
        <Link
          href={`/${locale}`}
          className="flex h-10 w-10 items-center justify-center rounded-full transition-colors active:bg-muted"
        >
          <ArrowLeft className="h-5 w-5" />
        </Link>
      </div>

      <div className="flex flex-1 flex-col px-6 pt-8">
        {/* Logo */}
        <div className="flex h-16 w-16 items-center justify-center rounded-2xl bg-malsat-green">
          <span className="text-2xl font-bold text-white">M</span>
        </div>

        <h1 className="mt-6 text-2xl font-bold">
          {isKy ? "MalSat'ка кирүү" : "Вход в MalSat"}
        </h1>
        <p className="mt-2 text-sm text-muted-foreground">
          {isKy
            ? "Телефон номериңизди киргизиңиз"
            : "Введите ваш номер телефона"}
        </p>

        <form onSubmit={handleSubmit} className="mt-8">
          <label className="text-sm font-medium">
            {isKy ? "Телефон номери" : "Номер телефона"}
          </label>
          <div className="relative mt-2">
            <Phone className="absolute left-4 top-1/2 h-5 w-5 -translate-y-1/2 text-muted-foreground" />
            <input
              type="tel"
              value={phone}
              onChange={(e) => setPhone(e.target.value)}
              placeholder="+996 XXX XXX XXX"
              className="h-14 w-full rounded-xl border border-border bg-card pl-12 pr-4 text-base outline-none transition-colors focus:border-malsat-green focus:ring-1 focus:ring-malsat-green"
              autoFocus
            />
          </div>

          {error && (
            <p className="mt-2 text-sm text-destructive">{error}</p>
          )}

          <button
            type="submit"
            disabled={phone.length < 10 || loading}
            className="mt-6 h-14 w-full rounded-xl bg-malsat-green font-semibold text-white text-base transition-colors active:bg-malsat-green-dark disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {loading
              ? (isKy ? "Жүктөлүүдө..." : "Загрузка...")
              : (isKy ? "Код жөнөтүү" : "Отправить код")}
          </button>
        </form>
      </div>
    </div>
  );
}
