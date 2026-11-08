import XCTest

@MainActor
final class ShoppingScreenUITests: XCTestCase {
    func testLabelGuideCanBeOpenedAsAnInAppDestination() {
        let app = XCUIApplication()
        app.launch()

        let guideNavigation = app.descendants(matching: .any)["sidebar.labelGuide"]
        XCTAssertTrue(guideNavigation.waitForExistence(timeout: 10))
        guideNavigation.click()
        XCTAssertTrue(app.descendants(matching: .any)["labelGuide.screen"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.buttons["guide.done"].exists)
    }

    func testShoppingScreenExposesStableListAddAndStoreFilterIdentifiers() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.descendants(matching: .any)["shopping.list"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["shopping.addItem"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["shopping.storeFilter"].exists)
    }

    func testAProductNeedsBothHouseholdApprovalsBeforeItCanBeListed() {
        let app = XCUIApplication()
        app.launch()

        let library = app.buttons["Product library"]
        XCTAssertTrue(library.waitForExistence(timeout: 10))
        library.click()
        XCTAssertTrue(app.descendants(matching: .any)["library.list"].waitForExistence(timeout: 10))

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
