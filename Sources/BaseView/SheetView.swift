import UIKit
import Motion
import BaseToolbox

/// Draggable bottom sheet view with detents and scroll-view coordination.
@available(iOS 26.0, *)
public class SheetView: SubviewHitTestOnlyView {

    public struct Detent: Equatable, Identifiable {

        public struct Context {
            public let bounds: CGRect
            public let safeAreaInsets: UIEdgeInsets

            public init(bounds: CGRect, safeAreaInsets: UIEdgeInsets) {
                self.bounds = bounds
                self.safeAreaInsets = safeAreaInsets
            }
        }

        public struct Resolved {
            public let height: CGFloat
            public let insets: UIEdgeInsets

            public var absoluteHeight: CGFloat {
                height + insets.top + insets.bottom
            }

            public init(height: CGFloat, insets: UIEdgeInsets = .zero) {
                self.height = height
                self.insets = insets
            }
        }

        public let id: String

        public static func medium() -> Detent {
            Detent(id: "medium") { context in
                Resolved(height: context.bounds.height * 0.5, insets: UIEdgeInsets(left: 6, bottom: 6, right: 6))
            }
        }

        public static func large() -> Detent {
            Detent(id: "large") { context in
                Resolved(height: context.bounds.height - context.safeAreaInsets.top, insets: .zero)
            }
        }

        public static func custom(id: String, resolver: @escaping (Context) -> Resolved) -> Detent {
            Detent(id: id, resolver: resolver)
        }

        public static func ==(lhs: Detent, rhs: Detent) -> Bool {
            lhs.id == rhs.id
        }

        public func resolve(in context: Context) -> Resolved {
            resolver(context)
        }

        private let resolver: (Context) -> Resolved

        private init(id: String, resolver: @escaping (Context) -> Resolved) {
            self.id = id
            self.resolver = resolver
        }
    }

    public lazy var panGR = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gr:)))
    public lazy var headerPanGR = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gr:)))
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
    public var headerHeight: CGFloat = 44
    public var onHeightChange: ((CGFloat) -> Void)?
    public var onDismiss: (() -> Void)?
    public var detents: [Detent] = [.medium(), .large()]

    public var contentView: UIView {
        glassView.contentView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        panGR.delegate = self
        headerPanGR.delegate = self
        addGestureRecognizer(panGR)
        addGestureRecognizer(headerPanGR)

        glassView.cornerConfiguration = UICornerConfiguration.uniformEdges(
            topRadius: 40,
            bottomRadius: .containerConcentric(minimum: 30)
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
            self?.overrideSheetAbsoluteHeight = value
        }
        sheetHeightAnimation.completion = { [weak self] in
            self?.overrideSheetAbsoluteHeight = nil
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        layoutGlassView()
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

    public var currentSheetAbsoluteHeight: CGFloat {
        overrideSheetAbsoluteHeight ?? resolvedDetent(detent: currentDetent).absoluteHeight
    }

    public var currentSheetHeight: CGFloat {
        interpolatedDetent(forSheetAbsoluteHeight: currentSheetAbsoluteHeight).height
    }

    public var sheetAbsoluteHeightRange: ClosedRange<CGFloat> {
        let min = detents.map { resolvedDetent(detent: $0).absoluteHeight }.min() ?? resolvedDetent(detent: .medium()).absoluteHeight
        let max = detents.map { resolvedDetent(detent: $0).absoluteHeight }.max() ?? resolvedDetent(detent: .large()).absoluteHeight
        return min...max
    }

    public var sheetHeightRange: ClosedRange<CGFloat> {
        let min = detents.map { resolvedDetent(detent: $0).height }.min() ?? resolvedDetent(detent: .medium()).height
        let max = detents.map { resolvedDetent(detent: $0).height }.max() ?? resolvedDetent(detent: .large()).height
        return min...max
    }

    public func setCurrentDetent(_ detent: Detent, animated: Bool) {
        if animated {
            let currentSheetAbsoluteHeight = currentSheetAbsoluteHeight
            overrideSheetAbsoluteHeight = currentSheetAbsoluteHeight
            currentDetent = detent

            let finalSheetAbsoluteHeight = resolvedDetent(detent: detent).absoluteHeight
            sheetHeightAnimation.updateValue(to: currentSheetAbsoluteHeight)
            sheetHeightAnimation.toValue = finalSheetAbsoluteHeight
            sheetHeightAnimation.start()
        } else {
            currentDetent = detent
            overrideSheetAbsoluteHeight = nil
            setNeedsLayout()
        }
    }

    // MARK: - Private

    private var isDraggingSheet = true

    private var overrideSheetAbsoluteHeight: CGFloat? {
        didSet {
            guard oldValue != overrideSheetAbsoluteHeight else { return }
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

        let currentSheetAbsoluteHeight = currentSheetAbsoluteHeight
        let finalSheetAbsoluteHeight = currentSheetAbsoluteHeight.clamp(sheetAbsoluteHeightRange.lowerBound, sheetAbsoluteHeightRange.upperBound)
        let top = bounds.height - min(currentSheetAbsoluteHeight, finalSheetAbsoluteHeight)
        let width = bounds.width
        let resolved = interpolatedDetent(forSheetAbsoluteHeight: finalSheetAbsoluteHeight)
        let height = resolved.height
        let insets = resolved.insets
        let targetWidth = width - insets.left - insets.right
        let scale = width > 0 ? (targetWidth / width).clamp(0, 1) : 1
        let unscaledHeight = scale > 0 ? height / scale : 0
        let targetMidX = insets.left + targetWidth / 2
        let targetMidY = top + insets.top + height / 2

        glassView.frameWithoutTransform = CGRect(
            center: CGPoint(x: targetMidX, y: targetMidY),
            size: CGSize(width: width, height: unscaledHeight)
        )
        glassView.transform = .identity.scaledBy(x: scale, y: scale)

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

    private func resolvedDetent(detent: Detent) -> Detent.Resolved {
        detent.resolve(in: .init(bounds: bounds, safeAreaInsets: safeAreaInsets))
    }

    private func interpolatedDetent(forSheetAbsoluteHeight sheetAbsoluteHeight: CGFloat) -> Detent.Resolved {
        let resolvedDetents = detents
            .map { resolvedDetent(detent: $0) }
            .sorted { $0.absoluteHeight < $1.absoluteHeight }

        guard let first = resolvedDetents.first else {
            return resolvedDetent(detent: .medium())
        }
        guard let last = resolvedDetents.last else {
            return first
        }

        if sheetAbsoluteHeight <= first.absoluteHeight {
            return first
        }
        if sheetAbsoluteHeight >= last.absoluteHeight {
            return last
        }

        for index in 1..<resolvedDetents.count {
            let lower = resolvedDetents[index - 1]
            let upper = resolvedDetents[index]
            guard sheetAbsoluteHeight <= upper.absoluteHeight else { continue }

            let heightDelta = upper.absoluteHeight - lower.absoluteHeight
            guard heightDelta > 0 else { return upper }

            let progress = ((sheetAbsoluteHeight - lower.absoluteHeight) / heightDelta).clamp(0, 1)
            return .init(
                height: lower.height + (upper.height - lower.height) * progress,
                insets: lower.insets + (upper.insets - lower.insets) * progress
            )
        }

        return last
    }
    @objc private func handlePan(gr: UIPanGestureRecognizer) {
        let translation = gr.translation(in: self).y

        switch gr.state {
        case .began:
            sheetHeightAnimation.stop(resolveImmediately: true, postValueChanged: false)
            let trackedScrollOffset = trackedScrollView.map { $0.contentOffset.y + $0.adjustedContentInset.top } ?? 0
            if gr == headerPanGR {
                overrideSheetAbsoluteHeight = currentSheetAbsoluteHeight
            } else {
                overrideSheetAbsoluteHeight = currentSheetAbsoluteHeight + trackedScrollOffset
            }
            fallthrough
        case .changed:
            let target = currentSheetAbsoluteHeight - translation
            overrideSheetAbsoluteHeight = target
            isDraggingSheet = currentSheetAbsoluteHeight <= sheetAbsoluteHeightRange.upperBound
            gr.setTranslation(.zero, in: nil)
            
            if gr != headerPanGR {
                trackedScrollView?.lockedToTop = isDraggingSheet
            }
            if isDraggingSheet {
                trackedScrollView?.panGestureRecognizer.setTranslation(.zero, in: nil)
            }
        default:
            let currentSheetAbsoluteHeight = currentSheetAbsoluteHeight
            if isDraggingSheet {
                let stopSheetAbsoluteHeight = currentSheetAbsoluteHeight - gr.velocity(in: self).y * 0.3

                if let onDismiss, stopSheetAbsoluteHeight < 0 {
                    onDismiss()
                } else {
                    let targetDetent = closestDetent(forSheetAbsoluteHeight: stopSheetAbsoluteHeight)
                    
                    if resolvedDetent(detent: targetDetent).absoluteHeight != detents.map({ resolvedDetent(detent: $0).absoluteHeight }).max(), let trackedScrollView {
                        trackedScrollView.setContentOffset(CGPoint(x: -trackedScrollView.adjustedContentInset.left, y: -trackedScrollView.adjustedContentInset.top), animated: true)
                    }

                    currentDetent = targetDetent
                    let finalSheetAbsoluteHeight = resolvedDetent(detent: targetDetent).absoluteHeight

                    sheetHeightAnimation.updateValue(to: currentSheetAbsoluteHeight)
                    sheetHeightAnimation.velocity = -gr.velocity(in: self).y
                    sheetHeightAnimation.toValue = finalSheetAbsoluteHeight
                    sheetHeightAnimation.start()
                }
            } else {
                let targetDetent = closestDetent(forSheetAbsoluteHeight: currentSheetAbsoluteHeight)
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

    private func closestDetent(forSheetAbsoluteHeight sheetAbsoluteHeight: CGFloat) -> Detent {
        detents.min { a, b in
            abs(resolvedDetent(detent: a).absoluteHeight - sheetAbsoluteHeight) < abs(resolvedDetent(detent: b).absoluteHeight - sheetAbsoluteHeight)
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
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == headerPanGR else { return true }
        let velocity = headerPanGR.velocity(in: self)
        return headerPanGR.location(in: glassView).y < headerHeight && velocity.y > 0 && abs(velocity.y) > abs(velocity.x)
    }

    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        guard gestureRecognizer != headerPanGR else { return false }
        return trackScrollView(from: otherGestureRecognizer)
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        gestureRecognizer == headerPanGR
    }
}
