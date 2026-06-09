import UIKit

/// "MPartners" tab — list of the 3 MPartners surfaces. Tap a row to push
/// the corresponding sub-controller. MPartners is a separate ad network;
/// its public API mirrors the standard ads 1:1 but autoRefresh, SKAdNetwork,
/// and MRC 50·100% timers are unsupported.
final class MPartnersExampleViewController: UIViewController {

    private struct Item {
        let title: String
        let subtitle: String
        let symbol: String
        let make: () -> UIViewController
    }

    private let items: [Item] = [
        .init(title: "Banner",       subtitle: "MPartners 배너 광고",
              symbol: "rectangle",
              make: { MPartnersBannerController() }),
        .init(title: "Interstitial", subtitle: "MPartners 전면 광고",
              symbol: "rectangle.fill.on.rectangle.fill",
              make: { MPartnersInterstitialController() }),
        .init(title: "Native",       subtitle: "MPartners 네이티브 광고",
              symbol: "doc.text.image",
              make: { MPartnersNativeController() })
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "MPartners"
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
        intro.addArranged(SectionLabel.make("MPartners"))
        intro.addArranged(Typography.body(
            "MPartners 네트워크의 광고 예제입니다. 표준 광고와 동일한 방식으로 사용할 수 있으며, " +
            "자동 갱신 · SKAdNetwork · 50% / 100% 가시성 노출 측정은 지원되지 않습니다."
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
