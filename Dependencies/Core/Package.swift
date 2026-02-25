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
    .package(url: "https://github.com/elegantchaos/CollectionExtensions.git", from: "1.1.9"),
    .package(url: "https://github.com/elegantchaos/DictionaryCoding.git", from: "1.0.9"),
    .package(url: "https://github.com/elegantchaos/Files.git", from: "1.2.2"),
    .package(url: "https://github.com/elegantchaos/JSONSession.git", from: "2.0.0"),
    .package(url: "https://github.com/elegantchaos/Keychain.git", from: "1.0.0"),
    .package(url: "https://github.com/elegantchaos/Logger.git", from: "2.0.1"),
    .package(url: "https://github.com/elegantchaos/Octoid.git", from: "2.0.0"),
    .package(path: "../Runtime"),
  ],
  targets: [
    .target(
      name: "Core",
      dependencies: [
        "DictionaryCoding",
        "Files",
      ],
      swiftSettings: [
        .swiftLanguageMode(.v6)
      ]),
    .target(
      name: "CoreUI",
      dependencies: [
        "Core",
        "CollectionExtensions",
        "DictionaryCoding",
        "Files",
        "Logger",
        .product(name: "LoggerUI", package: "Logger"),
        "JSONSession",
        "Keychain",
        "Octoid",
        "Runtime",
      ]),
    .testTarget(
      name: "CoreTests",
      dependencies: ["Core", "CoreUI"]),
  ],
  swiftLanguageModes: [.v5]
)
