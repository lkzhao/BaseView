import UIKit

/// View backed by private `CABackdropLayer` with a safe `CALayer` fallback when unavailable.
open class BackdropView: BaseView {
    private enum ObfuscatedKeys {
        static let backdropLayerClass = ObfuscatedString.decode([41, 200, 234, 166, 133, 110, 64, 49, 13, 241, 236, 222, 167, 152, 110], key: 0xC5)
        static let filterClass = ObfuscatedString.decode([100, 7, 35, 237, 207, 182, 132, 114], key: 0x82)
        static let filterWithType = ObfuscatedString.decode([160, 140, 104, 87, 39, 19, 215, 246, 202, 181, 168, 98, 74, 60, 66], key: 0x21)
        static let gaussianBlur = ObfuscatedString.decode([28, 251, 204, 171, 132, 127, 84, 58, 49, 254, 196, 162], key: 0xD6)
        static let colorMatrix = ObfuscatedString.decode([109, 66, 32, 4, 248, 228, 169, 147, 116, 76, 60], key: 0x69)
        static let vibrantColorMatrix = ObfuscatedString.decode([28, 224, 202, 181, 135, 107, 80, 0, 13, 237, 207, 205, 147, 156, 104, 73, 51, 1], key: 0xC5)
        static let displacementMap = ObfuscatedString.decode([187, 151, 110, 76, 55, 27, 250, 221, 186, 147, 123, 64, 30, 19, 225], key: 0x3A)
        static let opacityPair = ObfuscatedString.decode([144, 110, 92, 63, 18, 238, 192, 136, 150, 127, 71], key: 0x5A)
        static let inputRadius = ObfuscatedString.decode([123, 95, 32, 26, 250, 255, 173, 143, 99, 92, 59], key: 0x6D)
        static let inputNormalizeEdges = ObfuscatedString.decode([182, 144, 109, 73, 47, 52, 246, 202, 186, 151, 121, 93, 41, 23, 212, 212, 168, 139, 126], key: 0x3A)
        static let inputColorMatrix = ObfuscatedString.decode([20, 242, 203, 175, 141, 91, 88, 58, 26, 230, 254, 179, 133, 98, 70, 54], key: 0xD8)
        static let inputAmount = ObfuscatedString.decode([119, 83, 44, 14, 238, 248, 181, 152, 99, 91, 32], key: 0x79)
        static let enabled = ObfuscatedString.decode([146, 120, 84, 54, 31, 247, 213], key: 0x52)
        static let allowsInPlaceFiltering = ObfuscatedString.decode([65, 83, 50, 18, 235, 200, 147, 151, 72, 91, 55, 22, 241, 245, 187, 157, 100, 74, 60, 4, 226, 204], key: 0x7B)
        static let scale = ObfuscatedString.decode([126, 79, 42, 6, 236], key: 0x68)
        static let bleedAmount = ObfuscatedString.decode([136, 101, 77, 34, 2, 196, 201, 172, 151, 111, 84], key: 0x45)
        static let marginWidth = ObfuscatedString.decode([149, 118, 68, 50, 29, 253, 229, 184, 148, 123, 70], key: 0x53)
        static let windowServerAware = ObfuscatedString.decode([153, 100, 66, 47, 5, 254, 251, 162, 148, 115, 65, 49, 35, 246, 193, 205, 187], key: 0x49)
        static let ignoresScreenClip = ObfuscatedString.decode([167, 138, 98, 68, 56, 12, 251, 244, 165, 151, 97, 70, 44, 34, 236, 246, 206], key: 0x29)
        static let ignoresOffscreenGroups = ObfuscatedString.decode([9, 24, 240, 210, 174, 158, 105, 118, 62, 17, 229, 214, 166, 150, 119, 95, 23, 29, 225, 216, 188, 152], key: 0xBB)
        static let reducesCaptureBitDepth = ObfuscatedString.decode([83, 37, 59, 11, 254, 217, 168, 185, 120, 72, 35, 3, 231, 209, 145, 155, 101, 116, 42, 30, 249, 196], key: 0x7C)
        static let backdropRect = ObfuscatedString.decode([61, 31, 254, 215, 191, 136, 118, 72, 5, 19, 246, 192], key: 0xBA)
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
