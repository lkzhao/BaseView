import UIKit
import BaseView
import UIComponent
import BaseToolbox
import Motion

final class DemoViewController: UIViewController {
    private let rootView = DemoRootView()

    override func loadView() {
        view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "BaseView Example"
    }
}

private final class DemoRootView: BaseView {
    @available(iOS 26.0, *)
    let sheetView = SheetView().then {
        let smallDetent = SheetView.Detent.custom(id: "small") {
            .init(height: 60, insets: UIEdgeInsets(left: 16, bottom: 32, right: 16))
        }
        $0.detents = [
            .large(),
            .medium(),
            smallDetent
        ]
        $0.setCurrentDetent(smallDetent, animated: false)
        $0.contentView.componentEngine.component = VStack(spacing: 16) {
            Text("SheetView", font: .boldSystemFont(ofSize: 32))
            for i in 0...100 {
                Text("Sheet Item \(i)", font: .systemFont(ofSize: 16))
            }
        }.inset(v: 30, h: 20).scrollView().fill()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundColor = .systemBackground
        ClassRuntimePrinter.printInfo(for: "_UIFlexInteraction")
    }

    override func updateProperties() {
        super.updateProperties()
        componentEngine.component = VStack(spacing: 36) {
            DemoCard(
                title: "BaseView",
                detail: "Base class with viewDidLoad/updateProperties hooks and shadow-path support.",
                preview: ViewComponent<BaseViewExampleView>()
                    .size(width: .fill, height: 84)
            )

            DemoCard(
                title: "WrapperView<UILabel>",
                detail: "Generic container that insets and sizes its contentView automatically.",
                preview: ViewComponent<LabelWrapperDemoView>()
                    .size(width: .fill, height: 84)
            )

            DemoCard(
                title: "GradientView",
                detail: "CAGradientLayer-backed view with resolved dynamic colors.",
                preview: ZStack {
                    ViewComponent<GradientView>()
                        .colors([
                            UIColor(red: 0.07, green: 0.31, blue: 0.64, alpha: 1.0),
                            UIColor(red: 0.06, green: 0.53, blue: 0.72, alpha: 1.0),
                            UIColor(red: 0.10, green: 0.65, blue: 0.46, alpha: 1.0)
                        ])
                        .locations([0.0, 0.5, 1.0])
                        .startPoint(CGPoint(x: 0.0, y: 0.0))
                        .endPoint(CGPoint(x: 1.0, y: 1.0))
                        .cornerRadius(16)
                        .size(width: .fill, height: 84)
                    Text("Linear Gradient", font: .boldSystemFont(ofSize: 20))
                        .textColor(.white)
                }
            )

            DemoCard(
                title: "ShimmerView",
                detail: "Animated gradient that continuously sweeps highlight locations.",
                preview: ViewComponent<ShimmerView>()
                    .baseColor(UIColor(red: 0.14, green: 0.18, blue: 0.32, alpha: 1.0))
                    .shimmerColor(UIColor(red: 0.57, green: 0.75, blue: 0.96, alpha: 1.0))
                    .shimmerDuration(1.1)
                    .size(width: .fill, height: 58)
                    .cornerRadius(16)
            )

            DemoCard(
                title: "ShimmerLabel",
                detail: "Text masked by a moving shimmer gradient.",
                preview: ViewComponent<ShimmerLabel>()
                    .text("ShimmerLabel Demo")
                    .with(\.font, .boldSystemFont(ofSize: 22))
                    .textAlignment(.center)
                    .baseColor(UIColor(red: 0.22, green: 0.26, blue: 0.36, alpha: 1.0))
                    .shimmerColor(UIColor(red: 0.86, green: 0.91, blue: 0.99, alpha: 1.0))
                    .view()
                    .backgroundColor(.secondarySystemBackground)
                    .cornerRadius(16)
                    .size(width: .fill, height: 58)
            )

            DemoCard(
                title: "VisualEffectView",
                detail: "Adjust effect intensity and pick different blur styles.",
                preview: ViewComponent<VisualEffectIntensityDemoView>()
                    .size(width: .fill, height: 380)
            )

            DemoCard(
                title: "Glass Lava Button",
                detail: "Same glass button rendered with different base and highlight pairs.",
                preview: VStack(spacing: 16) {
                        GlassLavaButtonExample(
                            title: "Create",
                            symbolName: "plus",
                            baseColor: UIColor(red: 0.98, green: 0.62, blue: 0.02, alpha: 1.0),
                            highlightColor: UIColor(red: 1.00, green: 0.86, blue: 0.43, alpha: 1.0)
                        )
                        GlassLavaButtonExample(
                            title: "Share",
                            symbolName: "paperplane.fill",
                            baseColor: .systemBlue,
                            highlightColor: .systemPurple
                        )
                        GlassLavaButtonExample(
                            title: "Save",
                            symbolName: "bookmark.fill",
                            baseColor: .systemGreen
                        )
                    }
                    .inset(20)
                    .centered()
                    .size(width: .fill, height: 288)
                    .cornerRadius(14)
                    .backgroundColor(.secondarySystemBackground)
            )

            DemoCard(
                title: "BackdropView",
                detail: "Private CABackdropLayer wrapper with a blur overlay on top of BackgroundCirclesView.",
                preview: ViewComponent<BackdropDemoView>()
                    .size(width: .fill, height: 160)
            )

            DemoCard(
                title: "Backdrop Filter Study",
                detail: "Visualize the private filter stack pieces used by the active floating tab bar.",
                preview: ViewComponent<BackdropFilterStudyView>()
                    .measureSize(key: "backdrop")
            )

            DemoCard(
                title: "LensView",
                detail: "A clear lens that lifts on press.",
                preview: ViewComponent<LensDemoView>()
                    .size(width: .fill, height: 160)
            )
            
            DemoCard(
                title: "Loupe View",
                detail: "A magnifying loupe view that zooms.",
                preview: ViewComponent<LoupeDemoView>()
                    .size(width: .fill, height: 160)
            )

            DemoCard(
                title: "PressBackInteraction",
                detail: "Press to push the card backward in 3D; tilt follows your finger position.",
                preview: ViewComponent<PressBackInteractionDemoView>()
                    .size(width: .fill, height: 190)
            )

            DemoCard(
                title: "PortalPairView",
                detail: "Tap to spring-animate progress and frame interpolation between two label anchors.",
                preview: ViewComponent<PortalPairDemoView>()
                    .size(width: .fill, height: 170)
            )

            DemoCard(
                title: "ShapeView",
                detail: "CAShapeLayer-backed vector view with stroke and fill controls.",
                preview: ViewComponent<BadgeShapeDemoView>()
                    .size(width: .fill, height: 84)
            )
        }
        .inset(20)
        .inset(bottom: 120)
        .scrollView()
        .fill()
        .overlay {
            sheetView
        }
    }
}

private struct DemoCard<Content: Component>: ComponentBuilder {
    let title: String
    let detail: String
    let preview: Content

    func build() -> some Component {
        VStack(spacing: 10) {
            VStack(spacing: 4) {
                Text(title, font: .boldSystemFont(ofSize: 18))
                Text(detail, font: .systemFont(ofSize: 14))
                    .textColor(.secondaryLabel)
            }
            preview
        }
    }
}

private struct GlassLavaButtonExample: ComponentBuilder {
    let title: String
    let symbolName: String
    let baseColor: UIColor
    let highlightColor: UIColor?

    init(title: String, symbolName: String, baseColor: UIColor, highlightColor: UIColor? = nil) {
        self.title = title
        self.symbolName = symbolName
        self.baseColor = baseColor
        self.highlightColor = highlightColor
    }

    func build() -> some Component {
        HStack(spacing: 8, alignItems: .center) {
            Image(
                systemName: symbolName,
                withConfiguration: UIImage.SymbolConfiguration(font: .boldSystemFont(ofSize: 22))
            )
            .tintColor(.white)
            Text(title, font: .boldSystemFont(ofSize: 22))
                .textColor(.white)
        }
        .inset(h: 20, v: 12)
        .view(as: LavaLampView.self)
        .with(\.fieldView.baseColor, baseColor)
        .with(\.fieldView.highlightColor, highlightColor)
    }
}

class LavaLampView: BaseView, ViewWrapperComponentView {
    let fieldView = LavaLampBlobFieldView()
    let glassView = UIVisualEffectView(effect: UIGlassEffect(style: .clear))
    let gradientView = GradientView()

    private lazy var pressRecognizer = SimultaneousPressGestureRecognizer(
        target: self,
        action: #selector(handlePress(_:))
    )
    private var initialTouchPoint: CGPoint = .zero
    private var isPressing = false {
        didSet {
            guard oldValue != isPressing else { return }
            let anim = CASpringAnimation(perceptualDuration: 0.4, bounce: 0.65)
            anim.keyPath = "transform"
            if isPressing {
                anim.isAdditive = true
                anim.toValue = CATransform3D.identity.scaledBy(1.1)
                anim.fillMode = .both
                anim.isRemovedOnCompletion = false
                layer.add(anim, forKey: "transform")
            } else {
                anim.fromValue = layer.presentation()?.transform
                layer.add(anim, forKey: "transform")
                layer.transform = .identity
            }
            UIView.animate(springDuration: 0.35, bounce: 0.5, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
                self.fieldView.innerShadowView.shadowOffset = CGSize(width: 0, height: self.isPressing ? 10 : 6)
                self.fieldView.innerShadowView.shadowOpacity = self.isPressing ? 0.6 : 1.0
                self.gradientView.alpha = self.isPressing ? 1.0 : 0.0
                self.gradientView.locations = self.isPressing ? [0, 1] : [0, 2.3]
                self.gradientView.updatePropertiesIfNeeded()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubview(fieldView)
        addSubview(glassView)
        addSubview(gradientView)
        gradientView.colors = [.white.applyingContentHeadroom(1.5).withAlphaComponent(0.4), .white.applyingContentHeadroom(1.5).withAlphaComponent(0.0)]
        gradientView.gradientLayer.type = .radial
        gradientView.locations = [0, 1]
        gradientView.easeFunctions = [.easeInOut]
        gradientView.clipsToBounds = true
        gradientView.alpha = 0
        addGestureRecognizer(pressRecognizer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        fieldView.frameWithoutTransform = bounds
        glassView.frameWithoutTransform = bounds
        gradientView.frameWithoutTransform = bounds
        glassView.cornerRadius = bounds.height / 2
        fieldView.cornerRadius = bounds.height / 2
        gradientView.cornerRadius = bounds.height / 2
    }
    
    var contentComponentEngine: ComponentEngine {
        glassView.contentView.componentEngine
    }
    
    @objc private func handlePress(_ gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: self)

        switch gesture.state {
        case .began:
            isPressing = true
            initialTouchPoint = location
            fallthrough
        case .changed:
            gradientView.startPoint = location / bounds.size
            gradientView.endPoint = (location / bounds.size) + CGSize(width: 1, height: 1).size(fill: bounds.size) / bounds.size * 0.6
            let translation = location - initialTouchPoint
            let scaleX = 1.0 + abs(translation.x) * 0.0005
            let scaleY = 1.0 + abs(translation.y) * 0.0005
            let offset = translation * 0.03
            transform = CGAffineTransform.identity.scaledBy(x: scaleX, y: scaleY).translatedBy(offset)
        default:
            isPressing = false
        }
    }
}

final class LavaLampBlobFieldView: BaseView {
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

    let outerShadowView = UIView()
    let innerShadowView = UIView()
    let clippedContentView = UIView()
    let baseGradientView = GradientView()
    var baseColor: UIColor = UIColor(red: 0.98, green: 0.62, blue: 0.02, alpha: 1.0) {
        didSet {
            updateDerivedColors()
        }
    }
    var highlightColor: UIColor? = nil {
        didSet {
            updateDerivedColors()
        }
    }
    private let blobConfigurations: [BlobOrbitConfiguration] = [
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
    private lazy var blobs: [LavaLampBlobView] = (0..<4).map { _ in
        LavaLampBlobView(color: baseColor)
    }
    private var hasStartedAnimations = false
    private var animationBoundsSize: CGSize = .zero

    override func viewDidLoad() {
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

        baseGradientView.locations = [0, 0.5, 1]
        baseGradientView.startPoint = CGPoint(x: 0, y: 0.5)
        baseGradientView.endPoint = CGPoint(x: 1, y: 0.5)
        clippedContentView.addSubview(baseGradientView)

        for blob in blobs {
            clippedContentView.addSubview(blob)
        }

        updateDerivedColors()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        startAnimationsIfNeeded()
    }

    override func layoutSubviews() {
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

        baseGradientView.frameWithoutTransform = clippedContentView.bounds

        if animationBoundsSize != bounds.size {
            animationBoundsSize = bounds.size
            hasStartedAnimations = false
            for blob in blobs {
                blob.layer.removeAnimation(forKey: "lavaLamp")
            }
        }

        for (blob, configuration) in zip(blobs, blobConfigurations) {
            let size = CGSize(
                width: clippedContentView.bounds.width * configuration.size.width,
                height: clippedContentView.bounds.height * configuration.size.height
            )
            let origin = pointOnOrbit(
                around: resolvedOrbitCenter(for: configuration),
                radius: clippedContentView.bounds.width * configuration.orbitRadiusMultiplier,
                angle: configuration.startAngle
            )
            blob.frameWithoutTransform = CGRect(center: origin, size: size)
        }

        startAnimationsIfNeeded()
    }

    private func startAnimationsIfNeeded() {
        guard window != nil, bounds.width > 0, bounds.height > 0, !hasStartedAnimations else { return }
        hasStartedAnimations = true

        for (blob, configuration) in zip(blobs, blobConfigurations) {
            animate(
                blob,
                orbitCenter: resolvedOrbitCenter(for: configuration),
                orbitRadius: clippedContentView.bounds.width * configuration.orbitRadiusMultiplier,
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
        let keyTimes: [NSNumber] = [0, 0.26, 0.58, 0.82, 1]
        let timingFunctions = Array(repeating: CAMediaTimingFunction(name: .easeInEaseOut), count: keyTimes.count - 1)

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
        scale.keyTimes = keyTimes
        scale.timingFunctions = timingFunctions

        let opacity = CAKeyframeAnimation(keyPath: "opacity")
        opacity.values = opacityValues
        opacity.keyTimes = keyTimes
        opacity.timingFunctions = timingFunctions

        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [orbit, scale, opacity]
        animationGroup.duration = duration
        animationGroup.repeatCount = .infinity
        animationGroup.beginTime = CACurrentMediaTime() + delay
        animationGroup.isRemovedOnCompletion = false

        view.layer.add(animationGroup, forKey: "lavaLamp")
    }

    private func pointOnOrbit(around center: CGPoint, radius: CGFloat, angle: CGFloat) -> CGPoint {
        CGPoint(
            x: center.x + cos(angle) * radius,
            y: center.y + sin(angle) * radius
        )
    }

    private func resolvedOrbitCenter(for configuration: BlobOrbitConfiguration) -> CGPoint {
        CGPoint(
            x: clippedContentView.bounds.width * configuration.orbitCenter.x,
            y: clippedContentView.bounds.height * configuration.orbitCenter.y
        )
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
            glow
        ]

        blobs[0].blobColor = molten
        blobs[1].blobColor = base
        blobs[2].blobColor = warm
        blobs[3].blobColor = glow
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
            blobColor.withAlphaComponent(0)
        ]
    }
}

private final class BaseViewExampleView: BaseView {
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundColor = UIColor.systemBlue.withAlphaComponent(0.18)
        cornerRadius = 14
    }

    override func updateProperties() {
        super.updateProperties()
        componentEngine.component = VStack {
            Text("BaseView provides viewDidLoad and updateProperties hooks for setup and dynamic updates.")
                .font(.systemFont(ofSize: 14, weight: .medium))
        }.inset(12)
    }
}

private final class LabelWrapperDemoView: WrapperView<UILabel> {
    override func viewDidLoad() {
        super.viewDidLoad()

        inset = UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14)
        backgroundColor = UIColor.systemGreen.withAlphaComponent(0.18)
        cornerRadius = 16
        clipsToBounds = true

        contentView.text = "WrapperView controls insets and delegates sizing to contentView."
        contentView.textAlignment = .center
        contentView.numberOfLines = 0
        contentView.font = .systemFont(ofSize: 14, weight: .medium)
    }
}

private final class VisualEffectIntensityDemoView: BaseView {
    private struct EffectOption {
        let title: String
        let effect: UIVisualEffect?
    }

    private let effectOptions: [EffectOption] = [
        EffectOption(title: "Material", effect: UIBlurEffect(style: .systemMaterial)),
        EffectOption(title: "Thin", effect: UIBlurEffect(style: .systemThinMaterial)),
        EffectOption(title: "Thick", effect: UIBlurEffect(style: .systemThickMaterial)),
        EffectOption(title: "Chrome", effect: UIBlurEffect(style: .systemChromeMaterial)),
        EffectOption(title: "Ultra Thin", effect: UIBlurEffect(style: .systemUltraThinMaterial)),
        EffectOption(title: "Regular Glass", effect: UIGlassEffect(style: .regular)),
        EffectOption(title: "Clear Glass", effect: UIGlassEffect(style: .clear)),
        EffectOption(title: "Variable Blur", effect: UIBlurEffect.variable(direction: .topToBottom, radius: 8)),
        EffectOption(title: "Variable Blur (Horizontal)", effect: UIBlurEffect.variable(direction: .leftToRight, radius: 8)),
    ]

    private var intensity: CGFloat = 0.6 {
        didSet {
            guard intensity != oldValue else { return }
            setNeedsUpdateProperties()
        }
    }

    private var selectedEffectIndex: Int = 0 {
        didSet {
            guard selectedEffectIndex != oldValue else { return }
            setNeedsUpdateProperties()
        }
    }

    private var selectedEffect: UIVisualEffect? {
        effectOptions[selectedEffectIndex].effect
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        backgroundColor = .secondarySystemBackground
        cornerRadius = 16
        clipsToBounds = true
    }

    override func updateProperties() {
        super.updateProperties()
        componentEngine.component = VStack(spacing: 8) {
            ViewComponent<VisualEffectBackdropView>()
                .intensity(intensity)
                .visualEffect(selectedEffect)
                .size(width: .fill, height: 140)

            Text("Intensity: \(String(format: "%.2f", intensity))", font: .systemFont(ofSize: 13, weight: .semibold))
                .textColor(.label)

            ViewComponent<IntensitySlider>()
                .minimumValue(0)
                .maximumValue(1)
                .value(intensity)
                .onValueChanged { [weak self] value in
                    self?.intensity = value
                }
                .size(width: .fill, height: 28)

            Text("Effect: \(effectOptions[selectedEffectIndex].title)", font: .systemFont(ofSize: 13, weight: .semibold))
                .textColor(.label)

            ViewComponent<EffectPicker>()
                .titles(effectOptions.map(\.title))
                .selectedIndex(selectedEffectIndex)
                .onSelectionChanged { [weak self] index in
                    self?.selectedEffectIndex = index
                }
                .fill()
                .flex()
        }
        .inset(12)
        .fill()
    }
}

private final class VisualEffectBackdropView: BaseView {
    var intensity: CGFloat = 0.6 {
        didSet {
            guard intensity != oldValue else { return }
            setNeedsUpdateProperties()
        }
    }

    var visualEffect: UIVisualEffect? = UIBlurEffect(style: .systemMaterial) {
        didSet {
            setNeedsUpdateProperties()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundColor = UIColor(red: 0.18, green: 0.22, blue: 0.42, alpha: 1.0)
        cornerRadius = 10
        clipsToBounds = true
    }

    override func updateProperties() {
        super.updateProperties()
        componentEngine.component = ZStack {
            ViewComponent<BackgroundCirclesView>().fill()

            Text("Blur Sample", font: .boldSystemFont(ofSize: 20))
                .textColor(UIColor.white.withAlphaComponent(0.95))

            ViewComponent<UIVisualEffectView>()
                .effect(visualEffect)
                .effectIntensity(intensity)
                .size(width: 200, height: .fill)
                .cornerRadius(20)
                .inset(20)
        }
    }
}

private final class BackdropDemoView: BaseView {
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundColor = UIColor(red: 0.18, green: 0.22, blue: 0.42, alpha: 1.0)
        cornerRadius = 16
        clipsToBounds = true
    }

    override func updateProperties() {
        super.updateProperties()
        componentEngine.component = ZStack {
            ViewComponent<BackgroundCirclesView>().fill()

            ZStack {
                ViewComponent<BackdropView>()
                    .blurRadius(28)
                    .backdropScale(0.5)
                    .allowsInPlaceFiltering(true)
                    .bleedAmount(0.12)
                    .fill()

                VStack(spacing: 4, alignItems: .center) {
                    Text("BackdropView", font: .boldSystemFont(ofSize: 20))
                        .textColor(UIColor.white.withAlphaComponent(0.96))

                    Text("CABackdropLayer + gaussianBlur", font: .systemFont(ofSize: 12, weight: .semibold))
                        .textColor(UIColor.white.withAlphaComponent(0.8))
                }
            }
            .backgroundColor(UIColor.white.withAlphaComponent(0.14))
            .cornerRadius(24)
            .size(width: 228, height: 92)
            .inset(20)
        }
    }
}

private struct BackdropFilterStudyRow<Preview: Component>: ComponentBuilder {
    let title: String
    let detail: String
    let preview: Preview

    func build() -> some Component {
        VStack(spacing: 6) {
            VStack(spacing: 2) {
                Text(title, font: .systemFont(ofSize: 13, weight: .semibold))
                    .textColor(.label)

                Text(detail, font: .systemFont(ofSize: 11))
                    .textColor(.secondaryLabel)
            }

            preview
        }
    }
}

private final class BackdropFilterStudyView: BaseView {
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundColor = .secondarySystemBackground
        cornerRadius = 16
        clipsToBounds = true
    }

    override func updateProperties() {
        super.updateProperties()
        componentEngine.component = VStack(spacing: 12) {
            BackdropFilterStudyRow(
                title: "gaussianBlur",
                detail: "The actual tab pill uses radius 2 on its CABackdropLayer. Larger radii show the capture stage clearly.",
                preview: ViewComponent<BackdropFilterPreviewView>()
                    .update { $0.recipe = .blurOnly }
                    .size(width: .fill, height: 108)
            )

            BackdropFilterStudyRow(
                title: "gaussianBlur + colorMatrix",
                detail: "Blur first, then remap sampled colors with a 20-value RGBA matrix. The private filter expects `[NSNumber]`, not raw bytes.",
                preview: ViewComponent<BackdropFilterPreviewView>()
                    .update { $0.recipe = .tabSelection }
                    .size(width: .fill, height: 108)
            )

            BackdropFilterStudyRow(
                title: "Hard Invert Matrix",
                detail: "A plain 4x5 invert matrix makes the remap obvious. This is stronger than UIKit's tuned matrix but easier to reason about.",
                preview: ViewComponent<BackdropFilterPreviewView>()
                    .update { $0.recipe = .hardInvert }
                    .size(width: .fill, height: 108)
            )

            BackdropFilterStudyRow(
                title: "vibrantColorMatrix on Foreground",
                detail: "UIKit applies a second matrix to icon and label layers. This sample leaves the backdrop mild and remaps the foreground instead.",
                preview: ViewComponent<BackdropFilterPreviewView>()
                    .update { $0.recipe = .vibrantForeground }
                    .size(width: .fill, height: 108)
            )

            BackdropFilterStudyRow(
                title: "opacityPair",
                detail: "This uses `inputAmount` to rebalance two translucent passes. A side-by-side comparison makes the paired alpha response much easier to spot.",
                preview: ViewComponent<OpacityPairPreviewView>()
                    .size(width: .fill, height: 124)
            )

            BackdropFilterStudyRow(
                title: "displacementMap",
                detail: "The raw filter takes `inputAmount`, but UIKit's visible glass warp comes from a private clear-glass host supplying the displacement field.",
                preview: ViewComponent<DisplacementMapPreviewView>()
                    .size(width: .fill, height: 132)
            )
        }
        .inset(12)
        .fill()
    }
}

private enum BackdropFilterRecipe {
    case blurOnly
    case tabSelection
    case hardInvert
    case vibrantForeground

    var title: String {
        switch self {
        case .blurOnly:
            "Blur Only"
        case .tabSelection:
            "Tab-style Matrix"
        case .hardInvert:
            "Invert Matrix"
        case .vibrantForeground:
            "Vibrant Foreground"
        }
    }

    var subtitle: String {
        switch self {
        case .blurOnly:
            "gaussianBlur(radius: 18)"
        case .tabSelection:
            "blur 2 + tab lift matrix"
        case .hardInvert:
            "blur 2 + invert matrix"
        case .vibrantForeground:
            "foreground vibrantColorMatrix"
        }
    }

    var symbolName: String {
        switch self {
        case .blurOnly:
            "drop.fill"
        case .tabSelection:
            "circle.lefthalf.filled"
        case .hardInvert:
            "circle.righthalf.filled.inverse"
        case .vibrantForeground:
            "sparkles"
        }
    }

    var tintAlpha: CGFloat {
        switch self {
        case .blurOnly:
            0.12
        case .tabSelection:
            0.18
        case .hardInvert:
            0.08
        case .vibrantForeground:
            0.16
        }
    }

    var contentColor: UIColor {
        switch self {
        case .hardInvert:
            UIColor.black.withAlphaComponent(0.92)
        case .vibrantForeground:
            UIColor(red: 1.0, green: 0.97, blue: 0.88, alpha: 1.0)
        default:
            UIColor.white.withAlphaComponent(0.96)
        }
    }

    func makeBackdropFilters() -> [Any] {
        switch self {
        case .blurOnly:
            return [
                BackdropView.makeGaussianBlurFilter(radius: 18, normalizeEdges: true)
            ].compactMap { $0 }

        case .tabSelection:
            return [
                BackdropView.makeGaussianBlurFilter(radius: 2, normalizeEdges: true),
                BackdropView.makeColorMatrixFilter(matrix: BackdropFilterMatrices.tabSelectionBackdrop)
            ].compactMap { $0 }

        case .hardInvert:
            return [
                BackdropView.makeGaussianBlurFilter(radius: 2, normalizeEdges: true),
                BackdropView.makeColorMatrixFilter(matrix: BackdropFilterMatrices.invert)
            ].compactMap { $0 }

        case .vibrantForeground:
            return [
                BackdropView.makeGaussianBlurFilter(radius: 8, normalizeEdges: true),
                BackdropView.makeColorMatrixFilter(matrix: BackdropFilterMatrices.softLift)
            ].compactMap { $0 }
        }
    }

    func makeForegroundFilters() -> [Any] {
        switch self {
        case .vibrantForeground:
            return [
                BackdropView.makeVibrantColorMatrixFilter(matrix: BackdropFilterMatrices.foregroundVibrant)
            ].compactMap { $0 }

        default:
            return []
        }
    }
}

private enum BackdropFilterMatrices {
    static let softLift: [Float] = [
        1.18, -0.05, -0.01, 0.00, 0.06,
        -0.03, 1.14, -0.03, 0.00, 0.08,
        -0.02, -0.06, 1.20, 0.00, 0.10,
        0.00, 0.00, 0.00, 1.00, 0.00
    ]

    // Approximates the live tab-bar backdrop pass: a small blur plus a lifted color remap.
    static let tabSelectionBackdrop: [Float] = [
        1.18, -0.05, -0.01, 0.00, 0.08,
        -0.04, 1.15, -0.03, 0.00, 0.10,
        -0.02, -0.06, 1.22, 0.00, 0.14,
        0.00, 0.00, 0.00, 1.00, 0.00
    ]

    static let invert: [Float] = [
        -1.00, 0.00, 0.00, 0.00, 1.00,
        0.00, -1.00, 0.00, 0.00, 1.00,
        0.00, 0.00, -1.00, 0.00, 1.00,
        0.00, 0.00, 0.00, 1.00, 0.00
    ]

    static let foregroundVibrant: [Float] = [
        0.50, 0.00, 0.00, 0.00, 0.30,
        0.00, 0.50, 0.00, 0.00, 0.30,
        0.00, 0.00, 0.50, 0.00, 0.30,
        0.00, 0.00, 0.00, 1.00, 0.00
    ]
}

private final class BackdropFilterPreviewView: BaseView {
    var recipe: BackdropFilterRecipe = .blurOnly {
        didSet {
            setNeedsUpdateProperties()
        }
    }

    private let circlesView = BackgroundCirclesView()
    private let pillView = UIView()
    private let backdropView = BackdropView()
    private let tintView = UIView()
    private let contentFilterView = UIView()
    private let symbolView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundColor = UIColor(red: 0.18, green: 0.22, blue: 0.42, alpha: 1.0)
        cornerRadius = 16
        clipsToBounds = true

        addSubview(circlesView)

        pillView.cornerRadius = 24
        pillView.clipsToBounds = true
        addSubview(pillView)

        pillView.addSubview(backdropView)

        tintView.isUserInteractionEnabled = false
        pillView.addSubview(tintView)

        contentFilterView.isUserInteractionEnabled = false
        pillView.addSubview(contentFilterView)

        symbolView.contentMode = .scaleAspectFit
        contentFilterView.addSubview(symbolView)

        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.8
        contentFilterView.addSubview(titleLabel)

        subtitleLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.minimumScaleFactor = 0.8
        contentFilterView.addSubview(subtitleLabel)
    }

    override func updateProperties() {
        super.updateProperties()

        backdropView.backdropFilters = recipe.makeBackdropFilters()
        tintView.backgroundColor = UIColor.white.withAlphaComponent(recipe.tintAlpha)
        contentFilterView.layer.filters = recipe.makeForegroundFilters()

        symbolView.image = UIImage(systemName: recipe.symbolName)
        symbolView.tintColor = recipe.contentColor

        titleLabel.text = recipe.title
        titleLabel.textColor = recipe.contentColor

        subtitleLabel.text = recipe.subtitle
        subtitleLabel.textColor = recipe.contentColor.withAlphaComponent(0.78)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        circlesView.frameWithoutTransform = bounds

        let pillFrame = bounds.insetBy(dx: 20, dy: 16)
        pillView.frameWithoutTransform = pillFrame
        backdropView.frameWithoutTransform = pillView.bounds
        tintView.frameWithoutTransform = pillView.bounds
        contentFilterView.frameWithoutTransform = pillView.bounds

        let insetX: CGFloat = 18
        let insetY: CGFloat = 14
        symbolView.frameWithoutTransform = CGRect(
            x: insetX,
            y: (pillView.bounds.height - 22) / 2,
            width: 22,
            height: 22
        )

        let textX = symbolView.frame.maxX + 12
        let textWidth = max(0, pillView.bounds.width - textX - insetX)
        titleLabel.frameWithoutTransform = CGRect(
            x: textX,
            y: insetY,
            width: textWidth,
            height: 24
        )
        subtitleLabel.frameWithoutTransform = CGRect(
            x: textX,
            y: titleLabel.frame.maxY + 2,
            width: textWidth,
            height: 16
        )
    }
}

private final class OpacityPairPreviewView: BaseView {
    private let circlesView = BackgroundCirclesView()
    private let rawPillView = UIView()
    private let rawBlurView = BackdropView()
    private let rawBaseTintView = UIView()
    private let rawInnerTintView = UIView()
    private let rawHighlightView = UIView()
    private let rawTitleLabel = UILabel()
    private let rawDetailLabel = UILabel()

    private let filteredPillView = UIView()
    private let filteredBlurView = BackdropView()
    private let filteredBaseTintView = UIView()
    private let filteredInnerTintView = UIView()
    private let filteredHighlightView = UIView()
    private let filteredTitleLabel = UILabel()
    private let filteredDetailLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundColor = UIColor(red: 0.18, green: 0.22, blue: 0.42, alpha: 1.0)
        cornerRadius = 16
        clipsToBounds = true

        addSubview(circlesView)

        configurePill(rawPillView)
        configurePill(filteredPillView)

        rawTitleLabel.text = "Raw stack"
        rawDetailLabel.text = "two alpha passes"

        filteredTitleLabel.text = "opacityPair"
        filteredDetailLabel.text = "inputAmount = 0.55"
    }

    override func updateProperties() {
        super.updateProperties()

        let blurFilters = [
            BackdropView.makeGaussianBlurFilter(radius: 10, normalizeEdges: true)
        ].compactMap { $0 }

        rawBlurView.backdropFilters = blurFilters
        filteredBlurView.backdropFilters = blurFilters

        rawPillView.layer.filters = nil
        filteredPillView.layer.filters = [
            BackdropView.makeOpacityPairFilter(amount: 0.55)
        ].compactMap { $0 }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        circlesView.frameWithoutTransform = bounds

        let horizontalInset: CGFloat = 12
        let topInset: CGFloat = 14
        let gap: CGFloat = 12
        let pillWidth = (bounds.width - (horizontalInset * 2) - gap) / 2
        let pillFrame = CGRect(
            x: horizontalInset,
            y: topInset,
            width: pillWidth,
            height: bounds.height - (topInset * 2)
        )

        layoutPill(
            rawPillView,
            blurView: rawBlurView,
            baseTintView: rawBaseTintView,
            innerTintView: rawInnerTintView,
            highlightView: rawHighlightView,
            titleLabel: rawTitleLabel,
            detailLabel: rawDetailLabel,
            frame: pillFrame
        )

        layoutPill(
            filteredPillView,
            blurView: filteredBlurView,
            baseTintView: filteredBaseTintView,
            innerTintView: filteredInnerTintView,
            highlightView: filteredHighlightView,
            titleLabel: filteredTitleLabel,
            detailLabel: filteredDetailLabel,
            frame: pillFrame.offsetBy(dx: pillWidth + gap, dy: 0)
        )
    }

    private func configurePill(_ pillView: UIView) {
        pillView.cornerRadius = 22
        pillView.clipsToBounds = true
        pillView.layer.borderWidth = 1
        pillView.layer.borderColor = UIColor.white.withAlphaComponent(0.18).cgColor
        addSubview(pillView)

        let blurView = pillView === rawPillView ? rawBlurView : filteredBlurView
        let baseTintView = pillView === rawPillView ? rawBaseTintView : filteredBaseTintView
        let innerTintView = pillView === rawPillView ? rawInnerTintView : filteredInnerTintView
        let highlightView = pillView === rawPillView ? rawHighlightView : filteredHighlightView
        let titleLabel = pillView === rawPillView ? rawTitleLabel : filteredTitleLabel
        let detailLabel = pillView === rawPillView ? rawDetailLabel : filteredDetailLabel

        pillView.addSubview(blurView)

        baseTintView.backgroundColor = UIColor.systemPink.withAlphaComponent(0.26)
        baseTintView.isUserInteractionEnabled = false
        pillView.addSubview(baseTintView)

        innerTintView.backgroundColor = UIColor.systemTeal.withAlphaComponent(0.22)
        innerTintView.isUserInteractionEnabled = false
        pillView.addSubview(innerTintView)

        highlightView.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        highlightView.isUserInteractionEnabled = false
        pillView.addSubview(highlightView)

        titleLabel.font = .boldSystemFont(ofSize: 14)
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.96)
        pillView.addSubview(titleLabel)

        detailLabel.font = .systemFont(ofSize: 10, weight: .semibold)
        detailLabel.textColor = UIColor.white.withAlphaComponent(0.72)
        pillView.addSubview(detailLabel)
    }

    private func layoutPill(
        _ pillView: UIView,
        blurView: BackdropView,
        baseTintView: UIView,
        innerTintView: UIView,
        highlightView: UIView,
        titleLabel: UILabel,
        detailLabel: UILabel,
        frame: CGRect
    ) {
        pillView.frameWithoutTransform = frame
        blurView.frameWithoutTransform = pillView.bounds
        baseTintView.frameWithoutTransform = pillView.bounds
        innerTintView.frameWithoutTransform = pillView.bounds.insetBy(dx: 12, dy: 11)
        innerTintView.cornerRadius = 14

        let highlightWidth = max(28, pillView.bounds.width * 0.44)
        highlightView.frameWithoutTransform = CGRect(
            x: pillView.bounds.width - highlightWidth - 12,
            y: pillView.bounds.height - 20,
            width: highlightWidth,
            height: 8
        )
        highlightView.cornerRadius = 4

        let textWidth = pillView.bounds.width - 24
        titleLabel.frameWithoutTransform = CGRect(x: 12, y: 12, width: textWidth, height: 18)
        detailLabel.frameWithoutTransform = CGRect(x: 12, y: titleLabel.frame.maxY + 2, width: textWidth, height: 14)
    }
}

private final class DisplacementMapPreviewView: BaseView {
    private let rawTileView = UIView()
    private let rawPatternView = WarpPatternView()
    private let rawCardView = UIView()
    private let rawTitleLabel = UILabel()
    private let rawDetailLabel = UILabel()

    private let hostedTileView = UIView()
    private let hostedPatternView = WarpPatternView()
    private let hostedLensView = LensView()
    private let hostedTitleLabel = UILabel()
    private let hostedDetailLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundColor = UIColor(red: 0.17, green: 0.20, blue: 0.38, alpha: 1.0)
        cornerRadius = 16
        clipsToBounds = true

        configureTile(rawTileView)
        configureTile(hostedTileView)

        rawTileView.addSubview(rawPatternView)
        rawCardView.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        rawCardView.cornerRadius = 16
        rawCardView.layer.borderWidth = 1
        rawCardView.layer.borderColor = UIColor.white.withAlphaComponent(0.18).cgColor
        rawTileView.addSubview(rawCardView)

        rawTitleLabel.text = "Standalone"
        rawTitleLabel.font = .boldSystemFont(ofSize: 14)
        rawTitleLabel.textColor = UIColor.white.withAlphaComponent(0.96)
        rawCardView.addSubview(rawTitleLabel)

        rawDetailLabel.text = "displacementMap(1.25)"
        rawDetailLabel.font = .systemFont(ofSize: 10, weight: .semibold)
        rawDetailLabel.textColor = UIColor.white.withAlphaComponent(0.72)
        rawCardView.addSubview(rawDetailLabel)

        hostedTileView.addSubview(hostedPatternView)

        hostedLensView.style = .clear
        hostedLensView.restingBackgroundColor = UIColor.white.withAlphaComponent(0.08)
        hostedTileView.addSubview(hostedLensView)

        hostedTitleLabel.text = "Hosted"
        hostedTitleLabel.font = .boldSystemFont(ofSize: 14)
        hostedTitleLabel.textColor = UIColor.white.withAlphaComponent(0.96)
        hostedTileView.addSubview(hostedTitleLabel)

        hostedDetailLabel.text = "LensView(.clear)"
        hostedDetailLabel.font = .systemFont(ofSize: 10, weight: .semibold)
        hostedDetailLabel.textColor = UIColor.white.withAlphaComponent(0.72)
        hostedTileView.addSubview(hostedDetailLabel)
    }

    override func updateProperties() {
        super.updateProperties()
        rawTileView.layer.filters = [
            BackdropView.makeDisplacementMapFilter(amount: 1.25)
        ].compactMap { $0 }
        hostedLensView.setLifted(true, animated: false)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let horizontalInset: CGFloat = 12
        let verticalInset: CGFloat = 14
        let gap: CGFloat = 12
        let tileWidth = (bounds.width - (horizontalInset * 2) - gap) / 2
        let tileHeight = bounds.height - (verticalInset * 2)
        let rawFrame = CGRect(x: horizontalInset, y: verticalInset, width: tileWidth, height: tileHeight)
        let hostedFrame = rawFrame.offsetBy(dx: tileWidth + gap, dy: 0)

        layoutTile(rawTileView, patternView: rawPatternView, titleLabel: nil, detailLabel: nil, frame: rawFrame)
        layoutTile(hostedTileView, patternView: hostedPatternView, titleLabel: hostedTitleLabel, detailLabel: hostedDetailLabel, frame: hostedFrame)

        rawCardView.frameWithoutTransform = CGRect(
            x: 14,
            y: tileHeight - 48,
            width: tileWidth - 28,
            height: 34
        )
        let rawTextWidth = rawCardView.bounds.width - 18
        rawTitleLabel.frameWithoutTransform = CGRect(x: 10, y: 6, width: rawTextWidth, height: 16)
        rawDetailLabel.frameWithoutTransform = CGRect(x: 10, y: 20, width: rawTextWidth, height: 10)

        hostedLensView.frameWithoutTransform = CGRect(
            x: (tileWidth - 92) / 2,
            y: 26,
            width: 92,
            height: 56
        )
        let hostedTextWidth = tileWidth - 20
        hostedTitleLabel.frameWithoutTransform = CGRect(x: 10, y: tileHeight - 34, width: hostedTextWidth, height: 16)
        hostedDetailLabel.frameWithoutTransform = CGRect(x: 10, y: hostedTitleLabel.frame.maxY + 2, width: hostedTextWidth, height: 10)
    }

    private func configureTile(_ tileView: UIView) {
        tileView.cornerRadius = 20
        tileView.clipsToBounds = true
        tileView.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        tileView.layer.borderWidth = 1
        tileView.layer.borderColor = UIColor.white.withAlphaComponent(0.16).cgColor
        addSubview(tileView)
    }

    private func layoutTile(
        _ tileView: UIView,
        patternView: WarpPatternView,
        titleLabel: UILabel?,
        detailLabel: UILabel?,
        frame: CGRect
    ) {
        tileView.frameWithoutTransform = frame
        patternView.frameWithoutTransform = tileView.bounds
        titleLabel?.frameWithoutTransform = .zero
        detailLabel?.frameWithoutTransform = .zero
    }
}

private final class WarpPatternView: UIView {
    private let horizontalLayer = CAShapeLayer()
    private let verticalLayer = CAShapeLayer()
    private let dotViews = (0..<4).map { _ in UIView() }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red: 0.11, green: 0.13, blue: 0.28, alpha: 1.0)

        horizontalLayer.strokeColor = UIColor.white.withAlphaComponent(0.22).cgColor
        horizontalLayer.lineWidth = 1
        layer.addSublayer(horizontalLayer)

        verticalLayer.strokeColor = UIColor.white.withAlphaComponent(0.12).cgColor
        verticalLayer.lineWidth = 1
        layer.addSublayer(verticalLayer)

        for (index, dotView) in dotViews.enumerated() {
            dotView.backgroundColor = [
                UIColor.systemPink,
                UIColor.systemTeal,
                UIColor.systemOrange,
                UIColor.systemBlue
            ][index].withAlphaComponent(0.78)
            addSubview(dotView)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let horizontalPath = UIBezierPath()
        for progress in stride(from: 0.22, through: 0.78, by: 0.28) {
            let y = bounds.height * progress
            horizontalPath.move(to: CGPoint(x: 0, y: y))
            horizontalPath.addLine(to: CGPoint(x: bounds.width, y: y))
        }
        horizontalLayer.frame = bounds
        horizontalLayer.path = horizontalPath.cgPath

        let verticalPath = UIBezierPath()
        for progress in stride(from: 0.20, through: 0.80, by: 0.20) {
            let x = bounds.width * progress
            verticalPath.move(to: CGPoint(x: x, y: 0))
            verticalPath.addLine(to: CGPoint(x: x, y: bounds.height))
        }
        verticalLayer.frame = bounds
        verticalLayer.path = verticalPath.cgPath

        let dotFrames = [
            CGRect(x: bounds.width * 0.16, y: bounds.height * 0.20, width: 14, height: 14),
            CGRect(x: bounds.width * 0.68, y: bounds.height * 0.24, width: 12, height: 12),
            CGRect(x: bounds.width * 0.24, y: bounds.height * 0.60, width: 18, height: 18),
            CGRect(x: bounds.width * 0.72, y: bounds.height * 0.62, width: 16, height: 16)
        ]

        for (dotView, frame) in zip(dotViews, dotFrames) {
            dotView.frameWithoutTransform = frame
            dotView.cornerRadius = frame.width / 2
        }
    }
}

private final class LensDemoView: BaseView {
    private let lensView = LensView()
    private lazy var pressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handlePress(_:)))

    private var isPressing = false {
        didSet {
            guard isPressing != oldValue else { return }
            lensView.setLifted(isPressing, animated: true, alongsideAnimations: {
                self.lensView.transform = .identity.scaledBy(self.isPressing ? 1.2 : 1)
            })
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundColor = .secondarySystemBackground
        cornerRadius = 16
        clipsToBounds = true
        pressGesture.minimumPressDuration = 0
        lensView.addGestureRecognizer(pressGesture)
    }

    override func updateProperties() {
        super.updateProperties()
        componentEngine.component = ZStack {
            ViewComponent<BackgroundCirclesView>().fill()

            Text("Press and hold", font: .boldSystemFont(ofSize: 20))

            lensView
                .size(width: 200, height: 80)
                .inset(20)
        }
    }

    @objc private func handlePress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began, .changed:
            let local = gesture.location(in: self)
            isPressing = bounds.contains(local)
        default:
            isPressing = false
        }
    }
}

private final class BackgroundCirclesView: BaseView {
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundColor = .clear
    }

    override func updateProperties() {
        super.updateProperties()
        componentEngine.component = ZStack {
            Space(width: 110, height: 110)
                .backgroundColor(UIColor(red: 0.98, green: 0.55, blue: 0.35, alpha: 0.9))
                .roundedCorner()
                .offset(x: -28, y: -20)

            Space(width: 95, height: 95)
                .backgroundColor(UIColor(red: 0.22, green: 0.84, blue: 0.76, alpha: 0.86))
                .roundedCorner()
                .offset(x: 48, y: 20)

            Space(width: 120, height: 120)
                .backgroundColor(UIColor(red: 0.35, green: 0.50, blue: 0.98, alpha: 0.88))
                .roundedCorner()
                .offset(x: 120, y: -30)
        }
        .fill()
    }
}

private final class LoupeDemoView: BaseView {
    let loupeView = LoupeView()
    private lazy var pressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handlePress(_:)))

    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundColor = .secondarySystemBackground
        cornerRadius = 16
        clipsToBounds = true
        pressGesture.minimumPressDuration = 0
        addGestureRecognizer(pressGesture)
        loupeView.zPosition = 10
        addSubview(loupeView)
    }

    override func updateProperties() {
        super.updateProperties()
        componentEngine.component = ZStack {
            ViewComponent<BackgroundCirclesView>().fill()

            Text("Press and hold", font: .boldSystemFont(ofSize: 20))
        }
    }

    @objc private func handlePress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began, .changed:
            let local = gesture.location(in: self)
            loupeView.isActive = bounds.contains(local)
            loupeView.frameWithoutTransform = CGRect(center: local, size: CGSize(width: 120, height: 120))
        default:
            loupeView.isActive = false
        }
    }
}

private final class PressBackInteractionDemoView: BaseView {
    private let pressBackInteraction = PressBackInteraction()

    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundColor = .secondarySystemBackground
        cornerRadius = 16
        clipsToBounds = true
    }

    override func updateProperties() {
        super.updateProperties()
        componentEngine.component = ZStack {
            ViewComponent<BackgroundCirclesView>().fill()

            VStack(spacing: 6, alignItems: .center) {
                Text("Press and hold", font: .boldSystemFont(ofSize: 20))
                Text("Move finger to tilt", font: .systemFont(ofSize: 13, weight: .semibold))
                    .textColor(.secondaryLabel)
            }
            .inset(40)
            .visualEffectView()
            .effect(UIGlassEffect(style: .regular))
            .cornerRadius(24)
            .view()
            .zPosition(700)
            .update { [pressBackInteraction] in
                $0.addInteraction(pressBackInteraction)
            }
        }
    }
}

private final class IntensitySlider: UIView {
    private let slider = UISlider()
    var onValueChanged: ((CGFloat) -> Void)?

    var minimumValue: CGFloat = 0 {
        didSet {
            slider.minimumValue = Float(minimumValue)
        }
    }

    var maximumValue: CGFloat = 1 {
        didSet {
            slider.maximumValue = Float(maximumValue)
        }
    }

    var value: CGFloat = 0 {
        didSet {
            guard !slider.isTracking else { return }
            slider.value = Float(value)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        slider.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        componentEngine.component = slider.fill()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func valueChanged() {
        value = CGFloat(slider.value)
        onValueChanged?(value)
    }
}

private final class EffectPicker: UIView, UIPickerViewDataSource, UIPickerViewDelegate {
    private let pickerView = UIPickerView()

    var titles: [String] = [] {
        didSet {
            pickerView.reloadAllComponents()
            applySelectionIfNeeded()
        }
    }

    var selectedIndex: Int = 0 {
        didSet {
            applySelectionIfNeeded()
        }
    }

    var onSelectionChanged: ((Int) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        pickerView.dataSource = self
        pickerView.delegate = self
        componentEngine.component = pickerView.fill()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func applySelectionIfNeeded() {
        guard !titles.isEmpty else { return }
        let clamped = min(max(selectedIndex, 0), titles.count - 1)
        if clamped != selectedIndex {
            selectedIndex = clamped
            return
        }
        if pickerView.selectedRow(inComponent: 0) != clamped {
            pickerView.selectRow(clamped, inComponent: 0, animated: false)
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        titles.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        titles[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedIndex = row
        onSelectionChanged?(row)
    }
}

private final class PortalPairDemoView: BaseView {
    private let topLeftLabel = UIView().then {
        $0.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
        $0.cornerRadius = 8
        $0.componentEngine.component = Text("Top Left", font: .systemFont(ofSize: 14, weight: .semibold))
            .inset(h: 12, v: 8)
    }
    private let bottomRightLabel = UIView().then {
        $0.backgroundColor = UIColor.systemPink.withAlphaComponent(0.22)
        $0.cornerRadius = 8
        $0.componentEngine.component = Text("Bottom Right", font: .systemFont(ofSize: 14, weight: .semibold))
            .inset(h: 12, v: 8)
    }

    private lazy var portalPairView: PortalPairView = PortalPairView(backgroundView: topLeftLabel, foregroundView: bottomRightLabel)

    private let progressAnimation = SpringAnimation<CGFloat>(initialValue: 0)

    private var progress: CGFloat = 0 {
        didSet {
            applyProgress()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        backgroundColor = .secondarySystemBackground
        cornerRadius = 16
        clipsToBounds = true

        addSubview(portalPairView)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)

        progressAnimation.configure(response: 0.5, dampingRatio: 0.8)
        progressAnimation.onValueChanged(disableActions: true) { [weak self] value in
            self?.progress = value
        }
    }

    override func updateProperties() {
        super.updateProperties()
        componentEngine.component = ZStack {
            ZStack(verticalAlignment: .start, horizontalAlignment: .start) {
                topLeftLabel
            }.fill()
            ZStack(verticalAlignment: .end, horizontalAlignment: .end) {
                bottomRightLabel
            }.fill()
        }.inset(12)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        bringSubviewToFront(portalPairView)
        applyProgress()
    }

    @objc private func handleTap() {
        progressAnimation.toValue = progress < 0.5 ? 1 : 0
        progressAnimation.start()
    }

    private func applyProgress() {
        portalPairView.progress = progress
        portalPairView.frameWithoutTransform = interpolatedFrame(progress: progress)
    }

    private func interpolatedFrame(progress: CGFloat) -> CGRect {
        let fromFrame = topLeftLabel.frameWithoutTransform
        let toFrame = bottomRightLabel.frameWithoutTransform
        return lerp(from: fromFrame, to: toFrame, progress: progress)
    }
}

private final class BadgeShapeDemoView: ShapeView {
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundColor = .secondarySystemBackground
        cornerRadius = 16
        fillColor = UIColor.systemTeal.withAlphaComponent(0.20)
        strokeColor = .systemTeal
        lineWidth = 3
        lineCap = .round
        lineJoin = .round
        lineDashPattern = [8, 4]
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let outlineRect = bounds.insetBy(dx: 16, dy: 14)
        let outline = UIBezierPath(roundedRect: outlineRect, cornerRadius: 14)
        let circle = UIBezierPath(ovalIn: CGRect(center: outlineRect.center, size: CGSize(width: 30, height: 30)))
        outline.append(circle)
        path = outline
    }
}
