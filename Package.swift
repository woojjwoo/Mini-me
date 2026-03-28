// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MiniMe",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .executable(name: "PixelPalsApp", targets: ["PixelPals"])
    ],
    targets: [
        .executableTarget(
            name: "PixelPals",
            path: "PixelPals"
        ),
        .target(
            name: "PixelPalsWidget",
            path: "PixelPalsWidget"
        )
    ]
)
