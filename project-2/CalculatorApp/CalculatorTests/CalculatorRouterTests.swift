
import XCTest
import SwiftUI
@testable import CalculatorApp

class CalculatorRouterTests: XCTestCase {

    func testCreateModule_ReturnsUIViewController() {
        let module = CalculatorRouter.createModule()
        XCTAssertNotNil(module)
        XCTAssertTrue(module is UIHostingController<CalculatorView>)
    }

    func testCreateModule_PresenterIsConnected() {
        let module = CalculatorRouter.createModule() as! UIHostingController<CalculatorView>
        let calculatorView = module.rootView
        XCTAssertNotNil(calculatorView.presenter)
    }

    func testCreateModule_InteractorIsConnectedToPresenter() {
        let module = CalculatorRouter.createModule() as! UIHostingController<CalculatorView>
        let calculatorView = module.rootView
        let presenter = calculatorView.presenter as! CalculatorPresenter
        XCTAssertNotNil(presenter.interactor)
        XCTAssertTrue(presenter.interactor is CalculatorInteractor)
    }

    func testCreateModule_PresenterIsConnectedToInteractor() {
        let module = CalculatorRouter.createModule() as! UIHostingController<CalculatorView>
        let calculatorView = module.rootView
        let presenter = calculatorView.presenter as! CalculatorPresenter
        let interactor = presenter.interactor as! CalculatorInteractor
        XCTAssertNotNil(interactor.presenter)
        XCTAssertTrue(interactor.presenter === presenter)
    }

    func testCreateModule_RouterIsConnectedToPresenter() {
        let module = CalculatorRouter.createModule() as! UIHostingController<CalculatorView>
        let calculatorView = module.rootView
        let presenter = calculatorView.presenter as! CalculatorPresenter
        XCTAssertNotNil(presenter.router)
        XCTAssertTrue(presenter.router is CalculatorRouter)
    }
}
