// swift-tools-version: 5.9
import PackageDescription

let version  = "3.0.0-beta.3"

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
            checksum: "d51fd8af579c0ab06c2f94c9baaf5d37b54bf5adfa0ce58ba1aab773a21bf168"
        )
    ]
)
