import UIKit
import ObjectiveC.runtime

private enum LockedToTopAssociatedKeys {
    static var lockedToTop = 0
    static var hidesVerticalScrollIndicatorAtTop = 0
}

internal extension UIScrollView {
    var lockedToTop: Bool {
        get {
            (objc_getAssociatedObject(self, &LockedToTopAssociatedKeys.lockedToTop) as? NSNumber)?.boolValue ?? false
        }
        set {
            UIScrollView.installLockedToTopSwizzleIfNeeded()
            guard lockedToTop != newValue else { return }

            objc_setAssociatedObject(
                self,
                &LockedToTopAssociatedKeys.lockedToTop,
                NSNumber(value: newValue),
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )

            if newValue {
                setContentOffset(CGPoint(x: contentOffset.x, y: -adjustedContentInset.top), animated: false)
            }
        }
    }

    var hidesVerticalScrollIndicatorAtTop: Bool {
        get {
            (objc_getAssociatedObject(self, &LockedToTopAssociatedKeys.hidesVerticalScrollIndicatorAtTop) as? NSNumber)?.boolValue ?? false
        }
        set {
            UIScrollView.installLockedToTopSwizzleIfNeeded()
            guard hidesVerticalScrollIndicatorAtTop != newValue else { return }

            objc_setAssociatedObject(
                self,
                &LockedToTopAssociatedKeys.hidesVerticalScrollIndicatorAtTop,
                NSNumber(value: newValue),
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )

            updateVerticalScrollIndicatorVisibilityIfNeeded(for: contentOffset)
        }
    }
}

private extension UIScrollView {
    static func installLockedToTopSwizzleIfNeeded() {
        _ = lockedToTopSwizzleToken
    }

    static let lockedToTopSwizzleToken: Void = {
        let swizzles: [(Selector, Selector)] = [
            (#selector(setter: UIScrollView.contentOffset), #selector(bv_setContentOffset(_:))),
            (#selector(UIScrollView.setContentOffset(_:animated:)), #selector(bv_setContentOffset(_:animated:)))
        ]

        for (originalSelector, swizzledSelector) in swizzles {
            guard
                let originalMethod = class_getInstanceMethod(UIScrollView.self, originalSelector),
                let swizzledMethod = class_getInstanceMethod(UIScrollView.self, swizzledSelector)
            else {
                assertionFailure("Failed to install UIScrollView.lockedToTop swizzle for \(originalSelector)")
                continue
            }

            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }()

    @objc func bv_setContentOffset(_ contentOffset: CGPoint) {
        let adjustedOffset = lockedToTopAdjustedContentOffset(from: contentOffset)
        bv_setContentOffset(adjustedOffset)
        updateVerticalScrollIndicatorVisibilityIfNeeded(for: adjustedOffset)
    }

    @objc func bv_setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        let adjustedOffset = lockedToTopAdjustedContentOffset(from: contentOffset)
        bv_setContentOffset(adjustedOffset, animated: animated)
        updateVerticalScrollIndicatorVisibilityIfNeeded(for: adjustedOffset)
    }

    func lockedToTopAdjustedContentOffset(from requestedOffset: CGPoint) -> CGPoint {
        guard lockedToTop else { return requestedOffset }
        return CGPoint(x: requestedOffset.x, y: -adjustedContentInset.top)
    }

    func updateVerticalScrollIndicatorVisibilityIfNeeded(for contentOffset: CGPoint) {
        let hides = hidesVerticalScrollIndicatorAtTop && contentOffset.y <= -adjustedContentInset.top
        let alpha: CGFloat = hides ? 0.0 : 1.0
        if let view = verticalScrollIndicatorView?.subviews.first, view.alpha != alpha {
            if verticalScrollIndicatorView?.alpha == 0 {
                verticalScrollIndicatorView?.subviews.first?.alpha = alpha
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.verticalScrollIndicatorView?.subviews.first?.alpha = alpha
                }
            }
        }
    }

    var verticalScrollIndicatorView: UIView? {
        guard let indicatorIvar = class_getInstanceVariable(UIScrollView.self, "_verticalScrollIndicator") else {
            return nil
        }
        return object_getIvar(self, indicatorIvar) as? UIView
    }
}
