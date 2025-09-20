import UIKit
import SwiftUI

class CalculatorRouter: CalculatorRouterProtocol {
    static func createModule() -> UIViewController {
        // Create components
        let presenter = CalculatorPresenter()
        let interactor: CalculatorInteractorInputProtocol = CalculatorInteractor()
        let router: CalculatorRouterProtocol = CalculatorRouter()

        // Create the SwiftUI View and inject the presenter
        let view = CalculatorView(presenter: presenter)
        
        // The hosting controller for the SwiftUI view
        let hostingController = UIHostingController(rootView: view)
        
        // Connect the components
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter

        return hostingController
    }
}
