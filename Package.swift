// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SyncAccessibleActor_private",
    platforms: [
        .macOS(.v15),
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "SyncAccessibleActor_Debug",
            targets: ["SyncAccessibleActor"]),
    ],
    dependencies: [
        .package(url:"https://github.com/cacmartinez/StrategyDispatchQueue_private.git", branch: "main")
    ],
    targets: [
        .target(
            name: "SyncAccessibleActor",
            dependencies: [.product(name: "StrategyDispatchQueue_Debug", package: "StrategyDispatchQueue_private")],
            path: "Sources/SyncAccessibleActor"),
        .testTarget(
            name: "SyncAccessibleActorTests",
            dependencies: ["SyncAccessibleActor"]
        ),
    ]
)
