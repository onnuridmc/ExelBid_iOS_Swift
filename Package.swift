// swift-tools-version: 5.9
import PackageDescription

let version  = "3.0.2"

let package = Package(
    name: "ExelBid_iOS_Swift",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "ExelBidSDK",
            targets: ["ExelBidSDK"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "ExelBidSDK",
            url: "https://github.com/onnuridmc/ExelBid_iOS_Swift/releases/download/\(version)/ExelBidSDK.xcframework.zip",
            checksum: "a0abf546ae8653e9a37c250a3d67ad9b64a807272f26a302f07c5046ff4fe390"
        )
    ]
)
