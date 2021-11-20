import UIKit
import UIComponent

open class ComponentRootView: RootView {
    public let componentView = ComponentScrollView()
    
    open var component: Component {
        Space()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        backgroundColor = .systemBackground
        componentView.contentInsetAdjustmentBehavior = .always
        componentView.delaysContentTouches = false
        addSubview(componentView)
        reloadComponent()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        guard !transition.isTransitioning else { return }
        componentView.frameWithoutTransform = bounds
    }
    
    open func reloadComponent() {
        componentView.component = component
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        componentView.sizeThatFits(size)
    }
}
