import XCTest
@testable import QorumLogs

final class QorumOnlineLogsTests: XCTestCase {
    func testExtractsFirstFourUniqueGoogleFormEntryFieldsInOrder() {
        let html = """
        <input type="hidden" name="entry.111" jsname="L9xHkb">
        <input type="hidden" name="entry.222" jsname="L9xHkb">
        <input type="hidden" name="entry.222" jsname="L9xHkb">
        <input type="hidden" name="entry_333" jsname="L9xHkb">
        <input type="hidden" name="entry.444" jsname="L9xHkb">
        <input type="hidden" name="entry.555" jsname="L9xHkb">
        """

        let fields = QorumOnlineLogs.extractGoogleFormFields(from: html)

        XCTAssertEqual(fields?.appVersionField, "entry.111")
        XCTAssertEqual(fields?.userInfoField, "entry.222")
        XCTAssertEqual(fields?.methodInfoField, "entry_333")
        XCTAssertEqual(fields?.errorTextField, "entry.444")
    }

    func testExtractGoogleFormFieldsReturnsNilWhenFormHasTooFewFields() {
        let html = """
        <input type="hidden" name="entry.111">
        <input type="hidden" name="entry.222">
        <input type="hidden" name="entry.333">
        """

        XCTAssertNil(QorumOnlineLogs.extractGoogleFormFields(from: html))
    }

    func testSetupWithOnlyFormLinkNormalizesViewFormLinkForPosting() {
        QorumOnlineLogs.setupOnlineLogs(formLink: "https://docs.google.com/forms/d/demo/viewform")

        XCTAssertEqual(
            QorumOnlineLogs.currentGoogleFormLink,
            "https://docs.google.com/forms/d/demo/formResponse"
        )
    }
}
