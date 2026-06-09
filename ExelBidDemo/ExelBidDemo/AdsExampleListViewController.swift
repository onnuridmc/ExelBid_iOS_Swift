import UIKit

/// "Ads" tab — list of the 4 base ExelBid ad surfaces. Tap a row to push
/// the corresponding example controller onto the tab's nav stack.
final class AdsExampleListViewController: UIViewController {

    private struct Item {
        let title: String
        let subtitle: String
        let symbol: String
        let make: () -> UIViewController
    }

    private let items: [Item] = [
        .init(title: "Banner",       subtitle: "320×50 배너, 자동 갱신",
              symbol: "rectangle",
              make: { BannerExampleViewController() }),
        .init(title: "Interstitial", subtitle: "전체화면 광고",
              symbol: "rectangle.fill.on.rectangle.fill",
              make: { InterstitialExampleViewController() }),
        .init(title: "Native",       subtitle: "커스텀 레이아웃 네이티브 광고",
              symbol: "doc.text.image",
              make: { NativeExampleViewController() }),
        .init(title: "Video",        subtitle: "전체화면 비디오 광고",
              symbol: "play.rectangle",
              make: { VideoExampleViewController() })
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Ads"
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
        intro.addArranged(SectionLabel.make("Ads"))
        intro.addArranged(Typography.body("ExelBid가 제공하는 4가지 광고 유형 예제입니다. 항목을 선택하면 상세 화면으로 이동합니다."))
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
