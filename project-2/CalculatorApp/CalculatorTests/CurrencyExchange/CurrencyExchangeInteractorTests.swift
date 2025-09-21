import XCTest
@testable import Calculator

class CurrencyExchangeInteractorTests: XCTestCase {

    var interactor: CurrencyExchangeInteractor!
    var presenterMock: CurrencyExchangePresenterMock!

    override func setUp() {
        super.setUp()
        interactor = CurrencyExchangeInteractor()
        presenterMock = CurrencyExchangePresenterMock()
        interactor.presenter = presenterMock
    }

    override func tearDown() {
        interactor = nil
        presenterMock = nil
        super.tearDown()
    }

    func testConvertTWDToUSD() {
        interactor.convertAmount(amount: 100, from: .TWD, to: .USD)
        XCTAssertEqual(presenterMock.lastConvertedAmount, 3.2)
    }

    func testConvertUSDToJPY() {
        interactor.convertAmount(amount: 10, from: .USD, to: .JPY)
        XCTAssertEqual(presenterMock.lastConvertedAmount, 1500)
    }

    func testConvertJPYToKRW() {
        interactor.convertAmount(amount: 1000, from: .JPY, to: .KRW)
        XCTAssertEqual(presenterMock.lastConvertedAmount, 8900)
    }

    func testConvertKRWToTWD() {
        interactor.convertAmount(amount: 10000, from: .KRW, to: .TWD)
        XCTAssertEqual(presenterMock.lastConvertedAmount, 230)
    }

    func testConvertSameCurrency() {
        interactor.convertAmount(amount: 500, from: .TWD, to: .TWD)
        XCTAssertEqual(presenterMock.lastConvertedAmount, 500)
    }

    func testConvertZeroAmount() {
        interactor.convertAmount(amount: 0, from: .USD, to: .TWD)
        XCTAssertEqual(presenterMock.lastConvertedAmount, 0)
    }

    func testConvertNegativeAmount() {
        interactor.convertAmount(amount: -100, from: .USD, to: .TWD)
        XCTAssertEqual(presenterMock.lastError, CurrencyExchangeError.invalidAmount.localizedDescription)
    }
}

class CurrencyExchangePresenterMock: CurrencyExchangeInteractorOutputProtocol {
    var lastConvertedAmount: Decimal?
    var lastError: String?

    func didUpdateConvertedAmount(_ amount: Decimal) {
        lastConvertedAmount = amount
    }

    func didEncounterError(_ error: String) {
        lastError = error
    }
}
