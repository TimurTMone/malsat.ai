import { getDictionary } from "@/i18n/get-dictionary";
import type { Locale } from "@/i18n/config";
import { Header } from "@/components/layout/header";
import { User, Settings, ChevronRight, Star, Package, LogIn } from "lucide-react";
import Link from "next/link";

export default async function ProfilePage({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  const dict = await getDictionary(locale as Locale);

  // TODO: check auth state
  const isLoggedIn = false;

  if (!isLoggedIn) {
    return (
      <div className="flex flex-col">
        <Header locale={locale} dict={dict} />

        <div className="flex flex-1 flex-col items-center justify-center px-4 py-20 text-center">
          <div className="flex h-20 w-20 items-center justify-center rounded-full bg-malsat-green/10">
            <User className="h-10 w-10 text-malsat-green" />
          </div>
          <h2 className="mt-4 text-lg font-semibold">
            {locale === "ky" ? "Аккаунтуңузга кириңиз" : "Войдите в аккаунт"}
          </h2>
          <p className="mt-1 text-sm text-muted-foreground">
            {locale === "ky"
              ? "Жарыя берүү жана кабар жазуу үчүн"
              : "Чтобы размещать объявления и писать сообщения"}
          </p>
          <Link
            href={`/${locale}/auth/login`}
            className="mt-6 flex h-12 w-full max-w-xs items-center justify-center gap-2 rounded-xl bg-malsat-green font-semibold text-white transition-colors active:bg-malsat-green-dark"
          >
            <LogIn className="h-5 w-5" />
            {dict.common.login}
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="flex flex-col">
      <Header locale={locale} dict={dict} />

      {/* Profile info */}
      <div className="flex items-center gap-4 px-4 py-6">
        <div className="flex h-16 w-16 items-center justify-center rounded-full bg-malsat-green/10 text-2xl font-bold text-malsat-green">
          А
        </div>
        <div>
          <h2 className="text-lg font-semibold">Азамат</h2>
          <p className="text-sm text-muted-foreground">+996 555 123 456</p>
        </div>
      </div>

      {/* Menu items */}
      <div className="px-4">
        {[
          { icon: Package, label: dict.profile.myListings, href: `/${locale}/profile/listings` },
          { icon: Star, label: dict.profile.reviews, href: `/${locale}/profile/reviews` },
          { icon: Settings, label: dict.profile.settings, href: `/${locale}/profile/settings` },
        ].map((item) => (
          <Link
            key={item.href}
            href={item.href}
            className="flex h-14 items-center justify-between border-b border-border transition-colors active:bg-muted"
          >
            <div className="flex items-center gap-3">
              <item.icon className="h-5 w-5 text-muted-foreground" />
              <span className="text-sm font-medium">{item.label}</span>
            </div>
            <ChevronRight className="h-4 w-4 text-muted-foreground" />
          </Link>
        ))}
      </div>
    </div>
  );
}
