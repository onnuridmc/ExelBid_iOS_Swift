## MPartners 배너 광고

**1. 광고 요청을 위한 변수 선언**

```
// 광고 인스턴스  
var adView: MPartnersAdView?

// 광고가 표시될 뷰
@IBOutlet var adViewContainer: UIView!
```

**2. 광고 인스턴스 생성**
```
/**
 * @param adUnitId - 광고 유닛 ID
 * @param size - 원하는 광고 크기입니다.
 */
MPartnersAdView(adUnitId: String?, size: CGSize)
```

예시)
```
// 광고 인스턴스 생성
self.adView = MPartnersAdView(adUnitId: "adUnitId", size: self.adViewContainer.bounds.size)
if let adView = self.adView {
    adView.delegate = self
    
    // AdView 안에 너비 100%로 웹뷰가 바인딩되게 설정하려면 아래와 같이 메소드를 추가할 수 있습니다.  
    // 기본 상태는 설정된 광고사이즈로 센터정렬되어 바인딩 된다.
    adView.fullWebView = true
    
    // 광고의 효율을 높이기 위해 나이, 성별을 설정하는 것이 좋습니다.
    adView.yob = "1976"
    adView.gender = "M"
    // adView.testing = true
}
```

**3. 광고 위치에 광고 뷰 추가**
```
self.adViewContainer.addSubview(adView)

// 광고 뷰에 AutoLayout constraint 적용
setAutoLayout(view: self.adViewContainer, adView: adView)
```

**4. 광고 요청**
```
adView.loadAd()
```

### 배너광고 Protocol (EBAdViewDelegate Protocol Reference)
```
// 광고를 성공적으로로드하면 전송됩니다.
func adViewDidLoadAd(_ view: ExelBidSDK.EBAdView?)

// 광고로드에 실패 할 때 전송됩니다.
func adViewDidFailToLoadAd(_ view: ExelBidSDK.EBAdView?)

// 콘텐츠를로드하려고 할 때 전송됩니다.
func willLoadViewForAd(_ view: ExelBidSDK.EBAdView?)

// 모달 콘텐츠를 닫았을 때 전송되어 애플리케이션에 제어권을 반환합니다.
func didLoadViewForAd(_ view: ExelBidSDK.EBAdView?)

// 사용자가 광고를 탭하여 애플리케이션에서 나가려고 할 때 전송됩니다.
func willLeaveApplicationFromAd(_ view: ExelBidSDK.EBAdView?)
```

## MPartners 네이티브 광고

**1. 네이티브 광고 뷰 선언**

네이티브 프로토콜을 참고하여 필요한 항목들로 UIView 클래스를 구성한다.  
자세한 사항은 샘플 코드를 참고해주세요.

- [EBNativeAdView.swift](./sample/ExelbidSample/Views/EBNativeAdView.swift)

**네이티브 광고 뷰 인스턴스 변수 선언**
```
var titleLabel: UILabel!
var mainTextLabel: UILabel!
var iconImageView: UIImageView!
var mainImageView: UIImageView!
var mainVideoView: UIView!
var privacyInformationIconImageView: UIImageView!
var ctaLabel: UILabel!
```

**네이티브 광고 뷰 Protocol (EBNativeAdRenderingDelegate Protocol Reference)**
```
// 메인 텍스트에 사용하고있는 UILabel을 반환합니다.
func nativeMainTextLabel() -> UILabel?

// 제목 텍스트에 사용중인 UILabel을 반환합니다.
func nativeTitleTextLabel() -> UILabel?

// 아이콘 이미지에 사용중인 UIImageView를 반환합니다.
func nativeIconImageView() -> UIImageView?

// 메인 이미지에 사용중인 UIImageView를 반환합니다.
func nativeMainImageView() -> UIImageView?

// 동영상에 사용하는 UIView를 반환합니다. 동영상 광고를 게재 할 때만이를 구현하면됩니다.
func nativeVideoView() -> UIView?

// 클릭 유도 문안 (cta) 텍스트에 사용중인 UILabel을 반환합니다.
func nativeCallToActionTextLabel() -> UILabel?

// 개인 정보 아이콘에 대해 뷰가 사용중인 UIImageView를 반환합니다.
func nativePrivacyInformationIconImageView() -> UIImageView?
```

> 2017/07 방송통신위원회에서 시행되는 '온라인 맞춤형 광고 개인정보보호 가이드라인' 에 따라서 필수 적용 되어야 합니다.   
광고주측에서 제공하는 해당 광고의 타입(맞춤형 광고 여부)에 따라 정보 표시 아이콘(Opt-out)의 노출이 결정됩니다.  
※ 광고 정보 표시 아이콘이 노출될 ImageView의 사이즈는 NxN(권장 20x20)으로 설정 되어야 합니다.

**2. 네이트브 광고 인스턴스 변수 선언**
```
// 네이티브 광고 인스턴스 선언  
var nativeAd: EBNativeAd?

// 네이티브 광고가 표시될 뷰 선언
@IBOutlet var adViewContainer: UIView!
```

**3. 네이티브 광고 요청 전처리**

```
MPartnersNativeManager(_ identifier: String, _ adViewClass: AnyClass?)
```

예시)
```
let ebNativeManager = MPartnersNativeManager("adUnitId", EBNativeAdView.self)

// 광고의 효율을 높이기 위해 나이, 성별을 설정하는 것이 좋습니다.
ebNativeManager.yob("1987")
ebNativeManager.gender("M")
// ebNativeManager.testing(true)

// 네이티브 광고 요청시 어플리케이션에서 필수로 요청할 항목들을 설정합니다.
ebNativeManager.desiredAssets([EBNativeAsset.kAdIconImageKey,
                               EBNativeAsset.kAdMainImageKey,
                               EBNativeAsset.kAdCTATextKey,
                               EBNativeAsset.kAdTextKey,
                               EBNativeAsset.kAdTitleKey])
```

**4. 네이티브 광고 요청 및 표시**
```
ebNativeManager.startWithCompletionHandler { (request, response, error) in
    if error != nil {
        // 에러 처리
    }else{
        self.nativeAd = response
        self.nativeAd?.delegate = self
        
        // 네이티브 광고 표시
        self.displayAd()
    }
}
```
```

func displayAd() {
    // 기존에 표시되던 View들을 제거
    adViewContainer.subviews.forEach { subview in
        subview.removeFromSuperview()
    }
    
    if let adView = nativeAd?.retrieveAdViewWithError(nil) {
        adViewContainer.addSubview(adView)
        setAutoLayout2(view: adViewContainer, adView: adView)
    }
}
```

### 네이티브 광고 Protocol (EBNativeAdDelegate Protocol Reference)
```

// 네이티브 광고가 모달 콘텐츠를 표시 할 때 전송됩니다.
func willLoadForNativeAd(_ nativeAd: ExelBidSDK.EBNativeAd?)

// 네이티브 광고가 모달 콘텐츠를 닫았을 때 전송되어 애플리케이션에 제어권을 반환합니다.
func didLoadForNativeAd(_ nativeAd: ExelBidSDK.EBNativeAd?)

// 사용자가이 기본 광고를 탭한 결과로 애플리케이션에서 나 가려고 할 때 전송됩니다.
func willLeaveApplicationFromNativeAd(_ nativeAd: ExelBidSDK.EBNativeAd?)

// 광고를 탭할 때 나타날 수있는 인앱 브라우저와 같은 모달 콘텐츠를 표시하는 데 사용할 뷰 컨트롤러를 대리인에게 요청합니다.
func viewControllerForPresentingModalView() -> UIViewController?
```
