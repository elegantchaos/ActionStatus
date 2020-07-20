// swift-tools-version:5.3

/*
 Stub package which pulls the other packages that ActionCore needs into Xcode.
 Frankly this is easier and more reliable than relying on Xcode to do it.
 */
import PackageDescription

let package = Package(
    name: "ActionStatusPackages",
    platforms: [
        .macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v5)
    ],
    products: [
        .library(
            name: "ActionStatusPackages",
            targets: ["ActionStatusPackages"])
    ],
    dependencies: [
        .package(url: "https://github.com/elegantchaos/ApplicationExtensions.git", from: "1.1.0"),
        .package(url: "https://github.com/elegantchaos/ActionStatusCore.git", .branch("master")),
        .package(url: "https://github.com/elegantchaos/BindingsExtensions.git", from: "1.0.1"),
        .package(url: "https://github.com/elegantchaos/Bundles.git", from: "1.0.5"),
        .package(url: "https://github.com/elegantchaos/DictionaryCoding.git", from: "1.0.9"),
        .package(url: "https://github.com/elegantchaos/Displays.git", from: "1.1.0"),
        .package(url: "https://github.com/elegantchaos/Files.git", from: "1.0.5"),
        .package(url: "https://github.com/elegantchaos/Octoid.git", from: "1.0.0"),
        .package(url: "https://github.com/elegantchaos/ReleaseTools.git", .branch("resources")),
        .package(url: "https://github.com/elegantchaos/SwiftUIExtensions.git", from: "1.1.0"),
    ],
    targets: [
        .target(
            name: "ActionStatusPackages",
            dependencies: [
                "ApplicationExtensions",
                "ActionStatusCore",
                "BindingsExtensions",
                "DictionaryCoding",
                "Displays",
                "Files",
                "Octoid",
                "SwiftUIExtensions",
                .product(name: "rt", package: "ReleaseTools")
            ]),
        .testTarget(
            name: "ActionStatusPackagesTests",
            dependencies: ["ActionStatusPackages"]),
    ]
)
