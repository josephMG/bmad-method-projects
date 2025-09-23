import XCTest

class CalculatorUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testButtonsAreVisible() {
        let buttons = [
            "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
            "+", "-", "×", "÷", "=", "AC"
        ]

        for buttonLabel in buttons {
            let button = app.buttons[buttonLabel]
            XCTAssertTrue(button.waitForExistence(timeout: 5), "Button '\(buttonLabel)' did not appear.")
        }
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

    func testPercentageCalculation() {
        app.buttons["1"].tap()
        app.buttons["0"].tap()
        app.buttons["0"].tap()
        app.buttons["+"].tap()
        app.buttons["1"].tap()
        app.buttons["0"].tap()
        app.buttons["%"].tap()
        
        let display = app.staticTexts.firstMatch
        XCTAssertEqual(display.label, "110")
    }

    func testSquareRootCalculation() {
        app.buttons["9"].tap()
        app.buttons["√"].tap()
        
        let display = app.staticTexts.firstMatch
        XCTAssertEqual(display.label, "3")
    }

    func testSquareRootOfNegativeNumber() {
        app.buttons["4"].tap()
        app.buttons["+/-"].tap()
        app.buttons["√"].tap()
        
        let display = app.staticTexts.firstMatch
        XCTAssertEqual(display.label, "Invalid input for square root")
    }

    func testSignChangePositiveToNegative() {
        app.buttons["1"].tap()
        app.buttons["2"].tap()
        app.buttons["3"].tap()
        app.buttons["+/-"].tap()
        
        let display = app.staticTexts.firstMatch
        XCTAssertEqual(display.label, "-123")
    }

    func testSignChangeNegativeToPositive() {
        app.buttons["1"].tap()
        app.buttons["2"].tap()
        app.buttons["3"].tap()
        app.buttons["+/-"].tap() // Make it -123
        app.buttons["+/-"].tap() // Make it 123 again
        
        let display = app.staticTexts.firstMatch
        XCTAssertEqual(display.label, "123")
    }

    func testSignChangeZero() {
        app.buttons["0"].tap()
        app.buttons["+/-"].tap()
        
        let display = app.staticTexts.firstMatch
        XCTAssertEqual(display.label, "0")
    }
}
