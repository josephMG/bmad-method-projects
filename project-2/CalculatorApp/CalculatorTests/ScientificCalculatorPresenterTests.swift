import XCTest
@testable import Calculator

class ScientificCalculatorPresenterTests: XCTestCase {

    var presenter: ScientificCalculatorPresenter!
    var interactorMock: ScientificCalculatorInteractorMock!

    override func setUp() {
        super.setUp()
        presenter = ScientificCalculatorPresenter()
        interactorMock = ScientificCalculatorInteractorMock()
        
        presenter.interactor = interactorMock
    }

    override func tearDown() {
        presenter = nil
        interactorMock = nil
        super.tearDown()
    }

    func testDidTapPowerOfTwo() {
        presenter.didTapPowerOfTwo()
        XCTAssertTrue(interactorMock.processPowerOfTwoCalled)
    }

    func testDidTapSine() {
        presenter.didTapSine()
        XCTAssertTrue(interactorMock.processSineCalled)
    }

    func testDidTapCosine() {
        presenter.didTapCosine()
        XCTAssertTrue(interactorMock.processCosineCalled)
    }

    func testDidTapTangent() {
        presenter.didTapTangent()
        XCTAssertTrue(interactorMock.processTangentCalled)
    }

    func testDidTapNaturalLogarithm() {
        presenter.didTapNaturalLogarithm()
        XCTAssertTrue(interactorMock.processNaturalLogarithmCalled)
    }

    func testDidTapBase10Logarithm() {
        presenter.didTapBase10Logarithm()
        XCTAssertTrue(interactorMock.processBase10LogarithmCalled)
    }

    func testDidTapEToThePowerOfX() {
        presenter.didTapEToThePowerOfX()
        XCTAssertTrue(interactorMock.processEToThePowerOfXCalled)
    }

    func testDidTapTenToThePowerOfX() {
        presenter.didTapTenToThePowerOfX()
        XCTAssertTrue(interactorMock.processTenToThePowerOfXCalled)
    }

    func testDidTapXToThePowerOfY() {
        presenter.didTapXToThePowerOfY()
        XCTAssertTrue(interactorMock.processXToThePowerOfYCalled)
    }

    func testDidTapCubeRoot() {
        presenter.didTapCubeRoot()
        XCTAssertTrue(interactorMock.processCubeRootCalled)
    }

    func testDidTapFactorial() {
        presenter.didTapFactorial()
        XCTAssertTrue(interactorMock.processFactorialCalled)
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

class ScientificCalculatorInteractorMock: ScientificCalculatorInteractorInputProtocol {
    var presenter: ScientificCalculatorInteractorOutputProtocol?
    
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
    
    var processEqualsCalled = false
    func processEquals() {
        processEqualsCalled = true
    }
    
    var processClearCalled = false
    func processClear() {
        processClearCalled = true
    }
    
    var processDecimalCalled = false
    func processDecimal() {
        processDecimalCalled = true
    }
    
    var processSignCalled = false
    func processSign() {
        processSignCalled = true
    }

    var processPowerOfTwoCalled = false
    func processPowerOfTwo() {
        processPowerOfTwoCalled = true
    }

    var processSineCalled = false
    func processSine() {
        processSineCalled = true
    }

    var processCosineCalled = false
    func processCosine() {
        processCosineCalled = true
    }

    var processTangentCalled = false
    func processTangent() {
        processTangentCalled = true
    }

    var processNaturalLogarithmCalled = false
    func processNaturalLogarithm() {
        processNaturalLogarithmCalled = true
    }

    var processBase10LogarithmCalled = false
    func processBase10Logarithm() {
        processBase10LogarithmCalled = true
    }

    var processEToThePowerOfXCalled = false
    func processEToThePowerOfX() {
        processEToThePowerOfXCalled = true
    }

    var processTenToThePowerOfXCalled = false
    func processTenToThePowerOfX() {
        processTenToThePowerOfXCalled = true
    }

    var processXToThePowerOfYCalled = false
    func processXToThePowerOfY() {
        processXToThePowerOfYCalled = true
    }

    var processCubeRootCalled = false
    func processCubeRoot() {
        processCubeRootCalled = true
    }

    var processFactorialCalled = false
    func processFactorial() {
        processFactorialCalled = true
    }
}
