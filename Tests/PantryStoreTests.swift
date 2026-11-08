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
}
