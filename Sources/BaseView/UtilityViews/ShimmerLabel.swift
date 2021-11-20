import UIKit

open class ShimmerLabel: ShimmerView {
    private let label = UILabel()
    open var text: String {
        get { label.text ?? "" }
        set { label.text = newValue }
    }
    open var font: UIFont {
        get { label.font }
        set { label.font = newValue }
    }
    open var textAlignment: NSTextAlignment {
        get { label.textAlignment }
        set { label.textAlignment = newValue }
    }
    open var adjustsFontSizeToFitWidth: Bool {
        get { label.adjustsFontSizeToFitWidth }
        set { label.adjustsFontSizeToFitWidth = newValue }
    }
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
