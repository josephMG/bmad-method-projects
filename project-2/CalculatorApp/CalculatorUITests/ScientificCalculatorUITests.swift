import XCTest

class ScientificCalculatorUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
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
        XCTAssertEqual(display.label, "4")
    }

    func testSineCalculation() {
        // app.buttons["scientificCalculatorButton"].tap()
        app.buttons["9"].tap()
        app.buttons["0"].tap()
        app.buttons["sin"].tap()
        
        let display = app.staticTexts.firstMatch
        XCTAssertEqual(display.label, "1")
    }

    func testCosineCalculation() {
        // app.buttons["scientificCalculatorButton"].tap()
        app.buttons["0"].tap()
        app.buttons["cos"].tap()
        
        let display = app.staticTexts.firstMatch
        XCTAssertEqual(display.label, "1")
    }

    func testTangentCalculation() {
        // app.buttons["scientificCalculatorButton"].tap()
        app.buttons["4"].tap()
        app.buttons["5"].tap()
        app.buttons["tan"].tap()
        
        let display = app.staticTexts.firstMatch
        XCTAssertEqual(display.label, "1")
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
        XCTAssertEqual(display.label, "1")
    }

    func testBase10LogarithmCalculation() {
        app.buttons["1"].tap()
        app.buttons["0"].tap()
        app.buttons["0"].tap()
        app.buttons["log10"].tap()
        
        let display = app.staticTexts.firstMatch
        XCTAssertEqual(display.label, "2")
    }

    func testEToThePowerOfXCalculation() {
        app.buttons["1"].tap()
        app.buttons["e^x"].tap()
        
        let display = app.staticTexts.firstMatch
        XCTAssertEqual(display.label, "2.71828183")
    }

    func testTenToThePowerOfXCalculation() {
        app.buttons["2"].tap()
        app.buttons["10^x"].tap()
        
        let display = app.staticTexts.firstMatch
        XCTAssertEqual(display.label, "100")
    }

    func testXToThePowerOfYCalculation() {
        app.buttons["2"].tap()
        app.buttons["x^y"].tap()
        app.buttons["3"].tap()
        app.buttons["="].tap()
        
        let display = app.staticTexts.firstMatch
        XCTAssertEqual(display.label, "8")
    }

    func testCubeRootCalculation() {
        app.buttons["8"].tap()
        app.buttons["³√"].tap()
        
        let display = app.staticTexts.firstMatch
        XCTAssertEqual(display.label, "2")
    }

    func testFactorialCalculation() {
        app.buttons["5"].tap()
        app.buttons["x!"].tap()
        
        let display = app.staticTexts.firstMatch
        XCTAssertEqual(display.label, "120")
    }

    func testFactorialOfNegativeNumberError() {
        app.buttons["5"].tap()
        app.buttons["+/-"].tap()
        app.buttons["x!"].tap()
        
        let display = app.staticTexts.firstMatch
        XCTAssertEqual(display.label, "Factorial of negative or non-integer number")
    }
}
