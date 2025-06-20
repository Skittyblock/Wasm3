// swift-tools-version: 6.0

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
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.59.1")
    ],
    targets: [
        .target(
            name: "Wasm3",
            dependencies: ["wasm3-c", "wasm3-support"],
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
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
        .target(
            name: "wasm3-support",
            dependencies: ["wasm3-c"]
        ),
        .testTarget(
            name: "Wasm3Tests",
            dependencies: ["Wasm3"],
            resources: [.copy("Resources/wasm_test_bins.wasm")]
        ),
    ],
    swiftLanguageModes: [.v6]
)
