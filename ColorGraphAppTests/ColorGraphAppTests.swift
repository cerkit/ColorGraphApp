import XCTest
@testable import ColorGraphApp

final class ColorGraphAppTests: XCTestCase {

    var service: MQTTService!

    @MainActor
    override func setUpWithError() throws {
        service = MQTTService()
    }

    override func tearDownWithError() throws {
        service = nil
    }

    @MainActor
    func testInitialDataIsEmpty() throws {
        XCTAssertTrue(service.incomingData.isEmpty, "Expected no color data on initialization")
    }

    @MainActor
    func testHandleMockColorMessageAppendsData() {
        let service = MQTTService()

        let timestamp = ISO8601DateFormatter().string(from: Date())
        let payload = """
        {
            "timestamp": "\(timestamp)",
            "red": 123,
            "green": 45,
            "blue": 67
        }
        """

        service.handleMockMessage(payload: payload)

        let exp = expectation(description: "Wait for async append")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let point = service.incomingData.first {
                XCTAssertEqual(point.red, 123)
                XCTAssertEqual(point.green, 45)
                XCTAssertEqual(point.blue, 67)
                exp.fulfill()
            } else {
                XCTFail("No data found in incomingData")
            }
        }

        wait(for: [exp], timeout: 1.0)
    }

    @MainActor func testHandleInvalidJSONDoesNotCrash() throws {
        let badJSON = "Not a JSON string"
        service.handleMockMessage(payload: badJSON)
        XCTAssertTrue(service.incomingData.isEmpty, "Should ignore invalid payloads")
    }

    func testPerformanceColorParsing() throws {
        let payload = """
        {
            "timestamp": "\(ISO8601DateFormatter().string(from: Date()))",
            "red": 100,
            "green": 150,
            "blue": 200
        }
        """

        self.measure {
            for _ in 0..<1000 {
                service.handleMockMessage(payload: payload)
            }
        }
    }
    
    @MainActor
    func testHandleMockMessageAddsColorDataPoint() {
        let service = MQTTService()

        let timestamp = ISO8601DateFormatter().string(from: Date())
        let payload = """
        {
            "timestamp": "\(timestamp)",
            "red": 255,
            "green": 128,
            "blue": 64
        }
        """

        service.handleMockMessage(payload: payload)

        let expectation = XCTestExpectation(description: "Wait for main queue to update incomingData")

        // Wait on the main queue to verify the value was added
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            guard let point = service.incomingData.first else {
                XCTFail("No data found in incomingData")
                return
            }

            XCTAssertEqual(point.red, 255)
            XCTAssertEqual(point.green, 128)
            XCTAssertEqual(point.blue, 64)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

}
