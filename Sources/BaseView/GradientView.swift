import UIKit
import BaseToolbox

/// Gradient-backed view with optional per-interval easing between adjacent color stops.
open class GradientView: BaseView {
    private static let easedIntervalInsertedPointCount = 12

    open override class var layerClass: AnyClass {
        CAGradientLayer.self
    }

    open var gradientLayer: CAGradientLayer {
        layer as! CAGradientLayer
    }

    open var colors: [UIColor] = [] {
        didSet {
            guard colors != oldValue else { return }
            setNeedsUpdateProperties()
        }
    }

    open var locations: [CGFloat] = [] {
        didSet {
            guard locations != oldValue else { return }
            setNeedsUpdateProperties()
        }
    }

    open var easeFunctions: [EaseFunction] = [] {
        didSet {
            setNeedsUpdateProperties()
        }
    }

    @Proxy(\.gradientLayer.startPoint)
    open var startPoint: CGPoint

    @Proxy(\.gradientLayer.endPoint)
    open var endPoint: CGPoint

    public override init(frame: CGRect) {
        super.init(frame: frame)
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (view: Self, previousTraitCollection) in
            if view.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                view.setNeedsUpdateProperties()
            }
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func updateProperties() {
        super.updateProperties()
        let resolvedColors = colors.map { $0.resolvedColor(with: traitCollection) }
        guard resolvedColors.count > 1, resolvedColors.count == locations.count else {
            gradientLayer.colors = resolvedColors.map(\.cgColor)
            gradientLayer.locations = locations.map { NSNumber(value: Double($0)) }
            return
        }

        let mappedStops = createMappedStops(colors: resolvedColors, locations: locations)

        gradientLayer.colors = mappedStops.colors.map(\.cgColor)
        gradientLayer.locations = mappedStops.locations.map { NSNumber(value: Double($0)) }
    }

    private func createMappedStops(colors: [UIColor], locations: [CGFloat]) -> (colors: [UIColor], locations: [CGFloat]) {
        guard colors.count > 1 else {
            return (colors, locations)
        }

        var mappedColors: [UIColor] = [colors[0]]
        var mappedLocations: [CGFloat] = [locations[0]]

        for intervalIndex in 0..<(colors.count - 1) {
            let startColor = colors[intervalIndex]
            let endColor = colors[intervalIndex + 1]
            let startLocation = locations[intervalIndex]
            let endLocation = locations[intervalIndex + 1]

            if intervalIndex < easeFunctions.count {
                let easeFunction = easeFunctions[intervalIndex]
                if !easeFunction.isLinear {
                    for step in 1...Self.easedIntervalInsertedPointCount {
                        let linearT = CGFloat(step) / CGFloat(Self.easedIntervalInsertedPointCount + 1)
                        let easedT = easeFunction.value(at: linearT).clamp(0, 1)
                        mappedColors.append(.interpolated(from: startColor, to: endColor, progress: easedT))
                        mappedLocations.append(lerp(from: startLocation, to: endLocation, progress: linearT))
                    }
                }
            }

            mappedColors.append(endColor)
            mappedLocations.append(endLocation)
        }

        return (mappedColors, mappedLocations)
    }
}
