import UIKit
import Motion
import BaseToolbox

/// Draggable bottom sheet view with detents and scroll-view coordination.
@available(iOS 26.0, *)
public class SheetView: SubviewHitTestOnlyView {

    public struct Detent: Equatable, Identifiable {

        public struct Value {
            public let height: CGFloat
            public let insets: UIEdgeInsets

            public init(height: CGFloat, insets: UIEdgeInsets = .zero) {
                self.height = height
                self.insets = insets
            }
        }

        public let id: String

        public static func medium(insets: UIEdgeInsets = UIEdgeInsets(left: 6, bottom: 6, right: 6)) -> Detent {
            Detent(id: "medium", kind: .medium(insets: insets))
        }

        public static func large(insets: UIEdgeInsets = .zero) -> Detent {
            Detent(id: "large", kind: .large(insets: insets))
        }

        public static func custom(id: String, insets: UIEdgeInsets = .zero, resolver: @escaping () -> CGFloat) -> Detent {
            Detent(id: id, kind: .custom(resolver: {
                Value(height: resolver(), insets: insets)
            }))
        }

        public static func custom(id: String, resolver: @escaping () -> Value) -> Detent {
            Detent(id: id, kind: .custom(resolver: resolver))
        }

        public static func ==(lhs: Detent, rhs: Detent) -> Bool {
            lhs.id == rhs.id
        }

        enum Kind {
            case medium(insets: UIEdgeInsets)
            case large(insets: UIEdgeInsets)
            case custom(resolver: () -> Value)
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

    public var contentView: UIView {
        glassView.contentView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        panGR.delegate = self
        addGestureRecognizer(panGR)

        glassView.cornerConfiguration = UICornerConfiguration.uniformEdges(
            topRadius: 40,
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

        let currentSheetHeight = currentSheetHeight
        let finalSheetHeight = currentSheetHeight.clamp(sheetHeightRange.lowerBound, sheetHeightRange.upperBound)
        let top = bounds.height - min(currentSheetHeight, finalSheetHeight)
        let width = bounds.width
        let height = finalSheetHeight
        let insets = interpolatedInsets(forSheetHeight: finalSheetHeight)
        let targetWidth = width - insets.left - insets.right
        let scale = width > 0 ? (targetWidth / width).clamp(0, 1) : 1
        let unscaledHeight = scale > 0 ? height / scale : 0
        let targetMidX = insets.left + targetWidth / 2
        let targetMidY = top + height / 2 + insets.top - insets.bottom

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

    private func resolvedDetentValue(detent: Detent) -> Detent.Value {
        switch detent.kind {
        case .medium(let insets):
            return .init(height: bounds.height * 0.5, insets: insets)
        case .large(let insets):
            return .init(height: bounds.height - safeAreaInsets.top, insets: insets)
        case .custom(let resolver):
            return resolver()
        }
    }

    private func targetSheetHeight(detent: Detent) -> CGFloat {
        resolvedDetentValue(detent: detent).height
    }

    private func interpolatedInsets(forSheetHeight sheetHeight: CGFloat) -> UIEdgeInsets {
        let resolvedDetents = detents
            .map { resolvedDetentValue(detent: $0) }
            .sorted { $0.height < $1.height }

        guard let first = resolvedDetents.first else {
            return resolvedDetentValue(detent: .medium()).insets
        }
        guard let last = resolvedDetents.last else {
            return first.insets
        }

        if sheetHeight <= first.height {
            return first.insets
        }
        if sheetHeight >= last.height {
            return last.insets
        }

        for index in 1..<resolvedDetents.count {
            let lower = resolvedDetents[index - 1]
            let upper = resolvedDetents[index]
            guard sheetHeight <= upper.height else { continue }

            let heightDelta = upper.height - lower.height
            guard heightDelta > 0 else { return upper.insets }

            let progress = ((sheetHeight - lower.height) / heightDelta).clamp(0, 1)
            return lower.insets + (upper.insets - lower.insets) * progress
        }

        return last.insets
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
