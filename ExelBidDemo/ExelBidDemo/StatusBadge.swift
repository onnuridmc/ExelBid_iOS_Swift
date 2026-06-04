import UIKit

/// Pill-shaped status indicator for the ad lifecycle. Tinted background +
/// matching dot so the same state reads identically across screens.
final class StatusBadge: UIView {

    enum State {
        case idle, loading, ready, impression, clicked, failed
    }

    private let dot = UIView()
    private let label = UILabel()
    private(set) var state: State = .idle

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 14
        layer.cornerCurve = .continuous
        layer.masksToBounds = true

        dot.layer.cornerRadius = 4
        dot.translatesAutoresizingMaskIntoConstraints = false
        addSubview(dot)

        label.font = .preferredFont(forTextStyle: .footnote)
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        NSLayoutConstraint.activate([
            dot.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            dot.centerYAnchor.constraint(equalTo: centerYAnchor),
            dot.widthAnchor.constraint(equalToConstant: 8),
            dot.heightAnchor.constraint(equalToConstant: 8),

            label.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])

        set(.idle, text: "Idle")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    func set(_ state: State, text: String) {
        self.state = state
        label.text = text
        label.textColor = state.foreground
        dot.backgroundColor = state.foreground
        backgroundColor = state.background
    }
}

private extension StatusBadge.State {
    var foreground: UIColor {
        switch self {
        case .idle:       return .secondaryLabel
        case .loading:    return .systemOrange
        case .ready:      return .systemBlue
        case .impression: return .systemGreen
        case .clicked:    return .systemPurple
        case .failed:     return .systemRed
        }
    }
    var background: UIColor {
        foreground.withAlphaComponent(0.12)
    }
}
