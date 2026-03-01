import UIKit

open class ShimmerView: GradientView {
    open var shimmerColor: UIColor = UIColor(white: 0.1, alpha: 1) {
        didSet {
            guard shimmerColor != oldValue else { return }
            colors = [baseColor, shimmerColor, baseColor]
        }
    }
    open var baseColor = UIColor.black {
        didSet {
            guard baseColor != oldValue else { return }
            colors = [baseColor, shimmerColor, baseColor]
        }
    }
    open var shimmerDuration: TimeInterval = 1.5 {
        didSet {
            guard shimmerDuration != oldValue else { return }
            updateAnimation()
        }
    }
    open override func viewDidLoad() {
        super.viewDidLoad()

        startPoint = CGPoint(x: 0.0, y: 1.0)
        endPoint = CGPoint(x: 1.0, y: 1.0)
        colors = [baseColor, shimmerColor, baseColor]
        locations = [0.0, 0.5, 1.0]
        easeFunctions = [.easeInOut, .easeInOut]
    }
    open override func didMoveToWindow() {
        super.didMoveToWindow()
        updateAnimation()
    }

    func updateAnimation() {
        updatePropertiesIfNeeded()

        if window != nil {
            let baseLocations: [CGFloat]
            if let currentLocations = gradientLayer.locations?.map({ CGFloat(truncating: $0) }),
               !currentLocations.isEmpty {
                baseLocations = currentLocations
            } else if !locations.isEmpty {
                baseLocations = locations
            } else {
                baseLocations = [0.0, 0.5, 1.0]
            }

            let offset: CGFloat = 1.0
            let animation = CABasicAnimation(keyPath: "locations")
            animation.fromValue = baseLocations.map { NSNumber(value: Double($0 - offset)) }
            animation.toValue = baseLocations.map { NSNumber(value: Double($0 + offset)) }
            animation.repeatCount = .infinity
            animation.duration = shimmerDuration
            gradientLayer.add(animation, forKey: animation.keyPath)
        } else {
            gradientLayer.removeAllAnimations()
        }
    }
}
