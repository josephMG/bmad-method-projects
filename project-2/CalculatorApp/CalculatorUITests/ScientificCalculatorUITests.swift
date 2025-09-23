import XCTest

class ScientificCalculatorUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()

        // Navigate to scientific calculator view
        app.buttons["Scientific"].tap()
        // Wait for a scientific calculator button to appear to ensure the view is loaded
        XCTAssertTrue(app.buttons["x²"].waitForExistence(timeout: 5))
    }

    func testScientificButtonsAreVisible() {
        // Navigate to scientific calculator view (assuming a button exists in the main view)
        // For now, let's assume a button with accessibilityIdentifier "scientificCalculatorButton" exists
        // app.buttons["scientificCalculatorButton"].tap()
        
        // Since there's no explicit navigation yet, we'll assume the scientific calculator is the initial view for these tests
        XCTAssertTrue(app.buttons["x²"].exists)
        XCTAssertTrue(app.buttons["sin"].exists)
        XCTAssertTrue(app.buttons["cos"].exists)
        XCTAssertTrue(app.buttons["tan"].exists)
    }

    func testPowerOfTwoCalculation() {
        // app.buttons["scientificCalculatorButton"].tap()
        app.buttons["2"].tap()
        app.buttons["x²"].tap()
        
        let display = app.staticTexts.firstMatch
        let expectedValue: Decimal = 4.0
        XCTAssertEqual(display.label, formatExpectedDisplay(expectedValue))
    }

    func testSineCalculation() {
        // app.buttons["scientificCalculatorButton"].tap()
        app.buttons["9"].tap()
        app.buttons["0"].tap()
        app.buttons["sin"].tap()
        
        let display = app.staticTexts.firstMatch
        let expectedValue: Decimal = 1.0
        XCTAssertEqual(display.label, formatExpectedDisplay(expectedValue))
    }

    func testCosineCalculation() {
        // app.buttons["scientificCalculatorButton"].tap()
        app.buttons["0"].tap()
        app.buttons["cos"].tap()
        
        let display = app.staticTexts.firstMatch
        let expectedValue: Decimal = 1.0
        XCTAssertEqual(display.label, formatExpectedDisplay(expectedValue))
    }

    func testTangentCalculation() {
        // app.buttons["scientificCalculatorButton"].tap()
        app.buttons["4"].tap()
        app.buttons["5"].tap()
        app.buttons["tan"].tap()
        
        let display = app.staticTexts.firstMatch
        let expectedValue: Decimal = 1.0
        XCTAssertEqual(display.label, formatExpectedDisplay(expectedValue))
    }

    func testTangentNinetyDegreesError() {
        // app.buttons["scientificCalculatorButton"].tap()
        app.buttons["9"].tap()
        app.buttons["0"].tap()
        app.buttons["tan"].tap()
        
        let display = app.staticTexts.firstMatch
        XCTAssertEqual(display.label, "Invalid input for trigonometric function")
    }

    func testNaturalLogarithmCalculation() {
        app.buttons["2"].tap()
        app.buttons["."].tap()
        app.buttons["7"].tap()
        app.buttons["1"].tap()
        app.buttons["8"].tap()
        app.buttons["2"].tap()
        app.buttons["8"].tap()
        app.buttons["ln"].tap()
        
        let display = app.staticTexts.firstMatch
        let expectedValue: Decimal = 1.0
        XCTAssertEqual(display.label, formatExpectedDisplay(expectedValue))
    }

    func testBase10LogarithmCalculation() {
        app.buttons["1"].tap()
        app.buttons["0"].tap()
        app.buttons["0"].tap()
        app.buttons["log10"].tap()

        let display = app.staticTexts.firstMatch
        let expectedValue: Decimal = 2.0
        XCTAssertEqual(display.label, formatExpectedDisplay(expectedValue))
    }

    func testEToThePowerOfXCalculation() {
        app.buttons["1"].tap()
        app.buttons["e^x"].tap()
        
        let display = app.staticTexts.firstMatch
        let expectedValue: Decimal = 2.71828183
        XCTAssertEqual(display.label, formatExpectedDisplay(expectedValue))
    }

    func testTenToThePowerOfXCalculation() {
        app.buttons["2"].tap()
        app.buttons["10^x"].tap()
        
        let display = app.staticTexts.firstMatch
        let expectedValue: Decimal = 100.0
        XCTAssertEqual(display.label, formatExpectedDisplay(expectedValue))
    }

    func testXToThePowerOfYCalculation() {
        app.buttons["2"].tap()
        app.buttons["x^y"].tap()
        app.buttons["3"].tap()
        app.buttons["="].tap()
        
        let display = app.staticTexts.firstMatch
        let expectedValue: Decimal = 8.0
        XCTAssertEqual(display.label, formatExpectedDisplay(expectedValue))
    }

    func testCubeRootCalculation() {
        app.buttons["8"].tap()
        app.buttons["³√"].tap()
        
        let display = app.staticTexts.firstMatch
        let expectedValue: Decimal = 2.0
        XCTAssertEqual(display.label, formatExpectedDisplay(expectedValue))
    }

    func testFactorialCalculation() {
        app.buttons["5"].tap()
        app.buttons["x!"].tap()
        
        let display = app.staticTexts.firstMatch
        let expectedValue: Decimal = 120.0
        XCTAssertEqual(display.label, formatExpectedDisplay(expectedValue))
    }

    func testFactorialOfNegativeNumberError() {
        app.buttons["5"].tap()
        app.buttons["+/-"].tap()
        app.buttons["x!"].tap()
        
        let display = app.staticTexts.firstMatch
        XCTAssertEqual(display.label, "Factorial of negative or non-integer number")
    }

    func formatExpectedDisplay(_ value: Decimal) -> String {
        let number = NSDecimalNumber(decimal: value)
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 15
        formatter.usesGroupingSeparator = false
        formatter.decimalSeparator = "."
        return formatter.string(from: number) ?? "0"
    }
}