import UIKit
import ExelBidSDK

/// Mediated native ad. Uses `MediatedNativeAdView` — same `EBNativeAdRendering`
/// protocol as the standard native demo plus the optional `nativeMediaView()`
/// and `nativeAdChoicesView()` slots that AdMob / FAN adapters need to render
/// their own media views (`GADMediaView` / `FBMediaView`) and AdChoices badges.
final class MediatedNativeExampleViewController: UIViewController {

    private let badge = StatusBadge()
    private let winnerRow = InfoRow(key: "Winning network", value: "-")
    private let logView = LogView()
    private let waterfallView = LogView()
    private let options = TestOptionsPanel()
    private let adContainer = UIView()
    private var loadedAd: EBMediatedNativeAd?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Mediated Native"

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
        intro.addArranged(SectionLabel.make("Mediated Native"))
        intro.addArranged(Typography.body(
            "여러 네트워크의 네이티브 광고를 폴백 처리합니다. " +
            "광고 자산은 낙찰된 네트워크에 맞춰 자동으로 뷰에 바인딩됩니다."
        ))
        stack.addArrangedSubview(intro)

        let status = CardView()
        status.addArranged(SectionLabel.make("Status"))
        status.addArranged(badge)
        status.addArranged(winnerRow)
        stack.addArrangedSubview(status)

        stack.addArrangedSubview(options)

        let actions = CardView()
        actions.addArranged(SectionLabel.make("Action"))
        actions.addArranged(PrimaryButton.filled("Load mediated native ad", target: self, action: #selector(handleLoad)))
        stack.addArrangedSubview(actions)

        let creative = CardView()
        creative.addArranged(SectionLabel.make("Creative"))
        adContainer.translatesAutoresizingMaskIntoConstraints = false
        creative.addArranged(adContainer)
        stack.addArrangedSubview(creative)

        let waterfallCard = CardView()
        waterfallCard.addArranged(SectionLabel.make("Waterfall"))
        waterfallCard.addArranged(waterfallView)
        stack.addArrangedSubview(waterfallCard)

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

    @objc private func handleLoad() {
        winnerRow.set("-")
        waterfallView.append("─── load ───")
        set(.loading, "loading…")
        Task { [weak self] in await self?.loadAd() }
    }

    @MainActor
    private func loadAd() async {
        let loader = EBMediatedNativeAdLoader(adUnitId: AdUnitIds.native)
        loader.perNetworkTimeout = 5.0
        loader.rootViewControllerProvider = { [weak self] in self }
        loader.desiredAssets = [.title, .main, .icon, .ctatext, .desc]
        options.apply(to: loader.options)
        loader.onWaterfallEvent = { [weak self] event in
            self?.waterfallView.append(WaterfallFormatter.format(event))
        }

        do {
            let ad = try await loader.load()
            loadedAd?.detach()
            adContainer.subviews.forEach { $0.removeFromSuperview() }

            let adView = MediatedNativeAdView()
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
            winnerRow.set(ad.winningNetwork)
            self.loadedAd = ad
            set(.ready, "attached — won: \(ad.winningNetwork)")
        } catch {
            set(.failed, "failed: \(error.localizedDescription)")
        }
    }

    private func set(_ state: StatusBadge.State, _ text: String) {
        badge.set(state, text: text)
        logView.append(text)
    }
}
