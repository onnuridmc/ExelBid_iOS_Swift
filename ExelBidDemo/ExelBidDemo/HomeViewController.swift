import UIKit
import ExelBidSDK
import AppTrackingTransparency

final class HomeViewController: UIViewController {

    // MARK: - State cells

    private let attRow      = InfoRow(key: "ATT status", value: "-")
    private let logSegments = UISegmentedControl(items: ["off", "warn", "info", "debug"])
    private let attButton   = UIButton(type: .system)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "ExelBid Demo"

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.alwaysBounceVertical = true
        view.addSubview(scroll)

        let container = UIStackView()
        container.axis = .vertical
        container.spacing = Spacing.l
        container.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(container)

        container.addArrangedSubview(makeHeroCard())
        container.addArrangedSubview(makeATTCard())
        container.addArrangedSubview(makeLogLevelCard())

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            container.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: Spacing.l),
            container.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -Spacing.xxl),
            container.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: Spacing.l),
            container.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -Spacing.l)
        ])

        refreshATTStatus()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshATTStatus()
    }

    // MARK: - Cards

    private func makeHeroCard() -> UIView {
        let card = CardView()

        let eyebrow = SectionLabel.make("SDK")
        let title   = Typography.title("ExelBid iOS")
        let blurb   = Typography.footnote("ExelBid SDK 통합 예제입니다. 탭 메뉴에서 각 광고 유형의 로딩·노출 흐름을 확인할 수 있습니다.")

        card.addArranged([eyebrow, title, blurb])
        card.addArranged(InfoRow(key: "SDK version",   value: ExelBid.shared.sdkVersion))
        card.addArranged(InfoRow(key: "Deployment",    value: "iOS 13.0+"))
        return card
    }

    private func makeATTCard() -> UIView {
        let card = CardView()
        card.addArranged(SectionLabel.make("App Tracking Transparency"))
        card.addArranged(attRow)

        attButton.setTitle("Request ATT prompt", for: .normal)
        attButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body).withWeight(.semibold)
        attButton.setTitleColor(BrandColor.accent, for: .normal)
        attButton.contentHorizontalAlignment = .leading
        attButton.addTarget(self, action: #selector(handleATT), for: .touchUpInside)
        card.addArranged(attButton)
        return card
    }

    private func makeLogLevelCard() -> UIView {
        let card = CardView()
        card.addArranged(SectionLabel.make("Log level"))

        logSegments.selectedSegmentIndex = 3
        logSegments.addTarget(self, action: #selector(handleLogChanged(_:)), for: .valueChanged)
        card.addArranged(logSegments)

        let note = Typography.footnote("SDK 로그 출력 수준입니다. 운영 빌드에서는 warning 이상을 권장합니다.")
        card.addArranged(note)
        return card
    }

    // MARK: - Actions

    @objc private func handleATT() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { [weak self] _ in
                DispatchQueue.main.async { self?.refreshATTStatus() }
            }
        }
    }

    @objc private func handleLogChanged(_ sender: UISegmentedControl) {
        let levels: [LogLevel] = [.off, .warning, .info, .debug]
        ExelBid.shared.logLevel = levels[sender.selectedSegmentIndex]
    }

    private func refreshATTStatus() {
        if #available(iOS 14, *) {
            attRow.set(ATTrackingManager.trackingAuthorizationStatus.title)
        } else {
            attRow.set("not available (<iOS 14)")
        }
    }
}

@available(iOS 14, *)
private extension ATTrackingManager.AuthorizationStatus {
    var title: String {
        switch self {
        case .authorized:        return "authorized"
        case .denied:            return "denied"
        case .restricted:        return "restricted"
        case .notDetermined:     return "not determined"
        @unknown default:        return "unknown"
        }
    }
}
