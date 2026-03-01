import UIKit
import BaseToolbox

/// Shimmering text view that masks `ShimmerView` with an internal `UILabel`.
open class ShimmerLabel: ShimmerView {
    private let label = UILabel()

    @Proxy(\.label.text)
    open var text: String?

    @Proxy(\.label.attributedText)
    open var attributedText: NSAttributedString?

    @Proxy(\.label.font)
    open var font: UIFont

    @Proxy(\.label.textColor)
    open var textColor: UIColor

    @Proxy(\.label.highlightedTextColor)
    open var highlightedTextColor: UIColor?

    @Proxy(\.label.isHighlighted)
    open var isHighlighted: Bool

    @Proxy(\.label.isEnabled)
    open var isEnabled: Bool

    @Proxy(\.label.textAlignment)
    open var textAlignment: NSTextAlignment

    @Proxy(\.label.numberOfLines)
    open var numberOfLines: Int

    @Proxy(\.label.lineBreakMode)
    open var lineBreakMode: NSLineBreakMode

    @Proxy(\.label.adjustsFontSizeToFitWidth)
    open var adjustsFontSizeToFitWidth: Bool

    @Proxy(\.label.minimumScaleFactor)
    open var minimumScaleFactor: CGFloat

    @Proxy(\.label.baselineAdjustment)
    open var baselineAdjustment: UIBaselineAdjustment

    @Proxy(\.label.allowsDefaultTighteningForTruncation)
    open var allowsDefaultTighteningForTruncation: Bool

    @Proxy(\.label.adjustsFontForContentSizeCategory)
    open var adjustsFontForContentSizeCategory: Bool

    @Proxy(\.label.preferredMaxLayoutWidth)
    open var preferredMaxLayoutWidth: CGFloat

    open override func viewDidLoad() {
        super.viewDidLoad()
        mask = label
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
    }

    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        label.sizeThatFits(size)
    }
}
