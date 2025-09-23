import XCTest
@testable import Calculator

class CalculatorInteractorTests: XCTestCase {

    var interactor: CalculatorInteractor!
    var presenterMock: CalculatorPresenterMock!

    override func setUp() {
        super.setUp()
        interactor = CalculatorInteractor()
        presenterMock = CalculatorPresenterMock()
        interactor.presenter = presenterMock
    }

    override func tearDown() {
        interactor = nil
        presenterMock = nil
        super.tearDown()
    }

    func testAddition() {
        interactor.processDigit("2")
        interactor.processOperator("+")
        interactor.processDigit("3")
        interactor.processEquals()
        XCTAssertEqual(presenterMock.lastDisplayValue, "5")
    }

    func testAdditionWithDecimals() {
        interactor.processDigit("2.5")
        interactor.processOperator("+")
        interactor.processDigit("3.5")
        interactor.processEquals()
        XCTAssertEqual(presenterMock.lastDisplayValue, "6")
    }

    func testSubtraction() {
        interactor.processDigit("5")
        interactor.processOperator("-")
        interactor.processDigit("3")
        interactor.processEquals()
        XCTAssertEqual(presenterMock.lastDisplayValue, "2")
    }

    func testSubtractionResultingInNegative() {
        interactor.processDigit("3")
        interactor.processOperator("-")
        interactor.processDigit("5")
        interactor.processEquals()
        XCTAssertEqual(presenterMock.lastDisplayValue, "-2")
    }

    func testMultiplication() {
        interactor.processDigit("4")
        interactor.processOperator("×")
        interactor.processDigit("5")
        interactor.processEquals()
        XCTAssertEqual(presenterMock.lastDisplayValue, "20")
    }

    func testMultiplicationWithNegativeAndDecimal() {
        interactor.processDigit("-2.5")
        interactor.processOperator("×")
        interactor.processDigit("4")
        interactor.processEquals()
        XCTAssertEqual(presenterMock.lastDisplayValue, "-10")
    }

    func testDivision() {
        interactor.processDigit("10")
        interactor.processOperator("÷")
        interactor.processDigit("2")
        interactor.processEquals()
        XCTAssertEqual(presenterMock.lastDisplayValue, "5")
    }

    func testDivisionWithDecimals() {
        interactor.processDigit("10.5")
        interactor.processOperator("÷")
        interactor.processDigit("2")
        interactor.processEquals()
        XCTAssertEqual(presenterMock.lastDisplayValue, "5.25")
    }

    func testDivisionOfZeroByNonZero() {
        interactor.processDigit("0")
        interactor.processOperator("÷")
        interactor.processDigit("5")
        interactor.processEquals()
        XCTAssertEqual(presenterMock.lastDisplayValue, "0")
    }

    func testDivisionByZero() {
        interactor.processDigit("5")
        interactor.processOperator("÷")
        interactor.processDigit("0")
        interactor.processEquals()
        XCTAssertEqual(presenterMock.lastError, "Error")
    }
    
    func testSequentialOperations() {
        interactor.processDigit("5")
        interactor.processOperator("+")
        interactor.processDigit("5")
        interactor.processOperator("×") // Should calculate 5+5=10 first
        interactor.processDigit("2")
        interactor.processEquals() // 10*2=20
        XCTAssertEqual(presenterMock.lastDisplayValue, "20")
    }
    
    func testClear() {
        interactor.processDigit("1")
        interactor.processDigit("2")
        interactor.processClear()
        XCTAssertEqual(presenterMock.lastDisplayValue, "0")
    }

    func testPercentage() {
        interactor.processDigit("100")
        interactor.processOperator("+")
        interactor.processDigit("10")
        interactor.processPercent()
        XCTAssertEqual(presenterMock.lastDisplayValue, "110")
    }

    func testPercentageWithoutFirstOperand() {
        interactor.processDigit("50")
        interactor.processPercent()
        XCTAssertEqual(presenterMock.lastDisplayValue, "0.5")
    }

    func testSquareRoot() {
        interactor.processDigit("9")
        interactor.processSquareRoot()
        XCTAssertEqual(presenterMock.lastDisplayValue, "3")
    }

    func testSquareRootOfNegativeNumber() {
        interactor.processDigit("-4")
        interactor.processSquareRoot()
        XCTAssertEqual(presenterMock.lastError, "Invalid input for square root")
    }

    func testSignChangePositiveNumber() {
        interactor.processDigit("123")
        interactor.processSignChange()
        XCTAssertEqual(presenterMock.lastDisplayValue, "-123")
    }

    func testSignChangeNegativeNumber() {
        interactor.processDigit("-123")
        interactor.processSignChange()
        XCTAssertEqual(presenterMock.lastDisplayValue, "123")
    }

    func testSignChangeZero() {
        interactor.processDigit("0")
        interactor.processSignChange()
        XCTAssertEqual(presenterMock.lastDisplayValue, "0")
    }

    func testSignChangeMultipleTimes() {
        interactor.processDigit("10")
        interactor.processSignChange()
        XCTAssertEqual(presenterMock.lastDisplayValue, "-10")
        interactor.processSignChange()
        XCTAssertEqual(presenterMock.lastDisplayValue, "10")
        interactor.processSignChange()
        XCTAssertEqual(presenterMock.lastDisplayValue, "-10")
    }
}

// Mock Presenter for testing Interactor output
class CalculatorPresenterMock: CalculatorInteractorOutputProtocol {
    var lastDisplayValue: String?
    var lastError: String?

    func didUpdateDisplayValue(_ value: String) {
        lastDisplayValue = value
    }

    func didEncounterError(_ error: String) {
        lastError = error
    }
}
