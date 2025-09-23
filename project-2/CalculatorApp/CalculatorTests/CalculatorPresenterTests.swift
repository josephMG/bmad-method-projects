import XCTest
@testable import Calculator

class CalculatorPresenterTests: XCTestCase {

    var presenter: CalculatorPresenter!
    var interactorMock: CalculatorInteractorMock!

    override func setUp() {
        super.setUp()
        presenter = CalculatorPresenter()
        interactorMock = CalculatorInteractorMock()
        
        presenter.interactor = interactorMock
    }

    override func tearDown() {
        presenter = nil
        interactorMock = nil
        super.tearDown()
    }

    func testDidTapDigit() {
        presenter.didTapDigit("5")
        XCTAssertTrue(interactorMock.processDigitCalled)
        XCTAssertEqual(interactorMock.lastDigit, "5")
    }

    func testDidTapOperator() {
        presenter.didTapOperator("+")
        XCTAssertTrue(interactorMock.processOperatorCalled)
        XCTAssertEqual(interactorMock.lastOperator, "+")
    }
    
    func testDidUpdateDisplayValue() {
        presenter.didUpdateDisplayValue("123.45")
        XCTAssertEqual(presenter.displayText, "123.45")
    }
    
    func testDidEncounterError() {
        presenter.didEncounterError("Test Error")
        XCTAssertEqual(presenter.displayText, "Test Error")
    }

    func testDidUpdateDisplayValue_basicDecimal() {
        presenter.didUpdateDisplayValue("123.45")
        XCTAssertEqual(presenter.displayText, "123.45")
    }

    func testDidUpdateDisplayValue_largeNumber() {
        presenter.didUpdateDisplayValue("1234567890.12345")
        XCTAssertEqual(presenter.displayText, "1234567890.12345")
    }

    func testDidUpdateDisplayValue_manyDecimalPlaces() {
        presenter.didUpdateDisplayValue("0.123456789")
        XCTAssertEqual(presenter.displayText, "0.123456789")
    }

    func testDidUpdateDisplayValue_zero() {
        presenter.didUpdateDisplayValue("0")
        XCTAssertEqual(presenter.displayText, "0")
    }

    func testDidUpdateDisplayValue_negativeNumber() {
        presenter.didUpdateDisplayValue("-123.45")
        XCTAssertEqual(presenter.displayText, "-123.45")
    }

    func testDidUpdateDisplayValue_integer() {
        presenter.didUpdateDisplayValue("123.0")
        XCTAssertEqual(presenter.displayText, "123")
    }

    func testDidUpdateDisplayValue_integerWithoutDecimal() {
        presenter.didUpdateDisplayValue("123")
        XCTAssertEqual(presenter.displayText, "123")
    }


    func testDidTapPercent() {
        presenter.didTapPercent()
        XCTAssertTrue(interactorMock.processPercentCalled)
    }

    func testDidTapSquareRoot() {
        presenter.didTapSquareRoot()
        XCTAssertTrue(interactorMock.processSquareRootCalled)
    }

    func testDidTapSignChange() {
        presenter.didTapSignChange()
        XCTAssertTrue(interactorMock.processSignChangeCalled)
    }
}

// Mocks for testing Presenter
class CalculatorInteractorMock: CalculatorInteractorInputProtocol {
    var presenter: CalculatorInteractorOutputProtocol?
    
    var processDigitCalled = false
    var lastDigit: String?
    func processDigit(_ digit: String) {
        processDigitCalled = true
        lastDigit = digit
    }
    
    var processOperatorCalled = false
    var lastOperator: String?
    func processOperator(_ op: String) {
        processOperatorCalled = true
        lastOperator = op
    }
    
    var processPercentCalled = false
    func processPercent() {
        processPercentCalled = true
    }
    
    var processSquareRootCalled = false
    func processSquareRoot() {
        processSquareRootCalled = true
    }

    var processSignChangeCalled = false
    func processSignChange() {
        processSignChangeCalled = true
    }
    
    // Other protocol methods can be stubbed out as needed
    func processEquals() {}
    func processClear() {}
    func processDecimal() {}
    func processSign() {}
}