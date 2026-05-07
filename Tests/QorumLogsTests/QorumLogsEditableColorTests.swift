import XCTest
@testable import QorumLogs

final class QorumLogsEditableColorTests: XCTestCase {
    override func tearDown() {
        QorumLogs.resetColorsForLogLevels()
        super.tearDown()
    }

    func testCanSetColorUsingNamedLogLevel() {
        QorumLogs.setColor(QLColor(r: 1, g: 2, b: 3), for: .warning)

        XCTAssertEqual(QorumLogs.color(for: .warning).redColor, 1)
        XCTAssertEqual(QorumLogs.color(for: .warning).greenColor, 2)
        XCTAssertEqual(QorumLogs.color(for: .warning).blueColor, 3)
    }

    func testCanResetColorsToDefaults() {
        QorumLogs.setColor(QLColor(r: 1, g: 2, b: 3), for: .debug)

        QorumLogs.resetColorsForLogLevels()

        XCTAssertEqual(QorumLogs.color(for: .debug).redColor, 0)
        XCTAssertEqual(QorumLogs.color(for: .debug).greenColor, 180)
        XCTAssertEqual(QorumLogs.color(for: .debug).blueColor, 180)
    }

    func testNamedLevelsMapToExistingColorIndexes() {
        XCTAssertEqual(QorumLogLevel.infoColor.colorIndex, 0)
        XCTAssertEqual(QorumLogLevel.debug.colorIndex, 1)
        XCTAssertEqual(QorumLogLevel.info.colorIndex, 2)
        XCTAssertEqual(QorumLogLevel.warning.colorIndex, 3)
        XCTAssertEqual(QorumLogLevel.error.colorIndex, 4)
        XCTAssertEqual(QorumLogLevel.line.colorIndex, 5)
    }
}
