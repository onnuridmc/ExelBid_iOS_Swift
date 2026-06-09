import UIKit
import ExelBidSDK

/// Mediated fullscreen video. `load()` → `present(from:)` 2-stage. Single
/// use. When the ExelBid adapter wins, `onProgress` reports VAST quartile
/// boundaries (0/25/50/75/100). AdMob / FAN play their video creative as an
/// interstitial video (not rewarded) and `onProgress` is approximated with
/// start (0) and end (100) only.
final class MediatedVideoExampleViewController: UIViewController {

    private let badge = StatusBadge()
    private let winnerRow = InfoRow(key: "Winning network", value: "-")
    private let progressRow = InfoRow(key: "Progress", value: "-")
    private let logView = LogView()
    private let waterfallView = LogView()
    private let options = TestOptionsPanel()
    private var presentButtonRef: UIButton?
    private var videoAd: EBMediatedVideoAd?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Mediated Video"

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
        intro.addArranged(SectionLabel.make("Mediated Video"))
        intro.addArranged(Typography.body(
            "여러 네트워크의 비디오 광고를 폴백 처리합니다. 한 번 재생되면 닫힌 뒤 다시 로드해야 합니다.\n\n" +
            "ExelBid 외 일부 네트워크(AdMob · FAN)는 재생 진행률을 시작·종료 두 시점에만 보고합니다."
        ))
        stack.addArrangedSubview(intro)

        let status = CardView()
        status.addArranged(SectionLabel.make("Status"))
        status.addArranged(badge)
        status.addArranged(winnerRow)
        status.addArranged(progressRow)
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
        progressRow.set("-")
        waterfallView.append("─── load ───")
        set(.loading, "loading…")
        presentButtonRef?.isEnabled = false

        let ad = EBMediatedVideoAd(adUnitId: AdUnitIds.video)
        ad.perNetworkTimeout = 5.0
        ad.rootViewControllerProvider = { [weak self] in self }
        ad.options.videoSkipMin = 10
        ad.options.videoSkipAfter = 5
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
        ad.onProgress = { [weak self] percent in
            self?.progressRow.set("\(percent)%")
            self?.logView.append("onProgress \(percent)")
        }
        ad.onWillAppear    = { [weak self] in self?.logView.append("onWillAppear") }
        ad.onDidAppear     = { [weak self] in self?.set(.impression, "playing") }
        ad.onWillDisappear = { [weak self] in self?.logView.append("onWillDisappear") }
        ad.onClick         = { [weak self] in self?.set(.clicked,    "clicked") }
        ad.onLeaveApp      = { [weak self] in self?.logView.append("onLeaveApp") }
        ad.onDidDisappear  = { [weak self] in
            self?.set(.idle, "dismissed — reload to play again")
            self?.presentButtonRef?.isEnabled = false
            self?.videoAd = nil
        }
        ad.load()
        videoAd = ad
    }

    @objc private func handlePresent() {
        guard let ad = videoAd, ad.isReady else {
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
