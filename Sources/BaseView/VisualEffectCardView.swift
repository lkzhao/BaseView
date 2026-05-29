import UIKit
import BaseToolbox

/// Rounded visual-effect card with a pre-iOS 26 edge-shadow fallback and optional shadow override.
open class VisualEffectCardView: BaseView {
    public struct ShadowConfiguration {
        public var color: UIColor
        public var opacity: CGFloat
        public var radius: CGFloat
        public var offset: CGSize

        public init(color: UIColor, opacity: CGFloat, radius: CGFloat, offset: CGSize) {
            self.color = color
            self.opacity = opacity
            self.radius = radius
            self.offset = offset
        }
    }

    public let visualEffectView: UIVisualEffectView
    public let shadowView = EdgeShadowView()

    public var contentView: UIView {
        visualEffectView.contentView
    }

    open var effect: UIVisualEffect? {
        get { visualEffectView.effect }
        set { visualEffectView.effect = newValue }
    }

    open var shadowConfiguration: ShadowConfiguration? {
        didSet {
            setNeedsUpdateProperties()
        }
    }

    public override init(frame: CGRect) {
        if #available(iOS 26.0, tvOS 26.0, *) {
            visualEffectView = UIVisualEffectView(effect: UIGlassEffect(style: .regular).with(\.isInteractive, value: true))
        } else {
            #if os(tvOS)
            visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
            #else
            visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
            #endif
        }
        super.init(frame: frame)
    }

    public required init?(coder: NSCoder) {
        visualEffectView = UIVisualEffectView()
        super.init(coder: coder)
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        backgroundColor = .clear
        clipsToBounds = false
        
        if #available(iOS 26.0, tvOS 26.0, *) {
            cornerConfiguration = UICornerConfiguration.uniformEdges(
                topRadius: 30,
                bottomRadius: .containerConcentric(minimum: 30)
            )
        } else {
            cornerRadius = 30
            cornerCurve = .continuous
        }

        visualEffectView.contentView.clipsToBounds = true

        shadowView.isUserInteractionEnabled = false

        addSubview(shadowView)
        addSubview(visualEffectView)

        syncCardPresentation()
    }

    open override func updateProperties() {
        super.updateProperties()
        syncCardPresentation()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        shadowView.frameWithoutTransform = bounds
        visualEffectView.frameWithoutTransform = bounds
        syncCardPresentation()
    }

    private var usesManualShadowFallback: Bool {
        if #available(iOS 26.0, tvOS 26.0, *) {
            return false
        }
        return true
    }

    private var shouldShowShadowView: Bool {
        shadowConfiguration != nil || usesManualShadowFallback
    }

    private var resolvedShadowConfiguration: ShadowConfiguration {
        shadowConfiguration ?? ShadowConfiguration(
            color: UIColor.black.withAlphaComponent(0.2),
            opacity: 1,
            radius: 24,
            offset: CGSize(width: 0, height: 6)
        )
    }

    private func syncCardPresentation() {
        let clipsVisualEffectView = usesManualShadowFallback
        let shadowConfiguration = resolvedShadowConfiguration

        shadowView.isHidden = !shouldShowShadowView
        visualEffectView.clipsToBounds = clipsVisualEffectView

        shadowView.shadowColor = shadowConfiguration.color
        shadowView.shadowOpacity = shadowConfiguration.opacity
        shadowView.shadowRadius = shadowConfiguration.radius
        shadowView.shadowOffset = shadowConfiguration.offset

        let cornerRadius = min(min(bounds.height / 2, bounds.width / 2), cornerRadius)

        visualEffectView.cornerRadius = cornerRadius
        visualEffectView.cornerCurve = cornerCurve
        visualEffectView.maskedCorners = maskedCorners

        visualEffectView.contentView.cornerRadius = cornerRadius
        visualEffectView.contentView.cornerCurve = cornerCurve
        visualEffectView.contentView.maskedCorners = maskedCorners

        shadowView.cornerRadius = cornerRadius
        shadowView.cornerCurve = cornerCurve
        shadowView.maskedCorners = maskedCorners

        if #available(iOS 26.0, tvOS 26.0, *) {
            let currentCornerConfiguration = cornerConfiguration
            visualEffectView.cornerConfiguration = currentCornerConfiguration
            visualEffectView.contentView.cornerConfiguration = currentCornerConfiguration
            shadowView.cornerConfiguration = currentCornerConfiguration
        }

        shadowView.setNeedsUpdateProperties()
    }
}
