// swift-tools-version:5.5

import PackageDescription

let package = Package(
  name: "swift-parsing",
  products: [
    .library(
      name: "Parsing",
      targets: ["Parsing"]
    ),
    .library(
      name: "Routing",
      targets: ["Routing"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "0.5.0"),
    .package(name: "Benchmark", url: "https://github.com/google/swift-benchmark", from: "0.1.1"),
    .package(url: "https://github.com/pointfreeco/swift-case-paths", from: "0.7.0"),
  ],
  targets: [
    .target(
      name: "Parsing",
      dependencies: [
        .product(name: "CasePaths", package: "swift-case-paths"),
      ]
    ),

    .testTarget(
      name: "ParsingTests",
      dependencies: ["Parsing"]
    ),
    .target(
      name: "Routing",
      dependencies: [
        "Parsing",
        .product(name: "CasePaths", package: "swift-case-paths"),
      ]
    ),
    .testTarget(
      name: "RoutingTests",
      dependencies: ["Routing"]
    ),
    .executableTarget(
      name: "swift-parsing-benchmark",
      dependencies: [
        "Parsing",
        .product(name: "Benchmark", package: "Benchmark"),
      ]
    ),
    .executableTarget(
      name: "variadics-generator",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ]
    ),
  ]
)
