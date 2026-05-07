//
//  QorumLogs.swift
//  Qorum
//
//  Created by Goktug Yilmaz on 27/08/15.
//  Copyright (c) 2015 Goktug Yilmaz. All rights reserved.
//

import Foundation

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

private let kLogDebug = "Debug"
private let kLogInfo = "Info"
private let kLogWarning = "Warning"
private let kLogError = "Error"

public struct QorumLogs {

    /// While enabled QorumOnlineLogs does not work.
    nonisolated(unsafe) public static var enabled = false

    /// 1 to 4
    nonisolated(unsafe) public static var minimumLogLevelShown = 1

    /// Change the array element with another UIColor/NSColor.
    /// 0 is info gray, 5 is purple, rest are log levels.
    nonisolated(unsafe) public static var colorsForLogLevels: [QLColor] = [
        QLColor(r: 120, g: 120, b: 120), // 0
        QLColor(r: 0, g: 180, b: 180),   // 1
        QLColor(r: 0, g: 150, b: 0),     // 2
        QLColor(r: 255, g: 190, b: 0),   // 3
        QLColor(r: 255, g: 0, b: 0),     // 4
        QLColor(r: 160, g: 32, b: 240)   // 5
    ]

    /// Change the array element with another ANSI color.
    /// 0 is info gray, 5 is purple, rest are log levels.
    nonisolated(unsafe) public static var ansiColorsForLogLevels: [String] = [
        "37m", // 0 (gray)
        "34m", // 1 (blue)
        "32m", // 2 (green)
        "33m", // 3 (yellow)
        "31m", // 4 (red)
        "35m"  // 5 (magenta)
    ]

    /// Change the array element with another Emoji or String.
    /// 0 replaces gray color, 5 replaces purple, rest replace log levels.
    nonisolated(unsafe) public static var emojisForLogLevels: [String] = [
        "",   // 0
        "💙", // 1
        "💚", // 2
        "💛", // 3
        "❤️", // 4
        "💜"  // 5
    ]

    /// Uses emojis instead of colors when this is false.
    nonisolated(unsafe) public static var useColors = false

    /// Uses ANSI colors instead of colors or emojis when this is true.
    nonisolated(unsafe) public static var useAnsiColors = false

    /// Set your function that will get called whenever something new is logged.
    nonisolated(unsafe) public static var trackLogFunction: ((String) -> Void)?

    nonisolated(unsafe) private static var showFiles: [String] = []

    /// Ignores all logs from other files.
    public static func onlyShowTheseFiles(_ fileNames: Any...) {
        minimumLogLevelShown = 1

        let names = fileNames.map { resolveFileName(from: $0) }
        showFiles = names

        print(ColorLog.colorizeString("QorumLogs: Only Showing: \(names)", colorId: 5))
    }

    /// Ignores all logs from other files.
    public static func onlyShowThisFile(_ fileName: Any) {
        onlyShowTheseFiles(fileName)
    }

    /// Test to see if it works.
    public static func test() {
        let oldDebugLevel = minimumLogLevelShown
        minimumLogLevelShown = 1
        QL1(kLogDebug)
        QL2(kLogInfo)
        QL3(kLogWarning)
        QL4(kLogError)
        minimumLogLevelShown = oldDebugLevel
    }

    fileprivate static func shouldPrintLine(level: Int, fileName: String) -> Bool {
        guard enabled, minimumLogLevelShown <= level else {
            return false
        }
        return shouldShowFile(fileName)
    }

    fileprivate static func shouldShowFile(_ fileName: String) -> Bool {
        showFiles.isEmpty || showFiles.contains(fileName)
    }

    private static func resolveFileName(from object: Any) -> String {
        if let fileName = object as? String {
            return fileName
        }

        let reflectedTypeName = String(describing: type(of: object))
        return reflectedTypeName.split(separator: ".").last.map(String.init) ?? reflectedTypeName
    }
}

private let kOnlineLogDebug = "1Debug"
private let kOnlineLogInfo = "2Info"
private let kOnlineLogWarning = "3Warning"
private let kOnlineLogError = "4Error"

public struct QorumOnlineLogs {

    private static let appVersion = versionAndBuild()
    nonisolated(unsafe) private static var googleFormLink: String?
    nonisolated(unsafe) private static var googleFormAppVersionField: String?
    nonisolated(unsafe) private static var googleFormUserInfoField: String?
    nonisolated(unsafe) private static var googleFormMethodInfoField: String?
    nonisolated(unsafe) private static var googleFormErrorTextField: String?

    /// Online logs does not work while QorumLogs is enabled.
    nonisolated(unsafe) public static var enabled = false

    /// 1 to 4
    nonisolated(unsafe) public static var minimumLogLevelShown = 1

    /// Empty dictionary, add extra info like user id, username here.
    nonisolated(unsafe) public static var extraInformation: [String: String] = [:]

    /// Adds basic device information to the Google Docs user information payload.
    nonisolated(unsafe) public static var includeDeviceInformation = false

    nonisolated(unsafe) static var deviceInformationProvider: () -> [String: String] = defaultDeviceInformation

    /// Test to see if it works.
    public static func test() {
        let oldDebugLevel = minimumLogLevelShown
        minimumLogLevelShown = 1
        QL1(kLogDebug)
        QL2(kLogInfo)
        QL3(kLogWarning)
        QL4(kLogError)
        minimumLogLevelShown = oldDebugLevel
    }

    /// Setup Google Form links.
    public static func setupOnlineLogs(
        formLink: String,
        versionField: String,
        userInfoField: String,
        methodInfoField: String,
        textField: String
    ) {
        googleFormLink = formLink
        googleFormAppVersionField = versionField
        googleFormUserInfoField = userInfoField
        googleFormMethodInfoField = methodInfoField
        googleFormErrorTextField = textField
    }

    fileprivate static func sendError(classInformation: String, text: String, level: String) {
        guard
            let formLink = googleFormLink,
            let appVersionField = googleFormAppVersionField,
            let userInfoField = googleFormUserInfoField,
            let methodInfoField = googleFormMethodInfoField,
            let errorTextField = googleFormErrorTextField,
            let url = URL(string: formLink)
        else {
            return
        }

        let versionLevel = "\(appVersion) - \(level)"
        let userInfo = userInfoPayload().description

        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: appVersionField, value: versionLevel),
            URLQueryItem(name: userInfoField, value: userInfo),
            URLQueryItem(name: methodInfoField, value: classInformation),
            URLQueryItem(name: errorTextField, value: text)
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.percentEncodedQuery?.data(using: .utf8)

        URLSession.shared.dataTask(with: request).resume()

        let printText = "OnlineLogs: \(userInfo) - \(versionLevel) - \(classInformation) - \(text)"
        print(" \(ColorLog.colorizeString(printText, colorId: 5))\n", terminator: "")
    }

    fileprivate static func shouldSendLine(level: Int, fileName: String) -> Bool {
        guard enabled, minimumLogLevelShown <= level else {
            return false
        }
        return QorumLogs.shouldShowFile(fileName)
    }

    static func userInfoPayload() -> [String: String] {
        var payload = includeDeviceInformation ? deviceInformationProvider() : [:]
        extraInformation.forEach { key, value in
            payload[key] = value
        }
        return payload
    }

    static func defaultDeviceInformation() -> [String: String] {
        var info: [String: String] = [
            "device.osVersion": ProcessInfo.processInfo.operatingSystemVersionString,
            "device.locale": Locale.current.identifier,
            "device.timeZone": TimeZone.current.identifier
        ]

        #if os(macOS)
        info["device.system"] = "macOS"
        info["device.model"] = Host.current().localizedName ?? "Mac"
        #elseif canImport(UIKit)
        let device = UIDevice.current
        info["device.system"] = device.systemName
        info["device.model"] = device.model
        info["device.name"] = device.name
        #endif

        #if targetEnvironment(simulator)
        info["device.environment"] = "simulator"
        #else
        info["device.environment"] = "device"
        #endif

        return info
    }
}

/// Detailed logs only used while debugging.
public func QL1<T>(_ debug: T, _ file: String = #fileID, _ function: String = #function, _ line: Int = #line) {
    QLManager(debug, file: file, function: function, line: line, level: 1)
}

/// General information about app state.
public func QL2<T>(_ info: T, _ file: String = #fileID, _ function: String = #function, _ line: Int = #line) {
    QLManager(info, file: file, function: function, line: line, level: 2)
}

/// Indicates possible error.
public func QL3<T>(_ warning: T, _ file: String = #fileID, _ function: String = #function, _ line: Int = #line) {
    QLManager(warning, file: file, function: function, line: line, level: 3)
}

/// An unexpected error occured.
public func QL4<T>(_ error: T, _ file: String = #fileID, _ function: String = #function, _ line: Int = #line) {
    QLManager(error, file: file, function: function, line: line, level: 4)
}

private func printLog<T>(_ informationPart: String, text: T, level: Int) {
    print(" \(ColorLog.colorizeString(informationPart, colorId: 0))", terminator: "")
    print(" \(ColorLog.colorizeString(text, colorId: level))\n", terminator: "")
}

/// =====
public func QLShortLine(_ file: String = #fileID, _ function: String = #function, _ line: Int = #line) {
    QLineManager("======================================", file: file, function: function, line: line)
}

/// +++++
public func QLPlusLine(_ file: String = #fileID, _ function: String = #function, _ line: Int = #line) {
    QLineManager("+++++++++++++++++++++++++++++++++++++", file: file, function: function, line: line)
}

private func QLManager<T>(_ debug: T, file: String, function: String, line: Int, level: Int) {
    let levelText: String
    switch level {
    case 1:
        levelText = kOnlineLogDebug
    case 2:
        levelText = kOnlineLogInfo
    case 3:
        levelText = kOnlineLogWarning
    case 4:
        levelText = kOnlineLogError
    default:
        levelText = kOnlineLogDebug
    }

    let (filename, fileExtension) = extractFileNameAndExtension(from: file)
    let text = String(describing: debug)
    QorumLogs.trackLogFunction?(text)

    if QorumLogs.shouldPrintLine(level: level, fileName: filename) {
        let informationPart = "\(filename).\(fileExtension):\(line) \(function):"
        printLog(informationPart, text: debug, level: level)
    } else if QorumOnlineLogs.shouldSendLine(level: level, fileName: filename) {
        let informationPart = "\(filename).\(function)[\(line)]"
        QorumOnlineLogs.sendError(classInformation: informationPart, text: text, level: levelText)
    }
}

private func QLineManager(_ lineString: String, file: String, function: String, line: Int) {
    let (filename, fileExtension) = extractFileNameAndExtension(from: file)
    if QorumLogs.shouldPrintLine(level: 2, fileName: filename) {
        let informationPart = "\(filename).\(fileExtension):\(line) \(function):"
        printLog(informationPart, text: lineString, level: 5)
    }
}

private func extractFileNameAndExtension(from file: String) -> (name: String, ext: String) {
    let lastComponent = (file as NSString).lastPathComponent
    let nsString = lastComponent as NSString
    let name = nsString.deletingPathExtension
    let ext = nsString.pathExtension
    return (name, ext)
}

private struct ColorLog {
    private static let escape = "\u{001b}["
    private static let reset = "\(escape);"

    static func colorizeString<T>(_ object: T, colorId: Int) -> String {
        if QorumLogs.useAnsiColors {
            return "\(escape)1m\(escape)\(QorumLogs.ansiColorsForLogLevels[colorId])\(object)"
        }
        if QorumLogs.useColors {
            let color = QorumLogs.colorsForLogLevels[colorId]
            return "\(escape)fg\(color.redColor),\(color.greenColor),\(color.blueColor);\(object)\(reset)"
        }
        return "\(QorumLogs.emojisForLogLevels[colorId])\(object)\(QorumLogs.emojisForLogLevels[colorId])"
    }
}

private func versionAndBuild() -> String {
    let info = Bundle.main.infoDictionary
    let version = info?["CFBundleShortVersionString"] as? String ?? "0"
    let build = info?[kCFBundleVersionKey as String] as? String ?? "0"

    return version == build ? "v\(version)" : "v\(version)(\(build))"
}

/// Used in color settings for QorumLogs.
open class QLColor {
    #if os(macOS)
    let color: NSColor
    #elseif canImport(UIKit)
    let color: UIColor
    #endif

    private let redComponent: Int
    private let greenComponent: Int
    private let blueComponent: Int

    public init(r: CGFloat, g: CGFloat, b: CGFloat) {
        redComponent = Int(r.rounded()).clamped(to: 0...255)
        greenComponent = Int(g.rounded()).clamped(to: 0...255)
        blueComponent = Int(b.rounded()).clamped(to: 0...255)

        let redValue = CGFloat(redComponent) / 255.0
        let greenValue = CGFloat(greenComponent) / 255.0
        let blueValue = CGFloat(blueComponent) / 255.0

        #if os(macOS)
        color = NSColor(red: redValue, green: greenValue, blue: blueValue, alpha: 1)
        #elseif canImport(UIKit)
        color = UIColor(red: redValue, green: greenValue, blue: blueValue, alpha: 1)
        #endif
    }

    public convenience init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        self.init(r: red * 255, g: green * 255, b: blue * 255)
    }

    var redColor: Int { redComponent }
    var greenColor: Int { greenComponent }
    var blueColor: Int { blueComponent }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
