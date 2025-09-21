import XCTest
@testable import Calculator

class CurrencyExchangePresenterTests: XCTestCase {

    var presenter: CurrencyExchangePresenter!
    var interactorMock: CurrencyExchangeInteractorMock!

    override func setUp() {
        super.setUp()
        presenter = CurrencyExchangePresenter()
        interactorMock = CurrencyExchangeInteractorMock()
        presenter.interactor = interactorMock
    }

    override func tearDown() {
        presenter = nil
        interactorMock = nil
        super.tearDown()
    }

    func testDidEnterSourceAmount() {
        presenter.didEnterSourceAmount("123.45")
        XCTAssertEqual(presenter.sourceAmount, "123.45")
    }

    func testDidTapConvert() {
        presenter.sourceAmount = "100"
        presenter.selectedSourceCurrency = .TWD
        presenter.selectedTargetCurrency = .USD
        presenter.didTapConvert()
        XCTAssertTrue(interactorMock.convertAmountCalled)
        XCTAssertEqual(interactorMock.lastAmount, 100)
        XCTAssertEqual(interactorMock.lastSourceCurrency, .TWD)
        XCTAssertEqual(interactorMock.lastTargetCurrency, .USD)
    }

    func testDidTapConvertInvalidAmount() {
        presenter.sourceAmount = "abc"
        presenter.didTapConvert()
        XCTAssertEqual(presenter.targetAmount, "Error")
    }

    func testDidUpdateConvertedAmount() {
        presenter.didUpdateConvertedAmount(Decimal(string: "3.2")!)
        XCTAssertEqual(presenter.targetAmount, "3.2")
    }

    func testDidEncounterError() {
        presenter.didEncounterError("Test Error")
        XCTAssertEqual(presenter.targetAmount, "Test Error")
    }
}

class CurrencyExchangeInteractorMock: CurrencyExchangeInteractorInputProtocol {
    var presenter: CurrencyExchangeInteractorOutputProtocol?
    
    var convertAmountCalled = false
    var lastAmount: Decimal?
    var lastSourceCurrency: Currency?
    var lastTargetCurrency: Currency?

    func convertAmount(amount: Decimal, from sourceCurrency: Currency, to targetCurrency: Currency) {
        convertAmountCalled = true
        lastAmount = amount
        lastSourceCurrency = sourceCurrency
        lastTargetCurrency = targetCurrency
    }
}
