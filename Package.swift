// swift-tools-version: 5.9
import PackageDescription

let version  = "3.0.0-beta.5"

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
            checksum: "fb753702638def61d23bcac047bab90fb91f594858a7f30e21a6ed8dffa3e228"
        )
    ]
)
