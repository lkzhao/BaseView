import UIKit
import ObfuscateMacro
import ObjectiveC.runtime

@available(iOS 26.0, *)
public extension UIGlassEffect {
    struct VariantConfiguration {
        public var variant: Int
        public var size: Int

        public var identifier: Int?
        public var smoothness: CGFloat?
        public var tintColor: UIColor?
        public var controlTintColor: UIColor?
        public var subvariant: String?

        public var contentLensing: Bool?
        public var highlightsDisplayAngle: Bool?
        public var excludingPlatter: Bool?
        public var excludingForeground: Bool?
        public var excludingShadow: Bool?
        public var excludingControlLensing: Bool?
        public var excludingControlDisplacement: Bool?
        public var flexible: Bool?
        public var boostWhitePoint: Bool?
        public var allowsGrouping: Bool?
        public var backdropGroupName: String?

        public init(
            variant: Int,
            size: Int = 0,
            identifier: Int? = nil,
            smoothness: CGFloat? = nil,
            tintColor: UIColor? = nil,
            controlTintColor: UIColor? = nil,
            subvariant: String? = nil,
            contentLensing: Bool? = nil,
            highlightsDisplayAngle: Bool? = nil,
            excludingPlatter: Bool? = nil,
            excludingForeground: Bool? = nil,
            excludingShadow: Bool? = nil,
            excludingControlLensing: Bool? = nil,
            excludingControlDisplacement: Bool? = nil,
            flexible: Bool? = nil,
            boostWhitePoint: Bool? = nil,
            allowsGrouping: Bool? = nil,
            backdropGroupName: String? = nil
        ) {
            self.variant = variant
            self.size = size
            self.identifier = identifier
            self.smoothness = smoothness
            self.tintColor = tintColor
            self.controlTintColor = controlTintColor
            self.subvariant = subvariant
            self.contentLensing = contentLensing
            self.highlightsDisplayAngle = highlightsDisplayAngle
            self.excludingPlatter = excludingPlatter
            self.excludingForeground = excludingForeground
            self.excludingShadow = excludingShadow
            self.excludingControlLensing = excludingControlLensing
            self.excludingControlDisplacement = excludingControlDisplacement
            self.flexible = flexible
            self.boostWhitePoint = boostWhitePoint
            self.allowsGrouping = allowsGrouping
            self.backdropGroupName = backdropGroupName
        }
    }

    static func variant(_ configuration: VariantConfiguration) -> UIGlassEffect {
        if let effect = PrivateGlassEffectFactory.make(configuration) {
            return effect
        }
        let style: UIGlassEffect.Style = configuration.variant.isMultiple(of: 2) ? .regular : .clear
        return UIGlassEffect(style: style)
    }

    static func variant(
        _ variantIndex: Int,
        size: Int = 0,
        smoothness: CGFloat? = nil,
        tintColor: UIColor? = nil,
        controlTintColor: UIColor? = nil,
        subvariant: String? = nil
    ) -> UIGlassEffect {
        self.variant(
            VariantConfiguration(
                variant: variantIndex,
                size: size,
                smoothness: smoothness,
                tintColor: tintColor,
                controlTintColor: controlTintColor,
                subvariant: subvariant
            )
        )
    }
}

@available(iOS 26.0, *)
private enum PrivateGlassEffectFactory {
    private enum Keys {
        static let glassClass = #ObfuscatedString("_UIViewGlass")
        static let glassEffectClass = #ObfuscatedString("UIGlassEffect")
        static let initWithGlass = #ObfuscatedString("initWithGlass:")

        static let identifier = #ObfuscatedString("identifier")
        static let smoothness = #ObfuscatedString("smoothness")
        static let tintColor = #ObfuscatedString("tintColor")
        static let controlTintColor = #ObfuscatedString("controlTintColor")
        static let subvariant = #ObfuscatedString("subvariant")
        static let contentLensing = #ObfuscatedString("contentLensing")
        static let highlightsDisplayAngle = #ObfuscatedString("highlightsDisplayAngle")
        static let excludingPlatter = #ObfuscatedString("excludingPlatter")
        static let excludingForeground = #ObfuscatedString("excludingForeground")
        static let excludingShadow = #ObfuscatedString("excludingShadow")
        static let excludingControlLensing = #ObfuscatedString("excludingControlLensing")
        static let excludingControlDisplacement = #ObfuscatedString("excludingControlDisplacement")
        static let flexible = #ObfuscatedString("flexible")
        static let boostWhitePoint = #ObfuscatedString("boostWhitePoint")
        static let allowsGrouping = #ObfuscatedString("allowsGrouping")
        static let backdropGroupName = #ObfuscatedString("backdropGroupName")

        static let setIdentifier = #ObfuscatedString("setIdentifier:")
        static let setSmoothness = #ObfuscatedString("setSmoothness:")
        static let setTintColor = #ObfuscatedString("setTintColor:")
        static let setControlTintColor = #ObfuscatedString("setControlTintColor:")
        static let setSubvariant = #ObfuscatedString("setSubvariant:")
        static let setContentLensing = #ObfuscatedString("setContentLensing:")
        static let setHighlightsDisplayAngle = #ObfuscatedString("setHighlightsDisplayAngle:")
        static let setExcludingPlatter = #ObfuscatedString("setExcludingPlatter:")
        static let setExcludingForeground = #ObfuscatedString("setExcludingForeground:")
        static let setExcludingShadow = #ObfuscatedString("setExcludingShadow:")
        static let setExcludingControlLensing = #ObfuscatedString("setExcludingControlLensing:")
        static let setExcludingControlDisplacement = #ObfuscatedString("setExcludingControlDisplacement:")
        static let setFlexible = #ObfuscatedString("setFlexible:")
        static let setBoostWhitePoint = #ObfuscatedString("setBoostWhitePoint:")
        static let setAllowsGrouping = #ObfuscatedString("setAllowsGrouping:")
        static let setBackdropGroupName = #ObfuscatedString("setBackdropGroupName:")
    }

    static func make(_ configuration: UIGlassEffect.VariantConfiguration) -> UIGlassEffect? {
        guard let glassClass = NSClassFromString(Keys.glassClass) as? NSObject.Type,
            let material = instantiateMaterial(glassClass, configuration: configuration)
        else {
            return nil
        }

        apply(configuration, to: material)

        guard let glassEffectClass = NSClassFromString(Keys.glassEffectClass) as? NSObject.Type else {
            return nil
        }

        let allocated = allocateInstance(of: glassEffectClass) ?? glassEffectClass.init()
        let initSelector = NSSelectorFromString(Keys.initWithGlass)
        guard allocated.responds(to: initSelector) else { return nil }

        typealias InitWithGlassFn = @convention(c) (AnyObject, Selector, AnyObject) -> AnyObject
        let initializer = unsafeBitCast(
            allocated.method(for: initSelector),
            to: InitWithGlassFn.self
        )

        return initializer(allocated, initSelector, material) as? UIGlassEffect
    }

    private static func instantiateMaterial(
        _ glassClass: NSObject.Type,
        configuration: UIGlassEffect.VariantConfiguration
    ) -> NSObject? {
        let allocated = allocateInstance(of: glassClass) ?? glassClass.init()

        let variantSizeSelector = NSSelectorFromString("initWithVariant:size:")
        if allocated.responds(to: variantSizeSelector) {
            typealias InitVariantSizeFn = @convention(c) (AnyObject, Selector, Int, Int) -> AnyObject
            let initializer = unsafeBitCast(
                allocated.method(for: variantSizeSelector),
                to: InitVariantSizeFn.self
            )
            return initializer(allocated, variantSizeSelector, configuration.variant, configuration.size) as? NSObject
        }

        let variantSelector = NSSelectorFromString("initWithVariant:")
        if allocated.responds(to: variantSelector) {
            typealias InitVariantFn = @convention(c) (AnyObject, Selector, Int) -> AnyObject
            let initializer = unsafeBitCast(
                allocated.method(for: variantSelector),
                to: InitVariantFn.self
            )
            return initializer(allocated, variantSelector, configuration.variant) as? NSObject
        }

        return allocated as? NSObject
    }

    private static func apply(_ configuration: UIGlassEffect.VariantConfiguration, to material: NSObject) {
        set(configuration.identifier, on: material, key: Keys.identifier, setter: Keys.setIdentifier)
        set(configuration.smoothness.map(Double.init), on: material, key: Keys.smoothness, setter: Keys.setSmoothness)
        set(configuration.tintColor, on: material, key: Keys.tintColor, setter: Keys.setTintColor)
        set(configuration.controlTintColor, on: material, key: Keys.controlTintColor, setter: Keys.setControlTintColor)
        set(configuration.subvariant, on: material, key: Keys.subvariant, setter: Keys.setSubvariant)
        set(configuration.contentLensing, on: material, key: Keys.contentLensing, setter: Keys.setContentLensing)
        set(configuration.highlightsDisplayAngle, on: material, key: Keys.highlightsDisplayAngle, setter: Keys.setHighlightsDisplayAngle)
        set(configuration.excludingPlatter, on: material, key: Keys.excludingPlatter, setter: Keys.setExcludingPlatter)
        set(configuration.excludingForeground, on: material, key: Keys.excludingForeground, setter: Keys.setExcludingForeground)
        set(configuration.excludingShadow, on: material, key: Keys.excludingShadow, setter: Keys.setExcludingShadow)
        set(configuration.excludingControlLensing, on: material, key: Keys.excludingControlLensing, setter: Keys.setExcludingControlLensing)
        set(configuration.excludingControlDisplacement, on: material, key: Keys.excludingControlDisplacement, setter: Keys.setExcludingControlDisplacement)
        set(configuration.flexible, on: material, key: Keys.flexible, setter: Keys.setFlexible)
        set(configuration.boostWhitePoint, on: material, key: Keys.boostWhitePoint, setter: Keys.setBoostWhitePoint)
        set(configuration.allowsGrouping, on: material, key: Keys.allowsGrouping, setter: Keys.setAllowsGrouping)
        set(configuration.backdropGroupName, on: material, key: Keys.backdropGroupName, setter: Keys.setBackdropGroupName)
    }

    private static func set(_ value: Any?, on material: NSObject, key: String, setter: String) {
        guard let value else { return }
        let setterSelector = NSSelectorFromString(setter)
        guard material.responds(to: setterSelector) else { return }
        material.setValue(value, forKey: key)
    }

    private static func allocateInstance(of cls: NSObject.Type) -> AnyObject? {
        let allocSelector = NSSelectorFromString("alloc")
        guard
            let metaClass = object_getClass(cls),
            class_respondsToSelector(metaClass, allocSelector)
        else {
            return nil
        }

        typealias AllocFn = @convention(c) (AnyClass, Selector) -> AnyObject
        let allocator = unsafeBitCast(
            class_getMethodImplementation(metaClass, allocSelector),
            to: AllocFn.self
        )
        return allocator(cls, allocSelector)
    }
}
