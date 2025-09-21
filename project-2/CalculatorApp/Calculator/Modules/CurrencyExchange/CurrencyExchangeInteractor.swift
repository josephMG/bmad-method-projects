// CurrencyExchangeInteractor.swift
import Foundation

class CurrencyExchangeInteractor: CurrencyExchangeInteractorInputProtocol {
    weak var presenter: CurrencyExchangeInteractorOutputProtocol?

    func convertAmount(amount: Decimal, from sourceCurrency: Currency, to targetCurrency: Currency) {
        guard amount >= 0 else {
            presenter?.didEncounterError(CurrencyExchangeError.invalidAmount.localizedDescription)
            return
        }

        if sourceCurrency == targetCurrency {
            presenter?.didUpdateConvertedAmount(amount)
            return
        }

        guard let rate = ExchangeRates.rates[sourceCurrency]?[targetCurrency] else {
            presenter?.didEncounterError(CurrencyExchangeError.unsupportedCurrencyPair.localizedDescription)
            return
        }

        let convertedAmount = amount * rate
        presenter?.didUpdateConvertedAmount(convertedAmount)
    }
}