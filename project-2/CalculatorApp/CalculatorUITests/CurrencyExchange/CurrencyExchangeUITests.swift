import XCTest

class CurrencyExchangeUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testCurrencyExchangeViewElementsAreVisible() {
        // TODO: Add navigation to CurrencyExchangeView once implemented in CalculatorRouter
        // For now, assume CurrencyExchangeView is the initial view for these tests

        XCTAssertTrue(app.staticTexts["Currency Exchange"].exists)
        XCTAssertTrue(app.staticTexts["Source Currency"].exists)
        XCTAssertTrue(app.staticTexts["Target Currency"].exists)
        XCTAssertTrue(app.textFields["Enter amount"].exists)
        XCTAssertTrue(app.buttons["Convert"].exists)

        // Check for currency pickers (segmented controls)
        XCTAssertTrue(app.segmentedControls.buttons["TWD"].exists)
        XCTAssertTrue(app.segmentedControls.buttons["USD"].exists)
        XCTAssertTrue(app.segmentedControls.buttons["JPY"].exists)
        XCTAssertTrue(app.segmentedControls.buttons["KRW"].exists)
    }

    func testTWDToUSDConversion() {
        // TODO: Add navigation to CurrencyExchangeView once implemented in CalculatorRouter
        // For now, assume CurrencyExchangeView is the initial view for these tests

        let sourceAmountTextField = app.textFields["Enter amount"]
        let convertButton = app.buttons["Convert"]
        let targetAmountDisplay = app.staticTexts.matching(identifier: "targetAmountDisplay").firstMatch // Assuming an accessibility identifier

        // Select TWD as source, USD as target
        app.segmentedControls.buttons["TWD"].tap()
        app.segmentedControls.buttons["USD"].tap()

        sourceAmountTextField.tap()
        sourceAmountTextField.typeText("100")
        convertButton.tap()

        // Expected: 100 TWD * 0.032 = 3.2 USD
        XCTAssertEqual(app.staticTexts["3.2"].label, "3.2")
    }

    func testUSDToJPYConversion() {
        // TODO: Add navigation to CurrencyExchangeView once implemented in CalculatorRouter
        // For now, assume CurrencyExchangeView is the initial view for these tests

        let sourceAmountTextField = app.textFields["Enter amount"]
        let convertButton = app.buttons["Convert"]

        // Select USD as source, JPY as target
        app.segmentedControls.buttons["USD"].tap()
        app.segmentedControls.buttons["JPY"].tap()

        sourceAmountTextField.tap()
        sourceAmountTextField.typeText("10")
        convertButton.tap()

        // Expected: 10 USD * 150.00 = 1500 JPY
        XCTAssertEqual(app.staticTexts["1,500"].label, "1,500")
    }

    func testInvalidAmountInput() {
        // TODO: Add navigation to CurrencyExchangeView once implemented in CalculatorRouter
        // For now, assume CurrencyExchangeView is the initial view for these tests

        let sourceAmountTextField = app.textFields["Enter amount"]
        let convertButton = app.buttons["Convert"]

        app.segmentedControls.buttons["TWD"].tap()
        app.segmentedControls.buttons["USD"].tap()

        sourceAmountTextField.tap()
        sourceAmountTextField.typeText("abc")
        convertButton.tap()

        XCTAssertEqual(app.staticTexts["Error"].label, "Error")
    }
}
