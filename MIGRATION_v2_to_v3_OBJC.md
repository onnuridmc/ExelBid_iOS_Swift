# 마이그레이션 가이드: v2 → v3 (Objective-C)

ExelBid iOS SDK v3는 클린룸(clean-room) 재작성 버전입니다. 광고 서버와
주고받는 **통신 프로토콜은 그대로**라서 기존 광고 단위 ID(adUnitId)는
변경 없이 계속 동작합니다. 다만 **모든 공개 클래스 이름 · 콜백 형태 ·
생명주기**가 새롭게 바뀌었습니다.

이 문서는 **Objective-C** 호스트를 위한 v2 ↔ v3 대응 가이드입니다.
Swift 버전은 [`MIGRATION_v2_to_v3.md`](./MIGRATION_v2_to_v3.md) 를,
v3의 전체 ObjC 연동 방법은
[`INTEGRATION_OBJC.md`](./INTEGRATION_OBJC.md) 를 참고하세요.

핵심 ObjC 변화 한 줄 요약:

- **델리게이트 → 블록 콜백.** v2의 `@protocol` 델리게이트 체인이
  `onLoad` / `onFailureBlock` / `onClick` 등 블록 프로퍼티로 바뀌었습니다.
- **에러는 `onFailureBlock:^(NSError *error)`.** Swift의 타입 에러
  `EBAdError` 는 ObjC에서 `NSError`(`AdErrorCode*`)로 전달됩니다.

```objc
#import <ExelBidSDK/ExelBidSDK-Swift.h>
```

---

## 1. 최소 요구사항

| 항목 | v2 | v3 |
|---|---|---|
| iOS 배포 타깃 | 13.0+ | 13.0+ (동일) |
| Xcode | – | 15 이상 |
| 배포 방식 | xcodeproj → XCFramework | SwiftPM (Xcode 프로젝트는 선택) |
| 서버 통신 규약 | 동일 | 동일 (변경 없음) |
| 프라이버시 매니페스트 | `PrivacyInfo.xcprivacy` 번들 | 동일 |

- import 헤더가 `<ExelBidSDK/ExelBidSDK-Swift.h>` 로 바뀝니다.
- 모든 공개 타입은 `EB` 접두사를 사용합니다(`EBBannerAd`,
  `EBNativeAdLoader`, `EBVideoAd`, `EBInterstitialAd` 등).

---

## 2. 전역 설정 (Global configuration)

### v2

```objc
[ExelBid sharedInstance].testing = YES;        // 테스트 설정
[ExelBid sharedInstance].appId   = @"...";      // 앱 ID
```

### v3

```objc
// 싱글톤 진입점: [ExelBid shared]
// 광고별 설정은 전역이 아니라 각 광고의 options(EBAdOptions)로 지정합니다.
```

### 핵심 변화

- 싱글톤 진입점이 `[ExelBid sharedInstance]` → `[ExelBid shared]` 로
  바뀌었습니다.
- 전역 `testing` 설정은 사라지고, **광고별 `options.testing`** 으로
  이동했습니다(아래 "테스트 모드" 참고).
- `frequencyCappingIdUsageEnabled` 토글은 **제거**되었습니다. v3는
  IDFA를 쓸 수 없을 때 24시간 주기로 회전하는 UUID 폴백을 항상
  사용합니다.
- COPPA / 위치 / 키워드 등 광고별 설정은 **광고 객체마다
  `EBAdOptions`** 로 지정합니다.

### 테스트 모드 (`options.testing`)

v2에서 전역/광고별로 켜던 테스트 모드는 v3에서 **광고 객체마다
`options.testing`(`BOOL`)** 으로 일원화되었습니다. 기본값은 `NO`.

```objc
EBBannerAd *banner =
    [[EBBannerAd alloc] initWithAdUnitId:@"u" size:CGSizeMake(320, 50)];
banner.options.testing = NO;     // 개발/QA 중에만 YES. 기본값 NO
[banner load];
```

- 모든 포맷의 `options.testing` 으로 동일하게 동작합니다.
- **배포(릴리스) 빌드에서는 반드시 `NO`(기본값)로 두세요.** 테스트
  모드로 발생한 노출/클릭은 정상 집계 대상이 아닙니다.

---

## 3. 배너 (Banner)

### v2

```objc
@interface MyVC () <EBAdViewDelegate>
@property (nonatomic, strong) EBAdView *banner;
@end

@implementation MyVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.banner = [[EBAdView alloc] initWithAdUnitId:@"u"
                                                size:CGSizeMake(320, 50)];
    self.banner.delegate = self;
    self.banner.keywords = @"k1,k2";    // NSString (CSV)
    [self.view addSubview:self.banner];
    [self.banner loadAd];
}

- (void)adViewDidLoadAd:(EBAdView *)view { }
- (void)adViewDidFailToLoadAd:(EBAdView *)view { }
- (void)willLoadViewForAd:(EBAdView *)view { }            // 클릭 직후
- (void)didLoadViewForAd:(EBAdView *)view { }             // 클릭 처리 완료
- (void)willLeaveApplicationFromAd:(EBAdView *)view { }   // 앱 이탈
@end
```

### v3

```objc
EBBannerAd *banner =
    [[EBBannerAd alloc] initWithAdUnitId:@"u" size:CGSizeMake(320, 50)];
banner.options.keywords = @{@"k": @"v"};   // NSDictionary (CSV 자유문자열 아님)
banner.options.coppa    = NO;              // 광고별 COPPA
banner.autoRefresh      = YES;             // 기본 YES

banner.onLoad         = ^{ /* adViewDidLoadAd */ };
banner.onFailureBlock = ^(NSError *error) { /* adViewDidFailToLoadAd */ };
banner.onClick        = ^{ /* willLoadViewForAd */ };
banner.onClickFinish  = ^{ /* didLoadViewForAd */ };
banner.onLeaveApp     = ^{ /* willLeaveApplicationFromAd */ };

[self.view addSubview:banner];
[banner load];
// 중지:
[banner stop];
```

### 핵심 변화

- `delegate` → 블록 콜백. `EBAdViewDelegate` 채택을 제거하세요.
- `keywords`(`NSString` CSV) → `options.keywords`(`NSDictionary`).
- `yob` / `gender` / `coppa` → `options.yearOfBirth` / `.gender` / `.coppa`.
- `loadAd` / `stopAd` → `load` / `stop`.
- 자동 새로고침: `startAutomaticallyRefreshingContents` /
  `stopAutomaticallyRefreshingContents` → `banner.autoRefresh`(`BOOL`).
- 실패는 정보 없는 델리게이트 대신 `onFailureBlock`(`NSError`)으로 전달.
- `fullWebView` 플래그는 v3에도 있습니다 — `banner.fullWebView`(`BOOL`).
  기본 `NO`(크리에이티브 크기로 센터), `YES`면 광고 영역을 꽉 채움.
  v3는 크리에이티브 크기가 광고 영역을 넘지 않도록 클램프합니다.

---

## 4. 네이티브 (Native)

### v2

```objc
ExelBidNativeManager *manager =
    [[ExelBidNativeManager alloc] init:@"u" :[MyNativeAdView class]];
[manager keywords:@"k1,k2"];
[manager desiredAssets:[NSSet setWithArray:@[@"title", @"icon", @"main"]]];
[manager startWithCompletionHandler:^(EBNativeAdRequest *req,
                                      EBNativeAd *nativeAd,
                                      NSError *error) {
    if (!nativeAd) return;
    UIView *adView = [nativeAd retrieveAdViewWithError:nil];
    [self.container addSubview:adView];
}];
```

`MyNativeAdView` 는 `EBNativeAdRendering` 을 채택했습니다.

### v3

```objc
EBNativeAdLoader *loader =
    [[EBNativeAdLoader alloc] initWithAdUnitId:@"u"];
loader.desiredAssetsArray = @[          // NSArray<NSNumber *> (enum rawValue)
    @(EBNativeAssetTitle),
    @(EBNativeAssetIcon),
    @(EBNativeAssetMain)
];

MyNativeAdView *adView = [[MyNativeAdView alloc] init];
[self.container addSubview:adView];

__weak typeof(self) weakSelf = self;
[loader loadWithCompletion:^(EBNativeAd * _Nullable ad,
                             NSError * _Nullable error) {
    if (!ad) { NSLog(@"네이티브 실패: %@", error.localizedDescription); return; }
    ad.onImpression = ^{ /* 노출 */ };
    ad.onClick      = ^{ /* 클릭 */ };
    [ad attachTo:adView];               // 렌더링 + 트래킹 시작
    weakSelf.nativeAd = ad;             // 강한 참조 보관
}];
```

### 핵심 변화

- `ExelBidNativeManager` → `EBNativeAdLoader`.
- `startWithCompletionHandler:` → `loadWithCompletion:`.
- 자산 선택: 문자열 `NSSet` → `desiredAssetsArray`
  (`NSArray<NSNumber *>`, enum rawValue를 `@()` 로 감싼 값).
- 뷰 소유권: v2는 렌더링 뷰 클래스를 매니저에 주입했지만, v3는
  **호스트가 직접 렌더링 뷰를 생성**해 `attachTo:` 에 전달합니다.
  `retrieveAdViewWithError:` 는 사라졌습니다.
- 노출 콜백이 셋으로 분리됩니다: `onImpression` / `onImpression50` /
  `onImpression100`.

---

## 5. 비디오 / VAST (Video)

### v2

```objc
@interface MyVC () <EBVideoDelegate>
@property (nonatomic, strong) EBVideoManager *manager;
@end

@implementation MyVC
- (void)loadVideo {
    self.manager = [[EBVideoManager alloc] initWithIdentifier:@"u"];
    [self.manager keywords:@"k1,k2"];
    [self.manager startWithCompletionHandler:^(EBVideoAdRequest *req,
                                               NSError *error) {
        if (!error) [self.manager presentAdWithController:self delegate:self];
    }];
}

- (void)videoAdDidLoadWithAdUnitID:(NSString *)adUnitID { }
- (void)videoAdDidFailToLoadWithAdUnitID:(NSString *)adUnitID error:(NSError *)error { }
- (void)videoAdWillAppearWithAdUnitID:(NSString *)adUnitID { }
- (void)videoAdDidAppearWithAdUnitID:(NSString *)adUnitID { }
- (void)videoAdDidReceiveTapEventWithAdUnitID:(NSString *)adUnitID { }
@end
```

### v3

```objc
EBVideoAd *video = [[EBVideoAd alloc] initWithAdUnitId:@"u"];
video.options.keywords = @{@"k": @"v"};

video.onLoad          = ^{ /* videoAdDidLoad */ };
video.onFailureBlock  = ^(NSError *error) { /* videoAdDidFailToLoad */ };
video.onWillAppear    = ^{ /* videoAdWillAppear */ };
video.onDidAppear     = ^{ /* videoAdDidAppear */ };
video.onWillDisappear = ^{ /* videoAdWillDisappear */ };
video.onDidDisappear  = ^{ /* videoAdDidDisappear */ };
video.onClick         = ^{ /* videoAdDidReceiveTapEvent */ };
video.onProgress      = ^(NSInteger percent) { /* 0/25/50/75/100 */ };

[video load];
// 로드 완료 후 (video.isReady == YES):
[video presentFrom:self];
```

### 핵심 변화

- `EBVideoManager` → `EBVideoAd`.
- `EBVideoDelegate` → 블록. 델리게이트의 `adUnitID:` 인자는 사라지고,
  광고 객체 단위로 콜백을 설정합니다.
- `startWithCompletionHandler:` 후 `presentAdWithController:delegate:`
  → `load` 후 `presentFrom:` 2단계 호출.
- 재생 자연 종료 시 컴패니언(엔드카드)을 표시하며, 스킵 경로에서는
  표시하지 않습니다.

---

## 6. 전면 광고 (Interstitial)

### v2

```objc
@interface MyVC () <EBInterstitialAdControllerDelegate>
@property (nonatomic, strong) EBInterstitialAdController *interstitial;
@end

@implementation MyVC
- (void)loadInterstitial {
    self.interstitial =
        [[EBInterstitialAdController alloc] initWithAdUnitId:@"u"];
    self.interstitial.delegate = self;
    self.interstitial.keywords = @"k1,k2";
    [self.interstitial loadAd];
}

- (void)interstitialDidLoadAd:(EBInterstitialAdController *)ad {
    if (ad.ready) [ad showFromViewController:self];
}
- (void)interstitialDidFailToLoadAd:(EBInterstitialAdController *)ad { }
- (void)interstitialDidFailToShow:(EBInterstitialAdController *)ad { }
// willAppear / didAppear / willDisappear / didDisappear / didReceiveTapEvent …
@end
```

### v3

```objc
EBInterstitialAd *ad = [[EBInterstitialAd alloc] initWithAdUnitId:@"u"];
ad.options.keywords = @{@"k": @"v"};

__weak typeof(self) weakSelf = self;
ad.onLoad          = ^{ [weakSelf.interstitial presentFrom:weakSelf]; };
ad.onFailureBlock  = ^(NSError *error) { /* DidFailToLoad / DidFailToShow 통합 */ };
ad.onWillAppear    = ^{ /* interstitialWillAppear */ };
ad.onDidAppear     = ^{ /* interstitialDidAppear */ };
ad.onWillDisappear = ^{ /* interstitialWillDisappear */ };
ad.onDidDisappear  = ^{ /* interstitialDidDisappear */ };
ad.onClick         = ^{ /* interstitialDidReceiveTapEvent */ };
ad.onClickFinish   = ^{ /* 클릭 처리 완료 (인앱 스토어/사파리 닫힘) */ };

self.interstitial = ad;
[ad load];
// ad.isReady == YES 일 때 presentFrom: 호출
```

### 핵심 변화

- v2 `EBInterstitialAdController` 는 호스트가 직접 소유·표시하던
  `UIViewController` 였습니다. v3 `EBInterstitialAd` 는 `NSObject`
  오케스트레이터이고, 전체 화면 표시기는 내부에서 `presentFrom:`
  시점에 생성됩니다.
- `EBInterstitialAdControllerDelegate` → 블록.
- `loadAd` / `showFromViewController:` → `load` / `presentFrom:`.
- v2의 `ready` 프로퍼티 → v3의 `isReady`.
- `interstitialDidFailToShow` 는 `onFailureBlock` 으로 통합됩니다.
  `isReady` 가 `YES` 가 되기 전에 `presentFrom:` 을 호출하면
  `AdErrorCodeNotReady` 가 전달됩니다.
- 닫기 버튼(우측 상단)은 SDK가 직접 그립니다.
- **1회용**: 닫히면 `isReady` 가 다시 `NO` 로 돌아가며, 다음 표시 전에
  새 `load` 가 필요합니다.

---

## 7. MPartners 채널

MPartners는 일반 광고 인벤토리와 분리된 별도 채널을 사용하는 병렬
파사드 묶음입니다.

| v2 | v3 |
|---|---|
| `MPartnersAdView` | `EBMPartnersBannerAd` |
| `MPartnersInterstitialAdController` | `EBMPartnersInterstitialAd` |
| `MPartnersNativeManager` | `EBMPartnersNativeAdLoader` |

v3의 MPartners 파사드는 각각 `EBBannerAd` / `EBInterstitialAd` /
`EBNativeAdLoader` 와 **1:1로 동일한 인터페이스**를 가집니다(자동
새로고침·SKAdNetwork 어트리뷰션은 없음). ObjC 사용법은
[`MPARTNERS_OBJC.md`](./MPARTNERS_OBJC.md) 를 참고하세요.

---

## 8. 미디에이션 (Mediation)

v2의 `EBMediationManager` + 네트워크별 어댑터는 v3에서 `ExelBidSDK`
타깃 내부에 번들됩니다.

| 포맷 | v3 파사드 |
|---|---|
| 배너 | `EBMediatedBannerAd` |
| 전면 | `EBMediatedInterstitialAd` |
| 네이티브 | `EBMediatedNativeAdLoader` |
| 비디오 | `EBMediatedVideoAd` |

**제공 어댑터** — 서드파티 어댑터는 별도 저장소
(`ExelBid_iOS_Mediation_Adapter`)에서 제공됩니다. 사용하는 어댑터만
앱 타겟에 링크하고, 해당 네트워크 SDK는 호스트 앱이 별도로 통합합니다.

| 모듈 | 네트워크 | 포맷 | 최소 iOS | 배포 |
|---|---|---|---|---|
| `ExelBidMediationAdMob` | Google AdMob | 배너 / 전면 / 네이티브 / 전면 비디오 | 14 | SwiftPM · CocoaPods |
| `ExelBidMediationFAN` | Facebook Audience Network | 배너 / 전면 / 네이티브 / 전면 비디오 | 14 | CocoaPods (호스트가 `FBAudienceNetwork` 링크) |
| `ExelBidMediationAdFit` | Kakao AdFit | 배너 / 네이티브 | 13 | SwiftPM 전용 |

> Pangle / AppLovin / DT / TNK / TargetPick은 **예정**이며 현재는 미배포
> 어댑터로 처리되어(`EBWaterfallEvent.lost(.adapterNotRegistered)`)
> 다음 네트워크로 넘어갑니다.

**어댑터 설치 — CocoaPods**

```ruby
# Podfile
pod 'ExelBid_iOS_Swift',           '~> 3.0'
pod 'ExelBid_Mediation_Adapter/AdMob'
pod 'ExelBid_Mediation_Adapter/FAN'
```

> CocoaPods 어댑터는 어떤 subspec을 설치하든 모두
> `ExelBidMediationAdapter` 라는 **하나의 Swift 모듈로** 합쳐집니다(pod
> 배포명은 `ExelBid_Mediation_Adapter`, Swift 모듈명은
> `ExelBidMediationAdapter`).
> **AdFit은 SwiftPM 전용**입니다(Kakao가 AdFit SDK의 CocoaPods 배포를
> 중단). CocoaPods 환경에서 AdFit이 필요하면 어댑터 README의 수동 통합
> 절차를 참고하세요.

**앱 시작 시 모듈 등록 (Swift 부트스트랩 필요)**

`ExelBidMediationKit.register(modules:)` 가 Swift 프로토콜 메타타입
배열을 받기 때문에 **ObjC에서 직접 호출할 수 없습니다**. 작은 Swift
부트스트랩 파일을 추가해 등록 로직만 Swift로 작성하고 ObjC
`AppDelegate` 에서 호출하세요:

```swift
// ExelBidMediationBootstrap.swift  (ObjC 타깃에 추가)
import ExelBidSDK
import ExelBidMediationAdapter  // CocoaPods — 단일 모듈

@objc public final class ExelBidMediationBootstrap: NSObject {
    @objc public static func registerModules() {
        ExelBidMediationKit.shared.register(modules: [
            ExelBidBuiltInMediationModule.self,   // 필수
            AdMobMediationModule.self,
            FANMediationModule.self,
        ])
    }
}
```

```objc
// AppDelegate.m
#import "<ProductModuleName>-Swift.h"
[ExelBidMediationBootstrap registerModules];
```

> `ExelBidBuiltInMediationModule` 을 빠뜨리면 서버 워터폴 응답의
> "exelbid" 항목이 건너뛰어집니다. 전체 패턴은
> [`INTEGRATION_OBJC.md`](./INTEGRATION_OBJC.md) §미디에이션 참고.

**포맷 주의사항**

- **비디오 = 전면 비디오**: ExelBid 외 네트워크의 미디에이션 video는
  보상형이 아니라 **전면(인터스티셜) 비디오**를 의미합니다. AdMob/FAN
  비디오 어댑터는 각각 `InterstitialAd` / `FBInterstitialAd` 를 래핑하며
  분위(quartile) 진행률은 근사 처리합니다(`onProgress(0)` 시작,
  `onProgress(100)` 종료). 보상형이 필요하면 자체 어댑터를 작성해야
  합니다.
- **네이티브 미디어 슬롯**: AdMob / FAN / AdFit 네이티브는 메인 이미지·
  동영상을 각 네트워크의 미디어 뷰로 직접 렌더링합니다(URL로 표현되지
  않음). 호스트의 `EBNativeAdRendering` 뷰에 빈 컨테이너 슬롯을
  노출하세요:

  ```objc
  - (UIView * _Nullable)nativeMediaView { return self.mediaContainer; }
  - (UIView * _Nullable)nativeAdChoicesView { return self.adChoicesContainer; }  // FAN AdChoices (선택)
  ```

  슬롯이 없어도 텍스트 자산은 정상 동작하지만 미디어는 표시되지
  않습니다.
- **AdFit**: 인터스티셜·비디오 API가 없으므로 워터폴의 인터스티셜·비디오
  `"adfit"` 항목은 자동 스킵됩니다.

제공 어댑터가 맞지 않으면 직접 만들 수도 있습니다 —
[`MEDIATION_ADAPTER_GUIDE.md`](./MEDIATION_ADAPTER_GUIDE.md) 참고.

---

## 9. 에러 처리 (Errors)

### v2

실패는 `nil` 광고 객체, `NSError *` 파라미터, 또는 정보 없는
`adViewDidFailToLoadAd:` 호출로 노출되었습니다.

### v3

모든 실패는 `onFailureBlock:^(NSError *error)` 로 전달되며, `error.code`
가 `AdErrorCode*` 값입니다.

```objc
banner.onFailureBlock = ^(NSError *error) {
    switch (error.code) {
        case AdErrorCodeInvalidAdUnitId: break;  // 잘못된/공백 adUnitId
        case AdErrorCodeNoFill:          break;  // 응답 광고 없음(정상 케이스 포함)
        case AdErrorCodeNetwork:         break;  // 네트워크 전송 오류
        case AdErrorCodeHttpStatus:      break;  // HTTP 4xx/5xx (userInfo의 HTTPStatusCode)
        case AdErrorCodeDecoding:        break;  // 응답 디코딩 실패
        case AdErrorCodeVastParsing:     break;  // VAST 파싱 실패
        case AdErrorCodeMediaFileUnavailable: break; // 적합한 미디어 없음
        case AdErrorCodePlayback:        break;  // 재생 오류
        case AdErrorCodeNotReady:        break;  // 준비 전 presentFrom: 호출
        case AdErrorCodeCanceled:        break;  // 취소됨
        default: break;
    }
};
```

---

## 10. 제거/대체된 편의 프로퍼티

| v2 | v3 대체 |
|---|---|
| `[ExelBid sharedInstance]` | `[ExelBid shared]` |
| `testing` (전역 / 광고별) | `options.testing`(`BOOL`, 광고별) |
| `frequencyCappingIdUsageEnabled` | 제거. 24시간 UUID 회전 기본 동작 |
| `EBAdView.fullWebView` | `EBBannerAd.fullWebView` (`BOOL`, 기본 `NO`, 동작 동일). 크리에이티브 크기는 광고 영역으로 클램프 |
| `EBAdView.yob / gender / coppa` | `options.yearOfBirth / .gender / .coppa` |
| `[EBNativeAd retrieveAdViewWithError:]` | `[nativeAd attachTo:]` 단일 진입점 |
| `startAutomaticallyRefreshingContents` 등 | `banner.autoRefresh`(`BOOL`) |
| Placer (TableView/CollectionView/Stream 자동 삽입) | 범위 밖 |
| MoPub 스타일 `MP*` 클래스 / NIB 로더 | 제거 |

---

## 11. 단계별 업그레이드 체크리스트

1. **롤백 경로 확보** — 기존 v2 빌드를 그대로 유지합니다.
2. v3를 병렬 의존성으로 추가합니다(import `<ExelBidSDK/ExelBidSDK-Swift.h>`).
3. 광고 영역을 **하나씩** 마이그레이션합니다(배너 → 네이티브 → 비디오 순 권장).
4. 각 영역 마이그레이션 후, Exelbid가 발급한 **테스트 광고 단위 ID** 로
   동작을 검증합니다.
5. 모든 영역이 v3로 옮겨지면 v2 의존성을 제거합니다.
6. 리포팅 대시보드에서 노출 / 클릭 정상 동작을 재확인합니다.

---

이 가이드에서 다루지 않은 통합 세부 사항은 다음 문서를 참고하세요.

- [`MIGRATION_v2_to_v3.md`](./MIGRATION_v2_to_v3.md) — 이 가이드의 Swift 버전
- [`INTEGRATION_OBJC.md`](./INTEGRATION_OBJC.md) — Objective-C 통합 가이드
- [`MPARTNERS_OBJC.md`](./MPARTNERS_OBJC.md) — MPartners 채널(ObjC)
- [`MEDIATION_ADAPTER_GUIDE.md`](./MEDIATION_ADAPTER_GUIDE.md) — 미디에이션 커스텀 어댑터
