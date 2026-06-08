# ExelBid iOS SDK — 연동 가이드 (Swift)

호스트 앱에 ExelBid 광고를 추가하는 방법을 단계별로 설명합니다.
Objective-C 사용자는 [`INTEGRATION_OBJC.md`](./INTEGRATION_OBJC.md)를
참고하세요.

> **v2 호스트인가요?** 두 가지 선택지가 있습니다.
>
> - **2.x 그대로 유지** — 2.x 라인은 별도 브랜치
>   ([`release/2.x`](https://github.com/onnuridmc/ExelBid_iOS_Swift/tree/release/2.x))
>   에서 계속 유지되며 가이드도 그쪽에 있습니다
>   ([Swift](https://github.com/onnuridmc/ExelBid_iOS_Swift/blob/release/2.x/README.md)
>   · [Objective-C](https://github.com/onnuridmc/ExelBid_iOS_Swift/blob/release/2.x/README_OBJC.md)
>   · [MPartners (Swift)](https://github.com/onnuridmc/ExelBid_iOS_Swift/blob/release/2.x/README_MPartners.md)
>   · [MPartners (ObjC)](https://github.com/onnuridmc/ExelBid_iOS_Swift/blob/release/2.x/README_MPartners_Objc.md)).
>   SwiftPM 은 "Up to Next Major" 를 `2.2.0` (또는 최신 2.x 태그) 으로
>   잡고, CocoaPods 는 `pod 'ExelBid_iOS_Swift', '~> 2.2'` 로 핀하면
>   3.x 로 자동 올라가지 않습니다.
> - **v3 로 업그레이드** — 클래스 이름·콜백·생명주기가 v3 에서 새로
>   바뀌었습니다. v2 ↔ v3 대응 코드와 변경점은
>   [`MIGRATION_v2_to_v3.md`](./MIGRATION_v2_to_v3.md) 에서 영역별로
>   안내합니다 (Objective-C 는
>   [`MIGRATION_v2_to_v3_OBJC.md`](./MIGRATION_v2_to_v3_OBJC.md)). 광고
>   단위 ID 와 서버 통신 규약은 그대로라 기존 ID 를 계속 사용할 수
>   있습니다.

## 목차

- [요구사항](#요구사항)
- [설치](#설치)
- [앱 설정](#앱-설정)
- [배너 광고](#배너-광고)
- [전면 광고](#전면-광고)
- [네이티브 광고](#네이티브-광고)
- [비디오 광고](#비디오-광고)
- [공통 옵션](#공통-옵션)
- [미디에이션](#미디에이션)
- [에러 처리](#에러-처리)

> MPartners 광고는 별도 문서 [`MPARTNERS.md`](./MPARTNERS.md)에서
> 다룹니다.

---

## 요구사항

| 항목 | 값 |
|---|---|
| 최소 iOS | 13.0 |
| Xcode | 15 이상 |
| Swift | 5.9 이상 |
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
`SKAdNetworkItems`를 등록합니다.

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

광고 식별자(IDFA) 사용 권한을 요청합니다. 호출은 앱에서 직접
수행해야 하며 SDK가 임의로 호출하지 않습니다.

```swift
import AppTrackingTransparency

if #available(iOS 14, *) {
    ATTrackingManager.requestTrackingAuthorization { _ in
        // SDK가 매 요청마다 권한 상태를 다시 확인합니다.
        // 별도 연동 코드는 필요하지 않습니다.
    }
}
```

권한이 거부되거나 미요청 상태일 경우 SDK는 자동으로
24시간 주기 회전 UUID를 사용하고 요청에 `dnt=1`을 전송합니다.

---

## 배너 광고

```swift
import ExelBidSDK
import UIKit

final class HomeViewController: UIViewController {

    private var banner: EBBannerAd?

    override func viewDidLoad() {
        super.viewDidLoad()

        let banner = EBBannerAd(
            adUnitId: "YOUR_BANNER_UNIT_ID",
            size: CGSize(width: 320, height: 50)
        )
        banner.onLoad = { print("배너 로드 완료") }
        banner.onFail = { error in print("배너 실패: \(error)") }
        banner.onClick = { print("배너 클릭") }

        view.addSubview(banner)
        banner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            banner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            banner.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            banner.widthAnchor.constraint(equalToConstant: 320),
            banner.heightAnchor.constraint(equalToConstant: 50)
        ])

        self.banner = banner
        banner.load()
    }
}
```

### 주요 API

```swift
let banner = EBBannerAd(adUnitId: String, size: CGSize)

banner.autoRefresh = true                       // 기본 true. 유닛에서 정한 주기로 자동 재호출
banner.fullWebView = false                      // 기본 false. true면 광고를 광고 영역 전체에 채움
banner.options = EBAdOptions()                  // 키워드/위치 등 (아래 공통 옵션 참고)

banner.load()                                   // 광고 요청
banner.stop()                                   // 진행 중 요청 및 자동 갱신 취소

banner.onLoad:        (() -> Void)?
banner.onFail:        ((EBAdError) -> Void)?    // ObjC: onFailureBlock
banner.onClick:       (() -> Void)?
banner.onLeaveApp:    (() -> Void)?             // 외부 앱/Safari 이동 직전
banner.onClickFinish: (() -> Void)?             // 인앱 스토어/사파리 닫힘
```

---

## 전면 광고

전체화면 HTML 광고. 비디오와 동일하게 `load()` → `present(from:)`
2단계 사용 방식이고, 한 번 노출하면 단발성으로 종료됩니다.

```swift
import ExelBidSDK

final class InterstitialExampleViewController: UIViewController {

    private let interstitial = EBInterstitialAd(adUnitId: "YOUR_INTERSTITIAL_UNIT_ID")

    override func viewDidLoad() {
        super.viewDidLoad()

        interstitial.onLoad = { [weak self] in
            self?.interstitial.present(from: self!)
        }
        interstitial.onFail = { error in print("전면 실패: \(error)") }
        interstitial.onDidDisappear = { print("전면 닫힘") }

        interstitial.load()
    }
}
```

콜백/메서드는 `EBVideoAd`와 동일합니다 (`onProgress` 없음).

> `interstitial.fullWebView`(기본 `false`)로 크리에이티브 표시 방식을
> 정할 수 있습니다. 기본은 크리에이티브 크기로 화면 중앙 배치(화면을
> 넘지 않도록 클램프), `true`면 화면 전체를 채웁니다. (배너의
> `fullWebView`와 동일한 의미)

---

## 네이티브 광고

네이티브 광고는 호스트 앱이 직접 디자인한 뷰에 텍스트/이미지 에셋을
바인딩합니다. 두 단계로 진행됩니다.

### 1. 렌더링 뷰 작성

`EBNativeAdRendering` 프로토콜을 채택한 `UIView` 서브클래스를
만듭니다. SDK가 해당 메서드들이 반환하는 뷰에 자동으로 에셋을
바인딩합니다.

```swift
import UIKit
import ExelBidSDK

final class MyNativeAdView: UIView, EBNativeAdRendering {

    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()
    private let ctaButton = UIButton(type: .system)
    private let iconImageView = UIImageView()
    private let mediaContainer = UIView()   // 메인 크리에이티브(이미지/동영상)

    override init(frame: CGRect) {
        super.init(frame: frame)
        // titleLabel, bodyLabel, ctaButton 등 레이아웃 구성
    }
    required init?(coder: NSCoder) { fatalError() }

    // SDK가 자동 호출하는 메서드 — 채울 뷰만 반환
    func nativeTitleTextLabel() -> UILabel? { titleLabel }
    func nativeMainTextLabel() -> UILabel? { bodyLabel }
    func nativeCallToActionTextLabel() -> UILabel? { ctaButton.titleLabel }
    func nativeIconImageView() -> UIImageView? { iconImageView }

    // 메인 크리에이티브 슬롯(빈 UIView 하나). SDK가 이 안을 채웁니다 —
    // 응답에 동영상(VAST)이 있으면 음소거 인라인 플레이어, 없으면
    // 메인 이미지. 별도의 메인 이미지 슬롯은 없습니다.
    func nativeMediaView() -> UIView? { mediaContainer }
}
```

사용 가능한 메서드는 모두 `@objc optional`이므로 채우고 싶은
에셋에 해당하는 메서드만 구현하면 됩니다. 다른 메서드는 생략 가능.
단, **메인 이미지/동영상을 표시하려면 `nativeMediaView()`(빈 컨테이너)를
반드시 제공**하세요 — 메인 크리에이티브는 이 단일 슬롯을 통해 그려집니다.

> **동영상 네이티브**: 서버 응답에 동영상(VAST)이 포함되면 SDK가
> `nativeMediaView()` 슬롯 안에서 자동으로 인라인 재생합니다 — 음소거
> 자동재생, 화면에 50% 이상 보일 때 재생/벗어나면 일시정지, 우측 하단
> 음소거 해제 토글 제공. 동영상이 없으면 같은 슬롯에 메인 이미지를
> 표시합니다. 호스트가 따로 처리할 것은 없습니다. `hasVideoAsset`으로
> 동영상 여부를 확인할 수 있습니다.

### 2. 로드 및 연결

```swift
import ExelBidSDK

final class NativeViewController: UIViewController {

    private var loader: EBNativeAdLoader?
    private var nativeAd: EBNativeAd?
    private let adView = MyNativeAdView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(adView)
        // adView 레이아웃 구성

        let loader = EBNativeAdLoader(adUnitId: "YOUR_NATIVE_UNIT_ID")
        loader.desiredAssets = [.title, .main, .icon, .ctatext]

        loader.load { [weak self] ad, error in
            guard let self = self, let ad = ad else {
                print("네이티브 실패: \(error?.localizedDescription ?? "")")
                return
            }
            ad.onImpression = { print("노출 발생") }
            ad.onClick      = { print("클릭") }
            ad.attach(to: self.adView)
            self.nativeAd = ad
        }
        self.loader = loader
    }
}
```

Swift 6 / 콜백 대신 `async/await` 사용도 가능합니다.

```swift
Task {
    let ad = try await loader.load()
    ad.attach(to: adView)
}
```

### 사용 가능한 에셋

```swift
EBNativeAsset.title       // 광고 제목
              .desc        // 본문 설명
              .desc2       // 부가 설명
              .ctatext     // CTA 버튼 문구
              .sponsored   // 광고주 표기
              .displayUrl
              .icon        // 아이콘 이미지
              .main        // 메인 이미지
              .logo
              .rating
              .price
              .salePrice
              .downloads
              .likes
              .video       // 네이티브 비디오 (VAST)
```

`desiredAssets`을 비워두면 광고 유닛에서 설정한 에셋을 내려보냅니다.

---

## 비디오 광고

전체화면 VAST 비디오 광고입니다. `load()` 후 `present(from:)`으로
재생합니다.

```swift
import ExelBidSDK

final class VideoExampleViewController: UIViewController {

    private let videoAd = EBVideoAd(adUnitId: "YOUR_VIDEO_UNIT_ID")

    override func viewDidLoad() {
        super.viewDidLoad()

        videoAd.onLoad = { [weak self] in
            // 로드 성공 시점에 자동 재생하거나 사용자 액션을 기다림
            self?.videoAd.present(from: self!)
        }
        videoAd.onFail     = { error in print("비디오 실패: \(error)") }
        videoAd.onProgress = { percent in
            print("재생 진행률: \(percent)%")   // 0, 25, 50, 75, 100
        }
        videoAd.onClick      = { print("비디오 클릭") }
        videoAd.onDidDisappear = { print("비디오 종료") }

        videoAd.load()
    }
}
```

### 스킵 동작

기본값으로 광고 길이가 15초를 초과하면 5초 후 스킵 버튼이
노출됩니다. 옵션으로 조정 가능합니다.

```swift
videoAd.options.videoSkipMin   = 15  // 이 길이를 초과해야 스킵 허용 (초)
videoAd.options.videoSkipAfter = 5   // 시작 후 몇 초 뒤 스킵 노출
```

### 주요 API

```swift
videoAd.load()                                   // 광고 요청
videoAd.present(from: UIViewController)          // 재생 시작 (전체화면)
videoAd.isReady                                  // 로드 완료 여부

videoAd.onLoad / onFail / onClick / onLeaveApp
videoAd.onWillAppear / onDidAppear / onWillDisappear / onDidDisappear
videoAd.onProgress: ((Int) -> Void)?             // 0/25/50/75/100 발화
```

> `present(from:)` 호출 후 영상이 종료되거나 사용자가 닫으면
> `isReady`가 `false`로 돌아갑니다. 다음 광고는 다시 `load()`부터.

---

## 공통 옵션

모든 광고 객체에는 `options: EBAdOptions` 프로퍼티가 있습니다.
`load()` 호출 전에 설정합니다.

```swift
banner.options.keywords    = ["channel": "home", "section": "feed"]
banner.options.yearOfBirth = 1990                                  // 4자리 출생연도
banner.options.gender      = .male                                 // .male / .female / .unspecified
banner.options.location    = CLLocation(latitude: 37.5665,
                                        longitude: 126.9780)
banner.options.coppa       = false                                 // COPPA 적용 여부
banner.options.testing     = false                                 // 테스트 모드 (개발/QA용, 기본 false)
```

| 옵션 | 타입 | 설명 |
|---|---|---|
| `keywords` | `[String: String]` | 타겟팅용 키-값 메타데이터 |
| `yearOfBirth` | `Int` | 4자리 출생연도 (`0`은 미지정) |
| `gender` | `Gender` | `.male` / `.female` / `.unspecified` |
| `location` | `CLLocation?` | 호스트 앱이 보유한 사용자 위치 |
| `coppa` | `Bool` | COPPA 적용 여부 (광고 객체별 지정) |
| `testing` | `Bool` | 테스트 모드 (기본 `false`) |

> SDK는 위치를 직접 수집하지 않으므로, 위치 타겟팅이 필요하면
> 호스트 앱이 권한을 받아 직접 `CLLocation`을 전달해야 합니다.

> **테스트 모드**: `options.testing` 은 개발·QA 단계에서만 켜고,
> 배포(릴리스) 빌드에서는 반드시 `false`(기본값)로 두세요. 테스트
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

| 광고망 | SwiftPM 프로덕트 | 포맷 | 배포 |
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
통합해야 합니다.

**SwiftPM 설치** — 어댑터별 모듈로 분리됩니다:

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/onnuridmc/ExelBid_iOS_Swift.git",
             from: "3.0.0"),
    .package(url: "https://github.com/onnuridmc/ExelBid_iOS_Mediation_Adapter.git",
             from: "1.0.0"),
],
// target dependencies: 실제로 사용하는 프로덕트만
//   .product(name: "ExelBidMediationAdMob", package: "ExelBid_iOS_Mediation_Adapter")
//   .product(name: "ExelBidMediationFAN",   package: "ExelBid_iOS_Mediation_Adapter")
```

```swift
import ExelBidMediationAdMob   // 어댑터별 개별 import
import ExelBidMediationFAN
```

**CocoaPods 설치** — 모든 subspec 이 단일 모듈로 합쳐집니다:

```ruby
# Podfile
pod 'ExelBid_iOS_Swift',           '~> 3.0'
pod 'ExelBid_Mediation_Adapter/AdMob'
pod 'ExelBid_Mediation_Adapter/FAN'
```

```swift
import ExelBidMediationAdapter   // 어떤 subspec을 설치하든 단일 모듈
```

> **AdFit 은 SwiftPM 전용**입니다 — Kakao 가 AdFit SDK 의 CocoaPods 배포를
> 중단해 `AdFitSDK` pod 이 없습니다. CocoaPods 환경에서 AdFit 이 필요하면
> 어댑터 저장소 README 의 수동 통합 절차를 참고하세요.

> **직접 만들기 — 가장 빠른 경로일 때가 많습니다.** 다음 중 어느
> 하나라도 해당된다면 제공 어댑터를 템플릿 삼아 직접 작성하는 편이
> 빠릅니다.
>
> - 추후 지원 예정 네트워크 (Pangle / AppLovin / DT 등) 를 **지금
>   당장** 붙여야 할 때
> - 사내 광고 서버나 비공개 네트워크를 연결할 때
> - 제공 어댑터를 포크해 동작을 커스터마이즈 하고 싶을 때
> - AdFit 비디오, AdMob 보상형 등 **미지원 포맷** 이 필요할 때
>
> 공개 프로토콜 4개 (`EBBannerMediationAdapter` /
> `EBInterstitialMediationAdapter` / `EBNativeMediationAdapter` /
> `EBVideoMediationAdapter`) 중 필요한 것만 구현하면 되며, 단계별 작성
> 방법은 [`MEDIATION_ADAPTER_GUIDE.md`](./MEDIATION_ADAPTER_GUIDE.md)
> 에서 설명합니다.

### 모듈 등록

앱 시작 시(`AppDelegate.application(_:didFinishLaunchingWithOptions:)`
또는 `App.init`) 한 번만 등록합니다.

```swift
import ExelBidSDK
import ExelBidMediationAdMob   // SwiftPM: 어댑터별 import
import ExelBidMediationFAN
// CocoaPods 로 설치한 경우: import ExelBidMediationAdapter 하나만

ExelBidMediationKit.shared.register(modules: [
    ExelBidBuiltInMediationModule.self,   // ExelBid 자체 어댑터 (필수)
    AdMobMediationModule.self,
    FANMediationModule.self,
])
```

> `ExelBidBuiltInMediationModule`을 포함하지 않으면 서버 워터폴
> 응답의 "exelbid" 항목이 건너뛰어집니다. 일반적으로 항상 함께
> 등록하세요. 직접 만든 어댑터도 동일한 방식으로 등록하며, 같은
> `networkID` 로 재등록하면 제공 어댑터를 자신의 구현으로 교체할 수
> 있습니다.

### 배너

```swift
let banner = EBMediatedBannerAd(
    adUnitId: "YOUR_MEDIATION_UNIT_ID",
    size: CGSize(width: 320, height: 50)
)
banner.perNetworkTimeout = 5.0            // 기본 5초

banner.onLoad = { [weak banner] in
    print("낙찰 네트워크: \(banner?.winningNetwork ?? "?")")
}
banner.onFail = { error in print("전 네트워크 실패: \(error)") }
banner.onClick = { print("배너 클릭") }

view.addSubview(banner)
banner.load()
```

`EBBannerAd`와 시그니처가 거의 동일합니다. 차이점:

- `perNetworkTimeout` — 네트워크별 로드 타임아웃 (기본 5초)
- `winningNetwork: String?` — 로드 성공 후 낙찰된 네트워크 ID
- `onWaterfallEvent` — 워터폴 단계별 텔레메트리 (선택)
- 서버가 제공하는 `autoRefresh`는 지원하지 않습니다.

### 전면

```swift
let interstitial = EBMediatedInterstitialAd(adUnitId: "YOUR_UNIT_ID")
interstitial.rootViewControllerProvider = { [weak self] in self }

interstitial.onLoad = { [weak interstitial] in
    print("낙찰: \(interstitial?.winningNetwork ?? "?")")
}
interstitial.onFail = { error in print("로드 실패: \(error)") }
interstitial.onDidDisappear = { print("닫힘") }

interstitial.load()
// 사용자가 광고를 보길 원하는 시점:
interstitial.present(from: self)
```

`EBInterstitialAd`와 시그니처가 동일하며, 단발성 사용입니다
(`present(from:)` 이후 `isReady`가 `false`로 돌아갑니다).

> `rootViewControllerProvider`는 권장 설정입니다. FAN 등 일부 네트워크는
> **로드 시점**에 `rootViewController`가 필요합니다.

### 네이티브

```swift
let loader = EBMediatedNativeAdLoader(adUnitId: "YOUR_UNIT_ID")
loader.desiredAssets = [.title, .main, .icon, .ctatext]
loader.rootViewControllerProvider = { [weak self] in self }
loader.onWaterfallEvent = { event in /* 워터폴 텔레메트리 (선택) */ }  // load() 전에 설정

Task {
    do {
        let ad = try await loader.load()
        print("낙찰: \(ad.winningNetwork)")
        ad.onClick = { print("네이티브 클릭") }
        ad.attach(to: myNativeView)   // EBNativeAdRendering 채택
    } catch {
        print("네이티브 실패: \(error)")
    }
}
```

`EBNativeAdLoader`와 사용 흐름이 동일하며, 결과 타입만
`EBMediatedNativeAd`로 바뀝니다. **렌더링 뷰는 동일한
`EBNativeAdRendering` 프로토콜을 사용**하므로 일반 광고와 같은 뷰를
재사용할 수 있습니다. 어댑터가 각 네트워크의 자산을 `EBNativeAdModel`
스키마로 정규화해 전달합니다.

> **미디어 슬롯 (`nativeMediaView()`) 과 AdChoices**
>
> 메인 크리에이티브는 일반 네이티브와 동일하게 **`nativeMediaView()`
> 단일 슬롯**으로 그려집니다. 미디에이션에서는 어댑터가 이 슬롯에
> 네트워크 자체 미디어 뷰(AdMob `GADMediaView` / FAN `FBMediaView` —
> 동영상엔 필수)나, URL 전용 네트워크(AdFit)의 이미지 뷰를 꽂습니다.
> 따라서 **미디어/동영상을 표시하려면 이 슬롯을 반드시 제공**하세요:
>
> ```swift
> // 메인 크리에이티브가 들어갈 빈 컨테이너(UIView).
> func nativeMediaView() -> UIView? { mediaContainer }
>
> // FAN 등 일부 네트워크가 요구하는 AdChoices/광고옵션 오버레이 위치.
> func nativeAdChoicesView() -> UIView? { adChoicesContainer }
> ```
>
> 두 슬롯 모두 `@objc optional`이라 텍스트/아이콘만 쓰는 레이아웃에는
> 영향이 없습니다. 다만 슬롯이 없으면 메인 미디어는 표시되지 않습니다.

### 비디오

```swift
let videoAd = EBMediatedVideoAd(adUnitId: "YOUR_UNIT_ID")
videoAd.rootViewControllerProvider = { [weak self] in self }

videoAd.onLoad = { [weak videoAd] in
    print("낙찰: \(videoAd?.winningNetwork ?? "?")")
    // 또는 onLoad에서 즉시 present:
    // videoAd?.present(from: self)
}
videoAd.onFail     = { error in print("로드 실패: \(error)") }
videoAd.onProgress = { percent in print("진행률: \(percent)%") }
videoAd.onDidDisappear = { print("종료") }

videoAd.load()
```

`EBVideoAd`와 시그니처가 동일하며, 단발성 사용입니다.

> ExelBid 외 네트워크(AdMob / FAN)에서 video 포맷은 **전면(인터스티셜)
> 비디오**로 노출됩니다(보상형 아님). 비디오용 광고 유닛이 영상
> 크리에이티브를 전면으로 자동 재생하며, `onProgress`는 시작(`0`)·
> 종료(`100`) 두 시점만 근사 보고됩니다.

### 워터폴 이벤트 (선택)

`onWaterfallEvent`로 각 단계의 결과를 받아 호스트 앱 분석 도구로
전송할 수 있습니다.

```swift
banner.onWaterfallEvent = { event in
    switch event {
    case .fetching:                                  break
    case .fetched(let networks):                     // 시도할 네트워크 목록
        print("waterfall: \(networks)")
    case .trying(let net, _, let pos, let total):
        print("\(pos)/\(total) → \(net)")
    case .won(let net, _, let latency):
        print("won: \(net) (\(Int(latency * 1000))ms)")
    case .lost(let net, _, let reason):
        print("lost: \(net) (\(reason))")
    case .noFill:
        print("모든 네트워크 실패")
    }
}
```

`EBWaterfallFailReason`의 케이스: `adapterNotRegistered` /
`loadFailed(Error)` / `timeout(TimeInterval)` / `cancelled`.

> **스레드**: 미디에이션 콜백(`onLoad` / `onFail` / `onClick` /
> `onWaterfallEvent` 등)은 모두 **메인 스레드**로 전달됩니다. 콜백
> 안에서 UI를 바로 갱신해도 안전합니다. (배너 / 전면 / 네이티브 /
> 비디오 4개 포맷 공통)

---

## 에러 처리

모든 광고 객체는 실패 시 `onFail` 콜백에 `EBAdError`를 전달합니다.

```swift
public enum EBAdError: Error {
    case invalidAdUnitId        // 광고 단위 ID가 비었거나 공백
    case noFill                  // 서버가 광고를 내려주지 않음 (정상 케이스 포함)
    case network(underlying: Error)
    case httpStatus(code: Int)
    case decoding(underlying: Error)
    case notReady                // 로드 완료 전에 present(from:) 호출
}
```

`noFill`은 광고가 없다는 정상 상태입니다.
fallback UI를 보여주는 식으로 처리하세요.

```swift
banner.onFail = { error in
    switch error {
    case .noFill:
        // 광고 없음 — 빈 영역 처리
        break
    case .network, .httpStatus:
        // 네트워크 일시 오류 — 잠시 후 재시도
        break
    default:
        // 그 외 (단위 ID 오류 등) — 로그 확인 필요
        break
    }
}
```

---

연동 중 문제가 발생하면 광고 단위 ID, 디바이스 OS 버전, SDK 버전과
함께 운영팀에 문의해 주세요.
