Pod::Spec.new do |s|
  s.name             = "ExelBid_iOS_Swift"
  s.version          = "3.0.0-beta.2"
  s.summary          = "ExelBid iOS SDK — banner, native, and video ad formats."
  s.description      = <<-DESC
    ExelBid iOS SDK provides banner, native, and video
    ad formats with a Swift-first API and Objective-C compatibility.
    Distributed as a prebuilt XCFramework — no source compilation needed.
  DESC

  s.homepage         = "https://github.com/onnuridmc/ExelBid_iOS_Swift"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = { "ExelBid" => "dev@motiv-i.com" }

  s.platform         = :ios, "13.0"
  s.swift_versions   = ["5.9"]

  # Distribution: the prebuilt XCFramework is hosted as a GitHub Release
  # asset (zipped). CocoaPods downloads the zip directly, so the git
  # repository itself carries no binary artifacts.
  s.source = {
    :http => "https://github.com/onnuridmc/ExelBid_iOS_Swift/releases/download/#{s.version}/ExelBidSDK.xcframework.zip",
    :sha256 => "c685212bef39824b9479b6b6a4e8386aee7b6f994b43c1ae3f2d019dab1dfded"
  }

  s.vendored_frameworks = "ExelBidSDK.xcframework"

  s.frameworks = [
    "Foundation", "UIKit", "WebKit", "AVFoundation",
    "CoreGraphics", "CoreLocation", "CoreTelephony",
    "SystemConfiguration", "StoreKit", "AdSupport",
    "AppTrackingTransparency"
  ]
end
