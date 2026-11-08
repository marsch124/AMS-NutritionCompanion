# How it works

**Status:** Version 0.1.0. Mac app built and launched locally. iPhone/iPad runs and automated UI assertions remain unverified. Shared sync remains planned.

## Open and browse foods

On first load, the prototype reads saved product data from local UserDefaults, or loads the 100 proposed records from Resources/SeedProducts.json if nothing is saved. On subsequent edits it saves the encoded product array back to UserDefaults. This is device-local persistence for offline use; it does not share data with Anna or another device.

Browse the separate Product library and search by food name or category. The shopping list starts empty; open a candidate and, after both local Martin and Anna approval flags are set, add it to the list. Choose Sweden/SEK or Germany/EUR and optionally ICA, Coop, Willys, Lidl, or Other. Proposed seed products have no store assignments, so filtering to one retailer can hide those products until a store is added.

## Shopping list and product details

The app includes check-off controls and lets an iPhone shopper add or remove an item from the list with a swipe action. Product detail shows category, approval state, selection guidance, ingredient/processing criteria, store, and numeric price limits if present. Mac supports a three-column split view. These flows have been observed on Mac but have not passed automated UI tests.

Two separate approval actions store Martin's and Anna's local approval flags. Both must be set before an item can be added to the list. The app does not authenticate the person operating either action.

## Edit a product and photo

Add or edit a food name, exact brand/product, package size/unit, category, selection tip, ingredient/processing note, one store, minimum/maximum numeric price values, and package photo. Choose a photo from the device photo library; the image bytes are stored with the local product record. Direct camera capture, branch detail, price observations/history, and separate per-market/store ranges are not implemented.

The prototype stores one price range and its currency per product. If viewed under a different market currency, it identifies the saved currency and does not convert the value. Package/unit basis and separate limits per market/store are still missing.

## Read label terms

Open the static English label guide to see Swedish and German terms for energy, fat, saturated fat, carbohydrates, sugars, fibre, protein, and salt, plus brief ingredient-list guidance. It does not scan or interpret a package and does not include personalized nutrition thresholds, automated comparisons, or a health score.

## What happens when offline

Edits persist locally through UserDefaults, so the same app installation can reload saved product data offline. There is no sync queue, CloudKit operation, family invitation, conflict resolution, or cross-device backup.

## Before relying on the app

The Mac target builds and runs locally. iOS/iPad simulator/device runs, exhaustive day/night screen pictures, reviewer sign-off, UI automation, and release are not verified. The public repository is https://github.com/marsch124/AMS-NutritionCompanion; its CI workflow reached the iOS build and exposed a toolbar-builder compile error that is being fixed. The 100 candidates are unapproved suggestions; stores and prices need household entry. Use synthetic disposable data until sync, backups, and privacy behavior are implemented and tested. Personal Reminders and vault data are not used by this app.
