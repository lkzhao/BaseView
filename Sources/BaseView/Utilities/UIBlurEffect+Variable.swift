import UIKit
import ObfuscateMacro

public extension UIBlurEffect {
    enum Direction {
        case topToBottom
        case bottomToTop
        case leftToRight
        case rightToLeft
    }

    static func effectWithBlurRadius(_ blurRadius: CGFloat) -> UIBlurEffect {
        PrivateBlurEffectFactory.effectWithBlurRadius(blurRadius) ?? UIBlurEffect(style: .systemMaterial)
    }

    static func effectWithVariableBlurRadius(_ blurRadius: CGFloat, imageMask: UIImage) -> UIBlurEffect {
        PrivateBlurEffectFactory.effectWithVariableBlurRadius(blurRadius, imageMask: imageMask)
            ?? effectWithBlurRadius(blurRadius)
    }

    static func variable(
        direction: Direction,
        radius: CGFloat,
        easeFunction: EaseFunction = .linear
    ) -> UIBlurEffect {
        effectWithVariableBlurRadius(
            radius,
            imageMask: PrivateBlurEffectFactory.makeVariableMaskImage(direction: direction, easeFunction: easeFunction)
        )
    }
}

private enum PrivateBlurEffectFactory {
    private enum Keys {
        static let blurEffectClass = #ObfuscatedString("UIBlurEffect")
        static let effectWithBlurRadius = #ObfuscatedString("effectWithBlurRadius:")
        static let effectWithVariableBlurRadiusImageMask = #ObfuscatedString("effectWithVariableBlurRadius:imageMask:")
    }

    static func makeVariableMaskImage(
        direction: UIBlurEffect.Direction,
        easeFunction: EaseFunction,
        steps: Int = 30
    ) -> UIImage {
        let clampedSteps = max(steps, 2)
        let isVertical = direction == .topToBottom || direction == .bottomToTop
        let size = isVertical ? CGSize(width: 1, height: clampedSteps) : CGSize(width: clampedSteps, height: 1)
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = false
        format.scale = 1

        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { context in
            for index in 0..<clampedSteps {
                let ratio = CGFloat(index) / CGFloat(clampedSteps - 1)
                let directedRatio: CGFloat
                switch direction {
                case .topToBottom, .leftToRight:
                    directedRatio = ratio
                case .bottomToTop, .rightToLeft:
                    directedRatio = 1 - ratio
                }

                let eased = max(0, min(1, easeFunction.value(at: directedRatio)))
                let alpha = 1 - eased
                UIColor.black.withAlphaComponent(alpha).setFill()

                if isVertical {
                    context.fill(CGRect(x: 0, y: index, width: Int(size.width), height: 1))
                } else {
                    context.fill(CGRect(x: index, y: 0, width: 1, height: Int(size.height)))
                }
            }
        }
    }

    static func effectWithBlurRadius(_ blurRadius: CGFloat) -> UIBlurEffect? {
        guard
            let blurEffectClass = NSClassFromString(Keys.blurEffectClass) as? NSObject.Type,
            let effect = invokeEffectWithBlurRadius(on: blurEffectClass, blurRadius: blurRadius)
        else {
            return nil
        }

        return effect as? UIBlurEffect
    }

    static func effectWithVariableBlurRadius(_ blurRadius: CGFloat, imageMask: UIImage) -> UIBlurEffect? {
        guard
            let blurEffectClass = NSClassFromString(Keys.blurEffectClass) as? NSObject.Type,
            let effect = invokeEffectWithVariableBlurRadius(on: blurEffectClass, blurRadius: blurRadius, imageMask: imageMask)
        else {
            return nil
        }

        return effect as? UIBlurEffect
    }

    private static func invokeEffectWithBlurRadius(on cls: NSObject.Type, blurRadius: CGFloat) -> AnyObject? {
        let selector = NSSelectorFromString(Keys.effectWithBlurRadius)
        guard cls.responds(to: selector) else { return nil }

        typealias BlurRadiusFn = @convention(c) (AnyObject, Selector, CGFloat) -> AnyObject
        let implementation = unsafeBitCast(cls.method(for: selector), to: BlurRadiusFn.self)
        return implementation(cls, selector, blurRadius)
    }

    private static func invokeEffectWithVariableBlurRadius(on cls: NSObject.Type, blurRadius: CGFloat, imageMask: UIImage)
        -> AnyObject?
    {
        let selector = NSSelectorFromString(Keys.effectWithVariableBlurRadiusImageMask)
        guard cls.responds(to: selector) else { return nil }

        typealias VariableBlurRadiusFn = @convention(c) (AnyObject, Selector, CGFloat, AnyObject) -> AnyObject
        let implementation = unsafeBitCast(cls.method(for: selector), to: VariableBlurRadiusFn.self)
        return implementation(cls, selector, blurRadius, imageMask)
    }
}
