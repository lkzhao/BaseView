import UIKit
import BaseToolbox
import Motion

/// Interaction that pushes a view backward in 3D while pressed, with perspective and tilt.
open class PressBackInteraction: NSObject, UIInteraction {
    /// Maximum tilt angle in radians for each axis based on touch position.
    open var maximumTiltAngle: CGFloat = .pi / 8

    /// Depth (in points) the view moves backward while pressed.
    open var pressedDepth: CGFloat = 30

    /// Perspective distance used for `m34` (`-1 / distance`).
    open var perspectiveDistance: CGFloat = 500

    open var response: Double = 0.4
    open var dampingRatio: CGFloat = 0.5

    public private(set) weak var view: UIView?
    private lazy var pressRecognizer = SimultaneousPressGestureRecognizer(
        target: self,
        action: #selector(handlePress(_:))
    )

    private var targetPressDeltaTransform = CATransform3DIdentity {
        didSet {
            guard targetPressDeltaTransform != oldValue else { return }
            applyInterpolatedTransform()
        }
    }
    private let pressProgressAnimation = SpringAnimation<CGFloat>(initialValue: 0)
    private var pressProgress: CGFloat = 0 {
        didSet {
            guard pressProgress != oldValue else { return }
            applyInterpolatedTransform()
        }
    }
    private var isPressing = false {
        didSet {
            guard oldValue != isPressing else { return }
            pressProgressAnimation.configure(response: response, dampingRatio: dampingRatio)
            pressProgressAnimation.updateValue(to: pressProgress)
            pressProgressAnimation.toValue = isPressing ? 1 : 0
            pressProgressAnimation.start()
        }
    }

    public override init() {
        super.init()
        pressProgressAnimation.resolvingEpsilon = 0.001
        pressProgressAnimation.onValueChanged(disableActions: true) { [weak self] value in
            self?.pressProgress = value
        }
    }

    // MARK: - UIInteraction

    open func willMove(to view: UIView?) {
        guard let currentView = self.view else { return }
        currentView.removeGestureRecognizer(pressRecognizer)
        pressProgressAnimation.stop(resolveImmediately: true, postValueChanged: false)
        targetPressDeltaTransform = CATransform3DIdentity
        pressProgress = 0
        isPressing = false
    }

    open func didMove(to view: UIView?) {
        self.view = view
        view?.addGestureRecognizer(pressRecognizer)
    }

    // MARK: - Gesture Handling

    @objc private func handlePress(_ gesture: UILongPressGestureRecognizer) {
        guard let view else { return }
        let location = gesture.location(in: view)

        switch gesture.state {
        case .began:
            isPressing = true
            fallthrough
        case .changed:
            targetPressDeltaTransform = pressedDeltaTransform(for: location, in: view.bounds)
        default:
            isPressing = false
        }
    }

    private func pressedDeltaTransform(for location: CGPoint, in bounds: CGRect) -> CATransform3D {
        let centerX = bounds.midX
        let centerY = bounds.midY
        let diagonalRadius = max(hypot(bounds.width, bounds.height) * 0.5, 1)
        let offsetX = location.x - centerX
        let offsetY = location.y - centerY
        let offsetMagnitude = hypot(offsetX, offsetY)
        let normalizedMagnitude = min(offsetMagnitude / diagonalRadius, 1)
        let directionX = offsetMagnitude > 0 ? offsetX / offsetMagnitude : 0
        let directionY = offsetMagnitude > 0 ? offsetY / offsetMagnitude : 0
        let normalizedX = directionX * normalizedMagnitude
        let normalizedY = directionY * normalizedMagnitude
        var delta = CATransform3D.identity
        delta.m34 = -1 / max(perspectiveDistance, 1)
        delta.rotateBy(x: -normalizedY * maximumTiltAngle)
        delta.rotateBy(y: normalizedX * maximumTiltAngle)
        delta.translateBy(z: -pressedDepth)
        return delta
    }

    private func applyInterpolatedTransform() {
        guard let view else { return }
        view.layer.transform = lerp(
            from: .identity,
            to: targetPressDeltaTransform,
            progress: pressProgress
        )
    }
}

private final class SimultaneousPressGestureRecognizer: UILongPressGestureRecognizer, UIGestureRecognizerDelegate {
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        minimumPressDuration = 0
        allowableMovement = .greatestFiniteMagnitude
        cancelsTouchesInView = false
        delaysTouchesBegan = false
        delaysTouchesEnded = false
        delegate = self
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }

    override func canPrevent(_ preventedGestureRecognizer: UIGestureRecognizer) -> Bool {
        false
    }

    override func canBePrevented(by preventingGestureRecognizer: UIGestureRecognizer) -> Bool {
        false
    }
}
