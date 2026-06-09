import UIKit
import ExelBidSDK

/// MPartners native ad. Reuses `CustomNativeAdView` (the standard
/// `EBNativeAdRendering` view) — the SDK returns the same `EBNativeAd` type
/// regardless of which backend served it.
///
/// Note: MPartners native responses do not include `imp50tracker` /
/// `imp100tracker`, so the 50% / 100% impression callbacks never fire.
/// The single `onImpression` (immediate, on attach) is the only one used.
final class MPartnersNativeController: UIViewController {

    private let badge = StatusBadge()
    private let logView = LogView()
    private let options = TestOptionsPanel()
    private let adContainer = UIView()
    private var loadedAd: EBNativeAd?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "MPartners Native"

        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.alwaysBounceVertical = true
        view.addSubview(scroll)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Spacing.l
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)

        let status = CardView()
        status.addArranged(SectionLabel.make("Status"))
        status.addArranged(badge)
        stack.addArrangedSubview(status)

        stack.addArrangedSubview(options)

        let actions = CardView()
        actions.addArranged(SectionLabel.make("Action"))
        actions.addArranged(PrimaryButton.filled("Load MPartners native ad", target: self, action: #selector(handleLoad)))
        stack.addArrangedSubview(actions)

        let creative = CardView()
        creative.addArranged(SectionLabel.make("Creative"))
        adContainer.translatesAutoresizingMaskIntoConstraints = false
        creative.addArranged(adContainer)
        stack.addArrangedSubview(creative)

        let note = CardView()
        note.addArranged(SectionLabel.make("Note"))
        note.addArranged(Typography.footnote(
            "MPartners 네이티브 광고는 50% / 100% 가시성 노출 측정을 지원하지 않습니다. " +
            "광고 뷰가 화면에 표시되는 시점의 노출 이벤트만 호출됩니다."
        ))
        stack.addArrangedSubview(note)

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
        badge.set(.loading, text: "loading…")
        logView.append("load requested")
        Task { [weak self] in await self?.loadAd() }
    }

    @MainActor
    private func loadAd() async {
        let loader = EBMPartnersNativeAdLoader(adUnitId: AdUnitIds.MPartners.native)
        options.apply(to: loader.options)
        loader.desiredAssets = [.title, .main, .icon, .ctatext, .desc]

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
            ad.onImpression  = { [weak self] in self?.set(.impression, "impression") }
            ad.onClick       = { [weak self] in self?.set(.clicked,    "clicked") }
            ad.onLeaveApp    = { [weak self] in self?.set(.clicked,    "left app") }
            ad.onClickFinish = { [weak self] in self?.set(.ready,      "click finished") }

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
