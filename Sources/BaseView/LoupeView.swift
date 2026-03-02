import UIKit
import BaseToolbox

/// Magnifying loupe view backed by `PortalView` and `LensView`.
open class LoupeView: BaseView {
    private let portalView = PortalView()
    private let portalContainerView = UIView()
    private let lensView = LensView()
    private let scaleView = UIView()

    @Proxy(\.lensView.style)
    open var style: LensView.Style

    open var isActive = false {
        didSet {
            guard isActive != oldValue else { return }
            updateLayout()
            if isActive {
                portalView.alpha = 1
            }
            lensView.setLifted(isActive, animated: true, alongsideAnimations: {
                self.scaleView.transform = .identity.scaledBy(self.isActive ? 1.2 : 1)
                self.portalView.transform = .identity.scaledBy(self.isActive ? 1.3 : 1)
            }, completion: {
                if !self.isActive {
                    self.portalView.alpha = 0
                }
            })
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

    private func updateLayout() {
        guard let superview else { return }
        scaleView.frameWithoutTransform = bounds
        lensView.frameWithoutTransform = bounds
        portalContainerView.frameWithoutTransform = bounds
        portalContainerView.cornerRadius = bounds.height / 2

        let frameOfContainer = superview.convert(superview.bounds, to: self)
        portalView.frameWithoutTransform = frameOfContainer
        portalView.anchorPoint = superview.convert(bounds.center, from: self) / superview.bounds.size
    }
}
