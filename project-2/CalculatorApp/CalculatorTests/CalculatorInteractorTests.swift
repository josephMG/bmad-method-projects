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

    func testSubtraction() {
        interactor.processDigit("5")
        interactor.processOperator("-")
        interactor.processDigit("3")
        interactor.processEquals()
        XCTAssertEqual(presenterMock.lastDisplayValue, "2")
    }

    func testMultiplication() {
        interactor.processDigit("4")
        interactor.processOperator("×")
        interactor.processDigit("5")
        interactor.processEquals()
        XCTAssertEqual(presenterMock.lastDisplayValue, "20")
    }

    func testDivision() {
        interactor.processDigit("10")
        interactor.processOperator("÷")
        interactor.processDigit("2")
        interactor.processEquals()
        XCTAssertEqual(presenterMock.lastDisplayValue, "5")
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
