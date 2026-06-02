# ExelBid iOS SDK — MPartners 연동 가이드 (Swift)

MPartners는 일반 ExelBid 광고와는 다른 별도 광고망입니다. SDK 설치와
앱 설정은 [`README.md`](./README.md)와 동일하며, 본 문서는
MPartners 전용 클래스 사용법만 다룹니다. Objective-C 사용자는
[`MPARTNERS_OBJC.md`](./MPARTNERS_OBJC.md)를 참고하세요.

## 개요

- 일반 광고와 동일한 모듈(`ExelBidSDK`)에서 제공됩니다.
- 클래스 이름이 `EBMPartners` 프리픽스로 구분됩니다.
- 일반 광고와 별도의 광고 단위 ID를 사용합니다.
- 배너 / 전면 / 네이티브 세 포맷을 지원합니다.

## 목차

- [배너](#배너)
- [전면](#전면)
- [네이티브](#네이티브)

---

## 배너

```swift
import ExelBidSDK

let banner = EBMPartnersBannerAd(
    adUnitId: "YOUR_MPARTNERS_BANNER_UNIT_ID",
    size: CGSize(width: 320, height: 50)
)
banner.onLoad = { print("MPartners 배너 로드") }
banner.onFail = { error in print(error) }
view.addSubview(banner)
banner.load()
```

> `EBBannerAd`와 동일한 API이지만 `autoRefresh` 속성은 없습니다.
> (`fullWebView` 등 나머지 옵션은 동일하게 사용할 수 있습니다.)

---

## 전면

```swift
let interstitial = EBMPartnersInterstitialAd(adUnitId: "YOUR_UNIT_ID")
interstitial.onLoad = { interstitial.present(from: self) }
interstitial.onFail = { error in print(error) }
interstitial.load()
```

`EBInterstitialAd`와 동일하게 `load()` → `present(from:)` 2단계
사용 방식이며, 한 번 노출하면 단발성으로 종료됩니다. `fullWebView`
옵션도 동일하게 지원합니다.

---

## 네이티브

```swift
let loader = EBMPartnersNativeAdLoader(adUnitId: "YOUR_UNIT_ID")
loader.desiredAssets = [.title, .icon, .main, .ctatext]
loader.load { ad, error in
    guard let ad = ad else { return }
    let adView = MyNativeAdView()
    ad.attach(to: adView)
    self.container.addSubview(adView)
}
```

`EBNativeAdLoader`와 동일하게 `EBNativeAdRendering` 뷰를 그대로
재사용할 수 있습니다. 렌더링 뷰 작성과 사용 가능한 에셋 목록은
[`README.md`의 네이티브 광고 섹션](./README.md#네이티브-광고)을
참고하세요.

---

공통 옵션(`EBAdOptions`)과 에러 처리(`EBAdError`)는 일반 광고와
동일하게 동작합니다. 자세한 내용은
[`README.md`](./README.md)의 해당 섹션을 참고하세요.
