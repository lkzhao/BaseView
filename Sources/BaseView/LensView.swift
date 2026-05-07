import UIKit

/// Wrapper around private `_UILiquidLensView` with a safe fallback when unavailable.
@available(iOS 26.0, *)
open class LensView: UIView {
    private enum ObfuscatedKeys {
        static let liquidLensClass = ObfuscatedString.decode([35, 206, 243, 149, 145, 102, 67, 60, 16, 223, 215, 191, 131, 89, 71, 40, 27], key: 0xD7)
        static let style = ObfuscatedString.decode([69, 33, 13, 255, 215], key: 0x91)
        static let flexInteraction = ObfuscatedString.decode([145, 122, 80, 44, 58, 252, 197, 181, 157, 111, 78, 56, 2, 229, 199], key: 0x52)
        static let restingBackgroundColor = ObfuscatedString.decode([59, 13, 244, 210, 172, 138, 100, 96, 32, 3, 20, 249, 207, 179, 142, 116, 93, 27, 24, 250, 218, 166], key: 0xA4)
        static let belowGlassWarpBackdrop = ObfuscatedString.decode([67, 37, 51, 17, 234, 251, 183, 155, 106, 75, 0, 23, 231, 196, 145, 147, 114, 91, 43, 28, 226, 220], key: 0x7C)
        static let lifted = ObfuscatedString.decode([226, 196, 170, 159, 111, 77], key: 0xE9)
        static let setLiftedAnimatedAlongsideCompletion = ObfuscatedString.decode([78, 57, 15, 214, 208, 190, 131, 115, 81, 110, 18, 252, 216, 189, 142, 122, 72, 40, 81, 235, 197, 167, 137, 97, 86, 45, 7, 231, 224, 174, 182, 147, 124, 72, 50, 21, 247, 203, 237, 149, 122, 89, 35, 30, 244, 196, 166, 129, 99, 22], key: 0x98)
    }

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

        let animatedSelector = NSSelectorFromString(ObfuscatedKeys.setLiftedAnimatedAlongsideCompletion)
        if lensView.responds(to: animatedSelector), readyToLift {
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
            (lensView.value(forKey: ObfuscatedKeys.belowGlassWarpBackdrop) as? UIView)?.isHidden = true
            return
        }

        if readyToLift {
            lensView.setValue(lifted, forKey: ObfuscatedKeys.lifted)
        }
        alongsideAnimations?()
        completion?()
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
        updateWobbleInteractionEnabled(wobbleOnMove)
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
