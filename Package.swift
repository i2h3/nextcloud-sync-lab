// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NextcloudSyncLab",
    platforms: [
        .macOS(.v26),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        .package(url: "https://github.com/i2h3/nextcloud-container-manager.git", from: "1.3.0"),
        // .package(path: "../NextcloudContainerManager"),
        .package(url: "https://github.com/modelcontextprotocol/swift-sdk.git", from: "0.11.0"),
    ],
    targets: [
        .executableTarget(
            name: "NextcloudSyncLab",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "NextcloudContainerManager", package: "nextcloud-container-manager"),
                // .product(name: "NextcloudContainerManager", package: "NextcloudContainerManager"),
                .product(name: "MCP", package: "swift-sdk"),
            ]
        ),

    ],
    swiftLanguageModes: [.v6]
)
