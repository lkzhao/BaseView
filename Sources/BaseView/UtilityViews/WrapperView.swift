import UIKit
import BaseToolbox

open class WrapperView<V: UIView>: View {
    open var contentView: V

    public var inset: UIEdgeInsets = .zero {
        didSet {
            guard inset != oldValue else { return }
            setNeedsLayout()
        }
    }
    
    public init() {
        contentView = V()
        super.init(frame: .zero)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        addSubview(contentView)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frameWithoutTransform = bounds.inset(by: inset)
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        contentView.sizeThatFits(size.inset(by: inset)).inset(by: -inset)
    }
}
