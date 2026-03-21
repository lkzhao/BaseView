import UIKit
import BaseToolbox

/// Magnifying loupe view backed by `PortalView` and `LensView`.
@available(iOS 26.0, *)
open class LoupeView: BaseView {
    private let portalView = PortalView()
    private let portalContainerView = UIView()
    private let lensView = LensView()
    private let scaleView = UIView()

    @Proxy(\.lensView.style)
    open var style: LensView.Style

    private var _isLifted = false

    open var isLifted: Bool {
        get { _isLifted }
        set {
            guard newValue != _isLifted else { return }
            setLifted(newValue, animated: false)
        }
    }

    open override var center: CGPoint {
        didSet {
            updateLayout()
        }
    }

    open override var frame: CGRect {
        didSet {
            updateLayout()
        }
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        portalView.alpha = 0
        portalView.matchesTransform = false
        portalView.matchesAlpha = false
        portalView.matchesPosition = false
        style = .clear
        lensView.restingBackgroundColor = .clear
        lensView.wobbleOnMove = false

        scaleView.addSubview(portalContainerView)
        portalContainerView.clipsToBounds = true
        portalContainerView.addSubview(portalView)
        scaleView.addSubview(lensView)
        addSubview(scaleView)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
    }

    open override func didMoveToWindow() {
        super.didMoveToWindow()
        updateLayout()
    }

    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        portalView.sourceView = superview
        setNeedsLayout()
    }

    /// Updates lifted state while preserving the loupe's scale and portal transitions.
    open func setLifted(
        _ lifted: Bool,
        animated: Bool,
        alongsideAnimations: (() -> Void)? = nil,
        completion: (() -> Void)? = nil
    ) {
        guard lifted != _isLifted else { return }
        _isLifted = lifted

        updateLayout()
        if lifted {
            portalView.alpha = 1
        }

        lensView.setLifted(lifted, animated: animated, alongsideAnimations: {
            self.scaleView.transform = .identity.scaledBy(lifted ? 1.2 : 1)
            self.portalView.transform = .identity.scaledBy(lifted ? 1.3 : 1)
            alongsideAnimations?()
        }, completion: {
            if !self.isLifted {
                self.portalView.alpha = 0
            }
            completion?()
        })
    }

    /// Convenience overload for the common lifted-state update path.
    open func setLifted(_ lifted: Bool, animated: Bool) {
        setLifted(lifted, animated: animated, alongsideAnimations: nil, completion: nil)
    }

    private func updateLayout() {
        guard let superview, bounds.width > 0, bounds.height > 0 else { return }
        scaleView.frameWithoutTransform = bounds
        lensView.frameWithoutTransform = bounds
        portalContainerView.frameWithoutTransform = bounds
        portalContainerView.cornerRadius = bounds.height / 2

        let frameOfContainer = superview.convert(superview.bounds, to: self)
        portalView.frameWithoutTransform = frameOfContainer
        portalView.anchorPoint = superview.convert(bounds.center, from: self) / superview.bounds.size
    }
}
