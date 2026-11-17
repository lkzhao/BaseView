import UIKit

/// Wrapper around private `_UILiquidLensView` with a safe fallback when unavailable.
@available(iOS 26.0, *)
open class LensView: UIView {
    private typealias ObfuscatedKeys = BaseViewObfuscatedKeys.LensView

    internal var lensView: UIView?

    /// Whether the private lens implementation exists on this system.
    public private(set) var isAvailable = false

    public enum Style: Int {
        case regular = 0
        case clear = 1
    }

    /// Variant style index used by the private implementation.
    open var style: Style = .regular {
        didSet {
            lensView?.setValue(style.rawValue, forKey: ObfuscatedKeys.style)
        }
    }

    /// Whether the lens wobble interaction is enabled while moving.
    open var wobbleOnMove: Bool = false {
        didSet {
            guard wobbleOnMove != oldValue else { return }
            updateWobbleInteractionEnabled(wobbleOnMove)
        }
    }

    /// Background color in the resting state.
    open var restingBackgroundColor: UIColor? = UIColor.label.withAlphaComponent(0.1) {
        didSet {
            lensView?.setValue(restingBackgroundColor, forKey: ObfuscatedKeys.restingBackgroundColor)
        }
    }

    /// The view whose content the lens carries while lifted: the labels or icons of the control the lens
    /// selects in (for a tab bar or segmented control, the container of its items, a sibling of the lens).
    /// Under the lens the private view punches that content out and draws it inside the glass.
    ///
    /// On iOS 27 the lifted lens only refracts once it has lifted content. Without it, a lens that sits on
    /// another glass surface (a `UIGlassEffect` track) lifts as a flat pill. UIKit's own segmented control
    /// and tab bar always set it. Held weakly. No-op where the private property doesn't exist.
    open weak var liftedContentView: UIView? {
        didSet {
            guard liftedContentView !== oldValue else { return }
            setLensValueIfSupported(liftedContentView, forKey: ObfuscatedKeys.liftedContentView)
        }
    }

    /// Whether the lifted lens warps the content below it (UIKit's segmented control and tab bar turn this
    /// on). Off, the lens hides its below-glass warp backdrop after each lift (the previous behavior).
    /// No-op where the private property doesn't exist.
    open var warpsContentBelow: Bool = false {
        didSet {
            guard warpsContentBelow != oldValue else { return }
            setLensValueIfSupported(warpsContentBelow, forKey: ObfuscatedKeys.warpsContentBelow)
        }
    }

    private var _isLifted: Bool = false
    
    open var isLifted: Bool {
        get { _isLifted }
        set {
            guard newValue != _isLifted else { return }
            setLifted(newValue, animated: false)
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupLensView()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLensView()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        lensView?.frame = bounds
        liftIfNeeded()
    }
    
    open override func didMoveToWindow() {
        super.didMoveToWindow()
        liftIfNeeded()
    }

    /// Updates lifted state. Uses animated private API when available.
    open func setLifted(
        _ lifted: Bool,
        animated: Bool,
        alongsideAnimations: (() -> Void)? = nil,
        completion: (() -> Void)? = nil
    ) {
        guard let lensView else { return }
        self._isLifted = lifted

        if readyToLift, let animatedSelector = Self.animatedLiftSelector(for: lensView) {
            typealias SetLiftedFn = @convention(c) (AnyObject, Selector, Bool, Bool, AnyObject?, AnyObject?) -> Void
            let implementation = unsafeBitCast(lensView.method(for: animatedSelector), to: SetLiftedFn.self)
            let alongsideBlockObject = alongsideAnimations.map { animation -> AnyObject in
                let block: @convention(block) () -> Void = animation
                return unsafeBitCast(block, to: AnyObject.self)
            }
            let completionBlockObject = completion.map { finish -> AnyObject in
                let block: @convention(block) () -> Void = finish
                return unsafeBitCast(block, to: AnyObject.self)
            }
            implementation(lensView, animatedSelector, lifted, animated, alongsideBlockObject, completionBlockObject)
            if !warpsContentBelow {
                (lensView.value(forKey: ObfuscatedKeys.belowGlassWarpBackdrop) as? UIView)?.isHidden = true
            }
            return
        }

        // Only through a real setter: on iOS 27 `lifted` is read-only, and KVC would write the ivar
        // directly, flipping the flag without lifting.
        if readyToLift, lensView.responds(to: NSSelectorFromString(ObfuscatedKeys.setLifted)) {
            lensView.setValue(lifted, forKey: ObfuscatedKeys.lifted)
        }
        if animated, let alongsideAnimations {
            UIView.animate(springDuration: 0.35, bounce: 0.2, initialSpringVelocity: 0, delay: 0,
                           options: [.beginFromCurrentState, .allowUserInteraction],
                           animations: alongsideAnimations) { _ in completion?() }
        } else {
            alongsideAnimations?()
            completion?()
        }
    }

    /// The private animated lift: `setLifted:animated:alongsideAnimations:completion:` on iOS 27,
    /// `setLifted:animated:alongside:completion:` before. Both take (Bool, Bool, block?, block?).
    private static func animatedLiftSelector(for lensView: UIView) -> Selector? {
        for name in [ObfuscatedKeys.setLiftedAnimatedAlongsideAnimationsCompletion,
                     ObfuscatedKeys.setLiftedAnimatedAlongsideCompletion] {
            let selector = NSSelectorFromString(name)
            if lensView.responds(to: selector) { return selector }
        }
        return nil
    }

    /// Convenience overload for the common lifted-state update path.
    open func setLifted(_ lifted: Bool, animated: Bool) {
        setLifted(lifted, animated: animated, alongsideAnimations: nil, completion: nil)
    }
    
    private func liftIfNeeded() {
        if isLifted, !_lensIsLifted, readyToLift {
            setLifted(true, animated: false)
        }
    }
    
    private var _lensIsLifted: Bool {
        (lensView?.value(forKey: ObfuscatedKeys.lifted) as? NSNumber)?.boolValue ?? false
    }
    
    private var readyToLift: Bool {
        window != nil
    }

    private func setupLensView() {
        guard let lensClass = NSClassFromString(ObfuscatedKeys.liquidLensClass) as? UIView.Type else {
            isAvailable = false
            let fallback = UIView(frame: bounds)
            fallback.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            fallback.backgroundColor = .clear
            addSubview(fallback)
            return
        }

        let view = lensClass.init(frame: bounds)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        lensView = view
        isAvailable = true
        applyConfiguredValues()
    }

    private func applyConfiguredValues() {
        guard let lensView else { return }
        lensView.setValue(style.rawValue, forKey: ObfuscatedKeys.style)
        lensView.setValue(restingBackgroundColor, forKey: ObfuscatedKeys.restingBackgroundColor)
        setLensValueIfSupported(liftedContentView, forKey: ObfuscatedKeys.liftedContentView)
        setLensValueIfSupported(warpsContentBelow, forKey: ObfuscatedKeys.warpsContentBelow)
        updateWobbleInteractionEnabled(wobbleOnMove)
    }

    /// KVC set, only when the private view has the setter (KVC on a missing key throws).
    private func setLensValueIfSupported(_ value: Any?, forKey key: String) {
        guard let lensView, let first = key.first else { return }
        let setter = NSSelectorFromString("set" + first.uppercased() + key.dropFirst() + ":")
        guard lensView.responds(to: setter) else { return }
        lensView.setValue(value, forKey: key)
    }

    private func updateWobbleInteractionEnabled(_ enabled: Bool) {
        guard let lensView else { return }
        let flexSelector = NSSelectorFromString(ObfuscatedKeys.flexInteraction)
        guard lensView.responds(to: flexSelector),
              let flexInteraction = lensView.value(forKey: ObfuscatedKeys.flexInteraction) as? NSObject else {
            return
        }
        if enabled {
            lensView.addInteraction(flexInteraction as! UIInteraction)
        } else {
            lensView.removeInteraction(flexInteraction as! UIInteraction)
        }
    }
}
