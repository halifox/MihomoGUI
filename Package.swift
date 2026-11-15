// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MihomoGUI", platforms: [.macOS(.v13)],
    products: [.executable(name: "MihomoGUI", targets: ["MihomoGUI"]),
               .executable(name: "MihomoGUIHelper", targets: ["MihomoGUIHelper"])],
    targets: [
        .target(name: "MihomoGUICore"),
        .executableTarget(name: "MihomoGUIHelper", dependencies: ["MihomoGUICore"]),
        .executableTarget(name: "MihomoGUI", dependencies: ["MihomoGUICore"])
    ])
