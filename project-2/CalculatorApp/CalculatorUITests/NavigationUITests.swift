
import XCTest

final class NavigationUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testNavigationToScientificCalculatorAndBack() throws {
        let app = XCUIApplication()
        app.launch()

        // Tap the "Scientific" button
        app.buttons["Scientific"].tap()

        // Verify Scientific Calculator view appears (e.g., by checking for a unique button like "sin")
        XCTAssertTrue(app.buttons["sin"].waitForExistence(timeout: 5), "Scientific Calculator view did not appear.")

        // Dismiss the Scientific Calculator view (assuming it's presented modally and can be dismissed by swiping down or a close button)
        // For simplicity, we'll assume a swipe down gesture for modal dismissal.
        // In a real app, you might have a specific "Close" button.
        let coordinate1 = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        let coordinate2 = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
        coordinate1.press(forDuration: 0.1, thenDragTo: coordinate2)
        
        // Verify main calculator view reappears (e.g., by checking for "AC" button)
        XCTAssertTrue(app.buttons["AC"].waitForExistence(timeout: 5), "Did not return to main Calculator view.")
    }

    func testNavigationToCurrencyExchangeAndBack() throws {
        let app = XCUIApplication()
        app.launch()

        // Tap the "Currency" button
        app.buttons["Currency"].tap()

        // Verify Currency Exchange view appears (e.g., by checking for "Currency Exchange" title)
        XCTAssertTrue(app.staticTexts["Currency Exchange"].waitForExistence(timeout: 5), "Currency Exchange view did not appear.")

        // Dismiss the Currency Exchange view
        let coordinate1 = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        let coordinate2 = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
        coordinate1.press(forDuration: 0.1, thenDragTo: coordinate2)

        // Verify main calculator view reappears
        XCTAssertTrue(app.buttons["AC"].waitForExistence(timeout: 5), "Did not return to main Calculator view.")
    }
}
