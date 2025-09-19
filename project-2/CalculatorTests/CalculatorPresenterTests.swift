import XCTest
@testable import Calculator

class CalculatorPresenterTests: XCTestCase {

    var presenter: CalculatorPresenter!
    var interactorMock: CalculatorInteractorMock!
    var viewMock: CalculatorViewMock!

    override func setUp() {
        super.setUp()
        presenter = CalculatorPresenter()
        interactorMock = CalculatorInteractorMock()
        viewMock = CalculatorViewMock()
        
        presenter.interactor = interactorMock
        presenter.view = viewMock
    }

    override func tearDown() {
        presenter = nil
        interactorMock = nil
        viewMock = nil
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
        XCTAssertTrue(viewMock.updateDisplayCalled)
        XCTAssertEqual(viewMock.lastDisplayText, "123.45")
    }
    
    func testDidEncounterError() {
        presenter.didEncounterError("Test Error")
        XCTAssertTrue(viewMock.updateDisplayCalled)
        XCTAssertEqual(viewMock.lastDisplayText, "Test Error")
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

class CalculatorViewMock: CalculatorViewProtocol {
    var presenter: CalculatorPresenterProtocol?
    
    var updateDisplayCalled = false
    var lastDisplayText: String?
    func updateDisplay(with text: String) {
        updateDisplayCalled = true
        lastDisplayText = text
    }
}
