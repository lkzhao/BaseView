import UIKit
import ObjectiveC.runtime

extension UIVisualEffectView {
    /// Controls the applied fraction of `effect` in the range `0...1`.
    public var effectIntensity: CGFloat {
        get {
            Self.bv_installEffectIntensitySwizzles()
            return bv_effectIntensityHelper?.currentIntensity() ?? 1
        }
        set {
            Self.bv_installEffectIntensitySwizzles()
            let helper = bv_effectIntensityHelper ?? {
                let helper = VisualEffectIntensityHelper(view: self, initialEffect: effect, intensity: newValue)
                bv_effectIntensityHelper = helper
                return helper
            }()
            helper.setIntensity(newValue)
        }
    }
}

@MainActor
private final class VisualEffectIntensityHelper: NSObject {
    private static let minimumVisibleEffectIntensity: CGFloat = 0.005

    private weak var view: UIVisualEffectView?
    private var targetEffect: UIVisualEffect?
    private var effectAnimator: UIViewPropertyAnimator?
    private var intensity: CGFloat
    private var didRegisterTraitObserver = false

    init(view: UIVisualEffectView, initialEffect: UIVisualEffect?, intensity: CGFloat) {
        self.view = view
        targetEffect = initialEffect
        self.intensity = intensity
        super.init()
        registerTraitObserverIfNeeded()
        setTargetEffect(initialEffect)
    }

    func setIntensity(_ value: CGFloat) {
        intensity = max(0, min(1, value))
        updateEffectFraction()
    }

    func currentIntensity() -> CGFloat {
        intensity
    }

    func setTargetEffect(_ effect: UIVisualEffect?) {
        targetEffect = effect

        effectAnimator?.stopAnimation(true)
        effectAnimator = nil
        view?.bv_setEffectSwizzled(nil)

        guard let view, let effect, view.window != nil else { return }

        let animator = UIViewPropertyAnimator(duration: 1, curve: .linear) { [weak view] in
            view?.bv_setEffectSwizzled(effect)
        }
        animator.pauseAnimation()
        effectAnimator = animator

        updateEffectFraction()
    }

    func viewDidMoveToWindow() {
        guard let view, view.window != nil, let targetEffect else { return }

        // `UIVisualEffectView` can ignore `fractionComplete` until attached to a window.
        // Rebuilding the animator here guarantees the initial intensity is applied.
        setTargetEffect(targetEffect)
    }

    private func updateEffectFraction() {
        guard let effectAnimator else {
            view?.bv_setEffectSwizzled(nil)
            return
        }

        if intensity < Self.minimumVisibleEffectIntensity {
            effectAnimator.fractionComplete = 0
            view?.bv_setEffectSwizzled(nil)
            return
        }

        effectAnimator.fractionComplete = intensity
    }

    private func registerTraitObserverIfNeeded() {
        guard !didRegisterTraitObserver, let view else { return }
        didRegisterTraitObserver = true

        view.registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (view: UIVisualEffectView, previousTraitCollection) in
            guard let helper = view.bv_effectIntensityHelper else { return }
            guard view.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
            if let targetEffect = helper.targetEffect {
                helper.setTargetEffect(targetEffect)
            }
        }
    }
}

extension UIVisualEffectView {
    private enum VisualEffectIntensityRuntime {
        static var helperKey: UInt8 = 0
    }

    fileprivate var bv_effectIntensityHelper: VisualEffectIntensityHelper? {
        get {
            objc_getAssociatedObject(self, &VisualEffectIntensityRuntime.helperKey) as? VisualEffectIntensityHelper
        }
        set {
            objc_setAssociatedObject(self, &VisualEffectIntensityRuntime.helperKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private static let bv_swizzleEffectIntensityMethods: Void = {
        guard
            let originalSetEffect = class_getInstanceMethod(UIVisualEffectView.self, #selector(setter: UIVisualEffectView.effect)),
            let swizzledSetEffect = class_getInstanceMethod(UIVisualEffectView.self, #selector(UIVisualEffectView.bv_setEffectSwizzled(_:))),
            let originalDidMove = class_getInstanceMethod(UIVisualEffectView.self, #selector(UIView.didMoveToWindow)),
            let swizzledDidMove = class_getInstanceMethod(UIVisualEffectView.self, #selector(UIVisualEffectView.bv_didMoveToWindowSwizzled))
        else {
            return
        }

        method_exchangeImplementations(originalSetEffect, swizzledSetEffect)
        method_exchangeImplementations(originalDidMove, swizzledDidMove)
    }()

    fileprivate static func bv_installEffectIntensitySwizzles() {
        _ = bv_swizzleEffectIntensityMethods
    }

    @objc fileprivate func bv_setEffectSwizzled(_ effect: UIVisualEffect?) {
        if let helper = bv_effectIntensityHelper {
            helper.setTargetEffect(effect)
            return
        }
        bv_setEffectSwizzled(effect)
    }

    @objc private func bv_didMoveToWindowSwizzled() {
        bv_didMoveToWindowSwizzled()
        bv_effectIntensityHelper?.viewDidMoveToWindow()
    }
}
