// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Wasm3",
    platforms: [.macOS(.v12), .iOS(.v15)],
    products: [
        .library(
            name: "Wasm3",
            targets: ["Wasm3"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/realm/SwiftLint", from: "0.52.0")
    ],
    targets: [
        .target(
            name: "Wasm3",
            dependencies: ["wasm3-c"],
            plugins: [.plugin(name: "SwiftLintPlugin", package: "SwiftLint")]
        ),
        .target(
            name: "wasm3-c",
            cSettings: [
                .define("APPLICATION_EXTENSION_API_ONLY", to: "YES"),
                .define("d_m3MaxDuplicateFunctionImpl", to: "10"),
                .define("d_m3HasWASI", to: "YES"),
                .unsafeFlags(["-Wno-shorten-64-to-32"])
            ]
        ),
        .testTarget(
            name: "Wasm3Tests",
            dependencies: ["Wasm3"],
            resources: [.copy("Resources/wasm_test_bins.wasm")]
        ),
    ]
)
