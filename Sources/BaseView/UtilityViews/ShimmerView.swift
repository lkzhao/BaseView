import UIKit

open class ShimmerView: GradientView {
    open var shimmerColor: UIColor = UIColor(white: 0.1, alpha: 1) {
        didSet {
            colors = [baseColor, shimmerColor, baseColor]
        }
    }
    open var baseColor = UIColor.black {
        didSet {
            colors = [baseColor, shimmerColor, baseColor]
        }
    }
    open var shimmerDuration: TimeInterval = 1.5 {
        didSet {
            updateAnimation()
        }
    }
    open override func viewDidLoad() {
        super.viewDidLoad()

        startPoint = CGPoint(x: 0.0, y: 1.0)
        endPoint = CGPoint(x: 1.0, y: 1.0)
        colors = [baseColor, shimmerColor, baseColor]
        locations = [0.0, 0.5, 1.0]
    }
    open override func didMoveToWindow() {
        super.didMoveToWindow()
        updateAnimation()
    }
    func updateAnimation() {
        if window != nil {
            let animation = CABasicAnimation(keyPath: "locations")
            animation.fromValue = [-1.0, -0.5, 0.0]
            animation.toValue = [1.0, 1.5, 2.0]
            animation.repeatCount = .infinity
            animation.duration = shimmerDuration
            gradientLayer.add(animation, forKey: animation.keyPath)
        } else {
            gradientLayer.removeAllAnimations()
        }
    }
}
