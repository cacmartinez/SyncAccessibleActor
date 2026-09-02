// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SyncAccessibleActor",
    platforms: [
        .macOS(.v15),
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "SyncAccessibleActor",
            targets: ["SyncAccessibleActor"]),
    ],
    dependencies: [
        .package(url:"https://github.com/cacmartinez/StrategyDispatchQueue.git", branch: "main")
    ],
    targets: [
        .target(
            name: "SyncAccessibleActor",
            dependencies: [.product(name: "StrategyDispatchQueue", package: "StrategyDispatchQueue")],
            path: "Sources/SyncAccessibleActor"),
        .testTarget(
            name: "SyncAccessibleActorTests",
            dependencies: ["SyncAccessibleActor"]
        ),
    ]
)
