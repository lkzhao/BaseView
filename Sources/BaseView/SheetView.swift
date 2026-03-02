//
//  SheetView.swift
//  BaseView
//
//  Created by Luke Zhao on 3/1/26.
//

import UIKit
import Motion

@available(iOS 26.0, *)
open class SheetView: BaseView {

    lazy var panGR = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gr:)))
    public let glassView = UIVisualEffectView(effect: UIGlassEffect(style: .regular).with(\.isInteractive, value: true))
    var mediumSheetInsets: CGFloat = 6

    var onHeightChange: ((CGFloat) -> Void)?
    var onDismiss: (() -> Void)?

    let springAnim = SpringAnimation<CGFloat>()

    public var detents: [Detent] = [.medium(), .large()]
    let grabberView = UIView()

    public var contentView: UIView {
        glassView.contentView
    }

    private let grabberSize = CGSize(width: 40, height: 6)
    private let grabberTopInset: CGFloat = 5

    private var beginDraggingSheet = false
    private var lastNotifiedSheetHeight: CGFloat?
    private var lastLayoutNotificationBounds = CGRect.null
    private var lastLayoutNotificationSafeAreaInsets = UIEdgeInsets.zero
    private var isNotifyingSheetDidMove = false
    private weak var trackedScrollView: UIScrollView? {
        didSet {
            guard oldValue !== trackedScrollView else { return }
            oldValue?.lockedToTop = false
            trackedScrollView?.lockedToTop = isDraggingSheet
        }
    }

    public struct Detent: Equatable {
        typealias ID = String

        enum Kind {
            case medium
            case large
            case custom(resolver: () -> CGFloat)
        }

        let kind: Kind
        let identifier: ID

        public static func medium() -> Detent {
            Detent(kind: .medium, identifier: "medium")
        }

        public static func large() -> Detent {
            Detent(kind: .large, identifier: "large")
        }

        public static func custom(identifier: String, resolver: @escaping () -> CGFloat) -> Detent {
            Detent(kind: .custom(resolver: resolver), identifier: identifier)
        }

        public static func ==(lhs: Detent, rhs: Detent) -> Bool {
            lhs.identifier == rhs.identifier
        }
    }

    private var isDraggingSheet = true {
        didSet {
            guard oldValue != isDraggingSheet else { return }
            print(isDraggingSheet)
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

    override open func viewDidLoad() {
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

        springAnim.configure(response: 0.3, dampingRatio: 1.0)
        springAnim.resolvingEpsilon = 0.001
        springAnim.onValueChanged { [weak self] value in
            self?.overrideSheetHeight = value
        }

        springAnim.completion = { [weak self] in
            self?.overrideSheetHeight = nil
        }
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        layoutGlassView()
    }

    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        glassView.point(inside: convert(point, to: glassView), with: event)
    }

    override open func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil, bounds.height > 0 {
            notifyHeightChangeIfNeeded(force: true)
        }
    }

    private(set) var currentDetent: Detent = Detent.medium() {
        didSet {
            guard oldValue != currentDetent else { return }
            notifyHeightChangeIfNeeded()
        }
    }

    var currentSheetHeight: CGFloat {
        overrideSheetHeight ?? targetSheetHeight(detent: currentDetent)
    }

    var sheetHeightRange: ClosedRange<CGFloat> {
        let min = detents.map { targetSheetHeight(detent: $0) }.min() ?? targetSheetHeight(detent: .medium())
        let max = detents.map { targetSheetHeight(detent: $0) }.max() ?? targetSheetHeight(detent: .large())
        return min...max
    }

    func layoutGlassView() {
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

    func layoutGrabberView() {
        let bounds = glassView.contentView.bounds
        grabberView.frame = CGRect(
            x: (bounds.width - grabberSize.width) / 2,
            y: grabberTopInset,
            width: grabberSize.width,
            height: grabberSize.height
        )
    }

    func targetSheetHeight(detent: Detent) -> CGFloat {
        switch detent.kind {
        case .medium:
            return bounds.height * 0.5
        case .large:
            return bounds.height - safeAreaInsets.top
        case .custom(let resolver):
            return resolver()
        }
    }

    @objc func handlePan(gr: UIPanGestureRecognizer) {
        let translation = gr.translation(in: self).y

        switch gr.state {
        case .began:
            springAnim.stop(resolveImmediately: true, postValueChanged: false)
            let trackedScrollOffset = trackedScrollView.map { $0.contentOffset.y + $0.adjustedContentInset.top } ?? 0
            overrideSheetHeight = currentSheetHeight + trackedScrollOffset
            beginDraggingSheet = currentSheetHeight <= sheetHeightRange.upperBound
            fallthrough

        case .changed:
            let target = currentSheetHeight - translation
            overrideSheetHeight = target
            isDraggingSheet = currentSheetHeight <= sheetHeightRange.upperBound
            gr.setTranslation(.zero, in: nil)

            if isDraggingSheet, beginDraggingSheet {
                trackedScrollView?.panGestureRecognizer.setTranslation(.zero, in: nil)
            }

        default:
            defer {
                beginDraggingSheet = false
            }

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

                    springAnim.updateValue(to: currentSheetHeight)
                    springAnim.velocity = -gr.velocity(in: self).y
                    springAnim.toValue = finalSheetHeight
                    springAnim.start()
                }
            } else {
                let targetDetent = detents.min { a, b -> Bool in
                    abs(targetSheetHeight(detent: a) - currentSheetHeight) < abs(targetSheetHeight(detent: b) - currentSheetHeight)
                } ?? .medium()
                currentDetent = targetDetent
            }
        }
    }

    public func setCurrentDetent(_ detent: Detent, animated: Bool) {
        if animated {
            let currentSheetHeight = currentSheetHeight
            overrideSheetHeight = currentSheetHeight
            currentDetent = detent

            let finalSheetHeight = targetSheetHeight(detent: detent)
            springAnim.updateValue(to: currentSheetHeight)
            springAnim.toValue = finalSheetHeight
            springAnim.start()
        } else {
            currentDetent = detent
            overrideSheetHeight = nil
            setNeedsLayout()
        }
    }

    private func notifyHeightChangeIfNeeded(force: Bool = false) {
        let height = currentSheetHeight
        guard force || lastNotifiedSheetHeight != height else { return }
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
            scrollView.isDescendant(of: self)
        else {
            return false
        }

        trackedScrollView = scrollView
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
