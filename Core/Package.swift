// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Core",
    platforms: [
        .macOS(.v11), .iOS(.v14), .tvOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Core",
            targets: ["Core"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/elegantchaos/ApplicationExtensions.git", from: "2.1.3"),
        .package(url: "https://github.com/elegantchaos/BindingsExtensions.git", from: "1.0.1"),
        .package(url: "https://github.com/elegantchaos/Bundles.git", from: "1.0.9"),
        .package(url: "https://github.com/elegantchaos/CollectionExtensions.git", from: "1.1.6"),
        .package(url: "https://github.com/elegantchaos/DictionaryCoding.git", from: "1.0.9"),
        .package(url: "https://github.com/elegantchaos/Files.git", from: "1.2.1"),
        .package(url: "https://github.com/elegantchaos/Hardware.git", from: "1.0.1"),
        .package(url: "https://github.com/elegantchaos/Keychain.git", from: "1.0.0"),
        .package(url: "https://github.com/elegantchaos/LabelledGrid.git", from: "1.0.0"),
        .package(url: "https://github.com/elegantchaos/Logger.git", from: "1.7.3"),
        .package(url: "https://github.com/elegantchaos/Octoid.git", from: "1.0.4"),
        .package(url: "https://github.com/elegantchaos/SheetController.git", from: "1.0.2"),
        .package(url: "https://github.com/elegantchaos/SwiftUIExtensions.git", from: "1.3.6"),
        .package(url: "https://github.com/elegantchaos/UserDefaultsExtensions.git", from: "1.0.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Core",
            dependencies: [
                "ApplicationExtensions",
                "BindingsExtensions",
                "Bundles",
                "CollectionExtensions",
                "DictionaryCoding",
                "Files",
                "Hardware",
                "LabelledGrid",
                "Logger",
                .product(name: "LoggerUI", package: "Logger"),
                "Keychain",
                "Octoid",
                "SheetController",
                "SwiftUIExtensions",
                "UserDefaultsExtensions"
            ]),
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core"]),
    ]
)
