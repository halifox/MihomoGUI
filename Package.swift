// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "mihomo", platforms: [.macOS(.v13)],
    products: [.executable(name: "mihomo", targets: ["Mihomo"]),
               .executable(name: "mihomo-helper", targets: ["MihomoHelper"])],
    targets: [
        .target(name: "MihomoCore"),
        .executableTarget(name: "MihomoHelper", dependencies: ["MihomoCore"]),
        .executableTarget(name: "Mihomo", dependencies: ["MihomoCore"])
    ])
