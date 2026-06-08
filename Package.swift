// swift-tools-version: 5.9
import PackageDescription

let version  = "3.0.0-beta.6"

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
            checksum: "91c0f2ab50b7eeb2c84b9198ea539a54638d53cfa137243a29c956a66bda7275"
        )
    ]
)
