import XCTest
@testable import QorumLogs

final class QorumOnlineLogsDeviceInfoTests: XCTestCase {
    override func tearDown() {
        QorumOnlineLogs.extraInformation = [:]
        QorumOnlineLogs.includeDeviceInformation = false
        QorumOnlineLogs.deviceInformationProvider = QorumOnlineLogs.defaultDeviceInformation
        super.tearDown()
    }

    func testUserInfoPayloadIncludesExtraInformation() {
        QorumOnlineLogs.extraInformation = ["userId": "42"]

        let payload = QorumOnlineLogs.userInfoPayload()

        XCTAssertEqual(payload["userId"], "42")
    }

    func testUserInfoPayloadMergesDeviceInformationWhenEnabled() {
        QorumOnlineLogs.extraInformation = ["userId": "42"]
        QorumOnlineLogs.includeDeviceInformation = true
        QorumOnlineLogs.deviceInformationProvider = {
            [
                "device.model": "iPhone Test",
                "device.os": "iOS 18.0"
            ]
        }

        let payload = QorumOnlineLogs.userInfoPayload()

        XCTAssertEqual(payload["userId"], "42")
        XCTAssertEqual(payload["device.model"], "iPhone Test")
        XCTAssertEqual(payload["device.os"], "iOS 18.0")
    }

    func testExtraInformationWinsWhenItUsesSameKeyAsDeviceInformation() {
        QorumOnlineLogs.extraInformation = ["device.model": "custom model"]
        QorumOnlineLogs.includeDeviceInformation = true
        QorumOnlineLogs.deviceInformationProvider = { ["device.model": "default model"] }

        XCTAssertEqual(QorumOnlineLogs.userInfoPayload()["device.model"], "custom model")
    }
}
