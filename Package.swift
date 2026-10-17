// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ClashDesk", platforms: [.macOS(.v13)],
    products: [.executable(name: "ClashDesk", targets: ["ClashDesk"]),
               .executable(name: "clash-stats", targets: ["ClashStats"]),
               .executable(name: "clash-helper", targets: ["ClashHelper"])],
    targets: [
        .systemLibrary(name: "CSQLite"),
        .target(name: "ClashCore", dependencies: ["CSQLite"]),
        .executableTarget(name: "ClashStats", dependencies: ["ClashCore"]),
        .executableTarget(name: "ClashHelper", dependencies: ["ClashCore"]),
        .executableTarget(name: "ClashDesk", dependencies: ["ClashCore"])
    ])
