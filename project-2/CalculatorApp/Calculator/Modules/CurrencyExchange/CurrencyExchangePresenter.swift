// CurrencyExchangePresenter.swift
import Foundation
import Combine

class CurrencyExchangePresenter: ObservableObject, CurrencyExchangePresenterProtocol {
    var interactor: CurrencyExchangeInteractorInputProtocol?
    var router: CurrencyExchangeRouterProtocol?

    @Published var sourceAmount: String = "0"
    @Published var targetAmount: String = "0"
    @Published var selectedSourceCurrency: Currency = .TWD
    @Published var selectedTargetCurrency: Currency = .USD

    func viewDidLoad() {
        // Initial setup, if any
    }

    func didEnterSourceAmount(_ amount: String) {
        sourceAmount = amount
    }

    func didTapConvert() {
        guard let amount = Decimal(string: sourceAmount) else {
            targetAmount = "Error"
            return
        }
        interactor?.convertAmount(amount: amount, from: selectedSourceCurrency, to: selectedTargetCurrency)
    }
}

extension CurrencyExchangePresenter: CurrencyExchangeInteractorOutputProtocol {
    func didUpdateConvertedAmount(_ amount: Decimal) {
        targetAmount = formatDisplay(amount)
    }

    func didEncounterError(_ error: String) {
        targetAmount = error
    }
    
    private func formatDisplay(_ value: Decimal) -> String {
        let number = NSDecimalNumber(decimal: value)
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 8
        formatter.minimumFractionDigits = 0
        formatter.numberStyle = .decimal
        return formatter.string(from: number) ?? "0"
    }
}