import UIKit
import UIComponent
import Hero2

open class ComponentRootView: RootView {
    public let componentView = ComponentScrollView()
    
    open var component: Component? {
        get { componentView.component }
        set { componentView.component = newValue }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        componentView.contentInsetAdjustmentBehavior = .always
        componentView.delaysContentTouches = false
        addSubview(componentView)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        guard !isTransitionAnimating else { return }
        componentView.frameWithoutTransform = bounds
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        componentView.sizeThatFits(size)
    }
}
