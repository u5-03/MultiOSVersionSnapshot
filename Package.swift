// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MultiOSVersionSnapshot",
    products: [
        .executable(name: "MultiOSVersionSnapshot", targets: ["MultiOSVersionSnapshot"])
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", from: "3.0.1"),
        .package(url: "https://github.com/kylef/Commander.git", from: "0.9.1"),
        .package(url: "https://github.com/jakeheis/SwiftCLI.git", from: "6.0.0"),
        .package(url: "https://github.com/kylef/PathKit", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "MultiOSVersionSnapshot",
            dependencies: ["MultiOSVersionSnapshotCore", "Yams", "Commander", "SwiftCLI", "PathKit"]),
        .target(
            name: "MultiOSVersionSnapshotCore",
            dependencies: ["Commander"]),
        .testTarget(
            name: "MultiOSVersionSnapshotTests",
            dependencies: ["MultiOSVersionSnapshot"]),
    ]
)
