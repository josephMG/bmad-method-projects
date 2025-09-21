// ScientificCalculatorRouter.swift
import UIKit
import SwiftUI

class ScientificCalculatorRouter: ScientificCalculatorRouterProtocol {
    static func createModule() -> UIViewController {
        let presenter = ScientificCalculatorPresenter()
        let interactor: ScientificCalculatorInteractorInputProtocol = ScientificCalculatorInteractor()
        let router: ScientificCalculatorRouterProtocol = ScientificCalculatorRouter()

        let view = ScientificCalculatorView(presenter: presenter)
        let hostingController = UIHostingController(rootView: view)

        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter

        return hostingController
    }
}