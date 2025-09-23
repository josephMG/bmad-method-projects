// CurrencyExchangeRouter.swift
import UIKit
import SwiftUI

class CurrencyExchangeRouter: CurrencyExchangeRouterProtocol {
    static func createModule() -> UIViewController {
        let presenter = CurrencyExchangePresenter()
        let interactor: CurrencyExchangeInteractorInputProtocol = CurrencyExchangeInteractor()
        let router: CurrencyExchangeRouterProtocol = CurrencyExchangeRouter()

        let view = CurrencyExchangeView(presenter: presenter)
        let hostingController = UIHostingController(rootView: view)

        presenter.interactor = interactor
        presenter.router = router
//        interactor.presenter = presenter // Interactor does not need a presenter for this module

        return hostingController
    }
}