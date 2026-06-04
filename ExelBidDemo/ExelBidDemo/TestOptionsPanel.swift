import UIKit
import ExelBidSDK

/// Inline test-mode toggle for `EBAdOptions`. Each example screen embeds one
/// and calls `apply(to:)` right before `load()` so the value flows into the
/// SDK exactly the way a host app would set it per request.
///
/// Collapsible: the header acts as a tap target that hides/shows the body.
final class TestOptionsPanel: UIView {

    // MARK: - Inputs

    private let testingSwitch = UISwitch()

    // MARK: - Chrome

    private let header = UIButton(type: .system)
    private let chevron = UIImageView()
    private let bodyContainer = UIView()
    private let rootStack = UIStackView()
    private var isExpanded = false {
        didSet { applyExpandedState(animated: oldValue != isExpanded) }
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .secondarySystemGroupedBackground
        layer.cornerRadius = CornerRadius.card
        layer.cornerCurve = .continuous
        clipsToBounds = true

        // The accordion only animates correctly when its parts live inside
        // a UIStackView — toggling `isHidden` on an arranged subview is
        // what makes the panel actually shrink (vs. just fade out).
        rootStack.axis = .vertical
        rootStack.spacing = 0
        rootStack.alignment = .fill
        rootStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(rootStack)
        NSLayoutConstraint.activate([
            rootStack.topAnchor.constraint(equalTo: topAnchor),
            rootStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            rootStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            rootStack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        setupHeader()
        setupBody()
        applyExpandedState(animated: false)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Public

    /// Applies the current panel values to an SDK `EBAdOptions` instance.
    func apply(to options: EBAdOptions) {
        options.testing = testingSwitch.isOn
    }

    // MARK: - Layout

    private func setupHeader() {
        let titleLabel = UILabel()
        titleLabel.text = "Test options"
        titleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline).withWeight(.semibold)
        titleLabel.textColor = .label
        titleLabel.adjustsFontForContentSizeCategory = true

        chevron.image = UIImage(systemName: "chevron.down")
        chevron.tintColor = .secondaryLabel
        chevron.contentMode = .scaleAspectFit

        let headerStack = UIStackView(arrangedSubviews: [titleLabel, UIView(), chevron])
        headerStack.axis = .horizontal
        headerStack.spacing = Spacing.s
        headerStack.alignment = .center
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        headerStack.isUserInteractionEnabled = false

        header.translatesAutoresizingMaskIntoConstraints = false
        header.addTarget(self, action: #selector(toggle), for: .touchUpInside)
        header.contentEdgeInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        header.addSubview(headerStack)

        NSLayoutConstraint.activate([
            headerStack.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16),
            headerStack.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -16),
            headerStack.topAnchor.constraint(equalTo: header.topAnchor, constant: 14),
            headerStack.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -14),

            chevron.widthAnchor.constraint(equalToConstant: 14),
            chevron.heightAnchor.constraint(equalToConstant: 14)
        ])

        rootStack.addArrangedSubview(header)
    }

    private func setupBody() {
        let testingRow = UIStackView(arrangedSubviews: [
            label("testing"),
            UIView(),
            testingSwitch
        ])
        testingRow.axis = .horizontal
        testingRow.alignment = .center

        let helper = UILabel()
        helper.text = "ON 시 광고 요청에 test=1을 함께 전송합니다. (EBAdOptions.testing)"
        helper.font = .preferredFont(forTextStyle: .footnote)
        helper.textColor = .secondaryLabel
        helper.numberOfLines = 0
        helper.adjustsFontForContentSizeCategory = true

        let bodyStack = UIStackView(arrangedSubviews: [testingRow, helper])
        bodyStack.axis = .vertical
        bodyStack.spacing = Spacing.s
        bodyStack.translatesAutoresizingMaskIntoConstraints = false

        bodyContainer.addSubview(bodyStack)
        NSLayoutConstraint.activate([
            bodyStack.topAnchor.constraint(equalTo: bodyContainer.topAnchor, constant: 4),
            bodyStack.bottomAnchor.constraint(equalTo: bodyContainer.bottomAnchor, constant: -16),
            bodyStack.leadingAnchor.constraint(equalTo: bodyContainer.leadingAnchor, constant: 16),
            bodyStack.trailingAnchor.constraint(equalTo: bodyContainer.trailingAnchor, constant: -16)
        ])

        rootStack.addArrangedSubview(bodyContainer)
    }

    // MARK: - Helpers

    private func label(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .preferredFont(forTextStyle: .subheadline)
        l.textColor = .label
        l.adjustsFontForContentSizeCategory = true
        return l
    }

    @objc private func toggle() {
        isExpanded.toggle()
    }

    private func applyExpandedState(animated: Bool) {
        let block = {
            self.bodyContainer.isHidden = !self.isExpanded
            self.chevron.transform = self.isExpanded
                ? CGAffineTransform(rotationAngle: .pi)
                : .identity
        }
        if animated {
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           options: [.curveEaseInOut],
                           animations: { block(); self.layoutIfNeeded() })
        } else {
            block()
        }
    }
}
