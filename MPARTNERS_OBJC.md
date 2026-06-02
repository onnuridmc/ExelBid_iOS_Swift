# ExelBid iOS SDK — MPartners 연동 가이드 (Objective-C)

MPartners는 일반 ExelBid 광고와는 다른 별도 광고망입니다. SDK 설치와
앱 설정은 [`INTEGRATION_OBJC.md`](./INTEGRATION_OBJC.md)와 동일하며,
본 문서는 MPartners 전용 클래스 사용법만 다룹니다. Swift 사용자는
[`MPARTNERS.md`](./MPARTNERS.md)를 참고하세요.

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

```objc
EBMPartnersBannerAd *banner =
    [[EBMPartnersBannerAd alloc] initWithAdUnitId:@"YOUR_MPARTNERS_UNIT_ID"
                                             size:CGSizeMake(320, 50)];
banner.onLoad         = ^{ NSLog(@"MPartners 배너 로드"); };
banner.onFailureBlock = ^(NSError *error) { NSLog(@"%@", error); };
[self.view addSubview:banner];
[banner load];
```

> `EBBannerAd`와 동일한 API이지만 `autoRefresh` 속성은 없습니다.
> (`fullWebView` 등 나머지 옵션은 동일하게 사용할 수 있습니다.)

---

## 전면

```objc
EBMPartnersInterstitialAd *interstitial =
    [[EBMPartnersInterstitialAd alloc] initWithAdUnitId:@"YOUR_UNIT_ID"];

__weak typeof(self) weakSelf = self;
interstitial.onLoad = ^{
    [interstitial presentFrom:weakSelf];
};
interstitial.onFailureBlock = ^(NSError *error) { NSLog(@"%@", error); };
[interstitial load];
```

`EBInterstitialAd`와 동일하게 `load` → `presentFrom:` 2단계 사용
방식이며, 한 번 노출하면 단발성으로 종료됩니다. `fullWebView`
옵션도 동일하게 지원합니다.

---

## 네이티브

```objc
EBMPartnersNativeAdLoader *loader =
    [[EBMPartnersNativeAdLoader alloc] initWithAdUnitId:@"YOUR_UNIT_ID"];
loader.desiredAssetsArray = @[
    @(EBNativeAssetTitle),
    @(EBNativeAssetIcon),
    @(EBNativeAssetMain),
    @(EBNativeAssetCtatext)
];

__weak typeof(self) weakSelf = self;
[loader loadWithCompletion:^(EBNativeAd * _Nullable ad, NSError * _Nullable error) {
    if (!ad) return;
    MyNativeAdView *adView = [[MyNativeAdView alloc] init];
    [ad attachTo:adView];
    [weakSelf.container addSubview:adView];
}];
```

`EBNativeAdLoader`와 동일하게 `EBNativeAdRendering` 뷰를 그대로
재사용할 수 있습니다. 렌더링 뷰 작성과 사용 가능한 에셋 목록은
[`INTEGRATION_OBJC.md`의 네이티브 광고 섹션](./INTEGRATION_OBJC.md#네이티브-광고)을
참고하세요.

---

공통 옵션(`EBAdOptions`)과 에러 처리(`NSError` /
`ExelBidSDKErrorDomain` / `AdErrorCode`)는 일반 광고와 동일하게
동작합니다. 자세한 내용은 [`INTEGRATION_OBJC.md`](./INTEGRATION_OBJC.md)의
해당 섹션을 참고하세요.
