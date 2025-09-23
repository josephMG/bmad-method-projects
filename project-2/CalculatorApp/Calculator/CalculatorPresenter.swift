import Foundation
import Combine
import UIKit

class CalculatorPresenter: ObservableObject, CalculatorPresenterProtocol {
    var interactor: CalculatorInteractorInputProtocol?
    var router: CalculatorRouterProtocol?
    weak var view: UIViewController?

    @Published var displayText = "0"

    func viewDidLoad() {
        // Initial setup
    }

    func didTapDigit(_ digit: String) {
        interactor?.processDigit(digit)
    }

    func didTapOperator(_ op: String) {
        interactor?.processOperator(op)
    }

    func didTapEquals() {
        interactor?.processEquals()
    }

    func didTapClear() {
        interactor?.processClear()
    }
    
    func didTapDecimal() {
        interactor?.processDecimal()
    }
    
    func didTapSignChange() {
        interactor?.processSignChange()
    }
    
    func didTapPercent() {
        interactor?.processPercent()
    }
    
    func didTapSquareRoot() {
        interactor?.processSquareRoot()
    }

    func didTapScientificCalculator() {
        if let view = view {
            router?.presentScientificCalculator(from: view)
        }
    }

    func didTapCurrencyExchange() {
        if let view = view {
            router?.presentCurrencyExchange(from: view)
        }
    }

    func didTapCurrencyExchange() {
        if let view = view {
            router?.presentCurrencyExchange(from: view)
        }
    }
}

extension CalculatorPresenter: CalculatorInteractorOutputProtocol {
    func didUpdateDisplayValue(_ value: String) {
        displayText = value
    }

    func didEncounterError(_ error: String) {
        displayText = error
    }
}
