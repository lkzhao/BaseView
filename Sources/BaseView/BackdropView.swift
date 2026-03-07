import UIKit
import ObfuscateMacro

/// View backed by private `CABackdropLayer` with a safe `CALayer` fallback when unavailable.
open class BackdropView: BaseView {
    private enum ObfuscatedKeys {
        static let backdropLayerClass = #ObfuscatedString("CABackdropLayer")
        static let filterClass = #ObfuscatedString("CAFilter")
        static let filterWithType = #ObfuscatedString("filterWithType:")
        static let gaussianBlur = #ObfuscatedString("gaussianBlur")
        static let colorMatrix = #ObfuscatedString("colorMatrix")
        static let vibrantColorMatrix = #ObfuscatedString("vibrantColorMatrix")
        static let displacementMap = #ObfuscatedString("displacementMap")
        static let opacityPair = #ObfuscatedString("opacityPair")
        static let inputRadius = #ObfuscatedString("inputRadius")
        static let inputNormalizeEdges = #ObfuscatedString("inputNormalizeEdges")
        static let inputColorMatrix = #ObfuscatedString("inputColorMatrix")
        static let inputAmount = #ObfuscatedString("inputAmount")
        static let enabled = #ObfuscatedString("enabled")
        static let allowsInPlaceFiltering = #ObfuscatedString("allowsInPlaceFiltering")
        static let scale = #ObfuscatedString("scale")
        static let bleedAmount = #ObfuscatedString("bleedAmount")
        static let marginWidth = #ObfuscatedString("marginWidth")
        static let windowServerAware = #ObfuscatedString("windowServerAware")
        static let ignoresScreenClip = #ObfuscatedString("ignoresScreenClip")
        static let ignoresOffscreenGroups = #ObfuscatedString("ignoresOffscreenGroups")
        static let reducesCaptureBitDepth = #ObfuscatedString("reducesCaptureBitDepth")
        static let backdropRect = #ObfuscatedString("backdropRect")
    }

    private static let resolvedBackdropLayerClass: AnyClass = NSClassFromString(ObfuscatedKeys.backdropLayerClass) ?? CALayer.self

    open override class var layerClass: AnyClass {
        resolvedBackdropLayerClass
    }

    /// Whether the private backdrop implementation exists on this system.
    public var isAvailable: Bool {
        ObjectIdentifier(Self.resolvedBackdropLayerClass) != ObjectIdentifier(CALayer.self)
    }

    /// Accessor for the underlying backdrop layer.
    open var backdropLayer: CALayer {
        layer
    }

    /// Convenience gaussian blur radius applied through the private `CAFilter` API.
    open var blurRadius: CGFloat = 24 {
        didSet {
            guard blurRadius != oldValue else { return }
            updateBackdropFilters()
        }
    }

    /// Optional custom filter stack. When set, this replaces the default gaussian blur filter.
    open var backdropFilters: [Any]? {
        didSet {
            updateBackdropFilters()
        }
    }

    /// Whether blur filters should normalize edges to avoid clipping artifacts.
    open var normalizesEdges: Bool = true {
        didSet {
            guard normalizesEdges != oldValue else { return }
            updateBackdropFilters()
        }
    }

    /// Whether backdrop capture and filtering are enabled.
    open var isBackdropEnabled: Bool = true {
        didSet {
            guard isBackdropEnabled != oldValue else { return }
            applyValue(isBackdropEnabled, forKey: ObfuscatedKeys.enabled)
        }
    }

    /// Capture scale used by the backdrop layer.
    open var backdropScale: CGFloat = UIScreen.main.scale {
        didSet {
            guard backdropScale != oldValue else { return }
            applyValue(backdropScale, forKey: ObfuscatedKeys.scale)
        }
    }

    /// Extends capture slightly beyond bounds to reduce edge artifacts.
    open var bleedAmount: CGFloat = 0 {
        didSet {
            guard bleedAmount != oldValue else { return }
            applyValue(bleedAmount, forKey: ObfuscatedKeys.bleedAmount)
        }
    }

    /// Horizontal margin used by the backdrop capture region.
    open var marginWidth: CGFloat = 0 {
        didSet {
            guard marginWidth != oldValue else { return }
            applyValue(marginWidth, forKey: ObfuscatedKeys.marginWidth)
        }
    }

    /// Enables in-place filtering so the backdrop can process the captured content directly.
    open var allowsInPlaceFiltering: Bool = true {
        didSet {
            guard allowsInPlaceFiltering != oldValue else { return }
            applyValue(allowsInPlaceFiltering, forKey: ObfuscatedKeys.allowsInPlaceFiltering)
        }
    }

    /// Uses WindowServer capture when available.
    open var isWindowServerAware: Bool = false {
        didSet {
            guard isWindowServerAware != oldValue else { return }
            applyValue(isWindowServerAware, forKey: ObfuscatedKeys.windowServerAware)
        }
    }

    /// Allows the backdrop to sample content outside the screen clip.
    open var ignoresScreenClip: Bool = false {
        didSet {
            guard ignoresScreenClip != oldValue else { return }
            applyValue(ignoresScreenClip, forKey: ObfuscatedKeys.ignoresScreenClip)
        }
    }

    /// Allows the backdrop to continue sampling offscreen groups.
    open var ignoresOffscreenGroups: Bool = false {
        didSet {
            guard ignoresOffscreenGroups != oldValue else { return }
            applyValue(ignoresOffscreenGroups, forKey: ObfuscatedKeys.ignoresOffscreenGroups)
        }
    }

    /// Reduces capture precision for better performance when desired.
    open var reducesCaptureBitDepth: Bool = false {
        didSet {
            guard reducesCaptureBitDepth != oldValue else { return }
            applyValue(reducesCaptureBitDepth, forKey: ObfuscatedKeys.reducesCaptureBitDepth)
        }
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        backgroundColor = .clear
        applyConfiguredValues()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        guard isAvailable else { return }
        applyValue(NSValue(cgRect: bounds), forKey: ObfuscatedKeys.backdropRect)
    }

    /// Builds a private gaussian blur filter that can be assigned to `layer.filters`.
    public static func makeGaussianBlurFilter(radius: CGFloat, normalizeEdges: Bool = true) -> NSObject? {
        guard radius > 0,
              let filter = makeFilter(type: ObfuscatedKeys.gaussianBlur) else {
            return nil
        }
        filter.setValue(radius, forKey: ObfuscatedKeys.inputRadius)
        filter.setValue(normalizeEdges, forKey: ObfuscatedKeys.inputNormalizeEdges)
        return filter
    }

    /// Builds a private color-matrix filter. The matrix is a 4x5 row-major RGBA transform (20 floats).
    public static func makeColorMatrixFilter(matrix: [Float]) -> NSObject? {
        makeMatrixFilter(type: ObfuscatedKeys.colorMatrix, matrix: matrix)
    }

    /// Builds a private vibrant color-matrix filter. Uses the same 4x5 row-major RGBA matrix format.
    public static func makeVibrantColorMatrixFilter(matrix: [Float]) -> NSObject? {
        makeMatrixFilter(type: ObfuscatedKeys.vibrantColorMatrix, matrix: matrix)
    }

    /// Builds a private displacement filter. UIKit pairs this with clear-glass host views.
    public static func makeDisplacementMapFilter(amount: CGFloat) -> NSObject? {
        makeAmountFilter(type: ObfuscatedKeys.displacementMap, amount: amount)
    }

    /// Builds a private opacity-pair filter used to crossfade layered material passes.
    public static func makeOpacityPairFilter(amount: CGFloat) -> NSObject? {
        makeAmountFilter(type: ObfuscatedKeys.opacityPair, amount: amount)
    }

    private static func makeFilter(type: String) -> NSObject? {
        guard let filterClass = NSClassFromString(ObfuscatedKeys.filterClass) as? NSObject.Type else {
            return nil
        }

        let filterSelector = NSSelectorFromString(ObfuscatedKeys.filterWithType)
        guard filterClass.responds(to: filterSelector) else { return nil }
        return filterClass.perform(filterSelector, with: type)?.takeUnretainedValue() as? NSObject
    }

    private static func makeMatrixFilter(type: String, matrix: [Float]) -> NSObject? {
        guard matrix.count == 20,
              let filter = makeFilter(type: type) else {
            return nil
        }

        let numbers = matrix.map { NSNumber(value: $0) }
        filter.setValue(numbers, forKey: ObfuscatedKeys.inputColorMatrix)
        return filter
    }

    private static func makeAmountFilter(type: String, amount: CGFloat) -> NSObject? {
        guard let filter = makeFilter(type: type) else { return nil }
        filter.setValue(amount, forKey: ObfuscatedKeys.inputAmount)
        return filter
    }

    private func applyConfiguredValues() {
        guard isAvailable else { return }
        applyValue(isBackdropEnabled, forKey: ObfuscatedKeys.enabled)
        applyValue(backdropScale, forKey: ObfuscatedKeys.scale)
        applyValue(bleedAmount, forKey: ObfuscatedKeys.bleedAmount)
        applyValue(marginWidth, forKey: ObfuscatedKeys.marginWidth)
        applyValue(allowsInPlaceFiltering, forKey: ObfuscatedKeys.allowsInPlaceFiltering)
        applyValue(isWindowServerAware, forKey: ObfuscatedKeys.windowServerAware)
        applyValue(ignoresScreenClip, forKey: ObfuscatedKeys.ignoresScreenClip)
        applyValue(ignoresOffscreenGroups, forKey: ObfuscatedKeys.ignoresOffscreenGroups)
        applyValue(reducesCaptureBitDepth, forKey: ObfuscatedKeys.reducesCaptureBitDepth)
        updateBackdropFilters()
    }

    private func updateBackdropFilters() {
        guard isAvailable else {
            backdropLayer.filters = nil
            return
        }

        if let backdropFilters {
            backdropLayer.filters = backdropFilters
        } else if let blurFilter = Self.makeGaussianBlurFilter(radius: blurRadius, normalizeEdges: normalizesEdges) {
            backdropLayer.filters = [blurFilter]
        } else {
            backdropLayer.filters = nil
        }
    }

    private func applyValue(_ value: Any?, forKey key: String) {
        guard isAvailable else { return }
        backdropLayer.setValue(value, forKey: key)
    }
}
