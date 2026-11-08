import XCTest

@MainActor
final class ShoppingScreenUITests: XCTestCase {
    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments.append("--ams-ui-testing")
        app.launchEnvironment["AMS_PANTRY_TEST_SUITE"] = "ams.ui.tests.\(UUID().uuidString)"
        app.launch()
        return app
    }

    func testLabelGuideCanBeOpenedAsAnInAppDestination() {
        let app = launchApp()

        let guideNavigation = app.descendants(matching: .any)["sidebar.labelGuide"]
        XCTAssertTrue(guideNavigation.waitForExistence(timeout: 10))
        guideNavigation.click()
        XCTAssertTrue(app.descendants(matching: .any)["labelGuide.screen"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.buttons["guide.done"].exists)
    }

    func testMacProductRowUsesPersistentNativeSelection() {
        let app = launchApp()
        let library = app.descendants(matching: .any)["sidebar.productLibrary"]
        XCTAssertTrue(library.waitForExistence(timeout: 10))
        library.click()

        let rowName = app.staticTexts["library.name.green-lentils-dried"]
        XCTAssertTrue(rowName.waitForExistence(timeout: 10))
        let row = app.outlineRows.containing(.staticText, identifier: rowName.identifier).firstMatch
        XCTAssertTrue(row.exists)
        rowName.click()
        XCTAssertTrue(row.isSelected)
    }

    func testShoppingScreenExposesStableListAddAndStoreFilterIdentifiers() {
        let app = launchApp()

        XCTAssertTrue(app.descendants(matching: .any)["shopping.list"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["shopping.addItem"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["shopping.storeFilter"].exists)
    }

    func testChangingMarketResetsAnUnavailableStoreFilter() {
        let app = launchApp()
        let filter = app.buttons["shopping.storeFilter"]
        XCTAssertTrue(filter.waitForExistence(timeout: 10))

        filter.click()
        app.menuItems["ICA"].click()
        XCTAssertTrue(filter.label.contains("ICA"))

        filter.click()
        app.menuItems["Germany · EUR"].click()
        XCTAssertTrue(filter.label.contains("Germany"))
        XCTAssertTrue(filter.label.contains("All stores"))
    }

    func testAProductNeedsBothHouseholdApprovalsBeforeItCanBeListed() {
        let app = launchApp()

        let library = app.descendants(matching: .any)["sidebar.productLibrary"]
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
        app.descendants(matching: .any)["sidebar.shopping"].click()
        XCTAssertTrue(app.staticTexts["Green lentils, dried"].waitForExistence(timeout: 5))
    }
}
