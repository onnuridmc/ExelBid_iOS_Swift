import UIKit

/// Shared design tokens + small UIKit primitives. Targets the HIG defaults
/// (system colors, dynamic type, secondarySystemGroupedBackground cards)
/// while staying compatible with the demo's iOS 13 deployment target.
enum Spacing {
    static let xs: CGFloat  = 4
    static let s: CGFloat   = 8
    static let m: CGFloat   = 12
    static let l: CGFloat   = 16
    static let xl: CGFloat  = 20
    static let xxl: CGFloat = 28
}

enum CornerRadius {
    static let card: CGFloat   = 14
    static let button: CGFloat = 12
}

enum BrandColor {
    static let accent = UIColor.systemBlue
}

/// Container that visually groups related controls. Use `addArranged(_:)`
/// to stack subviews vertically inside the card with the standard padding.
final class CardView: UIView {

    private let stack = UIStackView()

    init(spacing: CGFloat = Spacing.m, insets: UIEdgeInsets = .init(top: 16, left: 16, bottom: 16, right: 16)) {
        super.init(frame: .zero)
        backgroundColor = .secondarySystemGroupedBackground
        layer.cornerRadius = CornerRadius.card
        layer.cornerCurve = .continuous

        stack.axis = .vertical
        stack.spacing = spacing
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: insets.top),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -insets.bottom),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -insets.right)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    func addArranged(_ view: UIView) {
        stack.addArrangedSubview(view)
    }

    func addArranged(_ views: [UIView]) {
        views.forEach { stack.addArrangedSubview($0) }
    }

    func setCustomSpacing(_ s: CGFloat, after view: UIView) {
        stack.setCustomSpacing(s, after: view)
    }
}

/// Section/eyebrow label — small, uppercase, tertiary color.
enum SectionLabel {
    static func make(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text.uppercased()
        l.font = UIFont.preferredFont(forTextStyle: .caption1).withWeight(.semibold)
        l.textColor = .secondaryLabel
        l.adjustsFontForContentSizeCategory = true
        return l
    }
}

enum Typography {
    static func title(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = UIFont.preferredFont(forTextStyle: .title2).withWeight(.bold)
        l.numberOfLines = 0
        l.adjustsFontForContentSizeCategory = true
        return l
    }

    static func body(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = UIFont.preferredFont(forTextStyle: .body)
        l.textColor = .label
        l.numberOfLines = 0
        l.adjustsFontForContentSizeCategory = true
        return l
    }

    static func footnote(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = UIFont.preferredFont(forTextStyle: .footnote)
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        l.adjustsFontForContentSizeCategory = true
        return l
    }
}

/// `key — value` two-column row used in info / status cards.
final class InfoRow: UIView {

    let valueLabel = UILabel()
    private let keyLabel = UILabel()

    init(key: String, value: String = "") {
        super.init(frame: .zero)

        keyLabel.text = key
        keyLabel.font = .preferredFont(forTextStyle: .subheadline)
        keyLabel.textColor = .secondaryLabel
        keyLabel.setContentHuggingPriority(.required, for: .horizontal)
        keyLabel.adjustsFontForContentSizeCategory = true

        valueLabel.text = value
        valueLabel.font = .preferredFont(forTextStyle: .subheadline)
        valueLabel.textColor = .label
        valueLabel.textAlignment = .right
        valueLabel.numberOfLines = 0
        valueLabel.adjustsFontForContentSizeCategory = true

        let stack = UIStackView(arrangedSubviews: [keyLabel, valueLabel])
        stack.axis = .horizontal
        stack.spacing = Spacing.m
        stack.alignment = .firstBaseline
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    func set(_ text: String) { valueLabel.text = text }
}

/// Primary / secondary button factory. Manual styling so it works on
/// iOS 13+ (UIButton.Configuration would need iOS 15).
enum PrimaryButton {
    static func filled(_ title: String, target: Any?, action: Selector) -> UIButton {
        let b = UIButton(type: .custom)
        b.setTitle(title, for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .disabled)
        b.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body).withWeight(.semibold)
        b.titleLabel?.adjustsFontForContentSizeCategory = true
        b.backgroundColor = BrandColor.accent
        b.layer.cornerRadius = CornerRadius.button
        b.layer.cornerCurve = .continuous
        b.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        b.addTarget(target, action: action, for: .touchUpInside)
        return b
    }

    static func tinted(_ title: String, target: Any?, action: Selector) -> UIButton {
        let b = UIButton(type: .custom)
        b.setTitle(title, for: .normal)
        b.setTitleColor(BrandColor.accent, for: .normal)
        b.setTitleColor(BrandColor.accent.withAlphaComponent(0.4), for: .disabled)
        b.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body).withWeight(.semibold)
        b.titleLabel?.adjustsFontForContentSizeCategory = true
        b.backgroundColor = BrandColor.accent.withAlphaComponent(0.12)
        b.layer.cornerRadius = CornerRadius.button
        b.layer.cornerCurve = .continuous
        b.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        b.addTarget(target, action: action, for: .touchUpInside)
        return b
    }
}

extension UIFont {
    func withWeight(_ weight: UIFont.Weight) -> UIFont {
        let descriptor = fontDescriptor.addingAttributes([
            .traits: [UIFontDescriptor.TraitKey.weight: weight]
        ])
        return UIFont(descriptor: descriptor, size: 0)
    }
}

/// Tappable card used by the Home / Ads / Mediation / MPartners list
/// screens. Icon + title + subtitle + optional trailing badge + chevron.
final class SurfaceCardView: UIView {

    private let action: () -> Void

    init(
        title: String,
        subtitle: String,
        symbol: String,
        accessoryText: String? = nil,
        action: @escaping () -> Void
    ) {
        self.action = action
        super.init(frame: .zero)

        backgroundColor = .secondarySystemGroupedBackground
        layer.cornerRadius = CornerRadius.card
        layer.cornerCurve = .continuous

        let icon = UIImageView(image: UIImage(systemName: symbol))
        icon.tintColor = BrandColor.accent
        icon.contentMode = .scaleAspectFit
        icon.setContentHuggingPriority(.required, for: .horizontal)

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        titleLabel.adjustsFontForContentSizeCategory = true

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .preferredFont(forTextStyle: .footnote)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0
        subtitleLabel.adjustsFontForContentSizeCategory = true

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        var trailingViews: [UIView] = []
        if let accessoryText = accessoryText {
            trailingViews.append(makeAccessoryBadge(accessoryText))
        }
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .tertiaryLabel
        chevron.setContentHuggingPriority(.required, for: .horizontal)
        trailingViews.append(chevron)

        let row = UIStackView(arrangedSubviews: [icon, textStack] + trailingViews)
        row.axis = .horizontal
        row.spacing = Spacing.m
        row.alignment = .center
        row.isUserInteractionEnabled = false
        row.translatesAutoresizingMaskIntoConstraints = false
        addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            row.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),
            row.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            row.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            icon.widthAnchor.constraint(equalToConstant: 28),
            icon.heightAnchor.constraint(equalToConstant: 28)
        ])

        let tap = UIButton(type: .system)
        tap.translatesAutoresizingMaskIntoConstraints = false
        tap.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        addSubview(tap)
        NSLayoutConstraint.activate([
            tap.topAnchor.constraint(equalTo: topAnchor),
            tap.bottomAnchor.constraint(equalTo: bottomAnchor),
            tap.leadingAnchor.constraint(equalTo: leadingAnchor),
            tap.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    @objc private func handleTap() { action() }

    private func makeAccessoryBadge(_ text: String) -> UIView {
        let label = UILabel()
        label.text = text
        label.font = UIFont.preferredFont(forTextStyle: .caption2).withWeight(.semibold)
        label.textColor = .secondaryLabel
        label.adjustsFontForContentSizeCategory = true

        let pill = UIView()
        pill.backgroundColor = UIColor.secondaryLabel.withAlphaComponent(0.12)
        pill.layer.cornerRadius = 8
        pill.layer.cornerCurve = .continuous
        pill.translatesAutoresizingMaskIntoConstraints = false

        label.translatesAutoresizingMaskIntoConstraints = false
        pill.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: pill.topAnchor, constant: 4),
            label.bottomAnchor.constraint(equalTo: pill.bottomAnchor, constant: -4),
            label.leadingAnchor.constraint(equalTo: pill.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: pill.trailingAnchor, constant: -8)
        ])
        return pill
    }
}

/// Monospaced append-only log used by example screens to surface SDK
/// lifecycle callbacks. Always scrolls to the latest line.
final class LogView: UIView {

    private let textView = UITextView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGroupedBackground
        layer.cornerRadius = 8
        layer.cornerCurve = .continuous
        clipsToBounds = true

        textView.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        textView.textColor = .label
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.alwaysBounceVertical = true
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        textView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textView)
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: topAnchor),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 160)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    func append(_ line: String) {
        let stamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        textView.text.append(contentsOf: "[\(stamp)] \(line)\n")
        let end = NSRange(location: (textView.text as NSString).length, length: 0)
        textView.scrollRangeToVisible(end)
    }

    func clear() { textView.text = "" }
}
