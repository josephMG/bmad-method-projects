// ScientificCalculatorContract.swift
import Foundation
import SwiftUI

// MARK: - Presenter Protocol
protocol ScientificCalculatorPresenterProtocol: AnyObject, ObservableObject {
    // Presenter -> View
    var displayText: String { get }

    // View -> Presenter
    func viewDidLoad()
    func didTapDigit(_ digit: String)
    func didTapOperator(_ operator: String)
    func didTapEquals()
    func didTapClear()
    func didTapDecimal()
    func didTapSign()
    func didTapPowerOfTwo()
    func didTapSine()
    func didTapCosine()
    func didTapTangent()
    func didTapNaturalLogarithm()
    func didTapBase10Logarithm()
    func didTapEToThePowerOfX()
    func didTapTenToThePowerOfX()
    func didTapXToThePowerOfY()
    func didTapCubeRoot()
    func didTapFactorial()
}

// MARK: - Interactor Protocols
protocol ScientificCalculatorInteractorInputProtocol: AnyObject {
    var presenter: ScientificCalculatorInteractorOutputProtocol? { get set }

    // Presenter -> Interactor
    func processDigit(_ digit: String)
    func processOperator(_ operator: String)
    func processEquals()
    func processClear()
    func processDecimal()
    func processSign()
    func processPowerOfTwo()
    func processSine()
    func processCosine()
    func processTangent()
    func processNaturalLogarithm()
    func processBase10Logarithm()
    func processEToThePowerOfX()
    func processTenToThePowerOfX()
    func processXToThePowerOfY()
    func processCubeRoot()
    func processFactorial()
}

protocol ScientificCalculatorInteractorOutputProtocol: AnyObject {
    // Interactor -> Presenter
    func didUpdateDisplayValue(_ value: String)
    func didEncounterError(_ error: String)
}

// MARK: - Router Protocol
protocol ScientificCalculatorRouterProtocol: AnyObject {
    static func createModule() -> UIViewController
}
