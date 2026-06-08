import UIKit
import ExelBidSDK

/// Reference host view implementing `EBNativeAdRendering`. Coded in plain
/// UIKit (no nib) to keep the demo self-contained.
///
/// `mainImageView` and `mediaContainer` are stacked in the same media slot
/// — the SDK populates whichever fits the served creative (URL image → main
/// image; video / SDK-rendered media → media container). When the demo
/// requests `EBNativeAsset.video`, the SDK uses `nativeMediaView()`.
final class CustomNativeAdView: UIView, EBNativeAdRendering {

    let iconView = UIImageView()
    let titleLabel = UILabel()
    let bodyLabel = UILabel()
    let mainImageView = UIImageView()
    let mediaContainer = UIView()
    let ctaLabel = UILabel()
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
    func nativeCallToActionTextLabel() -> UILabel? { ctaLabel }
    func nativeSponsoredTextLabel() -> UILabel? { sponsoredLabel }
    func nativeIconImageView() -> UIImageView? { iconView }
    func nativeMainImageView() -> UIImageView? { mainImageView }
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

        ctaLabel.font = .preferredFont(forTextStyle: .subheadline)
        ctaLabel.textColor = .systemBlue
        ctaLabel.textAlignment = .right

        iconView.contentMode = .scaleAspectFill
        iconView.clipsToBounds = true
        iconView.layer.cornerRadius = 4

        mainImageView.contentMode = .scaleAspectFill
        mainImageView.clipsToBounds = true

        mediaContainer.backgroundColor = .clear
        mediaContainer.clipsToBounds = true

        privacyIconView.contentMode = .scaleAspectFit
        privacyIconView.clipsToBounds = true
        privacyIconView.isUserInteractionEnabled = true

        let topRow = UIStackView(arrangedSubviews: [iconView, titleLabel, ctaLabel])
        topRow.spacing = 8
        topRow.alignment = .center

        // mediaSlot stacks the main image and the media container in the
        // same frame — only one is populated at a time depending on the
        // served creative (image asset vs video / SDK-rendered media).
        let mediaSlot = UIView()
        mediaSlot.translatesAutoresizingMaskIntoConstraints = false
        mainImageView.translatesAutoresizingMaskIntoConstraints = false
        mediaContainer.translatesAutoresizingMaskIntoConstraints = false
        mediaSlot.addSubview(mainImageView)
        mediaSlot.addSubview(mediaContainer)

        let stack = UIStackView(arrangedSubviews: [topRow, mediaSlot, bodyLabel, sponsoredLabel])
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

            mediaSlot.heightAnchor.constraint(equalToConstant: 180),
            mainImageView.topAnchor.constraint(equalTo: mediaSlot.topAnchor),
            mainImageView.bottomAnchor.constraint(equalTo: mediaSlot.bottomAnchor),
            mainImageView.leadingAnchor.constraint(equalTo: mediaSlot.leadingAnchor),
            mainImageView.trailingAnchor.constraint(equalTo: mediaSlot.trailingAnchor),
            mediaContainer.topAnchor.constraint(equalTo: mediaSlot.topAnchor),
            mediaContainer.bottomAnchor.constraint(equalTo: mediaSlot.bottomAnchor),
            mediaContainer.leadingAnchor.constraint(equalTo: mediaSlot.leadingAnchor),
            mediaContainer.trailingAnchor.constraint(equalTo: mediaSlot.trailingAnchor),

            privacyIconView.topAnchor.constraint(equalTo: mediaSlot.topAnchor, constant: 6),
            privacyIconView.trailingAnchor.constraint(equalTo: mediaSlot.trailingAnchor, constant: -6),
            privacyIconView.widthAnchor.constraint(equalToConstant: 20),
            privacyIconView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
}
