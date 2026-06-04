import UIKit
import ExelBidSDK

/// Mediated fullscreen HTML interstitial. Load → isReady → present(from:).
/// Single-use; after dismiss, `isReady` flips false and the host must
/// `load()` again.
final class MediatedInterstitialExampleViewController: UIViewController {

    private let badge = StatusBadge()
    private let winnerRow = InfoRow(key: "Winning network", value: "-")
    private let logView = LogView()
    private let waterfallView = LogView()
    private let options = TestOptionsPanel()
    private var presentButtonRef: UIButton?
    private var interstitial: EBMediatedInterstitialAd?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Mediated Interstitial"

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
        intro.addArranged(SectionLabel.make("Mediated Interstitial"))
        intro.addArranged(Typography.body(
            "EBMediatedInterstitialAd — load() → isReady → present(from:). " +
            "FAN 등 일부 네트워크는 로드 시점에 rootViewController가 필요해 " +
            "rootViewControllerProvider 설정이 권장됩니다."
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
        let load = PrimaryButton.tinted("Load", target: self, action: #selector(handleLoad))
        let present = PrimaryButton.filled("Present", target: self, action: #selector(handlePresent))
        present.isEnabled = false
        presentButtonRef = present
        let buttons = UIStackView(arrangedSubviews: [load, present])
        buttons.axis = .horizontal
        buttons.spacing = Spacing.m
        buttons.distribution = .fillEqually
        actions.addArranged(buttons)
        stack.addArrangedSubview(actions)

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
        presentButtonRef?.isEnabled = false

        let ad = EBMediatedInterstitialAd(adUnitId: AdUnitIds.interstitial)
        ad.perNetworkTimeout = 5.0
        ad.rootViewControllerProvider = { [weak self] in self }
        options.apply(to: ad.options)

        ad.onWaterfallEvent = { [weak self] event in
            self?.waterfallView.append(WaterfallFormatter.format(event))
        }
        ad.onLoad = { [weak self, weak ad] in
            self?.winnerRow.set(ad?.winningNetwork ?? "-")
            self?.set(.ready, "loaded — tap Present")
            self?.presentButtonRef?.isEnabled = true
        }
        ad.onFail = { [weak self] error in
            self?.set(.failed, "failed: \(error.localizedDescription)")
        }
        ad.onWillAppear    = { [weak self] in self?.logView.append("onWillAppear") }
        ad.onDidAppear     = { [weak self] in self?.set(.impression, "presented") }
        ad.onWillDisappear = { [weak self] in self?.logView.append("onWillDisappear") }
        ad.onClick         = { [weak self] in self?.set(.clicked,    "clicked") }
        ad.onLeaveApp      = { [weak self] in self?.logView.append("onLeaveApp") }
        ad.onClickFinish   = { [weak self] in self?.logView.append("onClickFinish") }
        ad.onDidDisappear  = { [weak self] in
            self?.set(.idle, "dismissed — reload to show again")
            self?.presentButtonRef?.isEnabled = false
            self?.interstitial = nil
        }
        ad.load()
        interstitial = ad
    }

    @objc private func handlePresent() {
        guard let ad = interstitial, ad.isReady else {
            set(.failed, "not ready — load first")
            return
        }
        ad.present(from: self)
    }

    private func set(_ state: StatusBadge.State, _ text: String) {
        badge.set(state, text: text)
        logView.append(text)
    }
}
