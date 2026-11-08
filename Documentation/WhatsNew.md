# What’s new

## Current prototype — 7 November 2026

This is a development snapshot, not a published release. The app displays version 0.1.0.

- Added a SwiftUI project with iOS and macOS targets, a three-column Mac layout, an iPad split-view source path, and an iPhone navigation flow.
- Added 100 proposed food candidates in Resources/SeedProducts.json; all begin as unapproved suggestions without store assignments or price limits.
- Added local UserDefaults persistence for product records and a categorized/searchable list with market and store filter controls.
- Added product detail and edit forms for exact brand/product, package size, selection/ingredient guidance, market-aware store choices, currency-tagged minimum/maximum price fields, and photo-library images.
- Added an English static label guide with Swedish and German nutrition terms.
- Added separate local Martin and Anna approval flags; both are required before a candidate can be added to the shopping list.
- Added GitHub Actions CI configuration to build iOS and run Mac UI tests on pushes and pull requests.

## Not delivered or verified

CloudKit/iCloud family sharing and cross-device sync are not implemented. Approval flags are local and do not authenticate who tapped them. The price model has no unit/package basis, branch, date, history, or separate per-market/store limits. The label guide does not scan labels. The Mac app builds and launches locally; iOS/iPad builds, simulator runs, complete day/night screenshots, automated UI assertions, reviewer sign-off, and publishing have not been verified. The public repository is https://github.com/marsch124/AMS-NutritionCompanion. Its first public Actions run exposed an iOS toolbar-builder compile error; verification is in progress.
