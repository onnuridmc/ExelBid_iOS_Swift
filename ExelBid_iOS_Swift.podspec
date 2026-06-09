Pod::Spec.new do |s|
  s.name             = "ExelBid_iOS_Swift"
  s.version          = "3.0.3"
  s.summary          = "ExelBid iOS SDK — banner, native, and video ad formats."
  s.description      = <<-DESC
    ExelBid iOS SDK provides banner, native, and video
    ad formats with a Swift-first API and Objective-C compatibility.
    Distributed as a prebuilt XCFramework — no source compilation needed.
  DESC

  s.homepage         = "https://github.com/onnuridmc/ExelBid_iOS_Swift"
  s.license          = { :type => "MIT" }
  s.author           = { "ExelBid" => "dev@motiv-i.com" }

  s.platform         = :ios, "13.0"
  s.swift_versions   = ["5.9"]

  # Distribution: the prebuilt XCFramework is hosted as a GitHub Release
  # asset (zipped). CocoaPods downloads the zip directly, so the git
  # repository itself carries no binary artifacts.
  s.source = {
    :http => "https://github.com/onnuridmc/ExelBid_iOS_Swift/releases/download/#{s.version}/ExelBidSDK.xcframework.zip",
    :sha256 => "e2c1923a44eb656d66630be633cd91654dc266b08a1d35dd264e5733fa4b5665"
  }

  s.vendored_frameworks = "ExelBidSDK.xcframework"

  s.frameworks = [
    "Foundation", "UIKit", "WebKit", "AVFoundation",
    "CoreGraphics", "CoreLocation", "CoreTelephony",
    "SystemConfiguration", "StoreKit", "AdSupport",
    "AppTrackingTransparency"
  ]
end
