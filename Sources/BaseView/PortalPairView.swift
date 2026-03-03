import UIKit
import BaseToolbox

/// Transition helper view that pairs two source views and crossfades between their portal clones.
open class PortalPairView: UIView {
    public let backgroundView: UIView
    public let foregroundView: UIView
    public let backgroundPortalView: PortalView
    public let foregroundPortalView: PortalView

    private let containerView: UIView
    private let styleAnimator = UIViewPropertyAnimator(duration: 0.5, curve: .linear)

    private let backgroundEffectView: UIVisualEffectView?
    private let foregroundEffectView: UIVisualEffectView?

    open var progress: CGFloat = 0 {
        didSet {
            applyProgress(progress)
        }
    }

    public init(backgroundView: UIView, foregroundView: UIView) {
        self.backgroundView = backgroundView
        self.foregroundView = foregroundView

        if let backgroundEffectSource = backgroundView as? UIVisualEffectView,
           let foregroundEffectSource = foregroundView as? UIVisualEffectView {
            let containerView = UIView()

            let backgroundEffectView = UIVisualEffectView(effect: backgroundEffectSource.effect)
            backgroundEffectView.effectIntensity = 1
            backgroundEffectView.overrideUserInterfaceStyle = backgroundEffectSource.traitCollection.userInterfaceStyle

            let foregroundEffectView = UIVisualEffectView(effect: foregroundEffectSource.effect)
            foregroundEffectView.effectIntensity = 0
            foregroundEffectView.overrideUserInterfaceStyle = foregroundEffectSource.traitCollection.userInterfaceStyle

            let backgroundPortalView = Self.makePortalView(from: backgroundEffectSource.contentView)
            let foregroundPortalView = Self.makePortalView(from: foregroundEffectSource.contentView)

            backgroundEffectView.contentView.addSubview(backgroundPortalView)
            foregroundEffectView.contentView.addSubview(foregroundPortalView)
            containerView.addSubview(backgroundEffectView)
            containerView.addSubview(foregroundEffectView)

            self.containerView = containerView
            self.backgroundEffectView = backgroundEffectView
            self.foregroundEffectView = foregroundEffectView
            self.backgroundPortalView = backgroundPortalView
            self.foregroundPortalView = foregroundPortalView

            backgroundView.isHidden = true
            foregroundView.isHidden = true
        } else {
            let containerView = UIView()
            let backgroundPortalView = Self.makePortalView(from: backgroundView)
            let foregroundPortalView = Self.makePortalView(from: foregroundView)

            containerView.addSubview(backgroundPortalView)
            containerView.addSubview(foregroundPortalView)

            self.containerView = containerView
            self.backgroundEffectView = nil
            self.foregroundEffectView = nil
            self.backgroundPortalView = backgroundPortalView
            self.foregroundPortalView = foregroundPortalView
        }

        super.init(frame: backgroundView.frameWithoutTransform)

        addSubview(containerView)
        synchronizeContainerValues(with: backgroundView)

        styleAnimator.addAnimations { [weak self] in
            guard let self else { return }
            self.synchronizeContainerValues(with: foregroundView)
        }
        styleAnimator.startAnimation()
        styleAnimator.pauseAnimation()

        applyProgress(progress)
    }

    public convenience init(bgView: UIView, fgView: UIView) {
        self.init(backgroundView: bgView, foregroundView: fgView)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        containerView.frameWithoutTransform = bounds
        backgroundEffectView?.frameWithoutTransform = containerView.bounds
        foregroundEffectView?.frameWithoutTransform = containerView.bounds

        layoutPortal(backgroundPortalView)
        layoutPortal(foregroundPortalView)
    }

    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview == nil {
            styleAnimator.stopAnimation(true)
            backgroundView.isHidden = false
            foregroundView.isHidden = false
        }
    }

    private static func makePortalView(from sourceView: UIView) -> PortalView {
        let portalView = PortalView()
        portalView.sourceView = sourceView
        portalView.hidesSourceView = true
        portalView.matchesAlpha = false
        portalView.matchesPosition = false
        portalView.matchesTransform = false
        portalView.frameWithoutTransform = sourceView.frameWithoutTransform
        return portalView
    }

    private func synchronizeContainerValues(with sourceView: UIView) {
        containerView.clipsToBounds = sourceView.clipsToBounds

        if #available(iOS 26.0, *) {
            containerView.cornerConfiguration = sourceView.cornerConfiguration
        } else {
            containerView.layer.cornerRadius = sourceView.layer.cornerRadius
            containerView.layer.maskedCorners = sourceView.layer.maskedCorners
            containerView.layer.cornerCurve = sourceView.layer.cornerCurve
        }

        if let sourceEffectView = sourceView as? UIVisualEffectView {
            if sourceView === backgroundView {
                backgroundEffectView?.effect = sourceEffectView.effect
            } else if sourceView === foregroundView {
                foregroundEffectView?.effect = sourceEffectView.effect
            }
        }
    }

    private func layoutPortal(_ portalView: PortalView) {
        portalView.center = bounds.center

        let sourceSize = portalView.sourceView?.bounds.size ?? .zero
        guard sourceSize.width > 0, sourceSize.height > 0 else {
            portalView.transform = .identity
            return
        }

        portalView.bounds.size = sourceSize
        portalView.transform = .identity.scaledBy(
            x: bounds.width / sourceSize.width,
            y: bounds.height / sourceSize.height
        )
    }

    private func applyProgress(_ progress: CGFloat) {
        let clampedProgress = progress.clamp(0, 1)

        let backgroundFadeProgress = ((clampedProgress - 0.4) / (0.9 - 0.4)).clamp(0, 1)
        let foregroundFadeProgress = ((clampedProgress - 0.1) / (0.6 - 0.1)).clamp(0, 1)
        backgroundPortalView.alpha = lerp(from: 1, to: 0, progress: backgroundFadeProgress)
        foregroundPortalView.alpha = lerp(from: 0, to: 1, progress: foregroundFadeProgress)

        styleAnimator.fractionComplete = clampedProgress

        if let backgroundEffectView, let foregroundEffectView {
            backgroundEffectView.effectIntensity = (1 - clampedProgress).clamp(0, 1)
            foregroundEffectView.effectIntensity = clampedProgress
        }

        let dismissedTransform = backgroundView.layer.presentation()?.transform ?? backgroundView.layer.transform
        let presentedTransform = foregroundView.layer.presentation()?.transform ?? foregroundView.layer.transform
        layer.transform = lerp(from: dismissedTransform, to: presentedTransform, progress: clampedProgress)
    }
}
