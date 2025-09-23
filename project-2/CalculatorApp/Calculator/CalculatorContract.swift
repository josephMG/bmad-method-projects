import SwiftUI
import Combine
import UIKit

// MARK: - Presenter Protocol
protocol CalculatorPresenterProtocol: AnyObject, ObservableObject {
    var interactor: CalculatorInteractorInputProtocol? { get set }
    var router: CalculatorRouterProtocol? { get set }
    var view: UIViewController? { get set }
    
    var displayText: String { get }
    
    // View -> Presenter
    func viewDidLoad()
    func didTapDigit(_ digit: String)
    func didTapOperator(_ operator: String)
    func didTapEquals()
    func didTapClear()
    func didTapDecimal()
    func didTapPercent()
    func didTapSignChange()
    func didTapSquareRoot()
    func didTapScientificCalculator()
    func didTapCurrencyExchange()
    func didTapCurrencyExchange()
}

// MARK: - Interactor Protocols
protocol CalculatorInteractorInputProtocol: AnyObject {
    var presenter: CalculatorInteractorOutputProtocol? { get set }
    
    // Presenter -> Interactor
    func processDigit(_ digit: String)
    func processOperator(_ operator: String)
    func processEquals()
    func processClear()
    func processDecimal()
    func processSignChange()
    func processPercent()
    func processSquareRoot()
}

protocol CalculatorInteractorOutputProtocol: AnyObject {
    // Interactor -> Presenter
    func didUpdateDisplayValue(_ value: String)
    func didEncounterError(_ error: String)
}

// MARK: - Router Protocol
protocol CalculatorRouterProtocol: AnyObject {
    static func createModule() -> UIViewController
    func presentScientificCalculator(from view: UIViewController)
    func presentCurrencyExchange(from view: UIViewController)
}
