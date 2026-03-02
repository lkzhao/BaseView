import UIKit
import BaseView
import UIComponent
import BaseToolbox

final class GlassVariantsViewController: UIViewController {
    override func loadView() {
        view = GlassVariantsView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Glass Variants"
        navigationItem.largeTitleDisplayMode = .never
    }
}

private final class GlassVariantsView: BaseView {

    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundColor = .black
    }

    override func updateProperties() {
        super.updateProperties()
        componentEngine.component = Image("AbstractBackground")
            .contentMode(.scaleAspectFill)
            .fill()
            .overlay {
                VStack(spacing: 12, alignItems: .stretch) {
                    Text("Glass Variants", font: .boldSystemFont(ofSize: 24))
                        .textColor(.white)

                    Text("Private _UIViewGlass variants over a static abstract image background.", font: .systemFont(ofSize: 13))
                        .textColor(UIColor.white.withAlphaComponent(0.84))

                    Waterfall(columns: 4, spacing: 5) {
                        for variant in 0...19 {
                            Text("Variant \(variant)", font: .systemFont(ofSize: 18))
                                .textColor(.white)
                                .inset(20)
                                .background {
                                    ViewComponent(generator: VisualEffectView(effect: UIGlassEffect.variant(variant))).cornerRadius(16)
                                }
                        }
                    }

                    Space(height: 50)

                    Text("Variant 1", font: .systemFont(ofSize: 18))
                        .textColor(.white)
                        .inset(20)
                        .background {
                            ViewComponent(generator: VisualEffectView(effect: UIGlassEffect.variant(.init(variant: 1)))).cornerRadius(16)
                        }

                    Text("No platter", font: .systemFont(ofSize: 18))
                        .textColor(.white)
                        .inset(20)
                        .background {
                            ViewComponent(generator: VisualEffectView(effect: UIGlassEffect.variant(.init(variant: 1, excludingPlatter: true)))).cornerRadius(16)
                        }

                    Text("No foreground", font: .systemFont(ofSize: 18))
                        .textColor(.white)
                        .inset(20)
                        .background {
                            ViewComponent(generator: VisualEffectView(effect: UIGlassEffect.variant(.init(variant: 1, excludingForeground: true)))).cornerRadius(16)
                        }

                    Text("No shadow", font: .systemFont(ofSize: 18))
                        .textColor(.white)
                        .inset(20)
                        .background {
                            ViewComponent(generator: VisualEffectView(effect: UIGlassEffect.variant(.init(variant: 1, excludingShadow: true)))).cornerRadius(16)
                        }

                    Text("No control lensing", font: .systemFont(ofSize: 18))
                        .textColor(.white)
                        .inset(20)
                        .background {
                            ViewComponent(generator: VisualEffectView(effect: UIGlassEffect.variant(.init(variant: 1, excludingControlLensing: true)))).cornerRadius(16)
                        }

                    Text("No control displacement", font: .systemFont(ofSize: 18))
                        .textColor(.white)
                        .inset(20)
                        .background {
                            ViewComponent(generator: VisualEffectView(effect: UIGlassEffect.variant(.init(variant: 1, excludingControlDisplacement: true)))).cornerRadius(16)
                        }
                }
                .inset(20)
                .scrollView()
                .contentInsetAdjustmentBehavior(.always)
            }
    }
}
