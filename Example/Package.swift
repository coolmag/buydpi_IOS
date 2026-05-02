// swift-tools-version:5.9
import PackageDescription

let BBDExcludeIOS: [String] = [
    //Excluded from ByeDPI 'no VPN' target
    "ByeByeDPIAppPrx.swift",
    "UI/ScreenView/HomeScreenPrx.swift",
    //iOS build - Exclude tvOS storyboard
    "LaunchScreenTvOS.storyboard"
]
let BBDExcludeTvOS: [String] = [
    //Excluded from ByeDPI 'no VPN' target
    "ByeByeDPIAppPrx.swift",
    "UI/ScreenView/HomeScreenPrx.swift",
    //tvOS build - Exclude iOS storyboard
    "LaunchScreen.storyboard"
]

let package = Package(
    name: "ByeDPIAppModules",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14), .tvOS(.v17)
    ],
    products: [
        .library(name: "ByeByeDPI", targets: ["ByeByeDPI"]),
        .library(name: "ByeByeDPITun", targets: ["ByeByeDPITun"]),
    ],
    dependencies: [
        .package(url: "https://github.com/EbrahimTahernejad/Tun2SocksKit", from: "5.14.4"),
        .package(url: "https://github.com/mac-cain13/R.swift.git", from: "7.8.0"),
        .package(url: "https://github.com/sochalewski/TextFieldAlert", from: "1.4.0"),
        .package(path: "../"),//Local SwByeDPI dependency
    ],
    targets: [
        .target(name: "ByeByeDPI", dependencies: [
            .product(name: "TextFieldAlert", package: "TextFieldAlert"),
            .product(name: "RswiftLibrary", package: "R.swift"),
            .product(name: "ByeDPIKit", package: "clone"),
            .product(name: "SwByeDPI", package: "clone")
        ], exclude: BBDExcludeIOS, resources: [.copy("PrivacyInfo.xcprivacy")], linkerSettings: [
            .linkedFramework("CoreFoundation"),
            .linkedFramework("NetworkExtension")
        ], plugins: [
            .plugin(name: "RswiftGenerateInternalResources", package: "R.swift")
        ]),
        .target(name: "ByeByeDPITun", dependencies: [
            .product(name: "ByeDPIKit", package: "clone"),
            .product(name: "Tun2SocksKit", package: "Tun2SocksKit"),
        ], linkerSettings: [
            .linkedFramework("CoreFoundation"),
            .linkedFramework("NetworkExtension")
        ]),
    ],
    swiftLanguageVersions: [.v5]
)
