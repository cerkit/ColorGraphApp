import XCTest

final class ColorGraphAppUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }

    @MainActor
    func testMainTitleIsDisplayed() throws {
        let title = app.staticTexts["Live Color Data"]
        XCTAssertTrue(title.exists, "Main title 'Live Color Data' should be visible")
    }

    @MainActor
    func testInitialWaitingMessage() throws {
        let waitingText = app.staticTexts["Waiting for data..."]
        XCTAssertTrue(waitingText.exists, "The 'Waiting for data...' message should be shown initially")
    }

    @MainActor
    func testRGBChartOrDataAppears() throws {
        // This is a placeholder — depends on your chart implementation
        let redLabel = app.staticTexts["Red"]
        let greenLabel = app.staticTexts["Green"]
        let blueLabel = app.staticTexts["Blue"]

        // One or more RGB elements should eventually appear
        let anyColorDisplayed = redLabel.exists || greenLabel.exists || blueLabel.exists
        XCTAssertTrue(anyColorDisplayed, "Red, Green, or Blue data should appear in the UI after data arrives")
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
