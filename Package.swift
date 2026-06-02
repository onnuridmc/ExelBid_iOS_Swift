// swift-tools-version: 5.9
import PackageDescription

let version  = "3.0.0-beta.2"

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
            checksum: "c685212bef39824b9479b6b6a4e8386aee7b6f994b43c1ae3f2d019dab1dfded"
        )
    ]
)
