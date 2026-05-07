import XCTest
@testable import QorumLogs

final class QorumLogsCustomQLTests: XCTestCase {
    override func tearDown() {
        QorumLogs.trackLogFunction = nil
        QorumLogs.enabled = false
        super.tearDown()
    }

    func testPublicQLFunctionAllowsCustomWrapperMethods() {
        var tracked: [String] = []
        QorumLogs.trackLogFunction = { tracked.append($0) }

        func QLNetwork<T>(_ value: T) {
            QL(value, level: 2, "NetworkClient.swift", "request()", 10)
        }

        QLNetwork("started")

        XCTAssertEqual(tracked, ["started"])
    }

    func testPublicQLFunctionClampsCustomLevelsToSupportedRange() {
        var tracked: [String] = []
        QorumLogs.trackLogFunction = { tracked.append($0) }

        QL("too low", level: -10)
        QL("too high", level: 99)

        XCTAssertEqual(tracked, ["too low", "too high"])
    }
}
