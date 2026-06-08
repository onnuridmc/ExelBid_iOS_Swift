# 미디에이션 커스텀 어댑터 개발 가이드

## 기본 제공 어댑터 (3개 광고망)

ExelBid v3 미디에이션은 다음 **3개 광고망** 용 어댑터를 별도 패키지
(`ExelBid_iOS_Mediation_Adapter`)에서 기본 제공합니다.

| 광고망 | 모듈 | 배너 | 전면 | 네이티브 | 비디오 | 배포 |
|---|---|:-:|:-:|:-:|:-:|---|
| Google AdMob | `ExelBidMediationAdMob` | ✅ | ✅ | ✅ | ✅ (전면 비디오) | SwiftPM · CocoaPods |
| Facebook Audience Network (FAN) | `ExelBidMediationFAN` | ✅ | ✅ | ✅ | ✅ (전면 비디오) | CocoaPods |
| Kakao AdFit | `ExelBidMediationAdFit` | ✅ | — | ✅ | — | SwiftPM 전용 |

> AdFit 은 SDK 차원에서 전면·비디오 API 가 없어 어댑터에서도 미지원입니다.
> AdMob / FAN 의 video 는 **전면(인터스티셜) 비디오** 를 의미하며 보상형이
> 아닙니다.

## 그 외 광고망 — 추후 지원 / 요청 기반 업데이트

다음 광고망은 **로드맵에는 있으나 현재는 미배포**입니다. 호스트 앱이
사용할 일정이 잡히면 운영팀에 요청해 우선순위를 조정할 수 있습니다.

- ByteDance Pangle (`PAGAdSDK`)
- AppLovin (`AppLovinSDK`)
- Digital Turbine / Fyber (`IASDKCore`)
- TNK Factory (`TnkAdSdk`)
- MezzoMedia TargetPick (`ADMixerZ`)
- 그 외 새 네트워크 — 요청 시 검토 후 정식 어댑터로 배포

배포되기 전까지는 서버 워터폴에 해당 `networkID` 가 포함돼 있어도
**미등록 어댑터**로 처리되어
(`EBWaterfallEvent.lost(.adapterNotRegistered)`) 다음 순번으로
건너뛰어집니다 — 즉 워터폴이 깨지지 않습니다.

## 직접 만드는 게 더 빠른 경우 — 제공 어댑터를 템플릿으로

아래 어느 한 경우라도 해당된다면 **제공 어댑터 패키지를 템플릿 삼아
직접 어댑터를 작성**하는 편이 더 빠릅니다. 정식 배포를 기다리지 않아도
됩니다.

- 로드맵에 있는 광고망(Pangle/AppLovin/DT 등)을 **지금 당장** 붙여야 할 때
- 제공 패키지에 아예 없는 광고망(예: 사내 광고 서버, 자체 네트워크)을
  연결할 때
- 제공 어댑터의 동작이 마음에 들지 않아 **포크해서 커스터마이즈** 하고
  싶을 때 (예: AdMob 배너 adaptive size 정책 변경, 호출 옵션 추가)
- 제공 어댑터가 다루지 않는 **포맷** 이 필요할 때 (예: AdFit 비디오,
  AdMob 보상형 비디오)

어댑터는 공개 프로토콜 4개(`EBBannerMediationAdapter` /
`EBInterstitialMediationAdapter` / `EBNativeMediationAdapter` /
`EBVideoMediationAdapter`) 중 필요한 것만 구현하면 되므로 — 제공 패키지와
**완전히 동일한 방식** 으로 누구나 만들 수 있습니다. 마법은 없으며 모든
계약이 이 문서에 공개되어 있습니다.

### 작성 워크플로 — 5단계

1. **가장 가까운 제공 어댑터를 골라 복사한다.** 풀스크린 SDK 래핑이면
   AdMob(전면/비디오), 단순 등록 패턴이면 FAN/AdFit, `#if canImport`
   가드가 필요하면 FAN. 자세한 매핑은 §"참고: 제공 어댑터 코드" 참고.
2. **`networkID` 를 서버 응답과 합의한다.** 운영팀이 워터폴에 내려주는
   `id` 와 한 글자라도 다르면 `.adapterNotRegistered` 로 스킵됩니다.
   §2 참고.
3. **포맷별 프로토콜을 구현한다.** §3 의 공통 계약 (`load(throw)` / `cancel`
   / `timeout` / 단일 resume 가드 / UIKit 메인 스레드) 을 지키고, 포맷별
   섹션(§4–§7) 의 골격 코드를 따라 채웁니다.
4. **모듈로 묶어 등록한다** — §8 의 `EBMediationModule` 패턴으로 한 번에
   등록. 같은 `networkID` 로 재등록하면 제공 어댑터를 자기 구현으로 교체할
   수도 있습니다(§9).
5. **워터폴 이벤트로 검증한다.** `EBWaterfallEvent` 로그를 흘려보내
   `adapterNotRegistered` / `loadFailed` / `timeout` 가 어디서 잡히는지
   확인 (§10). 등록 자체는 §12 의 테스트 패턴으로 단위 테스트할 수 있습니다.

### 이 문서가 답하는 질문

| 질문 | 섹션 |
|---|---|
| 미디에이션이 내 어댑터를 어떻게 호출하나? | [§1 구조](#1-미디에이션-구조-한눈에-보기) |
| 어댑터 패키지는 어떻게 구성하나? | [§2 패키지 구성](#2-패키지-구성) |
| 어댑터가 반드시 지켜야 할 계약은? | [§3 공통 계약](#3-어댑터가-지켜야-하는-공통-계약) |
| 포맷별 골격 코드는? | [§4 배너](#4-배너-어댑터) · [§5 전면](#5-전면인터스티셜-어댑터) · [§6 비디오](#6-비디오-어댑터) · [§7 네이티브](#7-네이티브-어댑터) |
| 여러 포맷을 한 번에 등록하려면? | [§8 모듈로 묶기](#8-어댑터를-모듈로-묶기) |
| 호스트 앱에서 어떻게 등록하나? | [§9 호스트 등록](#9-호스트-앱에서-등록) |
| 어떤 워터폴 이벤트를 보고 디버깅하나? | [§10 워터폴/텔레메트리](#10-워터폴-연동과-텔레메트리) |
| 다 만든 뒤 빠뜨린 게 있는지 확인하려면? | [§11 체크리스트](#11-구현-체크리스트) |
| 등록 동작을 단위 테스트하려면? | [§12 테스트](#12-테스트) |

> 미디에이션의 전체 동작 원리와 **호스트 측 사용법** (퍼사드 API, 콜백,
> 모듈 등록 위치 등) 은 [`README.md`](./README.md) §미디에이션 을 먼저
> 읽으면 §1 이 더 빨리 이해됩니다.

---

## 1. 미디에이션 구조 한눈에 보기

```
호스트 앱
  └─ EBMediatedBannerAd / …Interstitial / …Native / …Video   (퍼사드)
        └─ 워터폴 오케스트레이터   (SDK 내부: 폴백 · 타임아웃 · 텔레메트리)
              └─ 서버 워터폴 응답 [EBMediationEntry] (우선순위 순)
                    └─ networkID 로 레지스트리에서 어댑터 조회
                          └─ [당신이 만드는] 커스텀 어댑터
                                └─ 서드파티 / 사내 광고 SDK
```

오케스트레이터가 **폴백·타임아웃·등록·텔레메트리**를 모두 담당합니다.
어댑터가 할 일은 단 하나입니다:

> "광고 단위 ID를 받아 해당 광고망의 광고를 로드/표시하고, 결과를
> 콜백으로 알린다. 서드파티 델리게이트를 SDK 콜백으로 브리징한다."

모든 제공 어댑터(AdMob/FAN/AdFit)가 정확히 이 한 가지 일만 합니다.

---

## 2. 패키지 구성

커스텀 어댑터는 보통 **별도 SwiftPM 타깃/패키지**로 만들고 `ExelBidSDK`
를 의존성으로 둡니다. 제공 패키지의 `Package.swift` 와 동일한 형태입니다.

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MyNetworkAdapter",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "MyNetworkAdapter", targets: ["MyNetworkAdapter"]),
    ],
    dependencies: [
        // ExelBid SDK 3.x
        .package(url: "https://github.com/onnuridmc/ExelBid_iOS_Swift",
                 .upToNextMajor(from: "3.0.0")),
        // + 연동할 서드파티 광고 SDK (SwiftPM 미제공이면 호스트가 직접 링크)
    ],
    targets: [
        .target(
            name: "MyNetworkAdapter",
            dependencies: [
                .product(name: "ExelBidSDK", package: "ExelBidSDK"),
                // .product(name: "MyNetworkSDK", package: "...")
            ]
        ),
    ]
)
```

```swift
import ExelBidSDK     // 미디에이션 프로토콜은 코어 타깃에 포함됨
import UIKit
```

> 미디에이션 API(`EB*MediationAdapter`, `EBMediationRegistry`,
> `ExelBidMediationKit`, `EBMediationModule` 등)는 모두 `ExelBidSDK`
> 모듈에 있습니다. `import ExelBidSDK` 한 줄이면 됩니다.

### `networkID` 규칙

각 어댑터에는 고유 `networkID` 문자열이 있습니다. 이 값은 **서버 워터폴
응답의 `id` 필드와 정확히 일치**해야 오케스트레이터가 해당 순번에서
어댑터를 찾습니다.

서버가 내려주는 주요 `networkID` 와 광고망은 다음과 같습니다.

| `networkID` | 광고망 |
|---|---|
| `exelbid` | ExelBid |
| `admob` | Google AdMob |
| `adsense` | Google AdSense |
| `adfit` | Kakao AdFit |
| `dt` | Digital Turbine |
| `mp` | MPartners |

직접 만드는 광고망의 `networkID` 는 서버 응답 `id` 와 일치하도록 운영팀과
합의하세요. 어댑터의 `networkID` 와 서버 `id` 가 한 글자라도 다르면 해당
순번은 `.adapterNotRegistered` 로 건너뜁니다.

---

## 3. 어댑터가 지켜야 하는 공통 계약

포맷별 프로토콜(`EBBannerMediationAdapter` /
`EBInterstitialMediationAdapter` / `EBNativeMediationAdapter` /
`EBVideoMediationAdapter`)은 모양이 조금씩 다르지만 다음은 공통입니다.

| 멤버 | 의미 |
|---|---|
| `static var networkID: String` | 서버 `id` 와 일치하는 고유 식별자 |
| `static var isAvailable: Bool` | 런타임에 서드파티 SDK 링크 가능 여부. 하드 의존이면 항상 `true` |
| `init()` | 인자 없는 생성자. 오케스트레이터가 순번마다 새 인스턴스 생성 |
| `func load(... timeout:) async throws` | 로드 시작. **실패 시 `throw`** → 워터폴이 다음 광고망으로 진행 |
| `func cancel()` | 진행 중 로드 중단, 자원/델리게이트 해제 |
| `var onClick / onLeaveApp / …` | 서드파티 델리게이트를 SDK 콜백으로 브리징 |

핵심 원칙 (제공 어댑터가 모두 따르는 규약):

- **`throw` 로 워터폴을 진행시킨다.** 로드 실패는 에러를 던지면 끝. 폴백은
  오케스트레이터가 처리합니다.
- **`timeout` 을 존중한다.** 오케스트레이터도 타임아웃을 강제하지만,
  서드파티 SDK에 자체 타임아웃이 있으면 전달값으로 맞춰 자원을 정리하세요.
- **`cancel()` 에서 깔끔히 해제한다.** 진행 중 요청 취소 + 델리게이트/
  continuation 해제.
- **continuation 은 단 한 번만 resume.** `async throws` 를
  `withCheckedThrowingContinuation` 으로 브리징할 때 중복 호출돼도 한
  번만 resume 되도록 `resumed` 가드를 둡니다. (모든 제공 어댑터가 동일
  패턴)
- **UIKit 작업은 메인 스레드에서.** 뷰 생성·표시는 `DispatchQueue.main`.
- **콜백 클로저는 `[weak self]`** 로 순환 참조 방지.

---

## 4. 배너 어댑터

`load(...)` 가 렌더된 `UIView` 를 반환합니다. 아래는 제공 AdMob/AdFit
배너 어댑터와 동일한 골격입니다.

```swift
import Foundation
import UIKit
import ExelBidSDK
#if canImport(MyNetworkSDK)
import MyNetworkSDK

public final class MyNetworkBannerAdapter: NSObject, EBBannerMediationAdapter {

    public static let networkID = "mynetwork"      // 서버 id 와 일치
    public static var isAvailable: Bool { true }

    public var onClick: (() -> Void)?
    public var onLeaveApp: (() -> Void)?
    public var onClickFinish: (() -> Void)?

    private var bannerView: MNBannerView?
    private var continuation: CheckedContinuation<UIView, Error>?
    private var resumed = false

    public override init() { super.init() }

    public func load(
        unitId: String,
        size: CGSize,
        rootViewController: UIViewController?,
        timeout: TimeInterval
    ) async throws -> UIView {
        return try await withCheckedThrowingContinuation { cont in
            self.continuation = cont
            self.resumed = false
            DispatchQueue.main.async {
                let banner = MNBannerView(size: size)
                banner.placementID = unitId
                banner.rootViewController = rootViewController
                banner.delegate = self
                banner.load()
                self.bannerView = banner
            }
        }
    }

    public func cancel() {
        bannerView?.delegate = nil
        bannerView = nil
        resume(throwing: CancellationError())
    }

    private func resume(returning view: UIView) {
        guard !resumed else { return }; resumed = true
        continuation?.resume(returning: view); continuation = nil
    }
    private func resume(throwing error: Error) {
        guard !resumed else { return }; resumed = true
        continuation?.resume(throwing: error); continuation = nil
    }
}

// 서드파티 델리게이트 → SDK 콜백 브리징
extension MyNetworkBannerAdapter: MNBannerViewDelegate {
    public func bannerDidLoad(_ v: MNBannerView)          { resume(returning: v) }
    public func banner(_ v: MNBannerView, fail e: Error)  { resume(throwing: e) }
    public func bannerDidClick(_ v: MNBannerView)         { onClick?() }
    public func bannerWillLeaveApp(_ v: MNBannerView)     { onLeaveApp?() }
    public func bannerDidDismiss(_ v: MNBannerView)       { onClickFinish?() }
}

#else
// 서드파티 SDK 미링크 환경(SwiftPM-only 등)에서도 컴파일되도록 no-op 플레이스홀더.
// 호스트가 실제 SDK를 링크하면 위 구현이 자동 활성화됩니다.
public final class MyNetworkBannerAdapter: NSObject, EBBannerMediationAdapter {
    public static let networkID = "mynetwork"
    public static var isAvailable: Bool { false }
    public var onClick: (() -> Void)?
    public var onLeaveApp: (() -> Void)?
    public var onClickFinish: (() -> Void)?
    public override init() { super.init() }
    public func load(unitId: String, size: CGSize,
                     rootViewController: UIViewController?,
                     timeout: TimeInterval) async throws -> UIView {
        throw NSError(domain: "MyNetworkAdapter", code: -1)   // sdkNotLinked
    }
    public func cancel() {}
}
#endif
```

> **`#if canImport` 패턴**: 제공 FAN/AdFit 어댑터가 쓰는 방식입니다. 이
> 광고망 SDK가 SwiftPM으로 제공되지 않으면(FAN·AdFit이 그렇습니다),
> 어댑터 패키지에서는 `isAvailable == false` 인 no-op 으로 컴파일되고,
> 호스트가 CocoaPods/바이너리로 SDK를 직접 링크하면 실제 구현이 켜집니다.
> AdMob처럼 SwiftPM으로 항상 링크되는 하드 의존이면 `#if` 없이 작성하고
> `isAvailable` 을 `true` 로 두면 됩니다.

---

## 5. 전면(인터스티셜) 어댑터

전면은 **2단계** 입니다 — `load(...)` 는 준비되면 반환(`Void`)하고, 표시는
`present(from:)` 에서 합니다. 생명주기 콜백(`onWillAppear` /
`onDidAppear` / `onWillDisappear` / `onDidDisappear`)을 **반드시** 발사해
호스트 UI 흐름을 구동해야 합니다.

```swift
public final class MyNetworkInterstitialAdapter: NSObject, EBInterstitialMediationAdapter {

    public static let networkID = "mynetwork"
    public static var isAvailable: Bool { true }

    public var onWillAppear: (() -> Void)?
    public var onDidAppear: (() -> Void)?
    public var onWillDisappear: (() -> Void)?
    public var onDidDisappear: (() -> Void)?
    public var onClick: (() -> Void)?
    public var onLeaveApp: (() -> Void)?
    public var onClickFinish: (() -> Void)?

    private var interstitial: MNInterstitial?
    private var continuation: CheckedContinuation<Void, Error>?
    private var resumed = false

    public override init() { super.init() }

    public func load(
        unitId: String,
        rootViewController: UIViewController?,
        timeout: TimeInterval
    ) async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            self.continuation = cont; self.resumed = false
            let ad = MNInterstitial(placementID: unitId)
            ad.delegate = self
            ad.load()
            self.interstitial = ad
        }
    }

    public func present(from viewController: UIViewController) {
        interstitial?.present(from: viewController)
    }

    public func cancel() {
        interstitial?.delegate = nil
        interstitial = nil
        resume(throwing: CancellationError())
    }

    private func resume() {
        guard !resumed else { return }; resumed = true
        continuation?.resume(returning: ()); continuation = nil
    }
    private func resume(throwing error: Error) {
        guard !resumed else { return }; resumed = true
        continuation?.resume(throwing: error); continuation = nil
    }
}

extension MyNetworkInterstitialAdapter: MNInterstitialDelegate {
    public func interstitialDidLoad(_ ad: MNInterstitial)            { resume() }
    public func interstitial(_ ad: MNInterstitial, fail e: Error)    { resume(throwing: e) }
    public func interstitialWillShow(_ ad: MNInterstitial)           { onWillAppear?() }
    public func interstitialDidShow(_ ad: MNInterstitial)            { onDidAppear?() }
    public func interstitialWillClose(_ ad: MNInterstitial)          { onWillDisappear?() }
    public func interstitialDidClose(_ ad: MNInterstitial)           { onDidDisappear?() }
    public func interstitialDidClick(_ ad: MNInterstitial)           { onClick?() }
}
```

---

## 6. 비디오 어댑터

전면과 동일한 2단계 구조에 **VAST 사분위 진행률 `onProgress`** 가
추가됩니다. (AdFit처럼 제공 어댑터가 비디오를 지원하지 않는 광고망이라면,
이 커스텀 비디오 어댑터가 바로 "직접 만들어 쓰는" 대표 사례입니다.)

> ExelBid 외 네트워크에서 video 포맷은 **전면(인터스티셜) 비디오**를
> 의미합니다(보상형 아님). 제공 AdMob/FAN 비디오 어댑터는 각각
> `InterstitialAd` / `FBInterstitialAd` 를 래핑합니다 — 즉 전면 어댑터와
> 동일한 풀스크린 API에 `onProgress` 만 더한 형태입니다. 보상형(rewarded)
> 포맷이 필요하면 별도 커스텀 어댑터로 구현하세요.
>
> AdMob 전면 슬롯은 **디스플레이(배너/이미지)·비디오 크리에이티브를 같은
> `InterstitialAd` 객체로** 재생합니다(SDK 레벨에서 "비디오만" 요청 불가 —
> 광고 유닛 설정이 결정). 그래서 제공 AdMob 어댑터는 전면/비디오 두 포맷이
> 공유 드라이버 `AdMobFullScreenAd`(load/present + `FullScreenContentDelegate`
> 브리징)를 함께 쓰고, 각 어댑터는 포맷별 콜백(`onClickFinish` /
> `onProgress`)만 얇게 연결합니다. 같은 풀스크린 SDK를 두 포맷에 쓰는
> 네트워크라면 이 패턴을 참고하세요.

```swift
public final class MyNetworkVideoAdapter: NSObject, EBVideoMediationAdapter {

    public static let networkID = "mynetwork"
    public static var isAvailable: Bool { true }

    public var onWillAppear: (() -> Void)?
    public var onDidAppear: (() -> Void)?
    public var onWillDisappear: (() -> Void)?
    public var onDidDisappear: (() -> Void)?
    public var onClick: (() -> Void)?
    public var onLeaveApp: (() -> Void)?
    public var onProgress: ((Int) -> Void)?     // 0 / 25 / 50 / 75 / 100

    // load / present / cancel 은 전면 어댑터와 동일한 2단계 패턴.
    // 재생 진행에 맞춰 onProgress 를 발사합니다.
}
```

> `onProgress` 의 각 값은 **재생당 최대 1회**만 발사하세요. 사분위 추적이
> 어려운 광고망이라면 최소한 재생 시작에 `onProgress(0)`, 완료에
> `onProgress(100)` 만이라도 보내야 호스트가 사분위를 집계할 수 있습니다.

---

## 7. 네이티브 어댑터

네이티브는 다른 포맷과 다릅니다. SDK가 완성된 뷰를 돌려주는 게 아니라,
**호스트가 직접 에셋을 렌더링**한 뒤 그 뷰를 어댑터에 다시 등록해
서드파티 SDK가 클릭·노출 계측을 붙입니다.

핵심 계약:

- `load(...)` 는 광고망 에셋을 v3의 **`EBNativeAdModel`** 로 정규화해
  반환합니다. 그래야 호스트가 광고망과 무관하게 동일한
  `EBNativeAdRendering` 화면으로 렌더링할 수 있습니다.
- `bind(view:viewController:)` — 호스트가 모델을 뷰로 렌더링한 뒤
  호출됩니다. 렌더된 뷰를 서드파티 SDK에 등록해 클릭·노출 계측을 연결.
  - `view` 는 호출 시점에 **이미 뷰 계층에 있고**(superview 존재),
    텍스트/이미지 슬롯은 `StaticNativeRenderer` 가 이미 채운 상태입니다.
  - 미디에이션 네이티브는 SDK가 **자체 클릭 제스처를 설치하지 않습니다.**
    클릭은 전적으로 어댑터/네트워크가 소유합니다.
- `unbind()` — 호스트가 `detach()` 하거나 광고가 해제될 때 등록 해제.

광고망마다 뷰를 다루는 방식이 다릅니다. 세 가지 바인딩 모드로 정리됩니다:

| 모드 | 누가 채우나 | 적용 예 | 필요한 슬롯 |
|---|---|---|---|
| **직접 등록** | SDK가 채움 → 어댑터는 뷰 통째 register | FAN(텍스트), AdFit, 자사 | 기존 슬롯 |
| **아웃렛 매핑** | SDK가 채움 + 어댑터가 슬롯↔네트워크 아웃렛 연결 | AdMob | 기존 슬롯 + CTA |
| **네트워크-렌더 미디어** | 네트워크가 미디어 뷰를 직접 그림, 호스트는 빈 컨테이너만 제공 | AdMob `GADMediaView`, FAN `FBMediaView` | `nativeMediaView()` |

호스트 렌더링 뷰는 **완성된 결과가 아니라 슬롯 레이아웃**입니다.
`EBNativeAdRendering` 의 슬롯(텍스트 / 아이콘 / 로고 + 메인 크리에이티브
단일 슬롯 `nativeMediaView()` + `nativeAdChoicesView()`)을 어댑터가 자기
네트워크 방식대로 바인딩합니다. 메인 이미지/동영상은 모두
`nativeMediaView()` 하나로 그려집니다(별도 메인 이미지 슬롯 없음).

### 상속 문제는 합성으로 — `EBNativeAdContainerReparenter`

AdMob은 에셋이 반드시 `NativeAdView` 서브트리에 있어야 하는데, 호스트
뷰가 `NativeAdView` 를 상속할 수는 없습니다(FAN `FBNativeAdView` 와
동시 상속 불가). 그래서 **상속이 아니라 합성**으로 풉니다 — `bind()`
에서 호스트 뷰를 네트워크 컨테이너로 **그 자리에 재부모(reparent)**
합니다. SDK가 공유 헬퍼를 제공합니다:

```swift
let wrapper = NativeAdView(frame: view.frame)
guard EBNativeAdContainerReparenter.wrap(view, in: wrapper) else { return }
// view 의 원래 위치/제약/프레임을 wrapper 가 그대로 인계받고,
// view 는 wrapper 를 채우도록 핀 처리됩니다. superview 가 없으면 false.
```

FAN / AdFit 은 wrapping 없이 `registerView(...)` / `register(view:)`
로 제자리 등록만 하므로 이 헬퍼가 필요 없습니다.

### 미디어 소유권 규칙

`nativeMediaView()` 는 메인 크리에이티브의 **유일한 슬롯**입니다(별도
`nativeMainImageView()` 슬롯은 제거됨). 어댑터는 이 슬롯에 자기 네트워크
미디어 뷰(AdMob `MediaView`, FAN `FBMediaView`)를 꽂으며, URL 전용
네트워크(AdFit)는 자체 `UIImageView` 를 만들어 이 슬롯에 넣습니다. 호스트가
슬롯을 제공하지 않으면 메인 미디어는 표시되지 않습니다(텍스트/아이콘만).
자사(`exelbid`) 광고도 동일하게 이 슬롯을 사용하며, 응답에 동영상(VAST)이
있으면 SDK가 이 슬롯에서 인라인 재생합니다(`StaticNativeRenderer` 는 메인
크리에이티브를 다루지 않고 텍스트/아이콘/로고/privacy 만 처리).

> **AdMob 주의**: 메인 이미지/동영상은 반드시 `MediaView` 로
> 표시해야 합니다. `imageView` 아웃렛을 쓰면
> *"MediaView not used for main image or video asset"* 경고가 뜨고
> 동영상도 못 그립니다. 또 등록한 에셋 뷰는 모두 `NativeAdView` 경계
> 안에 있어야 하며(*"Advertiser assets outside native ad view"*),
> `nativeAd` 할당 직전에 `layoutIfNeeded()` 로 레이아웃을 확정해야
> 합니다. 제공 `AdMobNativeAdapter.bind` 참고.

### `EBNativeAdModel` 만들기 — JSON 정규화 패턴

`EBNativeAdModel` 은 `Decodable` 입니다. 따라서 별도 모듈에서도 광고망
에셋을 **ExelBid 네이티브 스키마 형태의 JSON 딕셔너리로 만든 뒤
`JSONDecoder` 로 디코딩**해 생성합니다. 제공 AdMob 네이티브 어댑터가
쓰는 실제 방식입니다.

주요 키: `title` / `desc` / `desc2` / `ctatext` / `sponsored` /
`displayurl` / `price` / `saleprice` / `rating` / `icon` / `main` /
`logo` / `video` 등 (`EBNativeAdModel` 의 프로퍼티명과 동일).

```swift
public final class MyNetworkNativeAdapter: NSObject, EBNativeMediationAdapter {

    public static let networkID = "mynetwork"
    public static var isAvailable: Bool { true }

    public var onImpression: (() -> Void)?
    public var onImpression50: (() -> Void)?
    public var onImpression100: (() -> Void)?
    public var onClick: (() -> Void)?
    public var onLeaveApp: (() -> Void)?
    public var onClickFinish: (() -> Void)?

    private var nativeAd: MNNativeAd?
    private var continuation: CheckedContinuation<EBNativeAdModel, Error>?
    private var resumed = false

    public override init() { super.init() }

    public func load(
        unitId: String,
        desiredAssets: Set<EBNativeAsset>,
        rootViewController: UIViewController?,
        timeout: TimeInterval
    ) async throws -> EBNativeAdModel {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<EBNativeAdModel, Error>) in
            self.continuation = cont; self.resumed = false
            // 서드파티 네이티브 광고 로드 → 델리게이트에서 normalise 후 resume
            // …
        }
    }

    public func bind(view: UIView, viewController: UIViewController?) {
        // 렌더된 view 를 서드파티 SDK에 등록 → 클릭·노출 계측 연결.
        // 계측 콜백이 오면 onImpression / onClick 등을 발사합니다.
    }

    public func unbind() { /* 등록 해제 */ }
    public func cancel() { resume(throwing: CancellationError()) }

    /// 광고망 에셋 → EBNativeAdModel (JSON 정규화)
    private func normalise(_ ad: MNNativeAd) -> EBNativeAdModel {
        var payload: [String: Any] = [:]
        if let v = ad.title    { payload["title"]   = v }
        if let v = ad.body     { payload["desc"]    = v }
        if let v = ad.cta      { payload["ctatext"] = v }
        if let v = ad.iconURL  { payload["icon"]    = v }
        if let v = ad.imageURL { payload["main"]    = v }
        let data = (try? JSONSerialization.data(withJSONObject: payload)) ?? Data("{}".utf8)
        return (try? JSONDecoder().decode(EBNativeAdModel.self, from: data))
            ?? (try! JSONDecoder().decode(EBNativeAdModel.self, from: Data("{}".utf8)))
    }

    private func resume(returning model: EBNativeAdModel) {
        guard !resumed else { return }; resumed = true
        continuation?.resume(returning: model); continuation = nil
    }
    private func resume(throwing error: Error) {
        guard !resumed else { return }; resumed = true
        continuation?.resume(throwing: error); continuation = nil
    }
}
```

> 위 `bind(view:)` 는 골격입니다. 네트워크별 실제 구현(reparenter,
> 미디어 슬롯, 아웃렛, `registerView`)은 위 **"상속 문제는 합성으로"**·
> **"미디어 소유권 규칙"** 절과 제공 `AdMobNativeAdapter.bind` /
> `FANNativeAdapter.bind` 를 참고하세요.

---

## 8. 어댑터를 모듈로 묶기

여러 포맷 어댑터를 하나의 **미디에이션 모듈**로 묶어 한 번에 등록합니다.
`EBMediationModule` 의 `register(in:)` 만 구현하면 됩니다. (제공
`AdMobMediationModule` / `AdFitMediationModule` 과 동일한 형태)

```swift
import ExelBidSDK

public enum MyNetworkMediationModule: EBMediationModule {
    public static func register(in registry: EBMediationRegistry) {
        registry.register(banner: MyNetworkBannerAdapter.self)
        registry.register(interstitial: MyNetworkInterstitialAdapter.self)
        registry.register(native: MyNetworkNativeAdapter.self)
        registry.register(video: MyNetworkVideoAdapter.self)
    }
}
```

특정 포맷만 지원하면 해당 `register(...)` 만 호출하면 됩니다. (AdFit
모듈이 비디오를 등록하지 않는 것과 같습니다.)

---

## 9. 호스트 앱에서 등록

호스트는 앱 시작 시 한 번, 사용할 모듈들을 등록합니다 (보통
`application(_:didFinishLaunchingWithOptions:)`).

```swift
import ExelBidSDK

ExelBidMediationKit.shared.register(modules: [
    ExelBidBuiltInMediationModule.self,   // 인하우스(exelbid)
    AdMobMediationModule.self,            // 제공 어댑터
    MyNetworkMediationModule.self,        // 직접 만든 어댑터
])
```

- 등록은 **명시적**입니다. 자동 등록 마법은 없습니다 — 등록하지 않은
  광고망은 서버 워터폴에 나와도 건너뜁니다.
- 단일 어댑터만 빠르게 등록하려면 `ExelBidMediationKit.shared.registry`
  로 `register(banner:)` 등을 직접 호출해도 됩니다.
- 등록은 **멱등**입니다. 같은 `networkID` 를 다시 등록하면 덮어씁니다.
  → **제공 어댑터를 직접 만든 어댑터로 교체**하려면, 같은 `networkID`
  (`"admob"` 등)로 당신의 모듈을 나중에 등록하면 됩니다.

---

## 10. 워터폴 연동과 텔레메트리

- 서버는 시도할 광고망 목록을 우선순위 순서의 `[EBMediationEntry]` 로
  내려줍니다. 각 항목의 `networkID` 가 등록된 어댑터의 `networkID` 와
  일치해야 호출됩니다.
- 오케스트레이터는 각 단계에서 `EBWaterfallEvent` 를 발사합니다. 호스트가
  이를 분석 파이프라인으로 전달해 어떤 광고망이 채웠는지, 왜 실패했는지,
  단계별 지연시간을 감사할 수 있습니다.

주의할 실패 사유:

| `EBWaterfallFailReason` | 의미 / 대응 |
|---|---|
| `.adapterNotRegistered` | 서버가 내려준 `networkID` 에 등록된 어댑터 없음 → 모듈 등록 누락 또는 `networkID` 불일치 |
| `.loadFailed(Error)` | 어댑터 `load` 가 던진 서드파티 에러 |
| `.timeout(TimeInterval)` | 어댑터가 할당 시간 초과 |
| `.cancelled` | 호스트가 `stop()` 또는 뷰 제거로 취소 |

> `networkID` 오타나 서버 `id` 불일치는 가장 흔한 연동 실수입니다. 광고가
> 안 채워지면 워터폴 이벤트에 `.adapterNotRegistered` 가 뜨는지 먼저
> 확인하세요. `isAvailable == false`(서드파티 SDK 미링크)인 어댑터도
> 등록되지 않은 것으로 처리됩니다.

---

## 11. 구현 체크리스트

- [ ] `networkID` 가 서버 워터폴 `id` 와 정확히 일치한다.
- [ ] `isAvailable` 이 실제 링크 가능 여부를 반영한다(`#if canImport`).
- [ ] `load` 는 실패 시 `throw` 한다(폴백은 오케스트레이터가 처리).
- [ ] 전달받은 `timeout` 을 서드파티 SDK 타임아웃에 반영한다.
- [ ] `cancel()` 에서 진행 중 요청·델리게이트·continuation 을 해제한다.
- [ ] continuation 은 단 한 번만 resume 된다(`resumed` 가드).
- [ ] 전면/비디오는 `onWillAppear` ~ `onDidDisappear` 생명주기를 모두 발사한다.
- [ ] 비디오는 최소 `onProgress(0)` / `onProgress(100)` 을 발사한다.
- [ ] 네이티브는 에셋을 `EBNativeAdModel` 로 정규화(JSON 디코딩)해 반환한다.
- [ ] UIKit 작업은 메인 스레드에서 수행한다.
- [ ] 콜백 클로저에서 `[weak self]` 로 순환 참조를 피한다.

---

## 12. 테스트

테스트에서 깨끗한 레지스트리가 필요하면 공개 테스트 전용 리셋을
사용합니다(프로덕션 코드에서는 호출 금지). 제공 패키지의
`AdapterRegistrationTests` 와 동일한 방식입니다.

```swift
EBMediationRegistry.shared.removeAllForTesting()
MyNetworkMediationModule.register(in: .shared)
XCTAssertEqual(
    EBMediationRegistry.shared.bannerAdapter(for: "mynetwork")?.networkID,
    "mynetwork"
)
```

---

## 참고: 제공 어댑터 코드 (직접 만들 때의 템플릿)

직접 만들 때는 가장 가까운 제공 어댑터를 복사해 시작하는 것이 가장
빠릅니다. 제공 어댑터 패키지(`ExelBid_iOS_Mediation_Adapter`)는
광고망별로 하나의 SwiftPM 프로덕트를 제공합니다.

| 광고망 | 프로덕트 | 포맷 |
|---|---|---|
| AdMob | `ExelBidMediationAdMob` | 배너 / 전면 / 네이티브 / 비디오 (SwiftPM 하드 의존) |
| FAN | `ExelBidMediationFAN` | 배너 / 전면 / 네이티브 / 비디오 (`#if canImport(FBAudienceNetwork)`) |
| AdFit | `ExelBidMediationAdFit` | 배너 / 전면 / 네이티브 (`#if canImport(AdFitSDK)`, 비디오 없음) |

- 호스트 측 사용법: [`README.md`](./README.md) §미디에이션
