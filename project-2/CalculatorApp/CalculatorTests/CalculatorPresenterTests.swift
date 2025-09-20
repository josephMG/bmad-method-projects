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
    
    // Other protocol methods can be stubbed out as needed
    func processEquals() {}
    func processClear() {}
    func processDecimal() {}
    func processSign() {}
    func processPercent() {}
}