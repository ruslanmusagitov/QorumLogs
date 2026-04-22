// swift-tools-version: 5.5
import PackageDescription

let package = Package(
    name: "QorumLogs",
    platforms: [
        .iOS(.v8),
        .tvOS(.v9),
        .macOS(.v10_10)
    ],
    products: [
        .library(
            name: "QorumLogs",
            targets: ["QorumLogs"]
        )
    ],
    targets: [
        .target(
            name: "QorumLogs",
            path: ".",
            exclude: [
                "QorumLogsExample",
                "QorumLogs",
                "LICENSE",
                "README.md",
                "Log To GoogleDocs.md",
                "QorumLogs.podspec"
            ],
            sources: ["QorumLogs.swift"]
        )
    ]
)

