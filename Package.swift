// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RegressionProtector",
    products: [
        .executable(
          name: "cli-regression-protector",
          targets: ["cli-regression-protector"]),
        .library(
            name: "RegressionProtector",
            targets: ["RegressionProtector"]),
    ],
    dependencies: [
	    .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.12.0"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.5.0"),
        .package(url: "https://github.com/kylef/Commander.git", .revision("314f8d7455e25e60e9e9b850040eebd0a87f2527")),
    ],
    targets: [
        .target(
          name: "cli-regression-protector",
          dependencies: ["RegressionProtector", "Commander"]),
        .target(
          name: "RegressionProtector",
          dependencies: ["SQLite"]),
        .testTarget(
          name: "RegressionProtectorTests",
          dependencies: ["SnapshotTesting", "RegressionProtector"]),
    ]
)
