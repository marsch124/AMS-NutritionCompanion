# Product specification

**Status:** Version 0.1.0. The Mac app has built and run locally; the iPhone/iPad build, UI tests, iCloud sync, screenshots, and publication are not verified. This document separates current behavior from the intended household product.

## Purpose

Help Martin shop accurately for the household with Anna. The intended app should show which exact product they have jointly approved, where they have found it, how to recognize a good individual item, and the agreed price guardrail. For unfamiliar packages, it should help the shopper read the label and apply their own household rules.

## Household and launch scope

- Household members: Martin and Anna. The goal is for both to edit and explicitly approve the shared catalog and shopping list.
- First market: Norrköping, Sweden; interface language: English; first currency: SEK.
- Initial Sweden store choices: ICA, Coop, Willys, Lidl. Germany market selection and common German retailer choices (Aldi, Edeka, REWE, Lidl) are present as editable starting options.
- Food rules: no meat or fish; plant-based dairy only; avoid mushrooms and garlic; no ultra-processed foods. Plain oats, tofu, unsweetened plant yoghurt, and simple additive-conscious wholegrain bread are acceptable. No allergies were reported.
- Selected design direction: **A — Quiet Pantry**.

## Present in the prototype source

- SwiftUI app targets are declared for iOS and macOS. macOS uses a three-column NavigationSplitView; iPhone uses a NavigationStack; regular-width iPad source uses a three-column NavigationSplitView.
- A categorized food list, search, completion toggles, an add-to-list swipe action on iOS, and market/store filters are defined.
- Product detail presents selection tips, ingredient/processing criteria, store and price text, and separate local approval flags for Martin and Anna. A candidate is marked approved only after both flags are set; this does not authenticate who tapped either control.
- Product add/edit fields include name, category, exact brand/product, package size/unit, selection tip, ingredient/processing criteria, one store, numeric minimum/maximum prices, and a photo-library selection.
- An English static label guide includes common nutrition terms in Swedish and German.
- Resources/SeedProducts.json contains 100 proposed candidate records. Seeded records are marked unapproved, have empty store assignments, and have no prefilled price limits.
- Product data and selected package-photo bytes are saved locally via UserDefaults, so the prototype has a local persistence path and is designed to load saved data offline on that device.

The points above describe source code and local Mac observation. The iPhone/iPad build/run, automated UI assertions, full screen review, screenshot set, and accessibility verification remain unconfirmed.

## Current prototype limits

- **No shared sync:** The app has no active CloudKit capability or code, household invitation flow, sync state, conflict handling, or confirmed CloudKit container/signing configuration. UserDefaults is local to the running app installation.
- **Approval is not authenticated:** Two separate buttons record local Martin/Anna approval flags. There is no household identity or server-side proof that each person approved.
- **Store filtering needs data:** The seed records have empty store lists. A specific store filter can exclude those records until the household adds store assignments. The editor supports one store per product and no branch/location detail.
- **Price fields are incomplete:** The prototype stores one min/max numeric pair with its currency, but no unit/package basis, observed price, date/history, or separate per-market/per-store limits. If viewed in another currency, the app identifies the original currency and does not convert the value. Do not use it as a cross-market comparison.
- **Photo capture:** A photo can be selected from the photo library. Direct in-app camera capture is not implemented.
- **Label help:** The guide is static English text. There is no barcode scan, OCR, label parsing, nutritional calculation, or editable household threshold system.
- No live retailer availability, product images, exact brands, or prices are supplied by the catalog.
- iPhone/iPad builds and runs, simulator screenshots, day/night screen inventory review, and release/publishing have not been verified. The local Mac app has been built and launched.

## Intended core experience

1. Open the current shared list offline, select a market and store, search or browse foods, and mark purchased items.
2. Open a product to see its jointly approved exact product, package photo, store notes, selection/ripeness tips, and an understandable price guardrail.
3. Enter observed price with currency, store/branch, package size or unit, and date. Keep acceptable ranges specific to market, store, and unit.
4. When the chosen product is unavailable or over its limit, offer only an explicitly approved alternative; otherwise make it easy to defer and ask Anna.
5. Either member can propose or edit a candidate. Keep it visibly unapproved until each required household member has approved it.
6. Use Swedish or German label guidance to understand local terms and compare them with household-authored rules. Do not invent thresholds, provide medical advice, or apply a general health score.

## The 100 proposed starter candidates

All 100 entries are proposals from Resources/SeedProducts.json. They are not yet jointly approved, retailer-verified, photographed, or priced. Check every packaged item for garlic, mushrooms, animal dairy, meat, fish, and unnecessary additives before approving it.

**Berries (13):** Blueberries, fresh; Raspberries, fresh; Strawberries, fresh; Blackberries, fresh; Lingonberries, fresh; Red currants, fresh; Black currants, fresh; Gooseberries, fresh; Blueberries, frozen; Raspberries, frozen; Strawberries, frozen; Mixed forest berries, frozen; Black currants, frozen.

**Fruit (15):** Apples; Pears; Bananas; Oranges; Clementines; Lemons; Kiwifruit; Avocados; Grapes; Plums; Peaches or nectarines; Melon; Pineapple; Pomegranate; Mango.

**Vegetables (28):** Carrots; Broccoli; Cauliflower; Red cabbage; Savoy cabbage; Kale; Spinach; Romaine lettuce; Tomatoes; Red bell peppers; Cucumber; Zucchini; Aubergine; Sweet potatoes; Potatoes; Beetroot; Parsnips; Yellow onions; Leeks; Celery stalks; Asparagus; Green beans; Green peas; Brussels sprouts; Fennel bulb; Celeriac; Radishes; Pumpkin.

**Beans and legumes (14):** Green lentils, dried; Red lentils, dried; Chickpeas, dried; Chickpeas, canned; Black beans, canned; Kidney beans, canned; Cannellini beans, canned; Brown beans, canned; Yellow split peas, dried; Edamame, frozen; Firm tofu, plain; Silken tofu, plain; Tempeh, plain; Mung beans, dried.

**Nuts and seeds (13):** Walnuts, unsalted; Almonds, unsalted; Hazelnuts, unsalted; Pistachios, unsalted; Cashews, unsalted; Peanuts, unsalted; Chia seeds; Ground flaxseed; Pumpkin seeds, unsalted; Sunflower seeds, unsalted; Hemp seeds, hulled; Sesame seeds; Tahini, plain.

**Whole grains (10):** Rolled oats; Steel-cut oats; Buckwheat groats; Pearl barley; Quinoa; Brown rice; Rye kernels; Wholegrain rye crispbread; Wholegrain rye bread; Whole-wheat pasta.

**Plant-based staples (4):** Unsweetened soy yoghurt, plain; Unsweetened oat yoghurt, plain; Unsweetened soy drink, plain; Unsweetened oat drink, plain.

**Cooking staples (3):** Extra-virgin olive oil; Cold-pressed rapeseed oil; Tomato passata, plain.

## Nutrition label guide requirements

Explain serving basis and per-100 g/ml comparisons; energy; fat and saturated fat; carbohydrates and sugars; fibre; protein; salt; and ingredient/allergen statements. Show Swedish and German package terms alongside plain English. Household thresholds and rules must be set by Martin and Anna, shown with units and scope, and never inferred by the app.

## Intended sync, privacy, and safeguards

The target is private iCloud sharing between Martin and Anna, with offline local use and transparent sync status. Implementing this requires the correct Apple team, app identifiers, CloudKit container, entitlements, sharing/acceptance flow, conflict handling, and recovery behavior. None is implemented or verified yet. Use synthetic data and a separate test account during development. Do not touch personal Reminders or vault data; integrations with them are out of scope.

## Out of scope

Live retailer inventory/pricing; general health scoring; medical/diet claims; public/social sharing; meat/fish/animal dairy; and Reminders integration.

## Future release acceptance

- Both members can edit products and lists, with attributable joint approval and a visible, reliable sync state.
- The shopping list works offline and filters correctly by market, city, store, and branch.
- Product guidance includes household photos, exact approved choices, selection tips, approved alternatives, and unit-aware manual price limits/history.
- Swedish and German guide flows explain label terms and household rules without a generic score or invented thresholds.
- iPhone, iPad, and Mac layouts, every listed screen/sheet/menu, accessibility, and light/dark appearance are reviewed and captured before release.
- Build, sync, and UI behavior are verified in test environments; no real household data or Reminders are used in testing.
