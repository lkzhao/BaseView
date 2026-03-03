import UIKit
import BaseView
import UIComponent
import BaseToolbox
import Motion

final class DemoViewController: UIViewController {
    private let rootView = DemoRootView()

    override func loadView() {
        view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "BaseView Example"
    }
}

private final class DemoRootView: BaseView {
    @available(iOS 26.0, *)
    let sheetView = SheetView().then {
        let smallDetent = SheetView.Detent.custom(id: "small") {
            120
        }
        $0.detents = [
            .large(),
            .medium(),
            smallDetent
        ]
        $0.setCurrentDetent(smallDetent, animated: false)
        $0.contentView.componentEngine.component = VStack(spacing: 16) {
            Text("SheetView", font: .boldSystemFont(ofSize: 32))
            for i in 0...100 {
                Text("Sheet Item \(i)", font: .systemFont(ofSize: 16))
            }
        }.inset(v: 30, h: 20).scrollView().fill()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundColor = .systemBackground
        ClassRuntimePrinter.printInfo(for: "_UIFlexInteraction")
    }

    override func updateProperties() {
        super.updateProperties()
        componentEngine.component = VStack(spacing: 18, alignItems: .stretch) {
            DemoCard(
                title: "BaseView",
                detail: "Base class with viewDidLoad/updateProperties hooks and shadow-path support.",
                preview: ViewComponent<BaseViewExampleView>()
                    .size(width: .fill, height: 84)
            )

            DemoCard(
                title: "WrapperView<UILabel>",
                detail: "Generic container that insets and sizes its contentView automatically.",
                preview: ViewComponent<LabelWrapperDemoView>()
                    .size(width: .fill, height: 84)
            )

            DemoCard(
                title: "GradientView",
                detail: "CAGradientLayer-backed view with resolved dynamic colors.",
                preview: ZStack {
                    ViewComponent<GradientView>()
                        .colors([
                            UIColor(red: 0.07, green: 0.31, blue: 0.64, alpha: 1.0),
                            UIColor(red: 0.06, green: 0.53, blue: 0.72, alpha: 1.0),
                            UIColor(red: 0.10, green: 0.65, blue: 0.46, alpha: 1.0)
                        ])
                        .locations([0.0, 0.5, 1.0])
                        .startPoint(CGPoint(x: 0.0, y: 0.0))
                        .endPoint(CGPoint(x: 1.0, y: 1.0))
                        .cornerRadius(14)
                        .size(width: .fill, height: 84)
                    Text("Linear Gradient", font: .boldSystemFont(ofSize: 20))
                        .textColor(.white)
                }
            )

            DemoCard(
                title: "ShimmerView",
                detail: "Animated gradient that continuously sweeps highlight locations.",
                preview: ViewComponent<ShimmerView>()
                    .baseColor(UIColor(red: 0.14, green: 0.18, blue: 0.32, alpha: 1.0))
                    .shimmerColor(UIColor(red: 0.57, green: 0.75, blue: 0.96, alpha: 1.0))
                    .shimmerDuration(1.1)
                    .size(width: .fill, height: 58)
                    .cornerRadius(14)
            )

            DemoCard(
                title: "ShimmerLabel",
                detail: "Text masked by a moving shimmer gradient.",
                preview: ViewComponent<ShimmerLabel>()
                    .text("ShimmerLabel Demo")
                    .with(\.font, .boldSystemFont(ofSize: 22))
                    .textAlignment(.center)
                    .baseColor(UIColor(red: 0.22, green: 0.26, blue: 0.36, alpha: 1.0))
                    .shimmerColor(UIColor(red: 0.86, green: 0.91, blue: 0.99, alpha: 1.0))
                    .size(width: .fill, height: 58)
                    .cornerRadius(14)
            )

            DemoCard(
                title: "VisualEffectView",
                detail: "Adjust effect intensity and pick different blur styles.",
                preview: ViewComponent<VisualEffectIntensityDemoView>()
                    .size(width: .fill, height: 380)
            )

            DemoCard(
                title: "LensView",
                detail: "A clear lens that lifts on press.",
                preview: ViewComponent<LensDemoView>()
                    .size(width: .fill, height: 160)
            )
            
            DemoCard(
                title: "Loupe View",
                detail: "A magnifying loupe view that zooms.",
                preview: ViewComponent<LoupeDemoView>()
                    .size(width: .fill, height: 160)
            )

            DemoCard(
                title: "PressBackInteraction",
                detail: "Press to push the card backward in 3D; tilt follows your finger position.",
                preview: ViewComponent<PressBackInteractionDemoView>()
                    .size(width: .fill, height: 190)
            )

            DemoCard(
                title: "PortalPairView",
                detail: "Tap to spring-animate progress and frame interpolation between two label anchors.",
                preview: ViewComponent<PortalPairDemoView>()
                    .size(width: .fill, height: 170)
            )

            DemoCard(
                title: "ShapeView",
                detail: "CAShapeLayer-backed vector view with stroke and fill controls.",
                preview: ViewComponent<BadgeShapeDemoView>()
                    .size(width: .fill, height: 84)
            )
        }
        .inset(20)
        .inset(bottom: 120)
        .scrollView()
        .fill()
        .overlay {
            sheetView
        }
    }
}

private struct DemoCard<Content: Component>: ComponentBuilder {
    let title: String
    let detail: String
    let preview: Content

    func build() -> some Component {
        VStack(spacing: 10, alignItems: .stretch) {
            Text(title, font: .boldSystemFont(ofSize: 18))
            Text(detail, font: .systemFont(ofSize: 14))
                .textColor(.secondaryLabel)
            preview
        }
    }
}

private final class BaseViewExampleView: BaseView {
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundColor = UIColor.systemBlue.withAlphaComponent(0.18)
        cornerRadius = 14
    }

    override func updateProperties() {
        super.updateProperties()
        componentEngine.component = VStack {
            Text("BaseView provides viewDidLoad and updateProperties hooks for setup and dynamic updates.")
                .font(.systemFont(ofSize: 14, weight: .medium))
        }.inset(12)
    }
}

private final class LabelWrapperDemoView: WrapperView<UILabel> {
    override func viewDidLoad() {
        super.viewDidLoad()

        inset = UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14)
        backgroundColor = UIColor.systemGreen.withAlphaComponent(0.18)
        layer.cornerRadius = 12
        clipsToBounds = true

        contentView.text = "WrapperView controls insets and delegates sizing to contentView."
        contentView.textAlignment = .center
        contentView.numberOfLines = 0
        contentView.font = .systemFont(ofSize: 14, weight: .medium)
    }
}

private final class VisualEffectIntensityDemoView: BaseView {
    private struct EffectOption {
        let title: String
        let effect: UIVisualEffect?
    }

    private let effectOptions: [EffectOption] = [
        EffectOption(title: "Material", effect: UIBlurEffect(style: .systemMaterial)),
        EffectOption(title: "Thin", effect: UIBlurEffect(style: .systemThinMaterial)),
        EffectOption(title: "Thick", effect: UIBlurEffect(style: .systemThickMaterial)),
        EffectOption(title: "Chrome", effect: UIBlurEffect(style: .systemChromeMaterial)),
        EffectOption(title: "Ultra Thin", effect: UIBlurEffect(style: .systemUltraThinMaterial)),
        EffectOption(title: "Regular Glass", effect: UIGlassEffect(style: .regular)),
        EffectOption(title: "Clear Glass", effect: UIGlassEffect(style: .clear)),
        EffectOption(title: "Variable Blur", effect: UIBlurEffect.variable(direction: .topToBottom, radius: 8)),
        EffectOption(title: "Variable Blur (Horizontal)", effect: UIBlurEffect.variable(direction: .leftToRight, radius: 8)),
    ]

    private var intensity: CGFloat = 0.6 {
        didSet {
            guard intensity != oldValue else { return }
            setNeedsUpdateProperties()
        }
    }

    private var selectedEffectIndex: Int = 0 {
        didSet {
            guard selectedEffectIndex != oldValue else { return }
            setNeedsUpdateProperties()
        }
    }

    private var selectedEffect: UIVisualEffect? {
        effectOptions[selectedEffectIndex].effect
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        backgroundColor = UIColor.secondarySystemBackground
        cornerRadius = 12
        clipsToBounds = true
    }

    override func updateProperties() {
        super.updateProperties()
        componentEngine.component = VStack(spacing: 8, alignItems: .stretch) {
            ViewComponent<VisualEffectBackdropView>()
                .intensity(intensity)
                .visualEffect(selectedEffect)
                .size(width: .fill, height: 140)

            Text("Intensity: \(String(format: "%.2f", intensity))", font: .systemFont(ofSize: 13, weight: .semibold))
                .textColor(.label)

            ViewComponent<IntensitySlider>()
                .minimumValue(0)
                .maximumValue(1)
                .value(intensity)
                .onValueChanged { [weak self] value in
                    self?.intensity = value
                }
                .size(width: .fill, height: 28)

            Text("Effect: \(effectOptions[selectedEffectIndex].title)", font: .systemFont(ofSize: 13, weight: .semibold))
                .textColor(.label)

            ViewComponent<EffectPicker>()
                .titles(effectOptions.map(\.title))
                .selectedIndex(selectedEffectIndex)
                .onSelectionChanged { [weak self] index in
                    self?.selectedEffectIndex = index
                }
                .fill()
                .flex()
        }
        .inset(12)
        .fill()
    }
}

private final class VisualEffectBackdropView: BaseView {
    var intensity: CGFloat = 0.6 {
        didSet {
            guard intensity != oldValue else { return }
            setNeedsUpdateProperties()
        }
    }

    var visualEffect: UIVisualEffect? = UIBlurEffect(style: .systemMaterial) {
        didSet {
            setNeedsUpdateProperties()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundColor = UIColor(red: 0.18, green: 0.22, blue: 0.42, alpha: 1.0)
        cornerRadius = 10
        clipsToBounds = true
    }

    override func updateProperties() {
        super.updateProperties()
        componentEngine.component = ZStack {
            ViewComponent<BackgroundCirclesView>().fill()

            Text("Blur Sample", font: .boldSystemFont(ofSize: 20))
                .textColor(UIColor.white.withAlphaComponent(0.95))

            ViewComponent<UIVisualEffectView>()
                .effect(visualEffect)
                .effectIntensity(intensity)
                .size(width: 200, height: .fill)
                .cornerRadius(20)
                .inset(20)
        }
    }
}

private final class LensDemoView: BaseView {
    private let lensView = LensView()
    private lazy var pressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handlePress(_:)))

    private var isPressing = false {
        didSet {
            guard isPressing != oldValue else { return }
            lensView.setLifted(isPressing, animated: true, alongsideAnimations: {
                self.lensView.transform = .identity.scaledBy(self.isPressing ? 1.2 : 1)
            })
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundColor = UIColor.secondarySystemBackground
        cornerRadius = 12
        clipsToBounds = true
        pressGesture.minimumPressDuration = 0
        lensView.addGestureRecognizer(pressGesture)
    }

    override func updateProperties() {
        super.updateProperties()
        componentEngine.component = ZStack {
            ViewComponent<BackgroundCirclesView>().fill()

            Text("Press and hold", font: .boldSystemFont(ofSize: 20))

            lensView
                .size(width: 200, height: 80)
                .inset(20)
        }
    }

    @objc private func handlePress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began, .changed:
            let local = gesture.location(in: self)
            isPressing = bounds.contains(local)
        default:
            isPressing = false
        }
    }
}

private final class BackgroundCirclesView: BaseView {
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundColor = .clear
    }

    override func updateProperties() {
        super.updateProperties()
        componentEngine.component = ZStack {
            Space(width: 110, height: 110)
                .backgroundColor(UIColor(red: 0.98, green: 0.55, blue: 0.35, alpha: 0.9))
                .roundedCorner()
                .offset(x: -28, y: -20)

            Space(width: 95, height: 95)
                .backgroundColor(UIColor(red: 0.22, green: 0.84, blue: 0.76, alpha: 0.86))
                .roundedCorner()
                .offset(x: 48, y: 20)

            Space(width: 120, height: 120)
                .backgroundColor(UIColor(red: 0.35, green: 0.50, blue: 0.98, alpha: 0.88))
                .roundedCorner()
                .offset(x: 120, y: -30)
        }
        .fill()
    }
}

private final class LoupeDemoView: BaseView {
    let loupeView = LoupeView()
    private lazy var pressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handlePress(_:)))

    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundColor = UIColor.secondarySystemBackground
        cornerRadius = 12
        clipsToBounds = true
        pressGesture.minimumPressDuration = 0
        addGestureRecognizer(pressGesture)
        addSubview(loupeView)
    }

    override func updateProperties() {
        super.updateProperties()
        componentEngine.component = ZStack {
            ViewComponent<BackgroundCirclesView>().fill()

            Text("Press and hold", font: .boldSystemFont(ofSize: 20))
        }
    }

    @objc private func handlePress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began, .changed:
            let local = gesture.location(in: self)
            loupeView.isActive = bounds.contains(local)
            loupeView.frameWithoutTransform = CGRect(center: local, size: CGSize(width: 120, height: 120))
        default:
            loupeView.isActive = false
        }
    }
}

private final class PressBackInteractionDemoView: BaseView {
    private let pressBackInteraction = PressBackInteraction()

    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundColor = UIColor.secondarySystemBackground
        cornerRadius = 12
        clipsToBounds = true
    }

    override func updateProperties() {
        super.updateProperties()
        componentEngine.component = ZStack {
            ViewComponent<BackgroundCirclesView>().fill()

            VStack(spacing: 6, alignItems: .center) {
                Text("Press and hold", font: .boldSystemFont(ofSize: 20))
                Text("Move finger to tilt", font: .systemFont(ofSize: 13, weight: .semibold))
                    .textColor(.secondaryLabel)
            }
            .inset(40)
            .visualEffectView()
            .effect(UIGlassEffect(style: .regular))
            .cornerRadius(24)
            .view()
            .zPosition(700)
            .update { [pressBackInteraction] in
                $0.addInteraction(pressBackInteraction)
            }
        }
    }
}

private final class IntensitySlider: UIView {
    private let slider = UISlider()
    var onValueChanged: ((CGFloat) -> Void)?

    var minimumValue: CGFloat = 0 {
        didSet {
            slider.minimumValue = Float(minimumValue)
        }
    }

    var maximumValue: CGFloat = 1 {
        didSet {
            slider.maximumValue = Float(maximumValue)
        }
    }

    var value: CGFloat = 0 {
        didSet {
            guard !slider.isTracking else { return }
            slider.value = Float(value)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        slider.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        componentEngine.component = slider.fill()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func valueChanged() {
        value = CGFloat(slider.value)
        onValueChanged?(value)
    }
}

private final class EffectPicker: UIView, UIPickerViewDataSource, UIPickerViewDelegate {
    private let pickerView = UIPickerView()

    var titles: [String] = [] {
        didSet {
            pickerView.reloadAllComponents()
            applySelectionIfNeeded()
        }
    }

    var selectedIndex: Int = 0 {
        didSet {
            applySelectionIfNeeded()
        }
    }

    var onSelectionChanged: ((Int) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        pickerView.dataSource = self
        pickerView.delegate = self
        componentEngine.component = pickerView.fill()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func applySelectionIfNeeded() {
        guard !titles.isEmpty else { return }
        let clamped = min(max(selectedIndex, 0), titles.count - 1)
        if clamped != selectedIndex {
            selectedIndex = clamped
            return
        }
        if pickerView.selectedRow(inComponent: 0) != clamped {
            pickerView.selectRow(clamped, inComponent: 0, animated: false)
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        titles.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        titles[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedIndex = row
        onSelectionChanged?(row)
    }
}

private final class PortalPairDemoView: BaseView {
    private let topLeftLabel = UIView().then {
        $0.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
        $0.cornerRadius = 8
        $0.componentEngine.component = Text("Top Left", font: .systemFont(ofSize: 14, weight: .semibold))
            .inset(h: 12, v: 8)
    }
    private let bottomRightLabel = UIView().then {
        $0.backgroundColor = UIColor.systemPink.withAlphaComponent(0.22)
        $0.cornerRadius = 8
        $0.componentEngine.component = Text("Bottom Right", font: .systemFont(ofSize: 14, weight: .semibold))
            .inset(h: 12, v: 8)
    }

    private lazy var portalPairView: PortalPairView = PortalPairView(backgroundView: topLeftLabel, foregroundView: bottomRightLabel)

    private let progressAnimation = SpringAnimation<CGFloat>(initialValue: 0)

    private var progress: CGFloat = 0 {
        didSet {
            applyProgress()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        backgroundColor = UIColor.secondarySystemBackground
        cornerRadius = 12
        clipsToBounds = true

        addSubview(portalPairView)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)

        progressAnimation.configure(response: 0.5, dampingRatio: 0.8)
        progressAnimation.onValueChanged(disableActions: true) { [weak self] value in
            self?.progress = value
        }
    }

    override func updateProperties() {
        super.updateProperties()
        componentEngine.component = ZStack {
            ZStack(verticalAlignment: .start, horizontalAlignment: .start) {
                topLeftLabel
            }.fill()
            ZStack(verticalAlignment: .end, horizontalAlignment: .end) {
                bottomRightLabel
            }.fill()
        }.inset(12)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyProgress()
    }

    @objc private func handleTap() {
        progressAnimation.toValue = progress < 0.5 ? 1 : 0
        progressAnimation.start()
    }

    private func applyProgress() {
        portalPairView.progress = progress
        portalPairView.frameWithoutTransform = interpolatedFrame(progress: progress)
    }

    private func interpolatedFrame(progress: CGFloat) -> CGRect {
        let fromFrame = topLeftLabel.frameWithoutTransform
        let toFrame = bottomRightLabel.frameWithoutTransform
        return CGRect(
            x: interpolate(from: fromFrame.minX, to: toFrame.minX, progress: progress),
            y: interpolate(from: fromFrame.minY, to: toFrame.minY, progress: progress),
            width: interpolate(from: fromFrame.width, to: toFrame.width, progress: progress),
            height: interpolate(from: fromFrame.height, to: toFrame.height, progress: progress)
        )
    }

    private func interpolate(from: CGFloat, to: CGFloat, progress: CGFloat) -> CGFloat {
        from + (to - from) * progress
    }
}

private final class BadgeShapeDemoView: ShapeView {
    override func viewDidLoad() {
        super.viewDidLoad()
        fillColor = UIColor.systemTeal.withAlphaComponent(0.20)
        strokeColor = .systemTeal
        lineWidth = 3
        lineCap = .round
        lineJoin = .round
        lineDashPattern = [8, 4]
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let outlineRect = bounds.insetBy(dx: 16, dy: 14)
        let outline = UIBezierPath(roundedRect: outlineRect, cornerRadius: 14)

        let checkmark = UIBezierPath()
        checkmark.move(to: CGPoint(x: outlineRect.minX + outlineRect.width * 0.28, y: outlineRect.midY))
        checkmark.addLine(to: CGPoint(x: outlineRect.midX - 2, y: outlineRect.maxY - outlineRect.height * 0.26))
        checkmark.addLine(to: CGPoint(x: outlineRect.maxX - outlineRect.width * 0.22, y: outlineRect.minY + outlineRect.height * 0.30))

        outline.append(checkmark)
        path = outline
    }
}
