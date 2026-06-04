// swift-tools-version: 5.9
import PackageDescription

let version  = "3.0.0"

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
            checksum: "9b42c31dcb07b6510df1373be24bad4c8db939a65d64607de996f3f9a4607cee"
        )
    ]
)
