Pod::Spec.new do |s|
    s.name        = 'ExelBid_iOS_Swift'
    s.version     = '2.0.1'
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

    s.source = {
        :git => 'https://github.com/onnuridmc/ExelBid_iOS_Swift.git',
        :tag => "#{s.version}"
    }

    s.platforms = {
        'ios' => '12.0'
    }

    s.pod_target_xcconfig = {
        'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
    }
    s.user_target_xcconfig = {
        'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
    }

    s.ios.deployment_target = '12.0'
    s.ios.vendored_frameworks = 'xcframework/ExelBidSDK.xcframework'

    s.frameworks = 'Foundation', 'UIKit', 'SystemConfiguration', 'AdSupport', 'AppTrackingTransparency', 'StoreKit', 'CoreGraphics', 'CoreLocation', 'CoreTelephony'

    s.requires_arc = true
end
