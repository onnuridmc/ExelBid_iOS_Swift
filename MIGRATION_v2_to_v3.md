# 마이그레이션 가이드: v2 → v3

ExelBid iOS SDK v3는 클린룸(clean-room) 재작성 버전입니다. 광고 서버와
주고받는 **통신 프로토콜은 그대로**라서 기존 광고 단위 ID(adUnitId)는
변경 없이 계속 동작합니다. 다만 **모든 공개 클래스 이름 · 콜백 형태 ·
생명주기**가 새롭게 바뀌었습니다.

이 문서는 각 영역별로 v2 ↔ v3 대응 코드를 보여줍니다.

---

## 1. 최소 요구사항

| 항목 | v2 | v3 |
|---|---|---|
| iOS 배포 타깃 | 13.0+ | 13.0+ (동일) |
| Swift | 5.x | 5.9+ |
| 배포 방식 | xcodeproj → XCFramework | SwiftPM (Xcode 프로젝트는 선택) |
| 서버 통신 규약 | 동일 | 동일 (변경 없음) |
| 프라이버시 매니페스트 | `PrivacyInfo.xcprivacy` 번들 | 동일 |

### 핵심 변화

- **분산 방식**: v2는 xcodeproj 빌드 기반, v3는 SwiftPM 패키지 + 바이너리
  XCFramework 배포입니다. 공개 배포는 별도 저장소
  (`ExelBid_iOS_Swift`)의 `Package.swift` / `.podspec` 으로 이루어집니다.
- **모듈 이름**: import 모듈명은 `ExelBidSDK` 입니다.
- **타입 접두사**: 호스트에 노출되는 모든 공개 타입은 `EB` 접두사를
  사용합니다 (`EBBannerAd`, `EBNativeAdLoader`, `EBVideoAd`,
  `EBInterstitialAd` 등). 브랜드 싱글톤은 `ExelBid` 접두사를 유지합니다
  (`ExelBid.shared`, `ExelBidMediationKit.shared`).

---

## 2. 전역 설정 (Global configuration)

### v2

```swift
// ExelBidKit == ExelBid.sharedInstance (전역 typealias)
ExelBidKit.appId   = "..."                       // 앱 ID
ExelBidKit.frequencyCappingIdUsageEnabled = true // ExelBid ID 사용 여부
let v = ExelBidKit.version
```

### v3

```swift
let kit = ExelBid.shared
kit.logLevel = .info          // 외부에 공개된 유일한 전역 설정
let v = kit.sdkVersion        // 요청의 sv 파라미터로도 사용됨
```

### 핵심 변화

- 전역 `testing` 설정은 사라지고, **광고별 `options.testing`** 으로
  이동했습니다(아래 "테스트 모드" 참고).
- `frequencyCappingIdUsageEnabled` 토글은 **제거**되었습니다. v3는
  IDFA를 쓸 수 없을 때 24시간 주기로 회전하는 UUID 폴백을 항상
  사용합니다.
- COPPA / 위치 / 키워드 등 광고별 설정은 전역이 아니라 **광고 객체마다
  `EBAdOptions`** 로 지정합니다(각 영역 참고).
- 싱글톤 진입점이 `ExelBid.sharedInstance` → `ExelBid.shared` 로
  바뀌었습니다 (`ExelBidKit` 전역 별칭은 사라짐).

### 테스트 모드 (`options.testing`)

v2에서 전역(`ExelBidKit.testing`) 또는 광고별(`EBAdView.testing` 등)으로
켜던 테스트 모드는, v3에서 **광고 객체마다 `options.testing` 불리언**으로
일원화되었습니다. 기본값은 `false` 입니다.

```swift
let banner = EBBannerAd(adUnitId: "u", size: CGSize(width: 320, height: 50))
banner.options.testing = true     // 개발/QA 중에만 사용. 기본값 false
banner.load()
```

- 모든 포맷에서 동일하게 동작합니다 — `EBBannerAd` / `EBNativeAdLoader` /
  `EBVideoAd` / `EBInterstitialAd` 의 `options.testing` 으로 설정합니다.
- **배포(릴리스) 빌드에서는 반드시 끄거나 기본값(`false`)을 유지**하세요.
  테스트 모드로 발생한 노출/클릭은 정상 집계 대상이 아닙니다.

---

## 3. 배너 (Banner)

### v2

```swift
class MyVC: UIViewController, EBAdViewDelegate {
    let banner = EBAdView(adUnitId: "u", size: CGSize(width: 320, height: 50))

    override func viewDidLoad() {
        banner.delegate = self
        banner.keywords = "k1,k2"   // String (CSV)
        banner.yob      = "1990"
        banner.gender   = "M"
        banner.coppa    = "1"
        view.addSubview(banner)
        banner.loadAd()
    }

    func adViewDidLoadAd(_ view: EBAdView?) { /* … */ }
    func adViewDidFailToLoadAd(_ view: EBAdView?) { /* … */ }
    func willLoadViewForAd(_ view: EBAdView?) { /* 클릭 직후 */ }
    func didLoadViewForAd(_ view: EBAdView?) { /* 클릭 처리 완료 */ }
    func willLeaveApplicationFromAd(_ view: EBAdView?) { /* 앱 이탈 */ }
}
```

### v3

```swift
let banner = EBBannerAd(adUnitId: "u", size: CGSize(width: 320, height: 50))
banner.options.keywords = ["k": "v"]   // [String: String] (CSV 자유문자열 아님)
banner.options.coppa    = true         // 광고별 COPPA (v3에는 전역 설정 없음)
banner.autoRefresh      = true         // 명시적; 기본값 true

banner.onLoad        = { /* adViewDidLoadAd */ }
banner.onFail        = { error in /* adViewDidFailToLoadAd, 타입 에러 전달 */ }
banner.onClick       = { /* willLoadViewForAd */ }
banner.onClickFinish = { /* didLoadViewForAd */ }
banner.onLeaveApp    = { /* willLeaveApplicationFromAd */ }

view.addSubview(banner)
banner.load()
// 중지:
banner.stop()
```

### 핵심 변화

- `delegate` → 클로저 콜백. `EBAdViewDelegate` 채택을 제거하세요.
- `keywords: String` (CSV) → `options.keywords: [String: String]`.
- `yob` / `gender` / `coppa` → `options.yearOfBirth` / `.gender` / `.coppa`
  (v2에서는 `String`, v3에서는 타입이 정리됨).
- `loadAd()` / `stopAd()` → `load()` / `stop()`.
- 자동 새로고침: v2의 `startAutomaticallyRefreshingContents()` /
  `stopAutomaticallyRefreshingContents()` → `banner.autoRefresh` 불리언.
- 실패 시 정보 없는 델리게이트 호출 대신 **타입이 있는 `EBAdError`** 가
  전달됩니다.
- `fullWebView` 플래그는 v2의 `EBAdView.fullWebView` 와 동일하게 v3에도
  있습니다 — `banner.fullWebView`. 기본값 `false`(크리에이티브 크기로
  센터 배치), `true`면 광고 영역을 꽉 채웁니다. 단 v3는 크리에이티브
  크기가 광고 영역(컨테이너)을 넘지 않도록 클램프합니다.
- v3는 노출(impression) 트래킹을 자동으로 처리합니다.

### Objective-C

ObjC에서는 `onFail`(Swift 전용) 대신 `onFailureBlock: ((NSError) -> Void)?`
를 사용합니다(`EBAdError.asNSError` 로 브리징됨).

---

## 4. 네이티브 (Native)

### v2

```swift
let manager = ExelBidNativeManager("u", MyNativeAdView.self)
manager.keywords("k1,k2")
manager.desiredAssets(["title", "icon", "main"] as NSSet)  // 문자열 집합
manager.startWithCompletionHandler { request, nativeAd, error in
    guard let nativeAd = nativeAd else { return }
    let adView = nativeAd.retrieveAdViewWithError(nil)
    self.container.addSubview(adView!)
}
```

`MyNativeAdView` 는 `EBNativeAdRendering` 을 채택했습니다.

### v3

```swift
final class MyNativeAdView: UIView, EBNativeAdRendering {
    let title = UILabel()
    func nativeTitleTextLabel() -> UILabel? { title }
    // … 나머지 자산 슬롯
}

let loader = EBNativeAdLoader(adUnitId: "u")
loader.options.keywords = ["k": "v"]
loader.desiredAssets    = [.title, .icon, .main]   // 문자열이 아닌 타입 enum

Task {
    let ad = try await loader.load()               // async throws
    let view = MyNativeAdView()
    container.addSubview(view)

    ad.presenterProvider = { [weak self] in self }  // 스토어/웹뷰 표시용
    ad.onImpression    = { /* 노출 시점 */ }
    ad.onImpression50  = { /* 50% 가시성 도달 */ }
    ad.onImpression100 = { /* 100% 가시성 도달 */ }
    ad.onClick         = { /* … */ }

    _ = ad.attach(to: view)                        // 렌더링 + 트래킹 시작
}
```

ObjC 호스트는 콜백 기반 진입점을 사용할 수 있습니다:

```objc
[loader loadWithCompletion:^(EBNativeAd *ad, NSError *err) { /* … */ }];
```

### 핵심 변화

- `ExelBidNativeManager` → `EBNativeAdLoader`.
- `startWithCompletionHandler` (콜백) → `load() async throws` (Swift) +
  `load(completion:)` (ObjC).
- 자산 선택: 자유 문자열 `NSSet` → `Set<EBNativeAsset>` 타입 enum
  (`.title` / `.desc` / `.icon` / `.main` / `.ctatext` / `.video` 등).
- 뷰 소유권: v2는 `viewClass`(`MyNativeAdView.self`)를 매니저에 주입했지만,
  v3는 **호스트가 직접 렌더링 뷰를 생성**해 `attach(to:)` 에 전달합니다.
  `retrieveAdViewWithError(_:)` 는 사라졌습니다.
- 노출(impression) 트리거가 셋으로 분리됩니다:
  - 기본 노출 → `attach(to:)` 즉시
  - 50% 노출 → 뷰가 일정 시간 동안 50% 이상 보일 때
  - 100% 노출 → 뷰가 일정 시간 동안 100% 보일 때

### v3에서 제거된 네이티브 기능

- `ExelBidNativeManager` 의 `startMPartnersWithCompletionHandler` 변형 →
  독립 `EBMPartnersNativeAdLoader` 파사드로 대체 (§7 참고).
- `EBTableViewAdPlacer` / `EBCollectionViewAdPlacer` /
  `EBStreamAdPlacer` (자동 삽입 헬퍼) → v3 1.0 범위 밖. 추후 별도
  `ExelBidNativePlacer` 모듈로 분리 검토 중.

---

## 5. 비디오 / VAST (Video)

### v2

```swift
class MyVC: UIViewController, EBVideoDelegate {
    let manager = EBVideoManager(identifier: "u")

    func loadVideo() {
        manager.keywords("k1,k2")
        manager.startWithCompletionHandler { request, error in
            guard error == nil else { return }
            self.manager.presentAd(controller: self, delegate: self)
        }
    }

    func videoAdDidLoad(adUnitID: String) { /* … */ }
    func videoAdDidFailToLoad(adUnitID: String, error: Error) { /* … */ }
    func videoAdWillAppear(adUnitID: String) { /* … */ }
    func videoAdDidAppear(adUnitID: String) { /* … */ }
    func videoAdWillDisappear(adUnitID: String) { /* … */ }
    func videoAdDidDisappear(adUnitID: String) { /* … */ }
    func videoAdDidReceiveTapEvent(adUnitID: String) { /* … */ }
}
```

### v3

```swift
let video = EBVideoAd(adUnitId: "u")
video.options.keywords = ["k": "v"]

video.onLoad          = { /* videoAdDidLoad */ }
video.onFail          = { error in /* videoAdDidFailToLoad */ }
video.onWillAppear    = { /* videoAdWillAppear */ }
video.onDidAppear     = { /* videoAdDidAppear */ }
video.onWillDisappear = { /* videoAdWillDisappear */ }
video.onDidDisappear  = { /* videoAdDidDisappear */ }
video.onClick         = { /* videoAdDidReceiveTapEvent */ }
video.onLeaveApp      = { /* 클릭으로 앱 이탈 직전 */ }
video.onProgress      = { percent in /* VAST 사분위 진행률 */ }

video.load()
// 로드 완료 후 (video.isReady == true):
video.present(from: self)
```

### 핵심 변화

- `EBVideoManager` → `EBVideoAd`.
- `EBVideoDelegate` → 클로저. 델리게이트 메서드의 `adUnitID:` 인자는
  사라지고, 광고 객체 단위로 콜백을 설정합니다.
- `startWithCompletionHandler { … presentAd(controller:delegate:) }`
  → `load()` 후 `present(from:)` 2단계 호출.
- 서버가 내려주는 트래킹 URL은 VAST XML 자체의 `<Impression>` /
  `<ClickTracking>` URL과 함께 발사됩니다(v2 동작과 동일).
- VAST Wrapper 체인 깊이는 비정상 체인을 막기 위해 **최대 5단계**로
  제한됩니다.
- 재생 자연 종료 시 컴패니언(엔드카드)을 표시하며, 스킵 경로에서는
  엔드카드를 표시하지 않습니다.

---

## 6. 전면 광고 (Interstitial)

### v2

```swift
class MyVC: UIViewController, EBInterstitialAdControllerDelegate {
    var interstitial: EBInterstitialAdController?

    func loadInterstitial() {
        interstitial = EBInterstitialAdController(adUnitId: "u")
        interstitial?.delegate = self
        interstitial?.keywords = "k1,k2"
        interstitial?.loadAd()
    }

    func interstitialDidLoadAd(_ ad: EBInterstitialAdController?) {
        if ad?.ready == true { ad?.showFromViewController(self) }
    }
    func interstitialDidFailToLoadAd(_ ad: EBInterstitialAdController?) { /* … */ }
    func interstitialDidFailToShow(_ ad: EBInterstitialAdController?) { /* … */ }
    // willAppear / didAppear / willDisappear / didDisappear /
    // didReceiveTapEvent / didExpire …
}
```

### v3

```swift
let ad = EBInterstitialAd(adUnitId: "u")
ad.options.keywords = ["k": "v"]

ad.onLoad          = { /* interstitialDidLoadAd */ }
ad.onFail          = { error in /* DidFailToLoad / DidFailToShow 통합 */ }
ad.onWillAppear    = { /* interstitialWillAppear */ }
ad.onDidAppear     = { /* interstitialDidAppear */ }
ad.onWillDisappear = { /* interstitialWillDisappear */ }
ad.onDidDisappear  = { /* interstitialDidDisappear */ }
ad.onClick         = { /* interstitialDidReceiveTapEvent */ }
ad.onClickFinish   = { /* 클릭 처리 완료 (인앱 스토어/사파리 닫힘) */ }
ad.onLeaveApp      = { /* 클릭으로 앱 이탈 직전 */ }

ad.load()
// ad.isReady == true 일 때:
ad.present(from: self)
```

### 핵심 변화

- v2 `EBInterstitialAdController` 는 호스트가 직접 소유·표시하던
  `UIViewController` 였습니다. v3 `EBInterstitialAd` 는 `NSObject`
  오케스트레이터이고, 전체 화면 표시기는 내부에서 `present(from:)`
  시점에 생성됩니다.
- `EBInterstitialAdControllerDelegate` → 클로저.
- `loadAd()` / `showFromViewController()` → `load()` / `present(from:)`.
- v2의 `ready` 프로퍼티 → v3의 `isReady`.
- `interstitialDidFailToShow` 는 `onFail` 로 통합됩니다. `isReady` 가
  `true` 가 되기 전에 `present(from:)` 을 호출하면 `EBAdError.notReady`
  가 전달됩니다.
- 닫기 버튼(우측 상단)은 SDK가 직접 그립니다. v2의 `EBCloseButtonX`
  이미지 번들은 더 이상 필요 없습니다.
- **1회용(single-use)**: 닫히면 `isReady` 가 다시 `false` 로 돌아가며,
  다음 표시 전에 새 `load()` 가 필요합니다.

---

## 7. MPartners 채널

MPartners는 일반 광고 인벤토리와 분리된 별도 채널을 사용하는 병렬
파사드 묶음입니다.

| v2 | v3 |
|---|---|
| `MPartnersAdView` | `EBMPartnersBannerAd` |
| `MPartnersInterstitialAdController` | `EBMPartnersInterstitialAd` |
| `MPartnersNativeManager` / `startMPartnersWithCompletionHandler` | `EBMPartnersNativeAdLoader` |

v3의 MPartners 파사드는 각각 `EBBannerAd` / `EBInterstitialAd` /
`EBNativeAdLoader` 와 **1:1로 동일한 공개 인터페이스**를 가집니다. 단,
백엔드가 제공하지 않으므로 자동 새로고침과 SKAdNetwork 어트리뷰션은
없습니다. 자세한 내용은 [`MPARTNERS.md`](./MPARTNERS.md) 를 참고하세요.

---

## 8. 미디에이션 (Mediation)

v2의 `EBMediationManager` + 네트워크별 어댑터는 v3에서 다시 포팅되어
**`ExelBidSDK` 타깃 내부에 번들**됩니다. 따라서 `import ExelBidSDK`
만으로 모든 호스트가 미디에이션 API를 함께 받습니다.

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

**어댑터 설치 — SwiftPM**

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/onnuridmc/ExelBid_iOS_Swift.git",
             from: "3.0.0"),
    .package(url: "https://github.com/onnuridmc/ExelBid_iOS_Mediation_Adapter.git",
             from: "1.0.0"),
],
// target dependencies: 사용할 어댑터 프로덕트만 추가
//   .product(name: "ExelBidMediationAdMob", package: "ExelBid_iOS_Mediation_Adapter")
```

**어댑터 설치 — CocoaPods**

```ruby
# Podfile
pod 'ExelBid_iOS_Swift',           '~> 3.0'
pod 'ExelBid_Mediation_Adapter/AdMob'
pod 'ExelBid_Mediation_Adapter/FAN'
```

> CocoaPods 어댑터는 어떤 subspec을 설치하든 모두
> `import ExelBidMediationAdapter` **하나로** 합쳐집니다(pod 배포명은
> `ExelBid_Mediation_Adapter`, Swift 모듈명은 `ExelBidMediationAdapter`).
> 반대로 SwiftPM은 어댑터별 모듈로 나뉘므로
> `import ExelBidMediationAdMob` 처럼 개별 import 합니다.
> **AdFit은 SwiftPM 전용**입니다(Kakao가 AdFit SDK의 CocoaPods 배포를
> 중단). CocoaPods 환경에서 AdFit이 필요하면 어댑터 README의 수동 통합
> 절차를 참고하세요.

**앱 시작 시 모듈 등록**

```swift
import ExelBidSDK
import ExelBidMediationAdMob       // SwiftPM: 어댑터별 import
// CocoaPods로 설치한 경우: import ExelBidMediationAdapter 하나만

ExelBidMediationKit.shared.register(modules: [
    ExelBidBuiltInMediationModule.self,   // ExelBid 자체 어댑터 (필수)
    AdMobMediationModule.self,
])
```

> `ExelBidBuiltInMediationModule`을 포함하지 않으면 서버 워터폴 응답의
> "exelbid" 항목이 건너뛰어집니다. 일반적으로 항상 함께 등록합니다.

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

  ```swift
  func nativeMediaView() -> UIView? { mediaContainer }
  func nativeAdChoicesView() -> UIView? { adChoicesContainer }  // FAN AdChoices (선택)
  ```

  슬롯이 없어도 텍스트 자산은 정상 동작하지만 미디어는 표시되지
  않습니다.
- **AdFit**: 인터스티셜·비디오 API가 없으므로 워터폴의 인터스티셜·비디오
  `"adfit"` 항목은 자동 스킵됩니다.

제공 어댑터가 맞지 않으면 어댑터를 직접 만들 수도 있습니다 —
[`MEDIATION_ADAPTER_GUIDE.md`](./MEDIATION_ADAPTER_GUIDE.md) 참고.

---

## 9. 에러 처리 (Errors)

### v2

실패는 `nil` 광고 객체, `Error?` 파라미터, 또는 정보 없는
`adViewDidFailToLoadAd` 호출로 노출되었습니다.

### v3

모든 실패는 `LocalizedError` 를 채택한 타입 enum **`EBAdError`** 로
전달됩니다:

```swift
banner.onFail = { error in
    switch error {
    case .invalidAdUnitId:        break   // 잘못된/공백 adUnitId
    case .noFill:                 break   // 응답 광고 없음
    case .network(let underlying): break  // 전송 계층 오류
    case .httpStatus(let code):   break   // 비정상 HTTP 상태
    case .decoding(let underlying):       break // 응답 파싱 실패
    case .vastParsing(let underlying):    break // VAST 파싱 실패
    case .mediaFileUnavailable:   break   // 재생 가능한 미디어 없음
    case .playback(let underlying): break // 재생 오류
    case .notReady:               break   // 준비 전 present 호출
    case .canceled:               break   // 취소됨
    @unknown default:             break
    }
}
```

- ObjC에서는 `onFailureBlock: ((NSError) -> Void)?` 를 사용하며,
  `EBAdError.asNSError` 로 동일한 케이스가 `NSError` 코드로 매핑됩니다
  (`invalidAdUnitId = 1` … `canceled = 10`).

---

## 10. 제거/대체된 편의 프로퍼티

| v2 | v3 대체 |
|---|---|
| `ExelBidKit` (전역 별칭) | `ExelBid.shared` |
| `ExelBidKit.testing` / `EBAdView.testing` | `options.testing` (광고별) |
| `ExelBidKit.frequencyCappingIdUsageEnabled` | 제거. 24시간 UUID 회전 기본 동작 |
| `EBAdView.fullWebView` | `EBBannerAd.fullWebView` (기본 `false`, 동작 동일). v3는 크리에이티브 크기를 광고 영역으로 클램프 |
| `EBAdView.yob / gender / coppa` (`String`) | `options.yearOfBirth / .gender / .coppa` |
| `EBNativeAd.retrieveAdViewWithError(_:)` | `nativeAd.attach(to:)` 단일 진입점 |
| `startAutomaticallyRefreshingContents()` / `stop…()` | `banner.autoRefresh: Bool` |
| Placer (TableView/CollectionView/Stream 자동 삽입) | 범위 밖. 추후 `ExelBidNativePlacer` 모듈 검토 |
| MoPub 스타일 `MP*` 클래스 / NIB 로더 | 제거 |

---

## 11. 단계별 업그레이드 체크리스트

1. **롤백 경로 확보** — 기존 v2 빌드를 그대로 유지해 되돌릴 수 있게 둡니다.
2. v3를 **병렬 SPM 의존성**으로 추가합니다(모듈명 `ExelBidSDK`).
3. 광고 영역을 **하나씩** 마이그레이션합니다:
   - 배너부터 — API 표면이 가장 작습니다.
   - 다음 네이티브 — 렌더링 뷰 포팅에 의존합니다.
   - 비디오는 마지막 — 사용자에게 가장 잘 보입니다.
4. 각 영역 마이그레이션 후, Exelbid가 발급한 **테스트 광고 단위 ID** 로
   동작을 검증합니다.
5. 모든 영역이 v3로 옮겨지면 v2 의존성을 제거합니다.
6. 리포팅 대시보드에서 노출 / 클릭 정상 동작을 재확인합니다.

---

이 가이드에서 다루지 않은 통합 세부 사항은 다음 문서를 참고하세요.

- [`README.md`](./README.md) — Swift 통합 가이드(기본 진입점)
- [`INTEGRATION_OBJC.md`](./INTEGRATION_OBJC.md) — Objective-C 통합 가이드
- [`MIGRATION_v2_to_v3_OBJC.md`](./MIGRATION_v2_to_v3_OBJC.md) — 이 가이드의 Objective-C 버전
- [`MPARTNERS.md`](./MPARTNERS.md) / [`MPARTNERS_OBJC.md`](./MPARTNERS_OBJC.md) — MPartners 채널
- [`MEDIATION_ADAPTER_GUIDE.md`](./MEDIATION_ADAPTER_GUIDE.md) — 미디에이션 커스텀 어댑터
