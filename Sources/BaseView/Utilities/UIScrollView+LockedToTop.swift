import UIKit
import ObjectiveC.runtime

private enum LockedToTopAssociatedKeys {
    static var lockedToTop = 0
}

public extension UIScrollView {
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
        bv_setContentOffset(lockedToTopAdjustedContentOffset(from: contentOffset))
    }

    @objc func bv_setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        bv_setContentOffset(lockedToTopAdjustedContentOffset(from: contentOffset), animated: animated)
    }

    func lockedToTopAdjustedContentOffset(from requestedOffset: CGPoint) -> CGPoint {
        guard lockedToTop else { return requestedOffset }
        return CGPoint(x: requestedOffset.x, y: -adjustedContentInset.top)
    }
}
