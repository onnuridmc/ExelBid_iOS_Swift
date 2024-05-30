Pod::Spec.new do |s|
    s.name        = 'ExelBid_iOS_Swift'
    s.version     = '2.0.8'
    s.summary     = 'ExelBidSDK'
    s.description = 'ExelBidSDK for Publisher'
    s.homepage    = 'https://github.com/onnuridmc/ExelBid_iOS_Swift'
    s.license     = {
        :type => 'commercial',
        :text => 'Copyright 2014. Motivintelligence, Inc. All rights reserved.'
    }
    s.author = {
        'Motiv Intelligence' => 'dev@motiv-i.com'
    }

    s.resource_bundles = {
        'ExelBid_iOS_Swift' => ['xcframework/ExelBidSDK.xcframework/ios-arm64/ExelBidSDK.framework/PrivacyInfo.xcprivacy']
    }

    s.source = {
        :git => 'https://github.com/onnuridmc/ExelBid_iOS_Swift.git',
        :tag => "#{s.version}"
    }

    s.platforms = {
        'ios' => '12.0'
    }

    s.pod_target_xcconfig = {
        'VALID_ARCHS[sdk=iphoneos*]' => 'arm64',
        'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64 arm64'
    }
    s.user_target_xcconfig = {
        'VALID_ARCHS[sdk=iphoneos*]' => 'arm64',
        'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64 arm64'
    }

    s.ios.deployment_target = '12.0'
    s.ios.vendored_frameworks = 'xcframework/ExelBidSDK.xcframework'

    s.frameworks = 'Foundation', 'UIKit', 'SystemConfiguration', 'AdSupport', 'AppTrackingTransparency', 'StoreKit', 'CoreGraphics', 'CoreLocation', 'CoreTelephony'

    s.requires_arc = true
end
