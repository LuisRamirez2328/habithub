// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "HabitCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "HabitCore", targets: ["HabitCore"]),
    ],
    targets: [
        .target(name: "HabitCore", path: "Sources/HabitCore"),
        .testTarget(name: "HabitCoreTests", dependencies: ["HabitCore"], path: "Tests/HabitCoreTests"),
    ]
)
