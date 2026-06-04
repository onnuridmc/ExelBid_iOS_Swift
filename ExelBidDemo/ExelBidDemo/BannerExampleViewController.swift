import UIKit
import ExelBidSDK

final class BannerExampleViewController: UIViewController {

    private let badge = StatusBadge()
    private let logView = LogView()
    private let options = TestOptionsPanel()
    private let bannerHost = UIView()

    /// Created on first Load tap so the heavy WKWebView init does not block
    /// the Home → Banner tab transition.
    private var bannerAd: EBBannerAd?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Banner"

        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.alwaysBounceVertical = true
        view.addSubview(scroll)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Spacing.l
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)

        // Intro card
        let intro = CardView()
        intro.addArranged(SectionLabel.make("Banner"))
        intro.addArranged(Typography.body("EBBannerAd 320×50. autoRefresh이 켜져 있으면 서버 응답의 갱신 주기에 맞춰 자동 재요청합니다."))
        stack.addArrangedSubview(intro)

        // Status card
        let status = CardView()
        status.addArranged(SectionLabel.make("Status"))
        status.addArranged(badge)
        stack.addArrangedSubview(status)

        // Options
        stack.addArrangedSubview(options)

        // Action card
        let actions = CardView()
        actions.addArranged(SectionLabel.make("Action"))
        actions.addArranged(PrimaryButton.filled("Load banner", target: self, action: #selector(handleLoad)))
        stack.addArrangedSubview(actions)

        // Banner host card — reserve a 320×50 slot now, fill it on first Load.
        let hostCard = CardView()
        hostCard.addArranged(SectionLabel.make("Creative"))
        bannerHost.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bannerHost.heightAnchor.constraint(equalToConstant: 100)
        ])
        hostCard.addArranged(bannerHost)
        stack.addArrangedSubview(hostCard)

        // Log
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
        set(.loading, "loading…")
        ad.load()
    }

    private func makeBannerAd() -> EBBannerAd {
        let banner = EBBannerAd(adUnitId: AdUnitIds.banner, size: CGSize(width: 320, height: 50))
        banner.autoRefresh = true
        banner.translatesAutoresizingMaskIntoConstraints = false
        bannerHost.addSubview(banner)
        NSLayoutConstraint.activate([
            banner.widthAnchor.constraint(equalTo: bannerHost.widthAnchor),
            banner.heightAnchor.constraint(equalTo: bannerHost.heightAnchor)
        ])
        
        banner.onLoad        = { [weak self] in self?.set(.ready,   "loaded") }
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
