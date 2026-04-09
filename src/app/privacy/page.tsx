import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Privacy Policy — MalSat",
  description: "MalSat privacy policy — how we collect, use, and protect your data.",
};

export default function PrivacyPage() {
  return (
    <html lang="ru">
      <body className="bg-white text-gray-900">
        <main className="mx-auto max-w-3xl px-6 py-12">
          <h1 className="mb-8 text-3xl font-bold">Privacy Policy</h1>
          <p className="mb-4 text-sm text-gray-500">
            Last updated: April 9, 2026
          </p>

          <section className="space-y-6 text-base leading-relaxed">
            <div>
              <h2 className="mb-2 text-xl font-semibold">1. Introduction</h2>
              <p>
                MalSat (&quot;we&quot;, &quot;our&quot;, &quot;us&quot;) operates
                the MalSat mobile application and website (the
                &quot;Service&quot;). This Privacy Policy explains how we
                collect, use, disclose, and safeguard your information when you
                use our Service.
              </p>
            </div>

            <div>
              <h2 className="mb-2 text-xl font-semibold">
                2. Information We Collect
              </h2>
              <h3 className="mb-1 font-medium">
                2.1 Information you provide directly
              </h3>
              <ul className="ml-6 list-disc space-y-1">
                <li>
                  <strong>Phone number</strong> — used for account creation and
                  SMS-based authentication (OTP verification).
                </li>
                <li>
                  <strong>Profile information</strong> — name, profile photo,
                  and optional bio that you choose to provide.
                </li>
                <li>
                  <strong>Listing content</strong> — photos, descriptions,
                  prices, and location data for livestock and meat listings you
                  create.
                </li>
                <li>
                  <strong>Payment information</strong> — QR codes and bank
                  transfer details that sellers provide for receiving payments.
                  We do not process payments directly.
                </li>
                <li>
                  <strong>Messages</strong> — content of messages exchanged
                  between buyers and sellers through the app.
                </li>
              </ul>

              <h3 className="mb-1 mt-4 font-medium">
                2.2 Information collected automatically
              </h3>
              <ul className="ml-6 list-disc space-y-1">
                <li>
                  <strong>Device information</strong> — device type, operating
                  system, and app version.
                </li>
                <li>
                  <strong>Usage data</strong> — pages viewed, features used, and
                  interaction patterns.
                </li>
                <li>
                  <strong>Location data</strong> — approximate location (only
                  when you grant permission) to show nearby listings and tag your
                  listings with a region.
                </li>
              </ul>
            </div>

            <div>
              <h2 className="mb-2 text-xl font-semibold">
                3. How We Use Your Information
              </h2>
              <ul className="ml-6 list-disc space-y-1">
                <li>To create and manage your account via SMS verification.</li>
                <li>
                  To display livestock and meat listings to potential buyers.
                </li>
                <li>
                  To facilitate communication between buyers and sellers.
                </li>
                <li>To process and track meat drop orders.</li>
                <li>
                  To show relevant listings based on your location and
                  preferences.
                </li>
                <li>To improve and maintain the Service.</li>
                <li>To send important service notifications via SMS.</li>
              </ul>
            </div>

            <div>
              <h2 className="mb-2 text-xl font-semibold">
                4. Camera and Photo Library
              </h2>
              <p>
                We request access to your camera and photo library solely to
                allow you to take and attach photos of livestock for listings.
                Photos are uploaded to our servers and displayed within the app.
                We do not access your camera or photos for any other purpose.
              </p>
            </div>

            <div>
              <h2 className="mb-2 text-xl font-semibold">5. Location Data</h2>
              <p>
                Location access is optional. When granted, we use your
                approximate location to tag listings with a region and show
                nearby livestock for sale. You can revoke location permission at
                any time through your device settings.
              </p>
            </div>

            <div>
              <h2 className="mb-2 text-xl font-semibold">
                6. Data Sharing and Disclosure
              </h2>
              <p>We do not sell your personal information. We may share data:</p>
              <ul className="ml-6 list-disc space-y-1">
                <li>
                  <strong>With other users</strong> — your public profile, listings,
                  and messages are visible to relevant users.
                </li>
                <li>
                  <strong>With service providers</strong> — hosting (Vercel),
                  SMS delivery, and image storage services that help operate the
                  Service.
                </li>
                <li>
                  <strong>As required by law</strong> — to comply with legal
                  obligations in the Kyrgyz Republic.
                </li>
              </ul>
            </div>

            <div>
              <h2 className="mb-2 text-xl font-semibold">7. Data Security</h2>
              <p>
                We use industry-standard security measures including HTTPS
                encryption for all data in transit and secure token storage on
                your device. However, no method of transmission over the
                Internet is 100% secure.
              </p>
            </div>

            <div>
              <h2 className="mb-2 text-xl font-semibold">
                8. Data Retention
              </h2>
              <p>
                We retain your account data for as long as your account is
                active. Listing data is retained for 12 months after a listing
                expires. You may request deletion of your account and associated
                data at any time by contacting us.
              </p>
            </div>

            <div>
              <h2 className="mb-2 text-xl font-semibold">9. Your Rights</h2>
              <p>You have the right to:</p>
              <ul className="ml-6 list-disc space-y-1">
                <li>Access the personal data we hold about you.</li>
                <li>Request correction of inaccurate data.</li>
                <li>Request deletion of your account and data.</li>
                <li>Withdraw consent for optional data collection (e.g., location).</li>
              </ul>
            </div>

            <div>
              <h2 className="mb-2 text-xl font-semibold">
                10. Children&apos;s Privacy
              </h2>
              <p>
                Our Service is not directed to children under 16. We do not
                knowingly collect personal information from children under 16.
              </p>
            </div>

            <div>
              <h2 className="mb-2 text-xl font-semibold">
                11. Changes to This Policy
              </h2>
              <p>
                We may update this Privacy Policy from time to time. We will
                notify you of changes by updating the &quot;Last updated&quot;
                date at the top. Continued use of the Service after changes
                constitutes acceptance of the updated policy.
              </p>
            </div>

            <div>
              <h2 className="mb-2 text-xl font-semibold">12. Contact Us</h2>
              <p>
                If you have questions about this Privacy Policy, contact us at:
              </p>
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
