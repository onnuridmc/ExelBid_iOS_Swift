import UIKit
import ExelBidSDK

final class VideoExampleViewController: UIViewController {

    private let badge = StatusBadge()
    private let progressRow = InfoRow(key: "VAST progress", value: "-")
    private let logView = LogView()
    private let options = TestOptionsPanel()

    private let loadButton    = UIButton(type: .system)
    private let presentButton = UIButton(type: .system)
    private var videoAd: EBVideoAd?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Video"

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
        intro.addArranged(SectionLabel.make("Video (VAST)"))
        intro.addArranged(Typography.body("EBVideoAd는 1회 재생 전용입니다. onDidDisappear 이후 다음 광고를 보여주려면 load()를 다시 호출해야 합니다."))
        stack.addArrangedSubview(intro)

        let status = CardView()
        status.addArranged(SectionLabel.make("Status"))
        status.addArranged(badge)
        status.addArranged(progressRow)
        stack.addArrangedSubview(status)

        stack.addArrangedSubview(options)

        let actions = CardView()
        actions.addArranged(SectionLabel.make("Action"))

        let load = PrimaryButton.tinted("Load", target: self, action: #selector(handleLoad))
        let present = PrimaryButton.filled("Present", target: self, action: #selector(handlePresent))
        present.isEnabled = false
        loadButton.tag = 0
        presentButton.tag = 0

        let buttons = UIStackView(arrangedSubviews: [load, present])
        buttons.axis = .horizontal
        buttons.spacing = Spacing.m
        buttons.distribution = .fillEqually
        actions.addArranged(buttons)
        stack.addArrangedSubview(actions)

        // Keep references so we can toggle present state
        self.loadButtonRef = load
        self.presentButtonRef = present

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

    private var loadButtonRef: UIButton?
    private var presentButtonRef: UIButton?

    @objc private func handleLoad() {
        badge.set(.loading, text: "loading…")
        progressRow.set("-")
        presentButtonRef?.isEnabled = false

        let ad = EBVideoAd(adUnitId: AdUnitIds.video)
        ad.options.videoSkipMin = 10
        ad.options.videoSkipAfter = 5
        options.apply(to: ad.options)

        ad.onLoad = { [weak self] in
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
