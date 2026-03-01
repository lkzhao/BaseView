import UIKit
import BaseView
import UIComponent
import BaseToolbox

final class DemoViewController: UIViewController {
    override func loadView() {
        view = DemoRootView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "BaseView Example"
    }
}

private final class DemoRootView: View {
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundColor = .systemBackground
    }

    override func updateProperties() {
        super.updateProperties()
        componentEngine.component = VStack(spacing: 18, alignItems: .stretch) {
            DemoCard(
                title: "View",
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
                title: "ShapeView",
                detail: "CAShapeLayer-backed vector view with stroke and fill controls.",
                preview: ViewComponent<BadgeShapeDemoView>()
                    .size(width: .fill, height: 84)
            )
        }
        .inset(20)
        .scrollView()
        .fill()
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

private final class BaseViewExampleView: View {
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
