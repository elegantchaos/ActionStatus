// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Core",
  platforms: [
    .macOS("26.0"), .iOS("26.0"), .tvOS("26.0"),
  ],
  products: [
    .library(
      name: "CoreUI",
      targets: ["CoreUI"]),
    .library(
      name: "Core",
      targets: ["Core"]),
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    .package(url: "https://github.com/elegantchaos/Bundles.git", from: "1.0.9"),
    .package(url: "https://github.com/elegantchaos/CollectionExtensions.git", from: "1.1.9"),
    .package(url: "https://github.com/elegantchaos/DictionaryCoding.git", from: "1.0.9"),
    .package(url: "https://github.com/elegantchaos/Files.git", from: "1.2.1"),
    .package(url: "https://github.com/elegantchaos/Hardware.git", from: "1.0.1"),
    .package(url: "https://github.com/elegantchaos/Keychain.git", from: "1.0.0"),
    .package(url: "https://github.com/elegantchaos/Logger.git", from: "1.7.3"),
    .package(url: "https://github.com/elegantchaos/Octoid.git", from: "1.0.6"),
  ],
  targets: [
    .target(
      name: "Core",
      dependencies: [
        "DictionaryCoding",
        "Files",
      ],
      path: "Sources/CoreRuntime",
      swiftSettings: [
        .swiftLanguageMode(.v6)
      ]),
    .target(
      name: "CoreUI",
      dependencies: [
        "Core",
        "Bundles",
        "CollectionExtensions",
        "DictionaryCoding",
        "Files",
        "Hardware",
        "Logger",
        .product(name: "LoggerUI", package: "Logger"),
        "Keychain",
        "Octoid",
      ],
      path: "Sources/Core"),
    .testTarget(
      name: "CoreTests",
      dependencies: ["CoreUI", "Core"]),
  ],
  swiftLanguageModes: [.v5]
)
