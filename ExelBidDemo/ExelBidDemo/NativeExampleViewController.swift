import UIKit
import ExelBidSDK

final class NativeExampleViewController: UIViewController {

    private let badge = StatusBadge()
    private let logView = LogView()
    private let options = TestOptionsPanel()
    private let videoSwitch = UISwitch()
    private let adContainer = UIView()
    private var loadedAd: EBNativeAd?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Native"

        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.alwaysBounceVertical = true
        view.addSubview(scroll)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Spacing.l
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)

        let intro = CardView()
        intro.addArranged(SectionLabel.make("Native"))
        intro.addArranged(Typography.body("EBNativeAdLoader로 받은 응답을 호스트 앱이 그린 EBNativeAdRendering view에 attach합니다. 노출은 attach 시점에 + 50%/100% 가시성 기반으로 발사됩니다."))
        stack.addArrangedSubview(intro)

        let status = CardView()
        status.addArranged(SectionLabel.make("Status"))
        status.addArranged(badge)
        stack.addArrangedSubview(status)

        let nativeOptions = CardView()
        nativeOptions.addArranged(SectionLabel.make("Native options"))
        nativeOptions.addArranged(buildVideoToggleRow())
        let videoHelp = Typography.body("ON 시 EBNativeAsset.video를 요청 자산에 포함하고 별도의 native video 광고 유닛(AdUnitIds.nativeVideo)으로 요청합니다. 응답에 동영상이 있으면 SDK가 nativeMediaView() 슬롯 안에서 음소거 인라인 재생합니다 — 호스트 추가 작업 없음.")
        videoHelp.textColor = .secondaryLabel
        nativeOptions.addArranged(videoHelp)
        stack.addArrangedSubview(nativeOptions)

        stack.addArrangedSubview(options)

        let actions = CardView()
        actions.addArranged(SectionLabel.make("Action"))
        actions.addArranged(PrimaryButton.filled("Load native ad", target: self, action: #selector(handleLoad)))
        stack.addArrangedSubview(actions)

        let creative = CardView()
        creative.addArranged(SectionLabel.make("Creative"))
        adContainer.translatesAutoresizingMaskIntoConstraints = false
        creative.addArranged(adContainer)
        stack.addArrangedSubview(creative)

        let log = CardView()
        log.addArranged(SectionLabel.make("Lifecycle log"))
        log.addArranged(logView)
        stack.addArrangedSubview(log)

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: Spacing.l),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -Spacing.xxl),
            stack.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: Spacing.l),
            stack.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -Spacing.l)
        ])

        badge.set(.idle, text: "Tap to load")
    }

    private func buildVideoToggleRow() -> UIView {
        let label = UILabel()
        label.text = "Request video asset"
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        let row = UIStackView(arrangedSubviews: [label, UIView(), videoSwitch])
        row.axis = .horizontal
        row.alignment = .center
        return row
    }

    @objc private func handleLoad() {
        badge.set(.loading, text: "loading…")
        logView.append("load requested")
        Task { [weak self] in await self?.loadAd() }
    }

    @MainActor
    private func loadAd() async {
        let wantsVideo = videoSwitch.isOn
        let adUnitId = wantsVideo ? AdUnitIds.nativeVideo : AdUnitIds.native
        let loader = EBNativeAdLoader(adUnitId: adUnitId)
        options.apply(to: loader.options)

        var assets: Set<EBNativeAsset> = [.title, .main, .icon, .ctatext, .desc]
        if wantsVideo { assets.insert(.video) }
        loader.desiredAssets = assets

        let assetNames = assets.map { String(describing: $0) }.sorted().joined(separator: ", ")
        logView.append("unit: \(adUnitId)")
        logView.append("assets: \(assetNames)")

        do {
            let ad = try await loader.load()
            loadedAd?.detach()
            adContainer.subviews.forEach { $0.removeFromSuperview() }

            let adView = CustomNativeAdView()
            adView.translatesAutoresizingMaskIntoConstraints = false
            adContainer.addSubview(adView)
            NSLayoutConstraint.activate([
                adView.leadingAnchor.constraint(equalTo: adContainer.leadingAnchor),
                adView.trailingAnchor.constraint(equalTo: adContainer.trailingAnchor),
                adView.topAnchor.constraint(equalTo: adContainer.topAnchor),
                adView.bottomAnchor.constraint(equalTo: adContainer.bottomAnchor)
            ])

            ad.presenterProvider = { [weak self] in self }
            ad.onImpression    = { [weak self] in self?.set(.impression, "impression") }
            ad.onImpression50  = { [weak self] in self?.set(.impression, "impression 50%") }
            ad.onImpression100 = { [weak self] in self?.set(.impression, "impression 100%") }
            ad.onClick         = { [weak self] in self?.set(.clicked,    "clicked") }
            ad.onLeaveApp      = { [weak self] in self?.set(.clicked,    "left app") }
            ad.onClickFinish   = { [weak self] in self?.set(.ready,      "click finished") }

            ad.attach(to: adView)
            self.loadedAd = ad
            set(.ready, "attached")
        } catch {
            set(.failed, "failed: \(error.localizedDescription)")
        }
    }

    private func set(_ state: StatusBadge.State, _ text: String) {
        badge.set(state, text: text)
        logView.append(text)
    }
}
