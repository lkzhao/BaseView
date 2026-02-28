import UIKit

// A base view class that provide viewDidLoad callback so that subclass don't need to implement two init functions
// Also provides compatibility for pre-iOS 26 versions by using layoutSubviews as a fallback for updateProperties
open class View: UIView {
    open var automaticallyCalculateShadowPath = true
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        viewDidLoad()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        viewDidLoad()
    }

    // subclass override
    open func viewDidLoad() {
        if #unavailable(iOS 26.0) {
            setNeedsUpdateProperties()
        }
    }

    open override func updateProperties() {
        if #available(iOS 26.0, *) {
            super.updateProperties()
        }
    }

    open override func setNeedsUpdateProperties() {
        if #available(iOS 26.0, *) {
            super.setNeedsUpdateProperties()
        } else {
            _needsUpdateProperties = true
            setNeedsLayout()
        }
    }

    open override func updatePropertiesIfNeeded() {
        if #available(iOS 26.0, *) {
            super.updatePropertiesIfNeeded()
        } else if _needsUpdateProperties {
            _updateProperties()
        }
    }

    private var _isInPreLayout = false
    private var _needsUpdateProperties = false

    private func _updateProperties() {
        withObservationTracking {
            updateProperties()
        } onChange: { [weak self] in
            MainActor.assumeIsolated {
                self?.setNeedsUpdateProperties()
            }
        }
        _needsUpdateProperties = false
    }

    open override func setNeedsLayout() {
        guard !_isInPreLayout else { return }
        super.setNeedsLayout()
    }

    open override func layoutSubviews() {
        if #unavailable(iOS 26.0), _needsUpdateProperties {
            _isInPreLayout = true
            _updateProperties()
            _isInPreLayout = false
        }
        super.layoutSubviews()
        if shadowOpacity > 0, automaticallyCalculateShadowPath {
            shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        }
    }
    
    open override func action(for layer: CALayer, forKey event: String) -> CAAction? {
        guard shadowOpacity > 0, automaticallyCalculateShadowPath, event == "shadowPath" else {
            return super.action(for: layer, forKey: event)
        }
        
        guard let priorPath = layer.presentation()?.shadowPath ?? layer.shadowPath else {
            return super.action(for: layer, forKey: event)
        }
        
        guard let sizeAnimation = layer.animation(forKey: "bounds.size") as? CABasicAnimation else {
            return super.action(for: layer, forKey: event)
        }
        
        let animation = sizeAnimation.copy() as! CABasicAnimation
        animation.keyPath = "shadowPath"
        let action = ShadowingViewAction()
        action.priorPath = priorPath
        action.pendingAnimation = animation
        return action
    }
}

private class ShadowingViewAction: NSObject, CAAction {
    var pendingAnimation: CABasicAnimation? = nil
    var priorPath: CGPath? = nil
    
    // CAAction Protocol
    func run(forKey event: String, object anObject: Any, arguments dict: [AnyHashable: Any]?) {
        guard let layer = anObject as? CALayer, let animation = self.pendingAnimation else {
            return
        }
        
        animation.fromValue = self.priorPath
        animation.toValue = layer.shadowPath
        layer.add(animation, forKey: "shadowPath")
    }
}
