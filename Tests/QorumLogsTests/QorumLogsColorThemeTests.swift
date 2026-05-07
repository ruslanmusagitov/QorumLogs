import XCTest
@testable import QorumLogs

final class QorumLogsColorThemeTests: XCTestCase {
    func testApplyingLightXcodeThemeUpdatesConsoleColors() {
        QorumLogs.applyColorTheme(.xcodeLight)

        XCTAssertEqual(QorumLogs.colorsForLogLevels[0].redColor, 80)
        XCTAssertEqual(QorumLogs.colorsForLogLevels[1].blueColor, 180)
    }

    func testApplyingDarkXcodeThemeUpdatesConsoleColors() {
        QorumLogs.applyColorTheme(.xcodeDark)

        XCTAssertEqual(QorumLogs.colorsForLogLevels[0].redColor, 170)
        XCTAssertEqual(QorumLogs.colorsForLogLevels[1].greenColor, 220)
    }

    func testThemesProvideSixLogLevelColors() {
        XCTAssertEqual(QorumLogColorTheme.xcodeLight.colors.count, 6)
        XCTAssertEqual(QorumLogColorTheme.xcodeDark.colors.count, 6)
    }
}
