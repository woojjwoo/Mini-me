// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PixieMe",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .executable(name: "PixieMe", targets: ["App"])
    ],
    targets: [
        .executableTarget(
            name: "App",
            path: "App"
        ),
        .target(
            name: "Widget",
            path: "Widget"
        )
    ]
)
