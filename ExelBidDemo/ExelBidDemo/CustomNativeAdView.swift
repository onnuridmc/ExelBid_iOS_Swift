import UIKit
import ExelBidSDK

/// Reference host view implementing `EBNativeAdRendering`. Coded in plain
/// UIKit (no nib) to keep the demo self-contained.
///
/// `mediaContainer` is the single slot for the main creative. The SDK fills
/// it — VAST inline player when the payload carries a `video` asset, an
/// internally-managed `UIImageView` loading `model.main` otherwise. The
/// host does not own a separate main-image view.
final class CustomNativeAdView: UIView, EBNativeAdRendering {

    let iconView = UIImageView()
    let titleLabel = UILabel()
    let bodyLabel = UILabel()
    let mediaContainer = UIView()
    let ctaButton = UIButton(type: .system)
    let sponsoredLabel = UILabel()
    let privacyIconView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 8
        layer.masksToBounds = true
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - EBNativeAdRendering

    func nativeTitleTextLabel() -> UILabel? { titleLabel }
    func nativeMainTextLabel() -> UILabel? { bodyLabel }
    func nativeCallToActionButton() -> UIButton? { ctaButton }
    func nativeSponsoredTextLabel() -> UILabel? { sponsoredLabel }
    func nativeIconImageView() -> UIImageView? { iconView }
    func nativeMediaView() -> UIView? { mediaContainer }
    func nativePrivacyInformationIconImageView() -> UIImageView? { privacyIconView }

    // MARK: - Layout

    private func setupLayout() {
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.numberOfLines = 2

        bodyLabel.font = .preferredFont(forTextStyle: .footnote)
        bodyLabel.numberOfLines = 3
        bodyLabel.textColor = .secondaryLabel

        sponsoredLabel.font = .preferredFont(forTextStyle: .caption2)
        sponsoredLabel.textColor = .tertiaryLabel

        ctaButton.titleLabel?.font = .preferredFont(forTextStyle: .subheadline)
        ctaButton.setTitleColor(.systemBlue, for: .normal)
        ctaButton.contentHorizontalAlignment = .right

        iconView.contentMode = .scaleAspectFill
        iconView.clipsToBounds = true
        iconView.layer.cornerRadius = 4

        mediaContainer.backgroundColor = .clear
        mediaContainer.clipsToBounds = true

        privacyIconView.contentMode = .scaleAspectFit
        privacyIconView.clipsToBounds = true
        privacyIconView.isUserInteractionEnabled = true

        let topRow = UIStackView(arrangedSubviews: [iconView, titleLabel, ctaButton])
        topRow.spacing = 8
        topRow.alignment = .center

        mediaContainer.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [topRow, mediaContainer, bodyLabel, sponsoredLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        privacyIconView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(privacyIconView)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 40),
            iconView.heightAnchor.constraint(equalToConstant: 40),

            mediaContainer.heightAnchor.constraint(equalToConstant: 180),

            privacyIconView.topAnchor.constraint(equalTo: mediaContainer.topAnchor, constant: 6),
            privacyIconView.trailingAnchor.constraint(equalTo: mediaContainer.trailingAnchor, constant: -6),
            privacyIconView.widthAnchor.constraint(equalToConstant: 20),
            privacyIconView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
}
