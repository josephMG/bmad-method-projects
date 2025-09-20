import Foundation
import Combine

class CalculatorPresenter: ObservableObject, CalculatorPresenterProtocol {
    var interactor: CalculatorInteractorInputProtocol?
    var router: CalculatorRouterProtocol?

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
    
    func didTapSign() {
        interactor?.processSign()
    }
    
    func didTapPercent() {
        interactor?.processPercent()
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