// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MiniMe",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .executable(name: "MiniMeApp", targets: ["MiniMe"])
    ],
    targets: [
        .executableTarget(
            name: "MiniMe",
            path: "MiniMe"
        ),
        .target(
            name: "MiniMeWidget",
            path: "MiniMeWidget"
        )
    ]
)
