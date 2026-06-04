import UIKit
import ExelBidSDK

/// MPartners 320×50 banner. Mirrors `BannerExampleViewController` but uses
/// `EBMPartnersBannerAd`. No autoRefresh — the host must tap Load to refresh.
final class MPartnersBannerController: UIViewController {

    private let badge = StatusBadge()
    private let logView = LogView()
    private let options = TestOptionsPanel()
    private let bannerHost = UIView()

    private var bannerAd: EBMPartnersBannerAd?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "MPartners Banner"

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
        actions.addArranged(PrimaryButton.filled("Load MPartners banner", target: self, action: #selector(handleLoad)))
        stack.addArrangedSubview(actions)

        let hostCard = CardView()
        hostCard.addArranged(SectionLabel.make("Creative"))
        bannerHost.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bannerHost.heightAnchor.constraint(equalToConstant: 50)
        ])
        hostCard.addArranged(bannerHost)
        stack.addArrangedSubview(hostCard)

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

    private func makeBannerAd() -> EBMPartnersBannerAd {
        let banner = EBMPartnersBannerAd(adUnitId: AdUnitIds.MPartners.banner,
                                       size: CGSize(width: 320, height: 50))
        banner.translatesAutoresizingMaskIntoConstraints = false
        bannerHost.addSubview(banner)
        NSLayoutConstraint.activate([
            banner.centerXAnchor.constraint(equalTo: bannerHost.centerXAnchor),
            banner.centerYAnchor.constraint(equalTo: bannerHost.centerYAnchor),
            banner.widthAnchor.constraint(equalToConstant: 320),
            banner.heightAnchor.constraint(equalToConstant: 50)
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
