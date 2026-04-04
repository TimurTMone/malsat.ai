export const locales = ["ky", "ru"] as const;
export type Locale = (typeof locales)[number];
export const defaultLocale: Locale = "ky";

export const localeNames: Record<Locale, string> = {
  ky: "Кыргызча",
  ru: "Русский",
};
