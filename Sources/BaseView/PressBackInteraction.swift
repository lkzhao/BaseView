import UIKit

/// Interaction that pushes a view backward in 3D while pressed, with perspective and tilt.
open class PressBackInteraction: NSObject, UIInteraction {
    /// Maximum tilt angle in radians for each axis based on touch position.
    open var maximumTiltAngle: CGFloat = .pi / 16

    /// Depth (in points) the view moves backward while pressed.
    open var pressedDepth: CGFloat = 24

    /// Perspective distance used for `m34` (`-1 / distance`).
    open var perspectiveDistance: CGFloat = 700

    /// Animation duration for press-in and pointer updates.
    open var pressInDuration: TimeInterval = 0.25

    /// Damping ratio used when pressing and updating the pointer position.
    open var pressDampingRatio: CGFloat = 0.82

    /// Animation duration for releasing back to the resting state.
    open var releaseDuration: TimeInterval = 0.6

    /// Damping ratio used when releasing back to the resting state.
    open var releaseDampingRatio: CGFloat = 0.5

    public private(set) weak var view: UIView?
    private lazy var pressRecognizer = SimultaneousPressGestureRecognizer(
        target: self,
        action: #selector(handlePress(_:))
    )

    private var restingTransform = CATransform3DIdentity
    private var isPressing = false

    public override init() {
        super.init()
    }

    // MARK: - UIInteraction

    open func willMove(to view: UIView?) {
        guard let currentView = self.view else { return }
        currentView.removeGestureRecognizer(pressRecognizer)

        if isPressing {
            currentView.layer.transform = restingTransform
            isPressing = false
        }
    }

    open func didMove(to view: UIView?) {
        self.view = view
        view?.addGestureRecognizer(pressRecognizer)
    }

    // MARK: - Gesture Handling

    @objc private func handlePress(_ gesture: UILongPressGestureRecognizer) {
        guard let view else { return }

        switch gesture.state {
        case .began:
            restingTransform = view.layer.transform
            isPressing = true
            fallthrough

        case .changed:
            if !isPressing {
                restingTransform = view.layer.transform
                isPressing = true
            }

            let location = gesture.location(in: view)
            let transform = pressedTransform(for: location, in: view.bounds)
            animate(view, to: transform, duration: pressInDuration, damping: pressDampingRatio)

        default:
            guard isPressing else { return }
            isPressing = false
            animate(view, to: restingTransform, duration: releaseDuration, damping: releaseDampingRatio)
        }
    }

    private func pressedTransform(for location: CGPoint, in bounds: CGRect) -> CATransform3D {
        let normalizedX = normalizedCoordinate(location.x, extent: bounds.width)
        let normalizedY = normalizedCoordinate(location.y, extent: bounds.height)

        var delta = CATransform3D.identity
        delta.m34 = -1 / max(perspectiveDistance, 1)
        delta.rotateBy(x: -normalizedY * maximumTiltAngle)
        delta.rotateBy(y: normalizedX * maximumTiltAngle)
        delta.translateBy(z: -pressedDepth)
        return restingTransform.concatenating(delta)
    }

    private func normalizedCoordinate(_ value: CGFloat, extent: CGFloat) -> CGFloat {
        guard extent > 0 else { return 0 }
        let normalized = (value / extent) * 2 - 1
        return min(max(normalized, -1), 1)
    }

    private func animate(_ view: UIView, to transform: CATransform3D, duration: TimeInterval, damping: CGFloat) {
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: damping,
            initialSpringVelocity: 0,
            options: [.allowUserInteraction, .beginFromCurrentState, .curveEaseOut]
        ) {
            view.layer.transform = transform
        }
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
