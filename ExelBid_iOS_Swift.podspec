Pod::Spec.new do |s|

  s.name         = "ExelBid_iOS_Swift"
  s.version      = "2.0.0"
  s.summary      = "ExelBidSDK.xcframework"
  s.homepage     = "https://github.com/onnuridmc/ExelBid_iOS_Swift"
  s.license      = { :type => "Commercial",
:text => <<-LICENSE
All text and design is copyright 2014-2024 Motiv Intelligence, Inc.
All rights reserved.
https://github.com/onnuridmc/ExelBid_iOS_Swift
LICENSE
}

  s.ios.deployment_target = '12.0'
  s.author             = { "Motiv Intelligence" => "dev@motiv-i.com" }
  s.platform     = :ios, "12.0"
  s.source       = { :git => "https://github.com/onnuridmc/ExelBid_iOS_Swift.git", :tag => "#{s.version}" }
  s.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

  s.ios.vendored_frameworks = 'ExelBidSDK.xcframework'
  s.frameworks = 'Foundation', 'UIKit', 'SystemConfiguration', 'AdSupport', 'AppTrackingTransparency', 'StoreKit', 'CoreGraphics', 'CoreLocation', 'CoreTelephony'

  s.requires_arc = true
end
