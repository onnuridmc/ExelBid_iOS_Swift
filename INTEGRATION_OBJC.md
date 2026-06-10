# ExelBid iOS SDK — 연동 가이드 (Objective-C)

호스트 앱에 ExelBid 광고를 추가하는 방법을 단계별로 설명합니다.
Swift 사용자는 [`README.md`](./README.md)를 참고하세요.

> **v2 호스트인가요?** 두 가지 선택지가 있습니다.
>
> - **2.x 그대로 유지** — 2.x 라인은 별도 브랜치
>   ([`release/2.x`](https://github.com/onnuridmc/ExelBid_iOS_Swift/tree/release/2.x))
>   에서 계속 유지되며 가이드도 그쪽에 있습니다
>   ([Objective-C](https://github.com/onnuridmc/ExelBid_iOS_Swift/blob/release/2.x/README_OBJC.md)
>   · [Swift](https://github.com/onnuridmc/ExelBid_iOS_Swift/blob/release/2.x/README.md)
>   · [MPartners (ObjC)](https://github.com/onnuridmc/ExelBid_iOS_Swift/blob/release/2.x/README_MPartners_Objc.md)
>   · [MPartners (Swift)](https://github.com/onnuridmc/ExelBid_iOS_Swift/blob/release/2.x/README_MPartners.md)).
>   CocoaPods 는 `pod 'ExelBid_iOS_Swift', '~> 2.2'` 로 핀하면 3.x 로
>   자동 올라가지 않으며, SwiftPM 은 "Up to Next Major" 를 `2.2.0`
>   (또는 최신 2.x 태그) 으로 잡으면 됩니다.
> - **v3 로 업그레이드** — 클래스 이름·델리게이트·생명주기가 v3 에서
>   새로 바뀌었습니다. v2 ↔ v3 대응 코드와 변경점은
>   [`MIGRATION_v2_to_v3_OBJC.md`](./MIGRATION_v2_to_v3_OBJC.md) 에서
>   영역별로 안내합니다. 광고 단위 ID 와 서버 통신 규약은 그대로라 기존
>   ID 를 계속 사용할 수 있습니다.

## 목차

- [요구사항](#요구사항)
- [설치](#설치)
- [앱 설정](#앱-설정)
- [SDK 임포트](#sdk-임포트)
- [배너 광고](#배너-광고)
- [전면 광고](#전면-광고)
- [네이티브 광고](#네이티브-광고)
- [비디오 광고](#비디오-광고)
- [공통 옵션](#공통-옵션)
- [미디에이션](#미디에이션)
- [에러 처리](#에러-처리)

> MPartners 광고는 별도 문서 [`MPARTNERS_OBJC.md`](./MPARTNERS_OBJC.md)에서
> 다룹니다.

---

## 요구사항

| 항목 | 값 |
|---|---|
| 최소 iOS | 13.0 |
| Xcode | 15 이상 |
| 광고 단위 ID | 운영팀에서 발급 |

---

## 설치

### Swift Package Manager

Xcode → **File → Add Package Dependencies…** 에서 아래 URL을 입력합니다.

```
https://github.com/onnuridmc/ExelBid_iOS_Swift
```

사용할 버전을 선택한 뒤 앱 타겟에 `ExelBidSDK` 라이브러리를 추가합니다.

### CocoaPods

`Podfile`에 다음 한 줄을 추가하고 `pod install`을 실행합니다.

```ruby
pod 'ExelBid_iOS_Swift'
```

> Objective-C 호스트 앱이라도 SDK 자체는 Swift로 작성되어
> 있으므로, 앱 타겟의 **Embedded Binaries**에 `ExelBidSDK`가
> 포함되어야 합니다. CocoaPods를 사용하는 경우 `use_frameworks!`가
> 필요합니다.

---

## 앱 설정

### Info.plist

다음 키를 호스트 앱의 `Info.plist`에 추가합니다.

```xml
<key>NSUserTrackingUsageDescription</key>
<string>맞춤형 광고 제공을 위해 광고 식별자를 사용합니다.</string>

<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
</dict>
```

> 일부 광고 크리에이티브가 HTTP로 서빙될 수 있어
> `NSAllowsArbitraryLoads`가 필요합니다. 보안 정책에 맞춰
> 도메인별 예외(`NSExceptionDomains`)로 제한해도 됩니다.

### SKAdNetwork (선택, 권장)

iOS 14+ 광고주 어트리뷰션을 받으려면 `Info.plist`에
`SKAdNetworkItems`를 등록합니다. 식별자 목록은 운영팀에서
제공받으세요.

```xml
<key>SKAdNetworkItems</key>
<array>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>example123.skadnetwork</string>
  </dict>
</array>
```

### App Tracking Transparency

광고 식별자(IDFA) 사용 권한을 요청합니다.

```objc
#import <AppTrackingTransparency/AppTrackingTransparency.h>

if (@available(iOS 14, *)) {
    [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
        // SDK가 매 요청마다 권한 상태를 다시 확인합니다.
    }];
}
```

권한이 거부되거나 미요청 상태일 경우 SDK는 자동으로
24시간 주기 회전 UUID를 사용하고 요청에 `dnt=1`을 전송합니다.

---

## SDK 임포트

Swift로 작성된 SDK이므로 자동 생성된 ObjC 헤더를 임포트합니다.

```objc
#import <ExelBidSDK/ExelBidSDK-Swift.h>
```

> CocoaPods의 `:modular_headers`가 활성화되어 있으면
> `@import ExelBidSDK;` 형식도 사용 가능합니다.

---

## 배너 광고

```objc
#import <ExelBidSDK/ExelBidSDK-Swift.h>

@interface HomeViewController ()
@property (nonatomic, strong) EBBannerAd *banner;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    EBBannerAd *banner =
        [[EBBannerAd alloc] initWithAdUnitId:@"YOUR_BANNER_UNIT_ID"
                                        size:CGSizeMake(320, 50)];

    banner.onLoad        = ^{ NSLog(@"배너 로드 완료"); };
    banner.onFailureBlock = ^(NSError *error) {
        NSLog(@"배너 실패: %@", error.localizedDescription);
    };
    banner.onClick       = ^{ NSLog(@"배너 클릭"); };

    [self.view addSubview:banner];
    banner.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [banner.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [banner.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        [banner.widthAnchor constraintEqualToConstant:320],
        [banner.heightAnchor constraintEqualToConstant:50]
    ]];

    self.banner = banner;
    [banner load];
}

@end
```

### 주요 API

```objc
// 초기화
EBBannerAd *banner =
    [[EBBannerAd alloc] initWithAdUnitId:adUnitId size:CGSizeMake(w, h)];

// 옵션
banner.autoRefresh = YES;                       // 기본 YES
banner.fullWebView = NO;                         // 기본 NO. YES면 광고를 광고 영역 전체에 채움
banner.options = [[EBAdOptions alloc] init];    // 키워드/위치 등

// 동작
[banner load];                                  // 광고 요청
[banner stop];                                  // 요청/자동 갱신 취소

// 콜백 (모두 선택)
banner.onLoad         = ^{ ... };
banner.onFailureBlock = ^(NSError *error) { ... };   // ObjC 전용
banner.onClick        = ^{ ... };
banner.onLeaveApp     = ^{ ... };                    // 외부 앱/Safari 이동 직전
banner.onClickFinish  = ^{ ... };                    // 인앱 스토어/사파리 닫힘
```

> Swift의 `onFail: ((EBAdError) -> Void)?`는 ObjC에서 사용할 수
> 없습니다. 대신 `onFailureBlock`이 `NSError`로 동일한 정보를
> 전달합니다.

---

## 전면 광고

전체화면 HTML 광고. 비디오와 동일하게 `load` → `presentFrom:`
2단계 사용 방식이고, 한 번 노출하면 단발성으로 종료됩니다.

```objc
@interface InterstitialExampleViewController ()
@property (nonatomic, strong) EBInterstitialAd *interstitial;
@end

@implementation InterstitialExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.interstitial =
        [[EBInterstitialAd alloc] initWithAdUnitId:@"YOUR_INTERSTITIAL_UNIT_ID"];

    __weak typeof(self) weakSelf = self;
    self.interstitial.onLoad = ^{
        [weakSelf.interstitial presentFrom:weakSelf];
    };
    self.interstitial.onFailureBlock = ^(NSError *error) {
        NSLog(@"전면 실패: %@", error.localizedDescription);
    };
    self.interstitial.onDidDisappear = ^{ NSLog(@"전면 닫힘"); };

    [self.interstitial load];
}

@end
```

콜백/메서드는 `EBVideoAd`와 동일합니다 (`onProgress` 없음).

> `interstitial.fullWebView`(`BOOL`, 기본 `NO`)로 크리에이티브 표시
> 방식을 정할 수 있습니다. 기본은 크리에이티브 크기로 화면 중앙
> 배치(화면을 넘지 않도록 클램프), `YES`면 화면 전체를 채웁니다.

---

## 네이티브 광고

네이티브 광고는 호스트 앱이 직접 디자인한 뷰에 텍스트/이미지 에셋을
바인딩합니다. 두 단계로 진행됩니다.

### 1. 렌더링 뷰 작성

`EBNativeAdRendering` 프로토콜을 채택한 `UIView` 서브클래스를
만듭니다. SDK가 해당 메서드들이 반환하는 뷰에 자동으로 에셋을
바인딩합니다.

```objc
// MyNativeAdView.h
#import <UIKit/UIKit.h>
#import <ExelBidSDK/ExelBidSDK-Swift.h>

@interface MyNativeAdView : UIView <EBNativeAdRendering>
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *bodyLabel;
@property (nonatomic, strong) UIButton *ctaButton;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIView *mediaContainer;   // 메인 크리에이티브(이미지/동영상)
@end

// MyNativeAdView.m
@implementation MyNativeAdView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // titleLabel, bodyLabel, ctaButton 등 레이아웃 구성
    }
    return self;
}

// SDK가 자동 호출하는 메서드 — 채울 뷰만 반환
- (UILabel *)nativeTitleTextLabel        { return self.titleLabel; }
- (UILabel *)nativeMainTextLabel         { return self.bodyLabel; }
- (UIButton *)nativeCallToActionButton   { return self.ctaButton; }
- (UIImageView *)nativeIconImageView     { return self.iconImageView; }
// 메인 크리에이티브 슬롯(빈 UIView). SDK가 이 안을 채웁니다 —
// 응답에 동영상(VAST)이 있으면 음소거 인라인 플레이어, 없으면 메인 이미지.
- (UIView *)nativeMediaView              { return self.mediaContainer; }

@end
```

`EBNativeAdRendering`의 메서드는 모두 `@optional`이므로 채우고
싶은 에셋에 해당하는 메서드만 구현하면 됩니다. 단, **메인 이미지/동영상을
표시하려면 `nativeMediaView()`(빈 컨테이너)를 반드시 제공**하세요 —
메인 크리에이티브는 이 단일 슬롯을 통해 그려집니다. 동영상(VAST) 응답이면
SDK가 슬롯 안에서 음소거 자동재생(가시성 게이팅, 음소거 해제 토글)합니다.

### 2. 로드 및 연결

```objc
#import <ExelBidSDK/ExelBidSDK-Swift.h>
#import "MyNativeAdView.h"

@interface NativeViewController ()
@property (nonatomic, strong) EBNativeAdLoader *loader;
@property (nonatomic, strong) EBNativeAd *nativeAd;
@property (nonatomic, strong) MyNativeAdView *adView;
@end

@implementation NativeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.adView = [[MyNativeAdView alloc] init];
    [self.view addSubview:self.adView];
    // adView 레이아웃 구성

    EBNativeAdLoader *loader =
        [[EBNativeAdLoader alloc] initWithAdUnitId:@"YOUR_NATIVE_UNIT_ID"];
    loader.desiredAssetsArray = @[
        @(EBNativeAssetTitle),
        @(EBNativeAssetMain),
        @(EBNativeAssetIcon),
        @(EBNativeAssetCtatext)
    ];

    __weak typeof(self) weakSelf = self;
    [loader loadWithCompletion:^(EBNativeAd * _Nullable ad, NSError * _Nullable error) {
        if (!ad) {
            NSLog(@"네이티브 실패: %@", error.localizedDescription);
            return;
        }
        ad.onImpression = ^{ NSLog(@"노출 발생"); };
        ad.onClick      = ^{ NSLog(@"클릭"); };
        [ad attachTo:weakSelf.adView];
        weakSelf.nativeAd = ad;
    }];
    self.loader = loader;
}

@end
```

> Swift의 `desiredAssets: Set<EBNativeAsset>`는 ObjC에서 사용할 수
> 없습니다. 대신 `desiredAssetsArray: NSArray<NSNumber *>`로 enum
> rawValue를 NSNumber로 감싸 전달합니다.

### 사용 가능한 에셋

```objc
EBNativeAssetTitle        // 광고 제목
EBNativeAssetDesc         // 본문 설명
EBNativeAssetDesc2        // 부가 설명
EBNativeAssetCtatext      // CTA 버튼 문구
EBNativeAssetSponsored    // 광고주 표기
EBNativeAssetDisplayUrl
EBNativeAssetIcon         // 아이콘 이미지
EBNativeAssetMain         // 메인 이미지
EBNativeAssetLogo
EBNativeAssetRating
EBNativeAssetPrice
EBNativeAssetSalePrice
EBNativeAssetDownloads
EBNativeAssetLikes
EBNativeAssetVideo        // 네이티브 비디오 (VAST)
```

---

## 비디오 광고

전체화면 VAST 비디오 광고입니다. `load` 후 `presentFrom:`으로
재생합니다.

```objc
#import <ExelBidSDK/ExelBidSDK-Swift.h>

@interface VideoExampleViewController ()
@property (nonatomic, strong) EBVideoAd *videoAd;
@end

@implementation VideoExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.videoAd = [[EBVideoAd alloc] initWithAdUnitId:@"YOUR_VIDEO_UNIT_ID"];

    __weak typeof(self) weakSelf = self;
    self.videoAd.onLoad = ^{
        [weakSelf.videoAd presentFrom:weakSelf];
    };
    self.videoAd.onFailureBlock = ^(NSError *error) {
        NSLog(@"비디오 실패: %@", error.localizedDescription);
    };
    self.videoAd.onProgress = ^(NSInteger percent) {
        NSLog(@"재생 진행률: %ld%%", (long)percent);   // 0, 25, 50, 75, 100
    };
    self.videoAd.onClick         = ^{ NSLog(@"비디오 클릭"); };
    self.videoAd.onDidDisappear  = ^{ NSLog(@"비디오 종료"); };

    [self.videoAd load];
}

@end
```

### 스킵 동작

두 옵션이 함께 동작합니다.

- **`videoSkipMin`** — *스킵 가능한 광고인지* 판별하는 **길이 기준**.
  광고 길이가 이 값보다 길어야 스킵이 허용되고, 짧으면 끝까지 재생해야
  합니다.
- **`videoSkipAfter`** — 스킵 가능한 광고에서 *✕ 버튼이 뜨기까지의
  의무 시청 시간*.

기본값(15 / 5)에서는 **15초를 초과하는 광고는 5초 후 ✕가 노출**되고,
15초 이하 광고는 끝까지 재생됩니다.

```objc
self.videoAd.options.videoSkipMin   = 15;  // 이 길이를 "초과"하는 광고만 스킵 허용 (초)
self.videoAd.options.videoSkipAfter = 5;   // 재생 시작 후 ✕ 노출까지 대기 시간 (초)
```

> 값이 누락(`videoSkipMin <= 0`)되었거나 `videoSkipAfter`가
> `videoSkipMin`보다 큰 모순된 조합이면, 의무 시청 시간이 스킵 기준을
> 넘지 않도록 `videoSkipMin`을 `videoSkipAfter`와 같게 자동 보정합니다.

### 주요 API

```objc
[videoAd load];                              // 광고 요청
[videoAd presentFrom:viewController];        // 재생 시작 (전체화면)
BOOL ready = videoAd.isReady;                // 로드 완료 여부

videoAd.onLoad / onFailureBlock / onClick / onLeaveApp
videoAd.onWillAppear / onDidAppear / onWillDisappear / onDidDisappear
videoAd.onProgress = ^(NSInteger percent) { ... };  // 0/25/50/75/100
```

> `presentFrom:` 호출 후 영상이 종료되거나 사용자가 닫으면
> `isReady`가 `NO`로 돌아갑니다. 다음 광고는 다시 `load`부터.

---

## 공통 옵션

모든 광고 객체에는 `options` 프로퍼티가 있습니다. `load` 호출 전에
설정합니다.

```objc
banner.options.keywords = @{@"channel": @"home", @"section": @"feed"};
banner.options.yearOfBirth = 1990;                            // 4자리 출생연도
banner.options.gender = GenderMale;                           // Unspecified/Male/Female
banner.options.location = [[CLLocation alloc] initWithLatitude:37.5665
                                                     longitude:126.9780];
banner.options.coppa = NO;
banner.options.testing = NO;                                  // 테스트 모드 (개발/QA용, 기본 NO)
```

| 옵션 | 타입 | 설명 |
|---|---|---|
| `keywords` | `NSDictionary<NSString *, NSString *> *` | 타겟팅용 키-값 메타데이터 |
| `yearOfBirth` | `NSInteger` | 4자리 출생연도 (`0`은 미지정) |
| `gender` | `Gender` | `GenderUnspecified` / `GenderMale` / `GenderFemale` |
| `location` | `CLLocation *` | 호스트 앱이 보유한 사용자 위치 |
| `coppa` | `BOOL` | COPPA 적용 여부 |
| `testing` | `BOOL` | 테스트 모드 (기본 `NO`) |

> SDK는 위치를 직접 수집하지 않으므로, 위치 타겟팅이 필요하면
> 호스트 앱이 권한을 받아 직접 `CLLocation`을 전달해야 합니다.

> **테스트 모드**: `options.testing` 은 개발·QA 단계에서만 켜고,
> 배포(릴리스) 빌드에서는 반드시 `NO`(기본값)로 두세요. 테스트
> 모드로 발생한 노출/클릭은 정상 집계 대상이 아닙니다.

---

## 미디에이션

미디에이션을 사용하면 서버가 정한 순서대로 여러 광고망(ExelBid /
AdMob / Facebook(FAN) / AdFit 등)을 순차 호출(waterfall)해 가장 먼저
응답하는 네트워크의 광고를 노출합니다. 광고 포맷별로 일반 광고
클래스와 시그니처가 동일한 `EBMediated*` 클래스를 제공합니다.

### 어댑터 모듈 설치

외부 네트워크 어댑터는 별도 저장소
[`ExelBid_iOS_Mediation_Adapter`](https://github.com/onnuridmc/ExelBid_iOS_Mediation_Adapter)
에서 제공합니다. 현재 **3개 광고망** 의 어댑터를 기본 지원합니다:

| 광고망 | Swift 모듈 | 포맷 | 배포 |
|---|---|---|---|
| Google AdMob | `ExelBidMediationAdMob` | 배너 / 전면 / 네이티브 / 전면 비디오 | SwiftPM · CocoaPods |
| Facebook Audience Network (FAN) | `ExelBidMediationFAN` | 배너 / 전면 / 네이티브 / 전면 비디오 | CocoaPods (호스트가 `FBAudienceNetwork` 링크) |
| Kakao AdFit | `ExelBidMediationAdFit` | 배너 / 네이티브 | SwiftPM 전용 |

> 그 외 네트워크 (Pangle / AppLovin / Digital Turbine / TNK /
> TargetPick) 는 **추후 지원 예정**이며 필요 시 운영팀에 요청해 우선순위
> 조정이 가능합니다. 배포 전까지는 워터폴에 포함돼 있어도 미등록
> 어댑터로 처리되어 (`EBWaterfallEvent.lost(.adapterNotRegistered)`)
> 다음 순번으로 건너뛰어집니다.

해당 네트워크의 SDK 자체(AdMob SDK / FAN SDK 등)는 호스트 앱이 별도로
통합해야 합니다. ObjC 호스트는 대부분 CocoaPods 환경이므로 다음
Podfile 패턴을 사용합니다:

```ruby
# Podfile
pod 'ExelBid_iOS_Swift',           '~> 3.0'
pod 'ExelBid_Mediation_Adapter/AdMob'
pod 'ExelBid_Mediation_Adapter/FAN'
```

CocoaPods 어댑터는 어떤 subspec 을 설치하든 모두
`ExelBidMediationAdapter` 라는 **단일 Swift 모듈**로 합쳐집니다 — 아래
Swift 부트스트랩에서 이 모듈 하나만 import 합니다.

> **AdFit 은 SwiftPM 전용**입니다 (Kakao 가 AdFit SDK 의 CocoaPods 배포를
> 중단). CocoaPods 환경에서 AdFit 이 필요하면 어댑터 저장소 README 의
> 수동 통합 절차를 참고하세요.

> **직접 만들기 — 가장 빠른 경로일 때가 많습니다.** 추후 지원 예정
> 네트워크 (Pangle / AppLovin 등) 를 지금 당장 붙여야 하거나, 사내 광고
> 서버 / 비공개 네트워크 / 미지원 포맷(AdFit 비디오 등)이 필요하면 제공
> 어댑터를 템플릿 삼아 직접 작성할 수 있습니다. 공개 프로토콜 4개
> (`EBBannerMediationAdapter` 등) 중 필요한 것만 구현하면 되며 단계별
> 작성 방법은 [`MEDIATION_ADAPTER_GUIDE.md`](./MEDIATION_ADAPTER_GUIDE.md)
> 에서 설명합니다.

### 모듈 등록 (Swift 파일 1개 필요)

`ExelBidMediationKit.register(modules:)`는 Swift 프로토콜 메타타입
배열을 받기 때문에 Objective-C에서 직접 호출할 수 없습니다. 다음과
같이 ObjC 호스트 앱에 작은 Swift 파일을 하나 추가해 등록 로직만
Swift로 작성하세요.

`ExelBidMediationBootstrap.swift`:

```swift
import Foundation
import ExelBidSDK
import ExelBidMediationAdapter   // CocoaPods: subspec 무관 단일 모듈
// SwiftPM 으로 설치한 경우엔 어댑터별로 import:
//   import ExelBidMediationAdMob
//   import ExelBidMediationFAN

@objc public final class ExelBidMediationBootstrap: NSObject {
    @objc public static func registerModules() {
        ExelBidMediationKit.shared.register(modules: [
            ExelBidBuiltInMediationModule.self,   // ExelBid 자체 어댑터 (필수)
            AdMobMediationModule.self,
            FANMediationModule.self,
        ])
    }
}
```

ObjC `AppDelegate`에서 호출:

```objc
#import "YourApp-Swift.h"   // Xcode 자동 생성 헤더

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [ExelBidMediationBootstrap registerModules];
    return YES;
}
```

> `ExelBidBuiltInMediationModule`을 포함하지 않으면 서버 워터폴
> 응답의 "exelbid" 항목이 건너뛰어집니다. 일반적으로 항상 함께
> 등록하세요. 직접 만든 어댑터도 동일한 부트스트랩에 추가하면 되며,
> 같은 `networkID` 로 재등록하면 제공 어댑터를 자신의 구현으로 교체할
> 수 있습니다.

> **옵션 적용:** 네 가지 미디에이션 광고 객체(`EBMediatedBannerAd` /
> `EBMediatedInterstitialAd` / `EBMediatedNativeAdLoader` /
> `EBMediatedVideoAd`)도 일반 광고처럼 `.options`(키워드 / 위치 /
> COPPA / 비디오 스킵 정책 등)를 설정할 수 있습니다. 이 옵션은
> ExelBid 자체 광고가 낙찰됐을 때 적용되며, 다른 네트워크는 각자의
> 요청 설정을 사용합니다.

### 배너

```objc
EBMediatedBannerAd *banner =
    [[EBMediatedBannerAd alloc] initWithAdUnitId:@"YOUR_MEDIATION_UNIT_ID"
                                            size:CGSizeMake(320, 50)];
banner.perNetworkTimeout = 5.0;   // 기본 5초

__weak typeof(banner) weakBanner = banner;
banner.onLoad = ^{
    NSLog(@"낙찰 네트워크: %@", weakBanner.winningNetwork ?: @"?");
};
banner.onFailureBlock = ^(NSError *error) {
    NSLog(@"전 네트워크 실패: %@", error.localizedDescription);
};
banner.onClick = ^{ NSLog(@"배너 클릭"); };

[self.view addSubview:banner];
[banner load];
```

`EBBannerAd`와 시그니처가 거의 동일합니다. 차이점:

- `perNetworkTimeout` — 네트워크별 로드 타임아웃 (기본 5초)
- `winningNetwork` — 로드 성공 후 낙찰된 네트워크 ID
- 서버가 제공하는 `autoRefresh`는 지원하지 않습니다.

> 워터폴 단계별 이벤트(`onWaterfallEvent` / `EBWaterfallEvent`)는
> Swift `enum`이라 Objective-C에서는 사용할 수 없습니다. 이는 배너뿐
> 아니라 전면 / 네이티브 / 비디오 미디에이션 전 포맷에 공통입니다
> (Swift에서는 네 포맷 모두 `onWaterfallEvent`를 제공합니다). 필요하다면
> 위 모듈 등록과 동일하게 Swift 래퍼를 추가하세요.

### 전면

```objc
EBMediatedInterstitialAd *interstitial =
    [[EBMediatedInterstitialAd alloc] initWithAdUnitId:@"YOUR_UNIT_ID"];

__weak typeof(self) weakSelf = self;
interstitial.rootViewControllerProvider = ^UIViewController * _Nullable {
    return weakSelf;
};
interstitial.onLoad = ^{ NSLog(@"낙찰: %@", interstitial.winningNetwork ?: @"?"); };
interstitial.onFailureBlock = ^(NSError *error) { NSLog(@"%@", error); };
interstitial.onDidDisappear = ^{ NSLog(@"닫힘"); };

[interstitial load];
// 사용자가 광고를 보길 원하는 시점:
[interstitial presentFrom:self];
```

`EBInterstitialAd`와 시그니처가 동일하며, 단발성 사용입니다
(`presentFrom:` 이후 `isReady`가 `NO`로 돌아갑니다).

> `rootViewControllerProvider`는 권장 설정입니다. FAN 등 일부 네트워크는
> **로드 시점**에 `rootViewController`가 필요합니다.

### 네이티브

```objc
EBMediatedNativeAdLoader *loader =
    [[EBMediatedNativeAdLoader alloc] initWithAdUnitId:@"YOUR_UNIT_ID"];

__weak typeof(self) weakSelf = self;
loader.rootViewControllerProvider = ^UIViewController * _Nullable {
    return weakSelf;
};

[loader loadWithCompletion:^(EBMediatedNativeAd * _Nullable ad, NSError * _Nullable error) {
    if (!ad) {
        NSLog(@"네이티브 실패: %@", error.localizedDescription);
        return;
    }
    NSLog(@"낙찰: %@", ad.winningNetwork);
    ad.onClick = ^{ NSLog(@"네이티브 클릭"); };
    MyNativeAdView *adView = [[MyNativeAdView alloc] init];
    [ad attachTo:adView];
    [weakSelf.container addSubview:adView];
}];
```

`EBNativeAdLoader`와 사용 흐름이 동일하며, 결과 타입만
`EBMediatedNativeAd`로 바뀝니다. **렌더링 뷰는 동일한
`EBNativeAdRendering` 프로토콜을 사용**하므로 일반 광고와 같은 뷰를
재사용할 수 있습니다.

> **미디어 슬롯 (`nativeMediaView`) 과 AdChoices**: 메인 크리에이티브는
> 일반 네이티브와 동일하게 `nativeMediaView` 단일 슬롯으로 그려집니다.
> 미디에이션에서는 어댑터가 이 슬롯에 네트워크 미디어 뷰(AdMob
> `GADMediaView` / FAN `FBMediaView` — 동영상엔 필수)나 URL 전용
> 네트워크(AdFit)의 이미지 뷰를 꽂습니다. 미디어/동영상을 보이려면 이
> 슬롯을 반드시 제공하세요:
>
> ```objc
> - (UIView *)nativeMediaView      { return self.mediaContainer; }
> - (UIView *)nativeAdChoicesView  { return self.adChoicesContainer; } // FAN AdChoices
> ```
>
> 두 메서드 모두 `@optional`이라 텍스트/아이콘만 쓰는 레이아웃에는
> 영향이 없습니다. 다만 슬롯이 없으면 메인 미디어는 표시되지 않습니다.

> Swift의 `desiredAssets`는 ObjC에서 사용할 수 없습니다. 자산 목록을
> 지정하지 않으면 광고 유닛에 설정된 자산이 그대로 내려옵니다.
> 명시적으로 지정해야 한다면 Swift 헬퍼 클래스를 통해 설정하세요.

### 비디오

```objc
EBMediatedVideoAd *videoAd =
    [[EBMediatedVideoAd alloc] initWithAdUnitId:@"YOUR_UNIT_ID"];

__weak typeof(self) weakSelf = self;
videoAd.rootViewControllerProvider = ^UIViewController * _Nullable {
    return weakSelf;
};

videoAd.onLoad = ^{
    NSLog(@"낙찰: %@", videoAd.winningNetwork ?: @"?");
};
videoAd.onFailureBlock = ^(NSError *error) { NSLog(@"%@", error); };
videoAd.onProgress = ^(NSInteger percent) {
    NSLog(@"진행률: %ld%%", (long)percent);
};
videoAd.onDidDisappear = ^{ NSLog(@"종료"); };

[videoAd load];
```

`EBVideoAd`와 시그니처가 동일하며, 단발성 사용입니다.

`EBVideoAd`처럼 `videoAd.options`로 스킵 정책 등을 설정할 수 있습니다.

```objc
videoAd.options.videoSkipMin   = 15;
videoAd.options.videoSkipAfter = 5;
```

스킵 정책(`videoSkipMin` / `videoSkipAfter`)은 ExelBid 자체 비디오가
낙찰됐을 때 적용됩니다. 다른 네트워크(AdMob / FAN)는 자체 재생 UI를
사용하므로 스킵 정책이 적용되지 않습니다.

> ExelBid 외 네트워크(AdMob / FAN)에서 video 포맷은 **전면(인터스티셜)
> 비디오**로 노출됩니다(보상형 아님). `onProgress`는 시작(`0`)·종료(`100`)
> 두 시점만 근사 보고됩니다.

---

## 에러 처리

모든 광고 객체는 실패 시 `onFailureBlock`에 `NSError`를 전달합니다.

- `domain`: `"com.motivi.exelbid.error"` (아래 상수 참고)
- `code`: `AdErrorCode` enum 값
- `localizedDescription`: 사람이 읽을 수 있는 메시지

```objc
// ExelBid 광고 에러 도메인 (호스트 앱 코드 어딘가에 한 번 선언)
static NSString * const ExelBidSDKErrorDomain = @"com.motivi.exelbid.error";

banner.onFailureBlock = ^(NSError *error) {
    if (![error.domain isEqualToString:ExelBidSDKErrorDomain]) {
        return;
    }
    switch ((AdErrorCode)error.code) {
        case AdErrorCodeNoFill:
            // 광고 없음 — 빈 영역 처리 (정상 케이스 포함)
            break;
        case AdErrorCodeNetwork:
        case AdErrorCodeHttpStatus:
            // 네트워크 일시 오류 — 잠시 후 재시도
            break;
        case AdErrorCodeInvalidAdUnitId:
            // 단위 ID 오류 — 운영팀 문의
            break;
        default:
            NSLog(@"광고 오류: %@", error.localizedDescription);
            break;
    }
};
```

### 에러 코드

| 코드 | 의미 |
|---|---|
| `AdErrorCodeInvalidAdUnitId` | 광고 단위 ID가 비었거나 공백 |
| `AdErrorCodeNoFill` | 서버가 광고를 내려주지 않음 (정상 케이스 포함) |
| `AdErrorCodeNetwork` | 네트워크 전송 오류 |
| `AdErrorCodeHttpStatus` | HTTP 4xx/5xx 응답 (userInfo에 `HTTPStatusCode`) |
| `AdErrorCodeDecoding` | 응답 디코딩 실패 |
| `AdErrorCodeVastParsing` | VAST XML 파싱 실패 |
| `AdErrorCodeMediaFileUnavailable` | 적합한 비디오 미디어 파일 없음 |
| `AdErrorCodePlayback` | 영상 재생 오류 |
| `AdErrorCodeNotReady` | 로드 완료 전 `presentFrom:` 호출 |
| `AdErrorCodeCanceled` | 요청 취소됨 |

---

연동 중 문제가 발생하면 광고 단위 ID, 디바이스 OS 버전, SDK 버전과
함께 운영팀에 문의해 주세요.
