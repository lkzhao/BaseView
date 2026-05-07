import UIKit
import BaseToolbox

/// View that mirrors another view.
open class PortalView: UIView {
    private enum ObfuscatedKeys {
        static let portalClass = ObfuscatedString.decode([244, 159, 160, 88, 72, 52, 17, 229, 207, 148, 136, 101, 104], key: 0x06)
        static let sourceView = ObfuscatedString.decode([227, 192, 187, 159, 111, 78, 28, 0, 237, 208], key: 0xEB)
        static let hidesSourceView = ObfuscatedString.decode([137, 105, 123, 91, 46, 47, 244, 207, 171, 155, 114, 96, 60, 17, 228], key: 0x3C)
        static let matchesAlpha = ObfuscatedString.decode([59, 20, 224, 208, 186, 148, 99, 110, 34, 29, 228, 202], key: 0xB1)
        static let matchesTransform = ObfuscatedString.decode([23, 248, 204, 180, 158, 112, 71, 7, 0, 240, 222, 188, 136, 98, 94, 38], key: 0xD5)
        static let matchesPosition = ObfuscatedString.decode([111, 64, 52, 60, 22, 248, 207, 139, 149, 106, 81, 35, 31, 250, 218], key: 0x5D)
        static let hidesSourceLayerInOtherPortals = ObfuscatedString.decode([107, 75, 37, 5, 12, 205, 210, 169, 137, 121, 92, 20, 22, 239, 208, 166, 186, 124, 126, 36, 7, 235, 223, 156, 132, 120, 93, 41, 11, 245], key: 0x5E)
    }

    internal var portalView: UIView?

    /// Whether the underlying portal implementation is available on this system.
    public private(set) var isAvailable = false

    /// The source view to mirror.
    open var sourceView: UIView? {
        didSet {
            updateSourceView()
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }

    open override var intrinsicContentSize: CGSize {
        if let sourceView {
            if sourceView.bounds.size.width > 0, sourceView.bounds.size.height > 0 {
                return sourceView.bounds.size
            }
            return sourceView.intrinsicContentSize
        }
        return CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
    }

    /// When `true`, the source view is hidden while being mirrored.
    open var hidesSourceView: Bool = false {
        didSet {
            portalView?.setValue(hidesSourceView, forKey: ObfuscatedKeys.hidesSourceView)
        }
    }

    /// When `true`, the portal matches the source alpha.
    open var matchesAlpha: Bool = true {
        didSet {
            portalView?.setValue(matchesAlpha, forKey: ObfuscatedKeys.matchesAlpha)
        }
    }

    /// When `true`, the portal matches the source transform.
    open var matchesTransform: Bool = true {
        didSet {
            portalView?.setValue(matchesTransform, forKey: ObfuscatedKeys.matchesTransform)
        }
    }

    /// When `true`, the portal matches the source position.
    open var matchesPosition: Bool = true {
        didSet {
            portalView?.setValue(matchesPosition, forKey: ObfuscatedKeys.matchesPosition)
        }
    }

    /// When `true`, the source layer is hidden in other portals.
    open var hidesSourceLayerInOtherPortals: Bool = false {
        didSet {
            guard #available(iOS 26.0, *) else { return }
            portalView?.setValue(hidesSourceLayerInOtherPortals, forKey: ObfuscatedKeys.hidesSourceLayerInOtherPortals)
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupPortalView()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPortalView()
    }

    public init(sourceView: UIView) {
        super.init(frame: .zero)
        setupPortalView()
        self.sourceView = sourceView
        layer.transform = sourceView.layer.transform
        layer.zPosition = sourceView.layer.zPosition
        frameWithoutTransform = sourceView.frameWithoutTransform
        updateSourceView()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        guard let portalView, let sourceView else { return }

        portalView.center = bounds.center
        portalView.bounds.size = sourceView.bounds.size

        let sourceSize = sourceView.bounds.size
        guard sourceSize.width > 0, sourceSize.height > 0 else {
            portalView.transform = .identity
            return
        }

        portalView.transform = .identity.scaledBy(
            x: bounds.width / sourceSize.width,
            y: bounds.height / sourceSize.height
        )
    }

    private func setupPortalView() {
        guard let portalClass = NSClassFromString(ObfuscatedKeys.portalClass) as? UIView.Type else {
            isAvailable = false

            let fallbackView = UIView(frame: bounds)
            fallbackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            fallbackView.backgroundColor = .clear
            addSubview(fallbackView)
            return
        }

        let portal = portalClass.init(frame: bounds)
        addSubview(portal)
        portalView = portal
        isAvailable = true

        portal.setValue(matchesAlpha, forKey: ObfuscatedKeys.matchesAlpha)
        portal.setValue(matchesTransform, forKey: ObfuscatedKeys.matchesTransform)
        portal.setValue(matchesPosition, forKey: ObfuscatedKeys.matchesPosition)
        portal.setValue(hidesSourceView, forKey: ObfuscatedKeys.hidesSourceView)
        if #available(iOS 26.0, *) {
            portal.setValue(hidesSourceLayerInOtherPortals, forKey: ObfuscatedKeys.hidesSourceLayerInOtherPortals)
        }
        updateSourceView()
    }

    private func updateSourceView() {
        guard isAvailable else { return }
        portalView?.setValue(sourceView, forKey: ObfuscatedKeys.sourceView)
    }
}
