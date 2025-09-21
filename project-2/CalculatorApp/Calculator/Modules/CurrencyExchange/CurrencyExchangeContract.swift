// CurrencyExchangeContract.swift
import Foundation
import SwiftUI

// MARK: - Presenter Protocol
protocol CurrencyExchangePresenterProtocol: AnyObject, ObservableObject {
    // Presenter -> View
    var sourceAmount: String { get }
    var targetAmount: String { get }
    var selectedSourceCurrency: Currency { get set }
    var selectedTargetCurrency: Currency { get set }

    // View -> Presenter
    func viewDidLoad()
    func didEnterSourceAmount(_ amount: String)
    func didTapConvert()
}

// MARK: - Interactor Protocols
protocol CurrencyExchangeInteractorInputProtocol: AnyObject {
    var presenter: CurrencyExchangeInteractorOutputProtocol? { get set }

    // Presenter -> Interactor
    func convertAmount(amount: Decimal, from: Currency, to: Currency)
}

protocol CurrencyExchangeInteractorOutputProtocol: AnyObject {
    // Interactor -> Presenter
    func didUpdateConvertedAmount(_ amount: Decimal)
    func didEncounterError(_ error: String)
}

// MARK: - Router Protocol
protocol CurrencyExchangeRouterProtocol: AnyObject {
    static func createModule() -> UIViewController
}
