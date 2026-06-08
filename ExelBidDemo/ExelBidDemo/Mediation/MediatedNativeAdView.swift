import UIKit
import ExelBidSDK

/// Native rendering view for the mediation demo. Adds the two optional
/// `EBNativeAdRendering` slots that AdMob / FAN adapters need:
///
/// - `nativeMediaView()` — single slot for the main creative. The SDK or
///   the winning adapter fills it: VAST inline player for ExelBid video
///   natives, the network's own media view (`GADMediaView` / `FBMediaView`)
///   for AdMob / FAN, or an internally-managed image view for static
///   payloads.
/// - `nativeAdChoicesView()` — overlay slot for AdChoices / privacy badges
///   that some networks require.
final class MediatedNativeAdView: UIView, EBNativeAdRendering {

    let iconView = UIImageView()
    let titleLabel = UILabel()
    let bodyLabel = UILabel()
    let mediaContainer = UIView()
    let adChoicesContainer = UIView()
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
    func nativePrivacyInformationIconImageView() -> UIImageView? { privacyIconView }

    // AdMob / FAN media + AdChoices slots.
    func nativeMediaView() -> UIView? { mediaContainer }
    func nativeAdChoicesView() -> UIView? { adChoicesContainer }

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

        mediaContainer.backgroundColor = .clear
        mediaContainer.clipsToBounds = true

        adChoicesContainer.backgroundColor = .clear
        adChoicesContainer.clipsToBounds = true

        privacyIconView.contentMode = .scaleAspectFit
        privacyIconView.clipsToBounds = true
        privacyIconView.isUserInteractionEnabled = true

        let topRow = UIStackView(arrangedSubviews: [iconView, titleLabel, ctaLabel])
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

        adChoicesContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(adChoicesContainer)

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
            privacyIconView.heightAnchor.constraint(equalToConstant: 20),

            adChoicesContainer.topAnchor.constraint(equalTo: mediaContainer.topAnchor, constant: 6),
            adChoicesContainer.leadingAnchor.constraint(equalTo: mediaContainer.leadingAnchor, constant: 6),
            adChoicesContainer.widthAnchor.constraint(equalToConstant: 20),
            adChoicesContainer.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
}
