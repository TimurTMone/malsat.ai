"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { Globe } from "lucide-react";
import type { Dictionary } from "@/i18n/get-dictionary";
import { localeNames, type Locale } from "@/i18n/config";

interface HeaderProps {
  locale: string;
  dict: Dictionary;
}

export function Header({ locale, dict }: HeaderProps) {
  const pathname = usePathname();

  const switchLocale = locale === "ky" ? "ru" : "ky";
  const switchPath = pathname.replace(`/${locale}`, `/${switchLocale}`);

  return (
    <header className="sticky top-0 z-40 border-b border-border bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/80">
      <div className="mx-auto flex h-14 max-w-6xl items-center justify-between px-4">
        <Link href={`/${locale}`} className="flex items-center gap-2">
          <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-malsat-green">
            <span className="text-sm font-bold text-white">M</span>
          </div>
          <span className="text-lg font-bold text-foreground">
            {dict.common.appName}
          </span>
        </Link>

        <Link
          href={switchPath}
          className="flex min-h-[44px] min-w-[44px] items-center justify-center gap-1.5 rounded-lg text-sm text-muted-foreground transition-colors hover:text-foreground active:bg-muted"
        >
          <Globe className="h-4 w-4" />
          <span>{localeNames[switchLocale as Locale]}</span>
        </Link>
      </div>
    </header>
  );
}
