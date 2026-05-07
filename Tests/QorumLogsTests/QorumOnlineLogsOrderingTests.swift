import XCTest
@testable import QorumLogs

final class QorumOnlineLogsOrderingTests: XCTestCase {
    override func tearDown() {
        QorumOnlineLogs.includeSequenceNumber = false
        QorumOnlineLogs.resetSequenceNumber()
        super.tearDown()
    }

    func testOnlineLogTextIsUnchangedByDefault() {
        XCTAssertEqual(QorumOnlineLogs.orderedLogText("hello"), "hello")
    }

    func testOnlineLogTextIncludesIncreasingSequenceNumberWhenEnabled() {
        QorumOnlineLogs.includeSequenceNumber = true

        XCTAssertEqual(QorumOnlineLogs.orderedLogText("first"), "#1 first")
        XCTAssertEqual(QorumOnlineLogs.orderedLogText("second"), "#2 second")
    }

    func testSequenceNumberCanBeResetForANewSession() {
        QorumOnlineLogs.includeSequenceNumber = true
        _ = QorumOnlineLogs.orderedLogText("first")

        QorumOnlineLogs.resetSequenceNumber()

        XCTAssertEqual(QorumOnlineLogs.orderedLogText("again"), "#1 again")
    }
}
