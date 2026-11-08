# What’s new

## Development update — 8 November 2026

- Separated shopping-list entries from catalog products. Each list entry has its own identifier, product reference, quantity, and bought state.
- Adding, checking off, or removing an item now changes only the shopping list. It leaves the approved catalog record intact.
- Enforced the requirement for both Martin and Anna’s approval in the data store, including the iPhone swipe-to-add path.
- Migrated existing local product-array data into the new state format, preserving list quantities and bought status. The original saved data remains in place, and stable migrated identifiers prevent duplicate list entries if migration is retried.
- If saved data cannot be read, show a warning and leave it untouched rather than replacing it with the starter catalog.
- The app now blocks edits when saved data is unreadable, requires both member flags even if a stale approval field disagrees, and removes a list entry when editing revokes approval.
- UI tests now launch with a unique named UserDefaults suite. They cannot read or mutate the normal app settings store; tests do not use Reminders or a notes vault.
- Avoid duplicate iPhone/iPad search fields, hide shopping filters on the label guide, and show the chosen store in its toolbar control.
- Added isolated tests for approval enforcement, list lifecycle, legacy migration, and preserving unreadable saved data. Tests use their own temporary UserDefaults suite.
- Changed the Mac/iPad sidebar to a native selectable list with a visible current section. The Label guide is now a normal in-app destination; iPhone navigation uses a Browse menu.
- Moved Mac search into the toolbar and removed the duplicate market/store selector from the list pane.
- Market changes reset a store selection that is not offered in the new country; a regression UI test checks Sweden/ICA to Germany/All stores. CI verification is pending.

## Existing prototype — Version 0.1.0

- Added a SwiftUI project with iOS and macOS targets, a three-column Mac layout, an iPad split-view source path, and an iPhone navigation flow.
- Added 100 proposed food candidates in Resources/SeedProducts.json; all begin as unapproved suggestions without store assignments or price limits.
- Added local persistence for catalog and shopping-list state, a categorized/searchable list, and market/store filter controls.
- Added product detail and edit forms for exact brand/product, package size, selection/ingredient guidance, market-aware store choices, currency-tagged minimum/maximum price fields, and photo-library images.
- Added an English static label guide with Swedish and German nutrition terms.
- Added GitHub Actions CI to build iOS and run Mac tests on pushes and pull requests.

## Not delivered or verified

CloudKit/iCloud family sharing and cross-device sync are not implemented. Approval flags are local and do not authenticate who tapped them. The price model has no unit/package basis, branch, date, history, or separate per-market/store limits. The label guide does not scan labels. iOS/iPad runtime review, complete day/night screenshots, reviewer sign-off, and publishing remain outstanding. The public repository is https://github.com/marsch124/AMS-NutritionCompanion.
