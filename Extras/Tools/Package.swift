// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "Tools",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
         .package(url: "https://github.com/elegantchaos/ReleaseTools", from: "1.0.3"),
    ],
    targets: [
        .target(
            name: "Tools",
            dependencies: []),
        .testTarget(
            name: "ToolsTests",
            dependencies: ["Tools"]),
    ]
)
