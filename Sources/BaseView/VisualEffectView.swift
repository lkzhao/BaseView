import UIKit

/// `UIVisualEffectView` variant with animatable effect intensity control.
open class VisualEffectView: UIVisualEffectView {
    private static let minimumVisibleEffectIntensity: CGFloat = 0.005

    private var targetEffect: UIVisualEffect?
    private var effectAnimator: UIViewPropertyAnimator?
    private var internalEffectIntensity: CGFloat = 1

    open override var effect: UIVisualEffect? {
        get { targetEffect }
        set { setTargetEffect(newValue) }
    }

    /// Controls the applied fraction of `effect` in the range `0...1`.
    open var effectIntensity: CGFloat {
        get { internalEffectIntensity }
        set { setEffectIntensity(newValue) }
    }

    public override init(effect: UIVisualEffect?) {
        super.init(effect: nil)
        commonInit(with: effect)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        let initialEffect = super.effect
        super.effect = nil
        commonInit(with: initialEffect)
    }

    open override func didMoveToWindow() {
        super.didMoveToWindow()

        guard window != nil, let targetEffect else { return }

        // `UIVisualEffectView` can ignore `fractionComplete` until attached to a window.
        // Rebuilding the animator here guarantees the initial intensity is applied.
        setTargetEffect(targetEffect)
    }

    deinit {
        effectAnimator?.stopAnimation(true)
    }

    private func commonInit(with effect: UIVisualEffect?) {
        setTargetEffect(effect)
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (view: Self, previousTraitCollection) in
            if view.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                if let targetEffect = view.targetEffect {
                    view.setTargetEffect(targetEffect)
                }
            }
        }
    }

    private func setTargetEffect(_ effect: UIVisualEffect?) {
        targetEffect = effect

        effectAnimator?.stopAnimation(true)
        effectAnimator = nil
        setUnderlyingEffect(nil)

        guard let effect, window != nil else { return }

        let animator = UIViewPropertyAnimator(duration: 1, curve: .linear) { [weak self] in
            self?.setUnderlyingEffect(effect)
        }
        animator.startAnimation()
        animator.pauseAnimation()
        effectAnimator = animator

        updateEffectFraction()
    }

    private func setEffectIntensity(_ intensity: CGFloat) {
        internalEffectIntensity = max(0, min(1, intensity))
        updateEffectFraction()
    }

    private func updateEffectFraction() {
        guard let animator = effectAnimator else {
            setUnderlyingEffect(nil)
            return
        }

        if internalEffectIntensity < Self.minimumVisibleEffectIntensity {
            animator.fractionComplete = 0
            setUnderlyingEffect(nil)
            return
        }

        animator.fractionComplete = internalEffectIntensity
    }

    private func setUnderlyingEffect(_ effect: UIVisualEffect?) {
        super.effect = effect
    }
}
