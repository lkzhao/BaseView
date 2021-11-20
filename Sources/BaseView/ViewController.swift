import UIKit
import Hero2

open class ViewController<RootViewType: RootView>: UIViewController {
    open var rootView: RootViewType {
        return view as! RootViewType
    }
    
    public init(rootView: RootViewType = RootViewType()) {
        super.init(nibName: nil, bundle: nil)
        
        self.view = rootView
        modalPresentationStyle = .fullScreen
        transitioningDelegate = TransitionCoordinator.shared
        title = rootView.title
        rootView.configure(viewController: self)
        additionalSafeAreaInsets = rootView.additionalSafeAreaInsets ?? .zero
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.view = RootViewType()
        transitioningDelegate = TransitionCoordinator.shared
        modalPresentationStyle = .fullScreen
        title = rootView.title
        rootView.configure(viewController: self)
        additionalSafeAreaInsets = rootView.additionalSafeAreaInsets ?? .zero
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        rootView.willAppear()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        rootView.didAppear()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        rootView.willDisappear()
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        rootView.didDisappear()
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        UIView.performWithoutAnimation {
            super.viewWillTransition(to: size, with: coordinator)
        }
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return rootView.preferredStatusBarStyle
    }
    
    open override var prefersStatusBarHidden: Bool {
        return rootView.prefersStatusBarHidden
    }
    
    open override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
}

extension ViewController: TransitionProvider {
    open func transitionFor(presenting: Bool, otherViewController: UIViewController) -> Transition? {
        rootView.transitionFor(presenting: presenting, otherViewController: otherViewController)
    }
}
