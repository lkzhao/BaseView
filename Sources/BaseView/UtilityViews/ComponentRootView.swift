import UIKit
import UIComponent
import Hero2

open class ComponentRootView: RootView {
    public let componentView = ComponentScrollView()
    
    open var component: Component {
        Space()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        componentView.contentInsetAdjustmentBehavior = .always
        componentView.delaysContentTouches = false
        addSubview(componentView)
        reloadComponent()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        guard !TransitionCoordinator.shared.isAnimating else { return }
        componentView.frameWithoutTransform = bounds
    }
    
    open func reloadComponent() {
        componentView.component = component
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        componentView.sizeThatFits(size)
    }
}
