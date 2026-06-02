// swift-tools-version: 5.9
import PackageDescription

let version  = "3.0.0-beta.1"

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
            checksum: "b79062763f98a27f52adb3d6b194ff5ce3ae31413194ec0c9878a9f0b514bfbe"
        )
    ]
)
