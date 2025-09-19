import UIKit
import SwiftUI

class CalculatorRouter: CalculatorRouterProtocol {
    static func createModule() -> UIViewController {
        // Create components
        var presenter: CalculatorPresenterProtocol & CalculatorInteractorOutputProtocol = CalculatorPresenter()
        var interactor: CalculatorInteractorInputProtocol = CalculatorInteractor()
        let router: CalculatorRouterProtocol = CalculatorRouter()

        // Create the SwiftUI View and inject the presenter
        var view = CalculatorView(presenter: presenter)
        
        // The hosting controller for the SwiftUI view
        let hostingController = UIHostingController(rootView: view)
        
        // Connect the components
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter

        return hostingController
    }
}
