import SwiftUI

// MARK: - View Protocol
protocol CalculatorViewProtocol: AnyObject {
    var presenter: CalculatorPresenterProtocol? { get set }
    
    // Presenter -> View
    func updateDisplay(with text: String)
}

// MARK: - Presenter Protocol
protocol CalculatorPresenterProtocol: AnyObject {
    var view: CalculatorViewProtocol? { get set }
    var interactor: CalculatorInteractorInputProtocol? { get set }
    var router: CalculatorRouterProtocol? { get set }
    
    // View -> Presenter
    func viewDidLoad()
    func didTapDigit(_ digit: String)
    func didTapOperator(_ operator: String)
    func didTapEquals()
    func didTapClear()
    func didTapDecimal()
    func didTapSign()
    func didTapPercent()
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
    func processSign()
    func processPercent()
}

protocol CalculatorInteractorOutputProtocol: AnyObject {
    // Interactor -> Presenter
    func didUpdateDisplayValue(_ value: String)
    func didEncounterError(_ error: String)
}

// MARK: - Router Protocol
protocol CalculatorRouterProtocol: AnyObject {
    static func createModule() -> UIViewController
}
