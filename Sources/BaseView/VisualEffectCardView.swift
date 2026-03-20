import UIKit
import BaseToolbox

/// Rounded visual-effect card that falls back to a manual edge shadow before iOS 26.
open class VisualEffectCardView: BaseView {
    public let visualEffectView: UIVisualEffectView
    public let shadowView = EdgeShadowView()

    public var contentView: UIView {
        visualEffectView.contentView
    }

    open var effect: UIVisualEffect? {
        get { visualEffectView.effect }
        set { visualEffectView.effect = newValue }
    }

    public override init(frame: CGRect) {
        if #available(iOS 26.0, *) {
            visualEffectView = UIVisualEffectView(effect: UIGlassEffect(style: .regular).with(\.isInteractive, value: true))
        } else {
            visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
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
        
        if #available(iOS 26.0, *) {
            cornerConfiguration = UICornerConfiguration.uniformEdges(
                topRadius: 40,
                bottomRadius: .containerConcentric(minimum: 30)
            )
        } else {
            cornerRadius = 40
            cornerCurve = .continuous
        }

        visualEffectView.contentView.clipsToBounds = true

        shadowView.isUserInteractionEnabled = false
        shadowView.shadowColor = UIColor.black.withAlphaComponent(0.25)
        shadowView.shadowOpacity = 1
        shadowView.shadowRadius = 24
        shadowView.shadowOffset = CGSize(width: 0, height: 6)

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
        if #available(iOS 26.0, *) {
            return false
        }
        return true
    }

    private func syncCardPresentation() {
        let clipsVisualEffectView = usesManualShadowFallback

        shadowView.isHidden = !usesManualShadowFallback
        visualEffectView.clipsToBounds = clipsVisualEffectView
        
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

        if #available(iOS 26.0, *) {
            let currentCornerConfiguration = cornerConfiguration
            visualEffectView.cornerConfiguration = currentCornerConfiguration
            visualEffectView.contentView.cornerConfiguration = currentCornerConfiguration
            shadowView.cornerConfiguration = currentCornerConfiguration
        }

        shadowView.setNeedsUpdateProperties()
    }
}
