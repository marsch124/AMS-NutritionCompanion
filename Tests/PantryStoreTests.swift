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

    private func sampleProduct() -> PantryProduct {
        PantryProduct(
            id: "test-product",
            name: "Test product",
            category: "Fruit",
            suggestedProduct: nil,
            packageSize: nil,
            ingredientsCriteria: "Whole food",
            selectionGuide: "Choose a fresh product",
            countries: ["SE"],
            approved: true,
            stores: [],
            minimumPrice: nil,
            maximumPrice: nil
        )
    }
}
