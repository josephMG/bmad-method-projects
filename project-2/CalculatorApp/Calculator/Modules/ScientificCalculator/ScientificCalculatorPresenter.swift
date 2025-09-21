// ScientificCalculatorPresenter.swift
import Foundation
import Combine

class ScientificCalculatorPresenter: ObservableObject, ScientificCalculatorPresenterProtocol {
    var interactor: ScientificCalculatorInteractorInputProtocol?
    var router: ScientificCalculatorRouterProtocol?

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

    func didTapPowerOfTwo() {
        interactor?.processPowerOfTwo()
    }

    func didTapSine() {
        interactor?.processSine()
    }

    func didTapCosine() {
        interactor?.processCosine()
    }

    func didTapTangent() {
        interactor?.processTangent()
    }

    func didTapNaturalLogarithm() {
        interactor?.processNaturalLogarithm()
    }

    func didTapBase10Logarithm() {
        interactor?.processBase10Logarithm()
    }

    func didTapEToThePowerOfX() {
        interactor?.processEToThePowerOfX()
    }

    func didTapTenToThePowerOfX() {
        interactor?.processTenToThePowerOfX()
    }

    func didTapXToThePowerOfY() {
        interactor?.processXToThePowerOfY()
    }

    func didTapCubeRoot() {
        interactor?.processCubeRoot()
    }

    func didTapFactorial() {
        interactor?.processFactorial()
    }
}

extension ScientificCalculatorPresenter: ScientificCalculatorInteractorOutputProtocol {
    func didUpdateDisplayValue(_ value: String) {
        displayText = value
    }

    func didEncounterError(_ error: String) {
        displayText = error
    }
}
