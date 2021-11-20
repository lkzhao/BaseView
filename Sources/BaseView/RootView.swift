import UIKit
import Hero2

open class RootView: View {
    open var transition: Transition = HeroTransition()

    open var title: String? {
        didSet {
            parentViewController?.title = title
        }
    }

    open var additionalSafeAreaInsets: UIEdgeInsets? {
        didSet {
            parentViewController?.additionalSafeAreaInsets = additionalSafeAreaInsets!
        }
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        backgroundColor = .systemBackground
    }

    open func configure(viewController: UIViewController) {}

    open func willAppear() {}
    open func willDisappear() {}
    open func didAppear() {}
    open func didDisappear() {}

    open var preferredStatusBarStyle: UIStatusBarStyle { overrideUserInterfaceStyle == .dark ? .lightContent : .default }
    open var prefersStatusBarHidden: Bool { false }

    open func transitionFor(presenting: Bool, otherViewController: UIViewController) -> Transition? {
        transition
    }
}
