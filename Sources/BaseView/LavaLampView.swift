import UIKit
import BaseToolbox

/// Glassy, animated lava-lamp view with drifting gradient blobs.
open class LavaLampView: BaseView {
    public let fieldView = LavaLampBlobFieldView()
    public let glassView: UIVisualEffectView
    public let highlightView = GradientView()

    public var contentView: UIView {
        glassView.contentView
    }

    open var effect: UIVisualEffect? {
        get { glassView.effect }
        set { glassView.effect = newValue }
    }

    open var baseColor: UIColor {
        get { fieldView.baseColor }
        set { fieldView.baseColor = newValue }
    }

    open var highlightColor: UIColor? {
        get { fieldView.highlightColor }
        set { fieldView.highlightColor = newValue }
    }

    private lazy var pressRecognizer = SimultaneousPressGestureRecognizer(
        target: self,
        action: #selector(handlePress(_:))
    )
    private var initialTouchPoint: CGPoint = .zero
    private var isPressing = false {
        didSet {
            guard oldValue != isPressing else { return }
            updatePressedState()
        }
    }

    public override init(frame: CGRect) {
        glassView = UIVisualEffectView(effect: Self.defaultGlassEffect())
        super.init(frame: frame)
    }

    public required init?(coder: NSCoder) {
        glassView = UIVisualEffectView(effect: Self.defaultGlassEffect())
        super.init(coder: coder)
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        addSubview(fieldView)
        addSubview(glassView)
        addSubview(highlightView)
        configureHighlightView()
        addGestureRecognizer(pressRecognizer)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        fieldView.frameWithoutTransform = bounds
        glassView.frameWithoutTransform = bounds
        highlightView.frameWithoutTransform = bounds
        let radius = bounds.height / 2
        glassView.cornerRadius = radius
        fieldView.cornerRadius = radius
        highlightView.cornerRadius = radius
    }

    private func configureHighlightView() {
        if #available(iOS 26.0, tvOS 26.0, *) {
            highlightView.colors = [
                .white.applyingContentHeadroom(1.5).withAlphaComponent(0.4),
                .white.applyingContentHeadroom(1.5).withAlphaComponent(0.0),
            ]
        } else {
            glassView.clipsToBounds = true
            highlightView.colors = [
                .white.withAlphaComponent(0.4),
                .white.withAlphaComponent(0.0),
            ]
        }
        highlightView.gradientLayer.type = .radial
        highlightView.locations = [0, 1]
        highlightView.easeFunctions = [.easeInOut]
        highlightView.clipsToBounds = true
        highlightView.alpha = 0
    }

    @objc private func handlePress(_ gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: self)

        switch gesture.state {
        case .began:
            isPressing = true
            initialTouchPoint = location
            fallthrough
        case .changed:
            guard bounds.width > 0, bounds.height > 0 else { return }
            highlightView.startPoint = location / bounds.size
            highlightView.endPoint = (location / bounds.size) + CGSize(width: 1, height: 1).size(fill: bounds.size) / bounds.size * 0.6
            let translation = location - initialTouchPoint
            let scaleX = 1.0 + abs(translation.x) * 0.0005
            let scaleY = 1.0 + abs(translation.y) * 0.0005
            let offset = translation * 0.03
            transform = CGAffineTransform.identity.scaledBy(x: scaleX, y: scaleY).translatedBy(offset)
        default:
            isPressing = false
        }
    }

    private func updatePressedState() {
        let transformAnimation = CASpringAnimation(perceptualDuration: 0.4, bounce: 0.65)
        transformAnimation.keyPath = "transform"
        if isPressing {
            transformAnimation.isAdditive = true
            transformAnimation.toValue = CATransform3D.identity.scaledBy(1.1)
            transformAnimation.fillMode = .both
            transformAnimation.isRemovedOnCompletion = false
            layer.add(transformAnimation, forKey: "transform")
        } else {
            transformAnimation.fromValue = layer.presentation()?.transform
            layer.add(transformAnimation, forKey: "transform")
            layer.transform = .identity
        }

        let updates = {
            self.fieldView.innerShadowView.shadowOffset = CGSize(width: 0, height: self.isPressing ? 10 : 6)
            self.fieldView.innerShadowView.shadowOpacity = self.isPressing ? 0.6 : 1.0
            self.highlightView.alpha = self.isPressing ? 1.0 : 0.0
            self.highlightView.locations = self.isPressing ? [0, 1] : [0, 2.3]
            self.highlightView.updatePropertiesIfNeeded()
        }

        UIView.animate(springDuration: 0.35, bounce: 0.5, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState], animations: updates)
    }

    private static func defaultGlassEffect() -> UIVisualEffect {
        if #available(iOS 26.0, tvOS 26.0, *) {
            return UIGlassEffect(style: .clear)
        }
        #if os(tvOS)
        return UIBlurEffect(style: .regular)
        #else
        return UIBlurEffect.effectWithBlurRadius(0)
        #endif
    }
}

open class LavaLampBlobFieldView: BaseView {
    private static let animationKey = "lavaLamp"
    private static let keyTimes: [NSNumber] = [0, 0.26, 0.58, 0.82, 1]
    private static let blobConfigurations: [BlobOrbitConfiguration] = [
        BlobOrbitConfiguration(
            size: CGSize(width: 0.72, height: 2.38),
            orbitCenter: CGPoint(x: 0.42, y: 0.48),
            orbitRadiusMultiplier: 0.18,
            startAngle: -.pi * 0.12,
            clockwise: true,
            scaleValues: [1.0, 1.18, 0.94, 1.08, 1.0],
            opacityValues: [0.92, 1.0, 0.86, 0.98, 0.92],
            duration: 5.1,
            delay: 0
        ),
        BlobOrbitConfiguration(
            size: CGSize(width: 0.72, height: 2.62),
            orbitCenter: CGPoint(x: 0.60, y: 0.42),
            orbitRadiusMultiplier: 0.24,
            startAngle: -.pi * 0.62,
            clockwise: false,
            scaleValues: [1.0, 0.95, 1.16, 1.02, 1.0],
            opacityValues: [0.94, 0.88, 1.0, 0.92, 0.94],
            duration: 5.9,
            delay: 0.5
        ),
        BlobOrbitConfiguration(
            size: CGSize(width: 0.78, height: 2.0),
            orbitCenter: CGPoint(x: 0.0, y: 0.62),
            orbitRadiusMultiplier: 0.5,
            startAngle: .pi * 0.22,
            clockwise: true,
            scaleValues: [1.0, 1.12, 0.96, 1.1, 1.0],
            opacityValues: [0.88, 0.98, 0.84, 0.94, 0.88],
            duration: 6.5,
            delay: 0.8
        ),
        BlobOrbitConfiguration(
            size: CGSize(width: 0.70, height: 2.7),
            orbitCenter: CGPoint(x: 0.80, y: 0.58),
            orbitRadiusMultiplier: 0.38,
            startAngle: .pi * 0.72,
            clockwise: true,
            scaleValues: [1.0, 1.14, 0.9, 1.05, 1.0],
            opacityValues: [0.86, 0.96, 0.82, 0.9, 0.86],
            duration: 8.6,
            delay: 0.25
        ),
    ]

    private struct BlobOrbitConfiguration {
        let size: CGSize
        let orbitCenter: CGPoint
        let orbitRadiusMultiplier: CGFloat
        let startAngle: CGFloat
        let clockwise: Bool
        let scaleValues: [CGFloat]
        let opacityValues: [CGFloat]
        let duration: CFTimeInterval
        let delay: CFTimeInterval
    }

    public let outerShadowView = UIView()
    public let innerShadowView = UIView()
    public let clippedContentView = UIView()
    public let lavaContentView = UIView()
    public let baseGradientView = GradientView()

    open var baseColor: UIColor = UIColor(red: 0.98, green: 0.62, blue: 0.02, alpha: 1.0) {
        didSet {
            updateDerivedColors()
        }
    }
    open var highlightColor: UIColor? = nil {
        didSet {
            updateDerivedColors()
        }
    }

    open var lavaContentAspectRatio: CGFloat = 3.35 {
        didSet {
            guard lavaContentAspectRatio != oldValue else { return }
            setNeedsLayout()
        }
    }

    private lazy var blobs: [LavaLampBlobView] = Self.blobConfigurations.map { _ in
        LavaLampBlobView(color: baseColor)
    }
    private var hasStartedAnimations = false
    private var animationBoundsSize: CGSize = .zero

    open override func viewDidLoad() {
        super.viewDidLoad()

        backgroundColor = .clear

        outerShadowView.backgroundColor = .clear
        outerShadowView.shadowOpacity = 1
        outerShadowView.shadowRadius = 24
        outerShadowView.shadowOffset = CGSize(width: 0, height: 6)
        addSubview(outerShadowView)

        innerShadowView.backgroundColor = .clear
        innerShadowView.shadowOpacity = 1
        innerShadowView.shadowRadius = 8
        innerShadowView.shadowOffset = CGSize(width: 0, height: 6)
        outerShadowView.addSubview(innerShadowView)

        clippedContentView.clipsToBounds = true
        innerShadowView.addSubview(clippedContentView)

        clippedContentView.addSubview(lavaContentView)

        baseGradientView.locations = [0, 0.5, 1]
        baseGradientView.startPoint = CGPoint(x: 0, y: 0.5)
        baseGradientView.endPoint = CGPoint(x: 1, y: 0.5)
        lavaContentView.addSubview(baseGradientView)

        for blob in blobs {
            lavaContentView.addSubview(blob)
        }

        updateDerivedColors()
    }

    open override func didMoveToWindow() {
        super.didMoveToWindow()
        startAnimationsIfNeeded()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        let radius = bounds.height / 2
        outerShadowView.frameWithoutTransform = bounds
        innerShadowView.frameWithoutTransform = outerShadowView.bounds
        clippedContentView.frameWithoutTransform = innerShadowView.bounds

        outerShadowView.cornerRadius = radius
        innerShadowView.cornerRadius = radius
        clippedContentView.cornerRadius = radius

        let shadowPath = UIBezierPath(roundedRect: outerShadowView.bounds, cornerRadius: radius).cgPath
        outerShadowView.layer.shadowPath = shadowPath
        innerShadowView.layer.shadowPath = shadowPath

        lavaContentView.frameWithoutTransform = aspectFillFrame(
            in: clippedContentView.bounds,
            aspectRatio: lavaContentAspectRatio
        )
        baseGradientView.frameWithoutTransform = lavaContentView.bounds

        if animationBoundsSize != lavaContentView.bounds.size {
            animationBoundsSize = lavaContentView.bounds.size
            hasStartedAnimations = false
            for blob in blobs {
                blob.layer.removeAnimation(forKey: Self.animationKey)
            }
        }

        for (blob, configuration) in zip(blobs, Self.blobConfigurations) {
            let size = CGSize(
                width: lavaContentView.bounds.width * configuration.size.width,
                height: lavaContentView.bounds.height * configuration.size.height
            )
            let origin = pointOnOrbit(
                around: resolvedOrbitCenter(for: configuration),
                radius: lavaContentView.bounds.width * configuration.orbitRadiusMultiplier,
                angle: configuration.startAngle
            )
            blob.frameWithoutTransform = CGRect(center: origin, size: size)
        }

        startAnimationsIfNeeded()
    }

    private func startAnimationsIfNeeded() {
        guard window != nil, lavaContentView.bounds.width > 0, lavaContentView.bounds.height > 0, !hasStartedAnimations else { return }
        hasStartedAnimations = true

        for (blob, configuration) in zip(blobs, Self.blobConfigurations) {
            animate(
                blob,
                orbitCenter: resolvedOrbitCenter(for: configuration),
                orbitRadius: lavaContentView.bounds.width * configuration.orbitRadiusMultiplier,
                startAngle: configuration.startAngle,
                clockwise: configuration.clockwise,
                scaleValues: configuration.scaleValues,
                opacityValues: configuration.opacityValues,
                duration: configuration.duration,
                delay: configuration.delay
            )
        }
    }

    private func animate(
        _ view: UIView,
        orbitCenter: CGPoint,
        orbitRadius: CGFloat,
        startAngle: CGFloat,
        clockwise: Bool,
        scaleValues: [CGFloat],
        opacityValues: [CGFloat],
        duration: CFTimeInterval,
        delay: CFTimeInterval
    ) {
        let timingFunctions = Array(repeating: CAMediaTimingFunction(name: .easeInEaseOut), count: Self.keyTimes.count - 1)

        let orbit = CAKeyframeAnimation(keyPath: "position")
        orbit.path = UIBezierPath(
            arcCenter: orbitCenter,
            radius: orbitRadius,
            startAngle: startAngle,
            endAngle: startAngle + (clockwise ? CGFloat.pi * 2 : -CGFloat.pi * 2),
            clockwise: clockwise
        ).cgPath
        orbit.calculationMode = .paced
        orbit.timingFunction = CAMediaTimingFunction(name: .linear)

        let scale = CAKeyframeAnimation(keyPath: "transform.scale")
        scale.values = scaleValues
        scale.keyTimes = Self.keyTimes
        scale.timingFunctions = timingFunctions

        let opacity = CAKeyframeAnimation(keyPath: "opacity")
        opacity.values = opacityValues
        opacity.keyTimes = Self.keyTimes
        opacity.timingFunctions = timingFunctions

        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [orbit, scale, opacity]
        animationGroup.duration = duration
        animationGroup.repeatCount = .infinity
        animationGroup.beginTime = CACurrentMediaTime() + delay
        animationGroup.isRemovedOnCompletion = false

        view.layer.add(animationGroup, forKey: Self.animationKey)
    }

    private func pointOnOrbit(around center: CGPoint, radius: CGFloat, angle: CGFloat) -> CGPoint {
        CGPoint(
            x: center.x + cos(angle) * radius,
            y: center.y + sin(angle) * radius
        )
    }

    private func resolvedOrbitCenter(for configuration: BlobOrbitConfiguration) -> CGPoint {
        CGPoint(
            x: lavaContentView.bounds.width * configuration.orbitCenter.x,
            y: lavaContentView.bounds.height * configuration.orbitCenter.y
        )
    }

    private func aspectFillFrame(in bounds: CGRect, aspectRatio: CGFloat) -> CGRect {
        guard bounds.width > 0, bounds.height > 0, aspectRatio > 0 else {
            return bounds
        }

        let boundsAspectRatio = bounds.width / bounds.height
        let size: CGSize
        if boundsAspectRatio > aspectRatio {
            size = CGSize(width: bounds.width, height: bounds.width / aspectRatio)
        } else {
            size = CGSize(width: bounds.height * aspectRatio, height: bounds.height)
        }

        return CGRect(center: bounds.center, size: size)
    }

    private func updateDerivedColors() {
        let base = baseColor
        let highlight = highlightColor ?? derivedHighlightColor(from: base)
        let molten = adjustedColor(
            base.dynamicMixWithColor(highlight, amount: 0.16),
            saturationMultiplier: 1.06,
            brightnessMultiplier: 0.98
        )
        let warm = adjustedColor(
            base.dynamicMixWithColor(highlight, amount: 0.38),
            saturationMultiplier: 1.0,
            brightnessMultiplier: 1.02
        )
        let glow = adjustedColor(
            base.dynamicMixWithColor(highlight, amount: 0.68),
            saturationMultiplier: 0.9,
            brightnessMultiplier: 1.08
        )
        let pale = adjustedColor(
            base.dynamicMixWithColor(highlight, amount: 0.92),
            saturationMultiplier: 0.76,
            brightnessMultiplier: 1.16
        )

        outerShadowView.shadowColor = adjustedColor(
            base.dynamicMixWithColor(highlight, amount: 0.2),
            saturationMultiplier: 0.96,
            brightnessMultiplier: 1.02,
            alpha: 0.34
        )
        innerShadowView.shadowColor = adjustedColor(
            base.dynamicMixWithColor(highlight, amount: 0.28),
            saturationMultiplier: 0.98,
            brightnessMultiplier: 1.04,
            alpha: 0.7
        )

        baseGradientView.colors = [
            pale,
            base,
            glow,
        ]

        for (blob, color) in zip(blobs, [molten, base, warm, glow]) {
            blob.blobColor = color
        }
    }

    private func derivedHighlightColor(from baseColor: UIColor) -> UIColor {
        adjustedColor(
            baseColor.dynamicMixWithColor(.white, amount: 0.4),
            saturationMultiplier: 0.82,
            brightnessMultiplier: 1.04
        )
    }

    private func adjustedColor(
        _ color: UIColor,
        hueOffset: CGFloat = 0,
        saturationMultiplier: CGFloat = 1,
        brightnessMultiplier: CGFloat = 1,
        alpha: CGFloat? = nil
    ) -> UIColor {
        UIColor(
            dark: adjustedResolvedColor(
                color.darkMode,
                hueOffset: hueOffset,
                saturationMultiplier: saturationMultiplier,
                brightnessMultiplier: brightnessMultiplier,
                alpha: alpha
            ),
            light: adjustedResolvedColor(
                color.lightMode,
                hueOffset: hueOffset,
                saturationMultiplier: saturationMultiplier,
                brightnessMultiplier: brightnessMultiplier,
                alpha: alpha
            )
        )
    }

    private func adjustedResolvedColor(
        _ color: UIColor,
        hueOffset: CGFloat = 0,
        saturationMultiplier: CGFloat = 1,
        brightnessMultiplier: CGFloat = 1,
        alpha: CGFloat? = nil
    ) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var resolvedAlpha: CGFloat = 0

        guard color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &resolvedAlpha) else {
            return color.withAlphaComponent(alpha ?? resolvedAlpha)
        }

        var wrappedHue = (hue + hueOffset).truncatingRemainder(dividingBy: 1)
        if wrappedHue < 0 {
            wrappedHue += 1
        }

        return UIColor(
            hue: wrappedHue,
            saturation: max(0, min(1, saturation * saturationMultiplier)),
            brightness: max(0, min(1, brightness * brightnessMultiplier)),
            alpha: alpha ?? resolvedAlpha
        )
    }
}

private final class LavaLampBlobView: GradientView {
    var blobColor: UIColor {
        didSet {
            applyBlobColor()
        }
    }

    init(color: UIColor) {
        blobColor = color
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        isUserInteractionEnabled = false
        gradientLayer.type = .radial
        startPoint = CGPoint(x: 0.5, y: 0.5)
        endPoint = CGPoint(x: 1.0, y: 1.0)
        locations = [0, 1]
        easeFunctions = [.easeInOut]
        applyBlobColor()
    }

    private func applyBlobColor() {
        colors = [
            blobColor,
            blobColor.withAlphaComponent(0),
        ]
    }
}
