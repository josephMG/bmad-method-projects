import Foundation

class CalculatorPresenter: CalculatorPresenterProtocol {
    weak var view: CalculatorViewProtocol?
    var interactor: CalculatorInteractorInputProtocol?
    var router: CalculatorRouterProtocol?

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
        view?.updateDisplay(with: value)
    }

    func didEncounterError(_ error: String) {
        view?.updateDisplay(with: error)
    }
}
