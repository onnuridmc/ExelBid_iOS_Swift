import UIKit

/// "Mediation" tab — list of the 4 mediated ad surfaces. Tap a row to push
/// the corresponding example controller. Adapters are registered once in
/// `AppDelegate`; each detail VC exercises the waterfall via
/// `onWaterfallEvent` so the per-network attempts are visible in the log.
final class MediationExampleListViewController: UIViewController {

    private struct Item {
        let title: String
        let subtitle: String
        let symbol: String
        let make: () -> UIViewController
    }

    private let items: [Item] = [
        .init(title: "Mediated Banner",       subtitle: "EBMediatedBannerAd + waterfall",
              symbol: "rectangle",
              make: { MediatedBannerExampleViewController() }),
        .init(title: "Mediated Interstitial", subtitle: "EBMediatedInterstitialAd + waterfall",
              symbol: "rectangle.fill.on.rectangle.fill",
              make: { MediatedInterstitialExampleViewController() }),
        .init(title: "Mediated Native",       subtitle: "EBMediatedNativeAdLoader + waterfall",
              symbol: "doc.text.image",
              make: { MediatedNativeExampleViewController() }),
        .init(title: "Mediated Video",        subtitle: "EBMediatedVideoAd + waterfall",
              symbol: "play.rectangle",
              make: { MediatedVideoExampleViewController() })
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Mediation"
        navigationItem.largeTitleDisplayMode = .always

        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.alwaysBounceVertical = true
        view.addSubview(scroll)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Spacing.m
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)

        let intro = CardView()
        intro.addArranged(SectionLabel.make("Mediation"))
        intro.addArranged(Typography.body(
            "서버 워터폴을 받아 어댑터를 자동 폴백 처리합니다. " +
            "데모는 ExelBid / AdMob / FAN / AdFit 4개 어댑터를 등록하지만, " +
            "FAN·AdFit 호스트 SDK는 링크하지 않아 isAvailable=false로 동작합니다 — " +
            "이때 워터폴 로그에 adapterNotRegistered 항목이 보입니다."
        ))
        stack.addArrangedSubview(intro)
        stack.setCustomSpacing(Spacing.l, after: intro)

        for (index, item) in items.enumerated() {
            let card = SurfaceCardView(
                title: item.title,
                subtitle: item.subtitle,
                symbol: item.symbol,
                action: { [weak self] in self?.push(index) }
            )
            stack.addArrangedSubview(card)
        }

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
    }

    private func push(_ index: Int) {
        let vc = items[index].make()
        navigationController?.pushViewController(vc, animated: true)
    }
}
