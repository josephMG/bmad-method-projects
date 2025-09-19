import XCTest

class CalculatorUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testButtonsAreVisible() {
        XCTAssertTrue(app.buttons["1"].exists)
        XCTAssertTrue(app.buttons["+"].exists)
        XCTAssertTrue(app.buttons["="].exists)
        XCTAssertTrue(app.buttons["AC"].exists)
    }

    func testSimpleCalculation() {
        // Tap 1
        app.buttons["1"].tap()
        
        // Tap +
        app.buttons["+"].tap()
        
        // Tap 2
        app.buttons["2"].tap()
        
        // Tap =
        app.buttons["="].tap()
        
        // Get the display text
        let display = app.staticTexts.firstMatch
        
        // Assert that the display shows "3"
        XCTAssertEqual(display.label, "3")
    }
}
