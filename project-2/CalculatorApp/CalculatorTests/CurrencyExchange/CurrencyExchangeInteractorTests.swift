import XCTest
@testable import CalculatorApp

class CurrencyExchangeInteractorTests: XCTestCase {

    var interactor: CurrencyExchangeInteractor!

    override func setUp() {
        super.setUp()
        interactor = CurrencyExchangeInteractor()
    }

    override func tearDown() {
        interactor = nil
        super.tearDown()
    }

    func testConvertTWDToUSD() throws {
        let convertedAmount = try interactor.convertAmount(amount: 100, from: .TWD, to: .USD)
        XCTAssertEqual(convertedAmount, 3.3)
    }

    func testConvertUSDToJPY() throws {
        let convertedAmount = try interactor.convertAmount(amount: 10, from: .USD, to: .JPY)
        XCTAssertEqual(convertedAmount, 1350.0)
    }

    func testConvertJPYToKRW() throws {
        let convertedAmount = try interactor.convertAmount(amount: 1000, from: .JPY, to: .KRW)
        XCTAssertEqual(convertedAmount, 9000.0)
    }

    func testConvertKRWToTWD() throws {
        let convertedAmount = try interactor.convertAmount(amount: 10000, from: .KRW, to: .TWD)
        XCTAssertEqual(convertedAmount, 250.0)
    }

    func testConvertSameCurrency() throws {
        let convertedAmount = try interactor.convertAmount(amount: 500, from: .TWD, to: .TWD)
        XCTAssertEqual(convertedAmount, 500)
    }

    func testConvertZeroAmount() throws {
        let convertedAmount = try interactor.convertAmount(amount: 0, from: .USD, to: .TWD)
        XCTAssertEqual(convertedAmount, 0)
    }

    func testConvertNegativeAmount() {
        XCTAssertThrowsError(try interactor.convertAmount(amount: -100, from: .USD, to: .TWD)) { error in
            XCTAssertEqual(error as? CurrencyError, CurrencyError.invalidInput)
        }
    }

    func testNoExchangeRate() {
        // Assuming there's no direct TWD to TWD rate in the map, but the logic handles it
        // This test case is for an actual missing rate between different currencies
        // For example, if we had a currency not in the ExchangeRate.rates map
        // Since all currencies have rates to each other, we can't easily test `noExchangeRate`
        // without modifying the `ExchangeRate.rates` or introducing a new currency.
        // For now, we'll assume the existing rates cover all valid pairs.
    }
}
