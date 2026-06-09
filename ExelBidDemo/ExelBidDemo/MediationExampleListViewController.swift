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
        .init(title: "Mediated Banner",       subtitle: "여러 네트워크의 배너 광고를 순차 시도",
              symbol: "rectangle",
              make: { MediatedBannerExampleViewController() }),
        .init(title: "Mediated Interstitial", subtitle: "여러 네트워크의 전면 광고를 순차 시도",
              symbol: "rectangle.fill.on.rectangle.fill",
              make: { MediatedInterstitialExampleViewController() }),
        .init(title: "Mediated Native",       subtitle: "여러 네트워크의 네이티브 광고를 순차 시도",
              symbol: "doc.text.image",
              make: { MediatedNativeExampleViewController() }),
        .init(title: "Mediated Video",        subtitle: "여러 네트워크의 비디오 광고를 순차 시도",
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
            "서버가 정한 순서대로 여러 광고 네트워크를 시도해, 가장 먼저 응답한 광고를 노출합니다. " +
            "예제에서는 ExelBid · AdMob · FAN · AdFit 네 가지 네트워크가 등록되어 있으며, " +
            "각 시도 결과는 워터폴 로그에서 확인할 수 있습니다."
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
