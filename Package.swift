// swift-tools-version: 5.9
import PackageDescription

let version  = "3.0.0-beta.4"

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
            checksum: "9280f4274a23c63eb88f85ef97fe21124564abcad123cdca551b959c78b19e8c"
        )
    ]
)
