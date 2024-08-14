## MPartners 배너 광고

**1. 광고 요청을 위한 변수 선언**

```
// 광고 인스턴스  
@property (nonatomic, strong) MPartnersAdView *adView;

// 광고가 표시될 뷰
@property (weak, nonatomic) IBOutlet UIView *adViewContainer;
```

**2. 광고 인스턴스 생성**
```
MPartnersAdView
/**
 * @param adUnitId - 광고 유닛 ID
 * @param size - 원하는 광고 크기입니다.
 */
- (nonnull instancetype)initWithAdUnitId:(NSString *)adUnitId size:(CGSize)size
```

예시)
```
// 광고 인스턴스 생성
self.adView = [[MPartnersAdView alloc] initWithAdUnitId:@"adUnitId" size:self.adViewContainer.bounds.size];
self.adView.delegate = self;

// 광고의 효율을 높이기 위해 나이, 성별을 설정하는 것이 좋습니다.
[self.adView setYob:@"1976"];
[self.adView setGender:@"M"];

// AdView 안에 너비 100%로 웹뷰가 바인딩되게 설정하려면 아래와 같이 메소드를 추가할 수 있습니다.  
// 기본 상태는 설정된 광고사이즈로 센터정렬되어 바인딩 된다.
[self.adView setFullWebView:YES];

// 광고 테스트 여부 (통계에 집계되지 않음)
[self.adView setTesting:YES];
```

**3. 광고 위치에 광고 뷰 추가**
```
[self.adViewContainer addSubview:self.adView];

// 광고 뷰에 AutoLayout constraint 적용
[self setAdViewAutolayoutConstraint:self.adViewContainer mine:self.adView];
```

**4. 광고 요청**
```
[self.adView loadAd];
```

### 배너광고 Protocol (EBAdViewDelegate Protocol Reference)
```
// 광고를 성공적으로로드하면 전송됩니다.
- (void)adViewDidLoadAd:(EBAdView *)view;

// 광고로드에 실패 할 때 전송됩니다.
- (void)adViewDidFailToLoadAd:(EBAdView *)view;

// 콘텐츠를로드하려고 할 때 전송됩니다.
- (void)willLoadViewForAd:(EBAdView *)view;

// 모달 콘텐츠를 닫았을 때 전송되어 애플리케이션에 제어권을 반환합니다.
- (void)didLoadViewForAd:(EBAdView *)view;

// 사용자가 광고를 탭하여 애플리케이션에서 나가려고 할 때 전송됩니다.
- (void)willLeaveApplicationFromAd:(EBAdView *)view;
```

## MPartners 네이티브 광고

**1. 네이티브 광고 뷰 선언**

네이티브 프로토콜을 참고하여 필요한 항목들로 UIView 클래스를 구성한다.  
자세한 사항은 샘플 코드를 참고해주세요.

- [EBNativeAdView.h](./sample_objc/EBNativeAdView.h)
- [EBNativeAdView.m](./sample_objc/EBNativeAdView.m)

**네이티브 광고 뷰 인스턴스 변수 선언**
```
@property (strong, nonatomic) UILabel *mainTextLabel;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIImageView *iconImageView;
@property (strong, nonatomic) UIImageView *mainImageView;
@property (strong, nonatomic) UIView *mainVideoView;
@property (strong, nonatomic) UIImageView *privacyInformationIconImageView;
@property (strong, nonatomic) UILabel *ctaLabel;
```

> 2017/07 방송통신위원회에서 시행되는 '온라인 맞춤형 광고 개인정보보호 가이드라인' 에 따라서 필수 적용 되어야 합니다.   
광고주측에서 제공하는 해당 광고의 타입(맞춤형 광고 여부)에 따라 정보 표시 아이콘(Opt-out)의 노출이 결정됩니다.  
※ 광고 정보 표시 아이콘이 노출될 ImageView의 사이즈는 NxN(권장 20x20)으로 설정 되어야 합니다.

**2. 네이트브 광고 인스턴스 변수 선언**
```
// 네이티브 광고 인스턴스 선언  
@property (nonatomic, strong) EBNativeAd *nativeAd;

// 네이티브 광고가 표시될 뷰 선언
@property (weak, nonatomic) IBOutlet UIView *adViewContainer;
```

**3. 네이티브 광고 요청 전처리**

```
MPartnersNativeManager
- (instancetype)init:(NSString *)identifier :(Class)adViewClass;
```

예시)
```
MPartnersNativeManager * ebNativeManager = [[MPartnersNativeManager alloc] init:@"adUnitId" :[EBNativeAdView class]];

// 네이티브 광고 요청시 어플리케이션에서 필수로 요청할 항목들을 설정합니다.
[ebNativeManager desiredAssets:[NSSet setWithObjects:
                                EBNativeAsset.kAdIconImageKey,
                                EBNativeAsset.kAdMainImageKey,
                                EBNativeAsset.kAdTitleKey,
                                EBNativeAsset.kAdTextKey,
                                EBNativeAsset.kAdCTATextKey,
                                nil]];
```

**3-1. 네이티브 동영상 광고 요청 전처리**
```
[ebNativeManager desiredAssets:[NSSet setWithObjects:
                                EBNativeAsset.kAdIconImageKey,
                                EBNativeAsset.kAdVideo,
                                EBNativeAsset.kAdTitleKey,
                                EBNativeAsset.kAdTextKey,
                                EBNativeAsset.kAdCTATextKey,
                                nil]];
```

**4. 네이티브 광고 요청 및 표시**
```

[ebNativeManager startWithCompletionHandler:^(EBNativeAdRequest *request, EBNativeAd *response, NSError *error) {
        if (error) {
            // 에러 처리
        } else {
            self.nativeAd = response;
            self.nativeAd.delegate = self;
            
            // 네이티브 광고 표시
            [self displayAd];
        }
}];
```
```
- (void)displayAd
{
    // 기존에 표시되던 View들을 제거
    [[self.adViewContainer subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIView *adView = [self.nativeAd retrieveAdViewWithError:nil];
    [self.adViewContainer addSubview:adView];
    adView.frame = self.adViewContainer.bounds;
}
```

**네이티브 광고 뷰 Protocol (EBNativeAdRenderingDelegate Protocol Reference)**
```
// 메인 텍스트에 사용하고있는 UILabel을 반환합니다.
- (UILabel *)nativeMainTextLabel;

// 제목 텍스트에 사용중인 UILabel을 반환합니다.
- (UILabel *)nativeTitleTextLabel;

// 아이콘 이미지에 사용중인 UIImageView를 반환합니다.
- (UIImageView *)nativeIconImageView;

// 메인 이미지에 사용중인 UIImageView를 반환합니다.
- (UIImageView *)nativeMainImageView;

// 동영상에 사용하는 UIView를 반환합니다.
// 동영상 광고를 게재 할 때만이를 구현하면됩니다.
- (UIView *)nativeVideoView;

// 클릭 유도 문안 (cta) 텍스트에 사용중인 UILabel을 반환합니다.
- (UILabel *)nativeCallToActionTextLabel;

// 개인 정보 아이콘에 대해 뷰가 사용중인 UIImageView를 반환합니다.
- (UIImageView *)nativePrivacyInformationIconImageView;
```
