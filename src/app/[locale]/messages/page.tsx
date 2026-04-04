import { getDictionary } from "@/i18n/get-dictionary";
import type { Locale } from "@/i18n/config";
import { Header } from "@/components/layout/header";
import { MessageCircle } from "lucide-react";

export default async function MessagesPage({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  const dict = await getDictionary(locale as Locale);

  return (
    <div className="flex flex-col">
      <Header locale={locale} dict={dict} />

      <div className="flex flex-1 flex-col items-center justify-center px-4 py-20 text-center">
        <div className="flex h-16 w-16 items-center justify-center rounded-full bg-muted">
          <MessageCircle className="h-8 w-8 text-muted-foreground/50" />
        </div>
        <p className="mt-4 text-sm text-muted-foreground">
          {dict.messages.noMessages}
        </p>
        <p className="mt-1 text-xs text-muted-foreground/70">
          {locale === "ky"
            ? "Жарыяга жооп жазганда кабарлар бул жерде пайда болот"
            : "Сообщения появятся здесь, когда вы напишете продавцу"}
        </p>
      </div>
    </div>
  );
}
