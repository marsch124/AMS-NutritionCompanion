# How it works

**Status:** Version 0.1.0 development prototype, updated 8 November 2026. GitHub CI builds the iOS target and passes the Mac unit and UI tests. The Mac app has been built and launched locally. iPhone/iPad runtime review and household sync are still outstanding.

## Product catalog and shopping list

The catalog stores food identity, household approval, selection guidance, store and price notes, and package-photo data. Shopping-list entries are separate records that refer to a catalog product and keep their own quantity and bought state. Adding, checking off, or removing a list entry does not change the catalog product.

Only products with both local Martin and Anna approval flags can be added. The store enforces that rule for the product detail button and the iPhone swipe action. The approval buttons are local flags; the app does not verify who pressed them.

On a new install, the app loads the 100 proposed records from Resources/SeedProducts.json. Changes are saved on the device in UserDefaults using one versioned state record. The list is available offline on that device; it is not shared with Anna.

## Existing saved data

The previous prototype saved a product array under `ams.pantry.products.v1`, with list quantity and bought status mixed into product records. On launch, the app migrates that array to `ams.pantry.state.v2`: product details stay in the catalog, while each existing list item becomes its own entry with its quantity and bought status. Migrated list entry identifiers are derived from the old product identifiers, so retrying migration does not create duplicate rows. The old saved copy is left in place.

If saved data cannot be read, the app shows a warning and does not replace it with seed data. The data and migration tests use a dedicated temporary UserDefaults suite; they do not use the normal app settings store.

## Browse and shop

Browse Product library and search by food name or category. The shopping list starts empty unless existing saved data is migrated. Choose Sweden/SEK or Germany/EUR and optionally ICA, Coop, Willys, Lidl, or Other. Proposed seed products have no store assignments, so filtering to one retailer can hide them until a store is added.

Product details show category, approval state, selection guidance, ingredient/processing criteria, store, and numeric price limits if present. The editor accepts an exact brand/product, package size/unit, category, selection tips, ingredient/processing notes, one store, a minimum/maximum price, and a package photo selected from the photo library. Direct camera capture, branch detail, price observations/history, and separate per-market/store ranges are not implemented.

The prototype stores one price range and its currency per product. If viewed under another market currency, it identifies the saved currency and does not convert the value. Package/unit basis and separate limits per market/store are still missing.

## Read label terms

Open the static English label guide to see Swedish and German terms for energy, fat, saturated fat, carbohydrates, sugars, fibre, protein, and salt, plus brief ingredient-list guidance. It does not scan or interpret a package and does not include personalized nutrition thresholds, automated comparisons, or a health score.

## Verification and remaining work

GitHub Actions passed the iOS target build, three isolated data/persistence tests, and two Mac UI tests on 8 November 2026. The UI tests exercise stable accessibility identifiers, joint approval, and adding an approved product to the list. The Mac app has been built and launched locally. iOS/iPad simulator and device behavior, full day/night screenshots, reviewer sign-off, iCloud sync, and release have not been verified.

The public repository is https://github.com/marsch124/AMS-NutritionCompanion. Use synthetic data during development. Personal Reminders and vault data are not used by this app.
