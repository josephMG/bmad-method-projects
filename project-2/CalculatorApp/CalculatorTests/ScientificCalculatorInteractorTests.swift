import XCTest
@testable import Calculator

class ScientificCalculatorInteractorTests: XCTestCase {

    var interactor: ScientificCalculatorInteractor!
    var presenterMock: ScientificCalculatorPresenterMock!

    override func setUp() {
        super.setUp()
        interactor = ScientificCalculatorInteractor()
        presenterMock = ScientificCalculatorPresenterMock()
        interactor.presenter = presenterMock
    }

    override func tearDown() {
        interactor = nil
        presenterMock = nil
        super.tearDown()
    }

    func testPowerOfTwo() {
        interactor.processDigit("2")
        interactor.processPowerOfTwo()
        XCTAssertEqual(presenterMock.lastDisplayValue, "4")
    }

    func testPowerOfTwoZero() {
        interactor.processDigit("0")
        interactor.processPowerOfTwo()
        XCTAssertEqual(presenterMock.lastDisplayValue, "0")
    }

    func testPowerOfTwoNegative() {
        interactor.processDigit("-3")
        interactor.processPowerOfTwo()
        XCTAssertEqual(presenterMock.lastDisplayValue, "9")
    }

    func testSineZero() {
        interactor.processDigit("0")
        interactor.processSine()
        XCTAssertEqual(presenterMock.lastDisplayValue, "0")
    }

    func testSineNinety() {
        interactor.processDigit("90")
        interactor.processSine()
        XCTAssertEqual(presenterMock.lastDisplayValue, "1")
    }

    func testCosineZero() {
        interactor.processDigit("0")
        interactor.processCosine()
        XCTAssertEqual(presenterMock.lastDisplayValue, "1")
    }

    func testCosineNinety() {
        interactor.processDigit("90")
        interactor.processCosine()
        XCTAssertEqual(presenterMock.lastDisplayValue, "0")
    }

    func testTangentFortyFive() {
        interactor.processDigit("45")
        interactor.processTangent()
        XCTAssertEqual(presenterMock.lastDisplayValue, "1")
    }

    func testTangentNinety() {
        interactor.processDigit("90")
        interactor.processTangent()
        XCTAssertEqual(presenterMock.lastError, "Invalid input for trigonometric function")
    }

    func testNaturalLogarithm() {
        interactor.processDigit("2.71828") // Approximately e
        interactor.processNaturalLogarithm()
        XCTAssertEqual(presenterMock.lastDisplayValue, "1")
    }

    func testNaturalLogarithmOfNonPositiveNumber() {
        interactor.processDigit("0")
        interactor.processNaturalLogarithm()
        XCTAssertEqual(presenterMock.lastError, "Logarithm of non-positive number")
    }

    func testBase10Logarithm() {
        interactor.processDigit("100")
        interactor.processBase10Logarithm()
        XCTAssertEqual(presenterMock.lastDisplayValue, "2")
    }

    func testBase10LogarithmOfNonPositiveNumber() {
        interactor.processDigit("-10")
        interactor.processBase10Logarithm()
        XCTAssertEqual(presenterMock.lastError, "Logarithm of non-positive number")
    }

    func testEToThePowerOfX() {
        interactor.processDigit("1")
        interactor.processEToThePowerOfX()
        XCTAssertEqual(presenterMock.lastDisplayValue, "2.71828183") // Approximately e
    }

    func testTenToThePowerOfX() {
        interactor.processDigit("2")
        interactor.processTenToThePowerOfX()
        XCTAssertEqual(presenterMock.lastDisplayValue, "100")
    }

    func testXToThePowerOfY() {
        interactor.processDigit("2")
        interactor.processXToThePowerOfY() // Sets first operand and pending operation
        interactor.processDigit("3")
        interactor.processXToThePowerOfY() // Performs calculation
        XCTAssertEqual(presenterMock.lastDisplayValue, "8")
    }

    func testCubeRoot() {
        interactor.processDigit("8")
        interactor.processCubeRoot()
        XCTAssertEqual(presenterMock.lastDisplayValue, "2")
    }

    func testFactorial() {
        interactor.processDigit("5")
        interactor.processFactorial()
        XCTAssertEqual(presenterMock.lastDisplayValue, "120")
    }

    func testFactorialZero() {
        interactor.processDigit("0")
        interactor.processFactorial()
        XCTAssertEqual(presenterMock.lastDisplayValue, "1")
    }

    func testFactorialNegativeNumber() {
        interactor.processDigit("-5")
        interactor.processFactorial()
        XCTAssertEqual(presenterMock.lastError, "Factorial of negative or non-integer number")
    }

    func testFactorialNonInteger() {
        interactor.processDigit("3.5")
        interactor.processFactorial()
        XCTAssertEqual(presenterMock.lastError, "Factorial of negative or non-integer number")
    }
}

class ScientificCalculatorPresenterMock: ScientificCalculatorInteractorOutputProtocol {
    var lastDisplayValue: String?
    var lastError: String?

    func didUpdateDisplayValue(_ value: String) {
        lastDisplayValue = value
    }

    func didEncounterError(_ error: String) {
        lastError = error
    }
}
