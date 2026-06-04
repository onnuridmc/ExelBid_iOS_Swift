import UIKit
import ExelBidSDK

/// Mediated 320×50 banner. Mirrors `BannerExampleViewController`, swapping
/// `EBBannerAd` for `EBMediatedBannerAd` and adding a dedicated waterfall
/// log card so per-network attempts (try → won/lost → noFill) are visible.
final class MediatedBannerExampleViewController: UIViewController {

    private let badge = StatusBadge()
    private let winnerRow = InfoRow(key: "Winning network", value: "-")
    private let logView = LogView()
    private let waterfallView = LogView()
    private let options = TestOptionsPanel()
    private let bannerHost = UIView()

    private var bannerAd: EBMediatedBannerAd?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Mediated Banner"

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
        intro.addArranged(SectionLabel.make("Mediated Banner"))
        intro.addArranged(Typography.body(
            "EBMediatedBannerAd — 서버가 정한 순서대로 어댑터를 순차 시도하고 " +
            "첫 성공 네트워크의 광고를 노출합니다. autoRefresh는 지원되지 않습니다."
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
        actions.addArranged(PrimaryButton.filled("Load mediated banner", target: self, action: #selector(handleLoad)))
        stack.addArrangedSubview(actions)

        let hostCard = CardView()
        hostCard.addArranged(SectionLabel.make("Creative"))
        bannerHost.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bannerHost.heightAnchor.constraint(equalToConstant: 50)
        ])
        hostCard.addArranged(bannerHost)
        stack.addArrangedSubview(hostCard)

        let waterfallCard = CardView()
        waterfallCard.addArranged(SectionLabel.make("Waterfall"))
        waterfallCard.addArranged(waterfallView)
        stack.addArrangedSubview(waterfallCard)

        let logCard = CardView()
        logCard.addArranged(SectionLabel.make("Lifecycle log"))
        logCard.addArranged(logView)
        stack.addArrangedSubview(logCard)

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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bannerAd?.stop()
    }

    @objc private func handleLoad() {
        let ad = bannerAd ?? makeBannerAd()
        ad.stop()
        options.apply(to: ad.options)
        winnerRow.set("-")
        waterfallView.append("─── load ───")
        set(.loading, "loading…")
        ad.load()
    }

    private func makeBannerAd() -> EBMediatedBannerAd {
        let banner = EBMediatedBannerAd(adUnitId: AdUnitIds.banner,
                                        size: CGSize(width: 320, height: 50))
        banner.perNetworkTimeout = 5.0
        banner.rootViewControllerProvider = { [weak self] in self }
        banner.translatesAutoresizingMaskIntoConstraints = false
        bannerHost.addSubview(banner)
        NSLayoutConstraint.activate([
            banner.centerXAnchor.constraint(equalTo: bannerHost.centerXAnchor),
            banner.centerYAnchor.constraint(equalTo: bannerHost.centerYAnchor),
            banner.widthAnchor.constraint(equalToConstant: 320),
            banner.heightAnchor.constraint(equalToConstant: 50)
        ])

        banner.onWaterfallEvent = { [weak self] event in
            self?.waterfallView.append(WaterfallFormatter.format(event))
        }
        banner.onLoad = { [weak self, weak banner] in
            self?.winnerRow.set(banner?.winningNetwork ?? "-")
            self?.set(.ready, "loaded")
        }
        banner.onFail        = { [weak self] error in self?.set(.failed, "failed: \(error.localizedDescription)") }
        banner.onClick       = { [weak self] in self?.set(.clicked, "clicked") }
        banner.onLeaveApp    = { [weak self] in self?.set(.clicked, "left app") }
        banner.onClickFinish = { [weak self] in self?.set(.ready,   "click finished") }
        bannerAd = banner
        return banner
    }

    private func set(_ state: StatusBadge.State, _ text: String) {
        badge.set(state, text: text)
        logView.append(text)
    }
}
