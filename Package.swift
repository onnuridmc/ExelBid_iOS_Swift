// swift-tools-version: 5.9
import PackageDescription

let version  = "3.0.4"

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
            checksum: "337256fc7c14a88ae1e2d24f4fae208b7c53126f36f387e460410fda43582bfb"
        )
    ]
)
