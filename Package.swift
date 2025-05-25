// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "EzImageCleaner",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "ezimagecleaner-cli",
            targets: ["EzImageCleanerCLI"]
        ),
        .library(
            name: "EzImageCleanerCore",
            targets: ["EzImageCleanerCore"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0")
    ],
    targets: [
        .target(
            name: "EzImageCleanerCore",
            dependencies: []
        ),
        .executableTarget(
            name: "EzImageCleanerCLI",
            dependencies: [
                "EzImageCleanerCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .testTarget(
            name: "EzImageCleanerTests",
            dependencies: ["EzImageCleanerCore"]
        )
    ]
)