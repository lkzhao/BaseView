//
//  SheetView.swift
//  BaseView
//
//  Created by Luke Zhao on 3/1/26.
//

import UIKit
import Motion

@available(iOS 26.0, *)
public class SheetView: BaseView {

    public struct Detent: Equatable, Identifiable {

        public let id: String

        public static func medium() -> Detent {
            Detent(id: "medium", kind: .medium)
        }

        public static func large() -> Detent {
            Detent(id: "large", kind: .large)
        }

        public static func custom(id: String, resolver: @escaping () -> CGFloat) -> Detent {
            Detent(id: id, kind: .custom(resolver: resolver))
        }

        public static func ==(lhs: Detent, rhs: Detent) -> Bool {
            lhs.id == rhs.id
        }

        enum Kind {
            case medium
            case large
            case custom(resolver: () -> CGFloat)
        }
        let kind: Kind
    }

    public lazy var panGR = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gr:)))
    public var sheetCornerConfiguration: UICornerConfiguration {
        get { glassView.cornerConfiguration }
        set {
            glassView.cornerConfiguration = newValue
            glassView.contentView.cornerConfiguration = newValue
        }
    }
    public var showsGrabber: Bool {
        get { !grabberView.isHidden }
        set { grabberView.isHidden = !newValue }
    }
    public var onHeightChange: ((CGFloat) -> Void)?
    public var onDismiss: (() -> Void)?
    public var detents: [Detent] = [.medium(), .large()]
    public var mediumSheetInsets: CGFloat = 6 {
        didSet {
            guard mediumSheetInsets != oldValue else { return }
            setNeedsLayout()
        }
    }

    public var contentView: UIView {
        glassView.contentView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        panGR.delegate = self
        addGestureRecognizer(panGR)

        glassView.cornerConfiguration = UICornerConfiguration.uniformEdges(
            topRadius: 56,
            bottomRadius: .containerConcentric()
        )
        glassView.contentView.cornerConfiguration = glassView.cornerConfiguration
        glassView.contentView.clipsToBounds = true

        addSubview(glassView)

        grabberView.backgroundColor = UIColor.secondaryLabel.withAlphaComponent(0.4)
        grabberView.isUserInteractionEnabled = false
        grabberView.layer.cornerRadius = grabberSize.height / 2
        glassView.contentView.addSubview(grabberView)

        sheetHeightAnimation.configure(response: 0.3, dampingRatio: 1.0)
        sheetHeightAnimation.resolvingEpsilon = 0.001
        sheetHeightAnimation.onValueChanged { [weak self] value in
            self?.overrideSheetHeight = value
        }
        sheetHeightAnimation.completion = { [weak self] in
            self?.overrideSheetHeight = nil
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        layoutGlassView()
    }

    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        glassView.point(inside: convert(point, to: glassView), with: event)
    }

    override open func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil, bounds.height > 0 {
            notifyHeightChangeIfNeeded()
        }
    }

    public private(set) var currentDetent: Detent = Detent.medium() {
        didSet {
            guard oldValue != currentDetent else { return }
            notifyHeightChangeIfNeeded()
        }
    }

    public var currentSheetHeight: CGFloat {
        overrideSheetHeight ?? targetSheetHeight(detent: currentDetent)
    }

    public var sheetHeightRange: ClosedRange<CGFloat> {
        let min = detents.map { targetSheetHeight(detent: $0) }.min() ?? targetSheetHeight(detent: .medium())
        let max = detents.map { targetSheetHeight(detent: $0) }.max() ?? targetSheetHeight(detent: .large())
        return min...max
    }

    public func setCurrentDetent(_ detent: Detent, animated: Bool) {
        if animated {
            let currentSheetHeight = currentSheetHeight
            overrideSheetHeight = currentSheetHeight
            currentDetent = detent

            let finalSheetHeight = targetSheetHeight(detent: detent)
            sheetHeightAnimation.updateValue(to: currentSheetHeight)
            sheetHeightAnimation.toValue = finalSheetHeight
            sheetHeightAnimation.start()
        } else {
            currentDetent = detent
            overrideSheetHeight = nil
            setNeedsLayout()
        }
    }

    // MARK: - Private

    private var isDraggingSheet = true {
        didSet {
            guard oldValue != isDraggingSheet else { return }
            trackedScrollView?.lockedToTop = isDraggingSheet
        }
    }

    private var overrideSheetHeight: CGFloat? {
        didSet {
            guard oldValue != overrideSheetHeight else { return }
            notifyHeightChangeIfNeeded()
            setNeedsLayout()
        }
    }

    private let grabberView = UIView()
    private let glassView = UIVisualEffectView(effect: UIGlassEffect(style: .regular).with(\.isInteractive, value: true))
    private let sheetHeightAnimation = SpringAnimation<CGFloat>()
    private let grabberSize = CGSize(width: 40, height: 6)
    private let grabberTopInset: CGFloat = 5
    private var lastNotifiedSheetHeight: CGFloat?
    private weak var trackedScrollView: UIScrollView? {
        didSet {
            guard oldValue !== trackedScrollView else { return }
            oldValue?.lockedToTop = false
            trackedScrollView?.lockedToTop = isDraggingSheet
        }
    }

    private func layoutGlassView() {
        guard bounds.height > 0, bounds.width > 0 else { return }

        let largeSheetHeight = targetSheetHeight(detent: .large())
        let mediumSheetHeight = targetSheetHeight(detent: .medium())
        let currentSheetHeight = currentSheetHeight
        let finalSheetHeight = currentSheetHeight.clamp(sheetHeightRange.lowerBound, sheetHeightRange.upperBound)

        let detentRange = largeSheetHeight - mediumSheetHeight
        let progress = detentRange > 0 ? ((largeSheetHeight - finalSheetHeight) / detentRange).clamp(0, 1) : 0
        let insets: CGFloat = progress * mediumSheetInsets
        let top = bounds.height - min(currentSheetHeight, finalSheetHeight)
        let width = bounds.width
        let height = finalSheetHeight

        let scaleX = width > 0 ? ((width - insets * 2) / width).clamp(0, 1) : 1
        let scaleY = height > 0 ? ((height - insets) / height).clamp(0, 1) : 1
        let unscaledY = top - (height * (1 - scaleY) / 2)

        glassView.frameWithoutTransform = CGRect(
            x: 0,
            y: unscaledY,
            width: width,
            height: height
        )
        glassView.transform = .identity.scaledBy(x: scaleX, y: scaleY)

        layoutGrabberView()
    }

    private func layoutGrabberView() {
        let bounds = glassView.contentView.bounds
        grabberView.frame = CGRect(
            x: (bounds.width - grabberSize.width) / 2,
            y: grabberTopInset,
            width: grabberSize.width,
            height: grabberSize.height
        )
    }

    private func targetSheetHeight(detent: Detent) -> CGFloat {
        switch detent.kind {
        case .medium:
            return bounds.height * 0.5
        case .large:
            return bounds.height - safeAreaInsets.top
        case .custom(let resolver):
            return resolver()
        }
    }

    @objc private func handlePan(gr: UIPanGestureRecognizer) {
        let translation = gr.translation(in: self).y

        switch gr.state {
        case .began:
            sheetHeightAnimation.stop(resolveImmediately: true, postValueChanged: false)
            let trackedScrollOffset = trackedScrollView.map { $0.contentOffset.y + $0.adjustedContentInset.top } ?? 0
            overrideSheetHeight = currentSheetHeight + trackedScrollOffset
            fallthrough

        case .changed:
            let target = currentSheetHeight - translation
            overrideSheetHeight = target
            isDraggingSheet = currentSheetHeight <= sheetHeightRange.upperBound
            gr.setTranslation(.zero, in: nil)

            if isDraggingSheet {
                trackedScrollView?.panGestureRecognizer.setTranslation(.zero, in: nil)
            }

        default:
            let currentSheetHeight = currentSheetHeight
            if isDraggingSheet {
                let stopSheetHeight = currentSheetHeight - gr.velocity(in: self).y * 0.3

                if let onDismiss, stopSheetHeight < 0 {
                    onDismiss()
                } else {
                    let targetDetent = detents.min { a, b -> Bool in
                        abs(targetSheetHeight(detent: a) - stopSheetHeight) < abs(targetSheetHeight(detent: b) - stopSheetHeight)
                    } ?? .medium()

                    currentDetent = targetDetent
                    let finalSheetHeight = targetSheetHeight(detent: targetDetent)

                    sheetHeightAnimation.updateValue(to: currentSheetHeight)
                    sheetHeightAnimation.velocity = -gr.velocity(in: self).y
                    sheetHeightAnimation.toValue = finalSheetHeight
                    sheetHeightAnimation.start()
                }
            } else {
                let targetDetent = detents.min { a, b -> Bool in
                    abs(targetSheetHeight(detent: a) - currentSheetHeight) < abs(targetSheetHeight(detent: b) - currentSheetHeight)
                } ?? .medium()
                currentDetent = targetDetent
            }
        }
    }

    private func notifyHeightChangeIfNeeded() {
        let height = currentSheetHeight
        guard lastNotifiedSheetHeight != height else { return }
        lastNotifiedSheetHeight = height
        onHeightChange?(height)
    }

    private func closestDetent(forSheetHeight sheetHeight: CGFloat) -> Detent {
        detents.min { a, b in
            abs(targetSheetHeight(detent: a) - sheetHeight) < abs(targetSheetHeight(detent: b) - sheetHeight)
        } ?? currentDetent
    }

    private func trackScrollView(from recognizer: UIGestureRecognizer) -> Bool {
        guard let scrollView = scrollView(for: recognizer),
              scrollView.isDescendant(of: self),
              scrollView.contentSize.height > scrollView.bounds.height
        else {
            return false
        }

        trackedScrollView = scrollView
        scrollView.hidesVerticalScrollIndicatorAtTop = true
        return true
    }

    private func scrollView(for recognizer: UIGestureRecognizer) -> UIScrollView? {
        if let scrollView = recognizer.view as? UIScrollView {
            return scrollView
        }

        var view = recognizer.view
        while let current = view {
            if let scrollView = current as? UIScrollView {
                return scrollView
            }
            view = current.superview
        }
        return nil
    }
}

@available(iOS 26.0, *)
extension SheetView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(
        _: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        trackScrollView(from: otherGestureRecognizer)
    }
}
