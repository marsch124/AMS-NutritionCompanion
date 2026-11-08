# AMS NutritionCompanion

A SwiftUI prototype, version 0.1.0, for Martin and Anna to browse a proposed household food catalog, build a shopping list, and keep product guidance close at hand.

## Current prototype

The Xcode project declares iOS and macOS app targets. Source code provides a three-column Mac layout, iPhone navigation, regular-width iPad split-view layout, search and market/store filters, product details and editing, photo-library package images, local price fields, separate Martin/Anna approval markers, and an English label guide with Swedish and German terms. Resources/SeedProducts.json contains 100 proposed candidates; they are not yet jointly approved, photographed, store-verified, or priced.

Product changes are encoded into UserDefaults on the device running the app. This gives the prototype local persistence and offline access on that device. It does not sync Martin’s data to Anna or to another device.

The Mac target was built and launched locally in Xcode. iPhone/iPad builds and runtime behavior have not been verified. Mac UI tests were blocked because XCTest could not enable automation mode, so no UI assertions ran. Complete screenshots, accessibility review, and publishing have not been verified.

## Important limits

- CloudKit/iCloud family sharing and sync are not implemented. No CloudKit capability is active in the app target and there is no sharing flow.
- Separate local Martin and Anna approval flags must both be set before adding a candidate to the list. They do not authenticate who tapped the controls.
- Seeded products have no store assignments or price limits. Store-specific filtering therefore needs household-entered product data before it can be useful.
- The editor stores exact product/package text, one selected store, one numeric minimum/maximum pair, and its currency per product. It does not record branch, price unit, observed-price date/history, or separate limits per market/store. Cross-currency values are not converted.
- Package photos are selected from the photo library; an in-app camera capture flow is not implemented.
- The label guide is static English text. It does not scan/OCR a package, calculate nutrition, or apply household thresholds.
- The iPad target family is declared, but its layout has not been reviewed or verified as an adaptive three-column experience.
- No live retailer prices or inventory are provided.

## Product direction

- Household: Martin and Anna; both should ultimately edit and explicitly approve shared products.
- First location: Norrköping, Sweden; interface language: English; Swedish and German label guides; Sweden/SEK and Germany/EUR market choices are present in the prototype.
- Initial store choices: ICA, Coop, Willys, Lidl, and Other.
- Food rules: plant-based, no meat or fish, plant-based dairy only, avoid mushrooms and garlic, and avoid ultra-processed foods. Plain oats, tofu, unsweetened plant yoghurt, and simple wholegrain bread are acceptable. No allergies were reported.
- Visual direction selected: **A — Quiet Pantry**.

## Documents

- [Product specification](Documentation/ProductSpec.md)
- [How it works](Documentation/HowItWorks.md)
- [What’s new](Documentation/WhatsNew.md)

## Setup and release status

Open AMSNutritionCompanion.xcodeproj in Xcode to inspect the declared targets and schemes. GitHub Actions configuration is in .github/workflows/ci.yml; no GitHub remote is connected. Configure the Apple Developer team and CloudKit container before implementing shared sync. Treat prototype data as disposable; use synthetic data and a separate test Apple account. Do not connect personal Reminders or a notes vault; they are outside this app’s scope.

No release has been published. Complete day/night screen captures, reviewer sign-off, iOS/iPad runtime checks, GitHub push/CI status, and publishing remain pending.
