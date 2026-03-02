import UIKit

/// View that only reports hit-testing success when one of its subviews contains the point.
open class SubviewHitTestOnlyView: BaseView {
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews.reversed() {
            guard !subview.isHidden, subview.alpha > 0.01, subview.isUserInteractionEnabled else {
                continue
            }

            let localPoint = convert(point, to: subview)
            if subview.point(inside: localPoint, with: event) {
                return true
            }
        }

        return false
    }
}
