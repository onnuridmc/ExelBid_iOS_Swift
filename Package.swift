// swift-tools-version: 5.9
import PackageDescription

let version  = "3.0.3"

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
            checksum: "e2c1923a44eb656d66630be633cd91654dc266b08a1d35dd264e5733fa4b5665"
        )
    ]
)
