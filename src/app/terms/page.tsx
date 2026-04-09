import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Terms of Service — MalSat",
  description: "MalSat terms of service — rules and guidelines for using the platform.",
};

export default function TermsPage() {
  return (
    <html lang="ru">
      <body className="bg-white text-gray-900">
        <main className="mx-auto max-w-3xl px-6 py-12">
          <h1 className="mb-8 text-3xl font-bold">Terms of Service</h1>
          <p className="mb-4 text-sm text-gray-500">
            Last updated: April 9, 2026
          </p>

          <section className="space-y-6 text-base leading-relaxed">
            <div>
              <h2 className="mb-2 text-xl font-semibold">
                1. Acceptance of Terms
              </h2>
              <p>
                By downloading, installing, or using the MalSat mobile
                application or website (the &quot;Service&quot;), you agree to be
                bound by these Terms of Service (&quot;Terms&quot;). If you do not
                agree, do not use the Service.
              </p>
            </div>

            <div>
              <h2 className="mb-2 text-xl font-semibold">
                2. Description of Service
              </h2>
              <p>
                MalSat is a marketplace platform that connects livestock sellers
                and buyers in the Kyrgyz Republic. The Service allows users to:
              </p>
              <ul className="ml-6 list-disc space-y-1">
                <li>List livestock for sale (horses, cattle, sheep, etc.).</li>
                <li>
                  Create meat drops — sell freshly butchered meat by weight (kg).
                </li>
                <li>Browse and search listings by category, region, and price.</li>
                <li>Place orders for meat with specific weight amounts.</li>
                <li>Communicate with other users.</li>
                <li>Manage livestock inventory (herd management).</li>
              </ul>
            </div>

            <div>
              <h2 className="mb-2 text-xl font-semibold">
                3. Account Registration
              </h2>
              <ul className="ml-6 list-disc space-y-1">
                <li>
                  You must provide a valid phone number to create an account.
                </li>
                <li>
                  You are responsible for maintaining the security of your
                  account and all activities under it.
                </li>
                <li>You must be at least 16 years old to use the Service.</li>
                <li>
                  You agree to provide accurate and truthful information in your
                  profile and listings.
                </li>
              </ul>
            </div>

            <div>
              <h2 className="mb-2 text-xl font-semibold">
                4. Listings and Transactions
              </h2>
              <h3 className="mb-1 font-medium">4.1 Sellers</h3>
              <ul className="ml-6 list-disc space-y-1">
                <li>
                  You are responsible for the accuracy of your listings,
                  including weight, breed, health status, and pricing.
                </li>
                <li>
                  You must fulfill orders as described and within the agreed
                  timeframe.
                </li>
                <li>
                  Meat sellers must comply with all applicable food safety and
                  veterinary regulations of the Kyrgyz Republic.
                </li>
                <li>
                  You are solely responsible for the quality and safety of meat
                  and livestock sold.
                </li>
              </ul>

              <h3 className="mb-1 mt-4 font-medium">4.2 Buyers</h3>
              <ul className="ml-6 list-disc space-y-1">
                <li>
                  You are responsible for verifying listing details before
                  placing an order.
                </li>
                <li>
                  Payment is made directly between buyers and sellers. MalSat
                  does not process or hold payments.
                </li>
                <li>
                  Disputes between buyers and sellers should be resolved
                  directly. MalSat may assist but is not obligated to mediate.
                </li>
              </ul>
            </div>

            <div>
              <h2 className="mb-2 text-xl font-semibold">
                5. MalSat&apos;s Role
              </h2>
              <p>
                MalSat is a marketplace platform only. We do not own, sell, or
                inspect any livestock or meat products. We do not guarantee the
                quality, safety, legality, or accuracy of any listing. We are
                not a party to any transaction between users.
              </p>
            </div>

            <div>
              <h2 className="mb-2 text-xl font-semibold">
                6. Prohibited Conduct
              </h2>
              <p>You agree not to:</p>
              <ul className="ml-6 list-disc space-y-1">
                <li>Post false, misleading, or fraudulent listings.</li>
                <li>
                  Sell stolen livestock or meat products obtained illegally.
                </li>
                <li>
                  Harass, threaten, or abuse other users.
                </li>
                <li>
                  Use the Service for any purpose that violates laws of the
                  Kyrgyz Republic.
                </li>
                <li>
                  Attempt to manipulate prices, reviews, or the platform.
                </li>
                <li>
                  Create multiple accounts or impersonate others.
                </li>
              </ul>
            </div>

            <div>
              <h2 className="mb-2 text-xl font-semibold">
                7. Content Ownership
              </h2>
              <p>
                You retain ownership of content you post (photos, descriptions).
                By posting content, you grant MalSat a non-exclusive,
                royalty-free license to display that content within the Service
                for the purpose of operating the marketplace.
              </p>
            </div>

            <div>
              <h2 className="mb-2 text-xl font-semibold">
                8. Account Termination
              </h2>
              <p>
                We may suspend or terminate your account if you violate these
                Terms, engage in fraudulent activity, or receive repeated
                complaints from other users. You may delete your account at any
                time by contacting us.
              </p>
            </div>

            <div>
              <h2 className="mb-2 text-xl font-semibold">
                9. Limitation of Liability
              </h2>
              <p>
                To the maximum extent permitted by law, MalSat shall not be
                liable for any indirect, incidental, or consequential damages
                arising from your use of the Service, including but not limited
                to losses from transactions between users, quality of livestock
                or meat products, or disputes between buyers and sellers.
              </p>
            </div>

            <div>
              <h2 className="mb-2 text-xl font-semibold">
                10. Disclaimers
              </h2>
              <p>
                The Service is provided &quot;as is&quot; without warranties of
                any kind. We do not warrant that the Service will be
                uninterrupted, error-free, or secure. We do not endorse any
                seller, buyer, or listing on the platform.
              </p>
            </div>

            <div>
              <h2 className="mb-2 text-xl font-semibold">
                11. Governing Law
              </h2>
              <p>
                These Terms are governed by the laws of the Kyrgyz Republic. Any
                disputes shall be resolved in the courts of Bishkek, Kyrgyz
                Republic.
              </p>
            </div>

            <div>
              <h2 className="mb-2 text-xl font-semibold">
                12. Changes to Terms
              </h2>
              <p>
                We may update these Terms from time to time. Continued use of
                the Service after changes constitutes acceptance. We will notify
                users of material changes through the app or via SMS.
              </p>
            </div>

            <div>
              <h2 className="mb-2 text-xl font-semibold">13. Contact</h2>
              <p>For questions about these Terms:</p>
              <ul className="ml-6 mt-2 list-none space-y-1">
                <li>
                  Email:{" "}
                  <a
                    href="mailto:support@malsat.kg"
                    className="text-green-700 underline"
                  >
                    support@malsat.kg
                  </a>
                </li>
                <li>App: MalSat</li>
                <li>Country: Kyrgyz Republic</li>
              </ul>
            </div>
          </section>

          <footer className="mt-12 border-t pt-6 text-sm text-gray-400">
            &copy; 2026 MalSat. All rights reserved.
          </footer>
        </main>
      </body>
    </html>
  );
}
