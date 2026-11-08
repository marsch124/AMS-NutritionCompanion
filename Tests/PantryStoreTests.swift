import XCTest
@testable import AMSNutritionCompanionMac

@MainActor
final class PantryStoreTests: XCTestCase {
    func testShoppingListLifecycleDoesNotChangeApprovedCatalogProduct() throws {
        let suiteName = "ams.pantry.tests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let approvedProduct = PantryProduct(
            id: "green-lentils",
            name: "Green lentils",
            category: "Beans",
            suggestedProduct: nil,
            packageSize: nil,
            ingredientsCriteria: "Whole dried lentils",
            selectionGuide: "Choose an intact package",
            countries: ["SE"],
            approved: true,
            martinApproved: true,
            annaApproved: true,
            stores: [],
            minimumPrice: nil,
            maximumPrice: nil,
            priceCurrency: nil
        )
        let unapprovedProduct = PantryProduct(
            id: "suggested-berries",
            name: "Suggested berries",
            category: "Berries",
            suggestedProduct: nil,
            packageSize: nil,
            ingredientsCriteria: "Whole berries",
            selectionGuide: "Choose fresh fruit",
            countries: ["SE"],
            approved: false,
            stores: [],
            minimumPrice: nil,
            maximumPrice: nil
        )
        let store = PantryStore(defaults: defaults, seedProducts: [approvedProduct, unapprovedProduct])

        XCTAssertTrue(store.addToShoppingList(productID: approvedProduct.id, quantity: "2 bags"))
        XCTAssertFalse(store.addToShoppingList(productID: unapprovedProduct.id, quantity: "1"))
        let item = try XCTUnwrap(store.shoppingListEntries.first)
        XCTAssertEqual(item.productID, approvedProduct.id)
        XCTAssertEqual(item.quantity, "2 bags")
        XCTAssertFalse(store.addToShoppingList(productID: approvedProduct.id, quantity: "1"))

        store.toggleShoppingListItem(item.id)
        XCTAssertTrue(try XCTUnwrap(store.shoppingListEntry(for: approvedProduct.id)).isChecked)
        store.removeShoppingListItem(item.id)

        XCTAssertTrue(store.shoppingListEntries.isEmpty)
        XCTAssertTrue(try XCTUnwrap(store.product(approvedProduct.id)).approved)
        XCTAssertTrue(try XCTUnwrap(store.product(approvedProduct.id)).martinApproved)

        let reloaded = PantryStore(defaults: defaults, seedProducts: [])
        XCTAssertTrue(reloaded.shoppingListEntries.isEmpty)
        XCTAssertTrue(try XCTUnwrap(reloaded.product(approvedProduct.id)).approved)
    }

    func testLegacySavedListMigratesWithoutChangingItsOriginalCopy() throws {
        let suiteName = "ams.pantry.tests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let legacyKey = "ams.pantry.products.v1"
        let legacyData = Data(#"[{"id":"legacy-oats","name":"Oats","category":"Grains","ingredientsCriteria":"Whole oats","selectionGuide":"Choose plain oats","countries":["SE"],"approved":true,"martinApproved":true,"annaApproved":true,"stores":[],"minimumPrice":null,"maximumPrice":null,"priceCurrency":null,"listQuantity":"2 bags","checked":true}]"#.utf8)
        defaults.set(legacyData, forKey: legacyKey)

        let migratedStore = PantryStore(defaults: defaults, seedProducts: [])
        let migratedEntry = try XCTUnwrap(migratedStore.shoppingListEntries.first)
        XCTAssertEqual(migratedEntry.productID, "legacy-oats")
        XCTAssertEqual(migratedEntry.quantity, "2 bags")
        XCTAssertTrue(migratedEntry.isChecked)
        XCTAssertEqual(defaults.data(forKey: legacyKey), legacyData)
        XCTAssertNotNil(defaults.data(forKey: "ams.pantry.state.v2"))

        let reloaded = PantryStore(defaults: defaults, seedProducts: [])
        XCTAssertEqual(reloaded.shoppingListEntries.count, 1)
        XCTAssertEqual(reloaded.shoppingListEntries.first?.id, migratedEntry.id)
    }

    func testUnreadableLegacyDataIsPreservedInsteadOfReplacedWithSeedProducts() throws {
        let suiteName = "ams.pantry.tests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let legacyKey = "ams.pantry.products.v1"
        let unreadableData = Data("not valid saved data".utf8)
        defaults.set(unreadableData, forKey: legacyKey)

        let store = PantryStore(defaults: defaults, seedProducts: [sampleProduct()])

        XCTAssertTrue(store.products.isEmpty)
        XCTAssertNotNil(store.persistenceWarning)
        XCTAssertEqual(defaults.data(forKey: legacyKey), unreadableData)
        XCTAssertNil(defaults.data(forKey: "ams.pantry.state.v2"))
    }

    func testApprovedFlagAloneCannotAddFoodWithoutBothMemberApprovals() {
        let suiteName = "ams.pantry.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let inconsistent = sampleProduct(approved: true)
        let store = PantryStore(defaults: defaults, seedProducts: [inconsistent])

        XCTAssertFalse(store.addToShoppingList(productID: inconsistent.id))
        XCTAssertTrue(store.shoppingListEntries.isEmpty)
    }

    func testRemovingApprovalAlsoRemovesExistingShoppingEntry() {
        let suiteName = "ams.pantry.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        var product = sampleProduct(approved: true, martinApproved: true, annaApproved: true)
        let store = PantryStore(defaults: defaults, seedProducts: [product])
        XCTAssertTrue(store.addToShoppingList(productID: product.id))

        product.approved = false
        product.martinApproved = false
        product.annaApproved = false
        store.update(product)

        XCTAssertTrue(store.shoppingListEntries.isEmpty)
    }

    func testUnreadableSavedDataBlocksMutationsAndPreservesOriginalBytes() {
        let suiteName = "ams.pantry.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let badData = Data("unreadable".utf8)
        defaults.set(badData, forKey: "ams.pantry.state.v2")
        let store = PantryStore(defaults: defaults, seedProducts: [sampleProduct()])

        store.add(sampleProduct())
        store.setApproval(sampleProduct(), householdMember: "Martin")
        XCTAssertFalse(store.addToShoppingList(productID: "test-product"))
        XCTAssertTrue(store.isReadOnly)
        XCTAssertEqual(defaults.data(forKey: "ams.pantry.state.v2"), badData)
    }

    func testRestoredUnapprovedListEntryIsHiddenAndCannotBeCheckedOff() throws {
        let suiteName = "ams.pantry.tests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let product = sampleProduct(approved: false)
        let entry = ShoppingListEntry(id: "old-entry", productID: product.id, quantity: "1", isChecked: false)
        let productData = try JSONEncoder().encode([product])
        let entryData = try JSONEncoder().encode([entry])
        let saved = try JSONSerialization.data(withJSONObject: [
            "products": try JSONSerialization.jsonObject(with: productData),
            "shoppingListEntries": try JSONSerialization.jsonObject(with: entryData)
        ])
        defaults.set(saved, forKey: "ams.pantry.state.v2")
        let store = PantryStore(defaults: defaults, seedProducts: [])

        XCTAssertTrue(store.visibleShoppingItems.isEmpty)
        store.toggleShoppingListItem(entry.id)
        XCTAssertFalse(try XCTUnwrap(store.shoppingListEntries.first).isChecked)
    }

    func testFailedEncodingShowsWarningAndBlocksFurtherChanges() {
        let suiteName = "ams.pantry.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let product = sampleProduct(approved: false)
        let store = PantryStore(defaults: defaults, seedProducts: [product])
        var invalid = product
        invalid.maximumPrice = .infinity

        store.update(invalid)

        XCTAssertTrue(store.isReadOnly)
        XCTAssertNotNil(store.persistenceWarning)
    }

    private func sampleProduct(approved: Bool = true, martinApproved: Bool = false, annaApproved: Bool = false) -> PantryProduct {
        PantryProduct(
            id: "test-product",
            name: "Test product",
            category: "Fruit",
            suggestedProduct: nil,
            packageSize: nil,
            ingredientsCriteria: "Whole food",
            selectionGuide: "Choose a fresh product",
            countries: ["SE"],
            approved: approved,
            martinApproved: martinApproved,
            annaApproved: annaApproved,
            stores: [],
            minimumPrice: nil,
            maximumPrice: nil
        )
    }
}
