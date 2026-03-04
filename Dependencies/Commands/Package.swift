// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "Commands",

  defaultLocalization: "en",

  platforms: [.macOS(.v26), .iOS(.v26), .macCatalyst(.v26), .watchOS(.v26)],

  products: [
    .library(
      name: "Commands",
      targets: ["Commands"]
    ),
    .library(
      name: "CommandsUI",
      targets: ["CommandsUI"]
    ),
  ],

  dependencies: [
    .package(path: "../Icons"),
    .package(url: "https://github.com/elegantchaos/Logger", from: "2.0.0")
  ],

  targets: [
    .target(
      name: "Commands",
      dependencies: [
        .product(name: "Logger", package: "Logger")
      ],
      exclude: [
        "README.md"
      ]
    ),

    .target(
      name: "CommandsUI",
      dependencies: [
        "Commands",
        .product(name: "Icons", package: "Icons")
      ],
      exclude: [
        "README.md"
      ],
      resources: [
        .process("Resources")
      ],
    ),

    .testTarget(
      name: "CommandsTests",
      dependencies: [
        "Commands"
      ]
    ),

    .testTarget(
      name: "CommandsUITests",
      dependencies: ["CommandsUI"]
    ),

  ]
)

for target in package.targets {
  var settings = target.swiftSettings ?? []
  settings.append(contentsOf: [
    .defaultIsolation(MainActor.self),
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("InferIsolatedConformances"),
    .enableExperimentalFeature("SendableProhibitsMainActorInference"),
  ])
  target.swiftSettings = settings
}
