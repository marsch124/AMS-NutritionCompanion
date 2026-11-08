import XCTest

final class ShoppingScreenUITests: XCTestCase {
    func testShoppingScreenExposesStableListAddAndStoreFilterIdentifiers() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.otherElements["shopping.list"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["shopping.addItem"].exists)
        XCTAssertTrue(app.buttons["shopping.storeFilter"].exists)
    }

    func testAProductNeedsBothHouseholdApprovalsBeforeItCanBeListed() {
        let app = XCUIApplication()
        app.launch()

        let library = app.buttons["Product library"]
        XCTAssertTrue(library.waitForExistence(timeout: 10))
        library.click()
        XCTAssertTrue(app.otherElements["library.list"].waitForExistence(timeout: 10))

        app.staticTexts["Green lentils, dried"].click()
        XCTAssertTrue(app.buttons["product.approve.martin"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["product.approve.anna"].exists)
        XCTAssertFalse(app.buttons["product.addToList"].exists)

        app.buttons["product.approve.martin"].click()
        XCTAssertTrue(app.buttons["product.approve.anna"].exists)
        XCTAssertFalse(app.buttons["product.addToList"].exists)

        app.buttons["product.approve.anna"].click()
        XCTAssertTrue(app.buttons["product.addToList"].waitForExistence(timeout: 5))
        app.buttons["product.addToList"].click()
        app.buttons["Shopping"].click()
        XCTAssertTrue(app.staticTexts["Green lentils, dried"].waitForExistence(timeout: 5))
    }
}
