// swift-tools-version:6.2
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
      name: "CoreUIPreviews",
      targets: ["CoreUIPreviews"]),
    .library(
      name: "Core",
      targets: ["Core"]),
  ],
  dependencies: [
    .package(url: "https://github.com/elegantchaos/CollectionExtensions.git", from: "1.1.9"),
    .package(url: "https://github.com/elegantchaos/DictionaryCoding.git", from: "1.0.9"),
    .package(url: "https://github.com/elegantchaos/Files.git", from: "1.2.2"),
    .package(url: "https://github.com/elegantchaos/Keychain.git", from: "1.0.0"),
    .package(url: "https://github.com/elegantchaos/Logger.git", from: "2.0.1"),
    .package(url: "https://github.com/elegantchaos/JSONSession.git", from: "3.0.0"),
    .package(url: "https://github.com/elegantchaos/Octoid.git", from: "3.0.0"),

    .package(path: "../Application"),
    .package(path: "../Previews"),
    .package(path: "../Commands"),
    .package(path: "../Icons"),
    .package(path: "../Runtime"),
    .package(path: "../Settings"),
  ],
  targets: [
    .target(
      name: "Core",
      dependencies: [
        .product(name: "Application", package: "Application"),
        "DictionaryCoding",
        "Files",
        "Keychain",
        "Logger",
        "JSONSession",
        "Runtime",
        "Octoid",

        .product(name: "Commands", package: "Commands"),
      ],
      swiftSettings: [
        .swiftLanguageMode(.v6),
        .defaultIsolation(MainActor.self),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableExperimentalFeature("SendableProhibitsMainActorInference"),
      ]),
    .target(
      name: "CoreUI",
      dependencies: [
        "Core",
        "CollectionExtensions",
        "DictionaryCoding",
        "Files",
        "Logger",

        .product(name: "Application", package: "Application"),
        .product(name: "Commands", package: "Commands"),
        .product(name: "CommandsUI", package: "Commands"),
        .product(name: "Icons", package: "Icons"),
        .product(name: "LoggerUI", package: "Logger"),
        .product(name: "Settings", package: "Settings"),
      ],
      swiftSettings: [
        .swiftLanguageMode(.v6),
        .defaultIsolation(MainActor.self),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableExperimentalFeature("SendableProhibitsMainActorInference"),
      ]),
    .target(
      name: "CoreUIPreviews",
      dependencies: [
        "CoreUI",
        .product(name: "Previews", package: "Previews"),
      ],
      swiftSettings: [
        .swiftLanguageMode(.v6),
        .defaultIsolation(MainActor.self),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableExperimentalFeature("SendableProhibitsMainActorInference"),
      ]),
    .testTarget(
      name: "CoreTests",
      dependencies: ["Core", "CoreUI", "CoreUIPreviews"]),
  ],
)
