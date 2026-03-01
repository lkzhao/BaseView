import UIKit
import BaseToolbox

extension UIColor {
    static func interpolated(from: UIColor, to: UIColor, progress: CGFloat) -> UIColor {
        let clampedProgress = progress.clamp(0, 1)
        guard
            let fromRGBA = from.rgbaComponents,
            let toRGBA = to.rgbaComponents
        else {
            return clampedProgress < 0.5 ? from : to
        }

        return UIColor(
            red: lerp(from: fromRGBA.red, to: toRGBA.red, progress: clampedProgress),
            green: lerp(from: fromRGBA.green, to: toRGBA.green, progress: clampedProgress),
            blue: lerp(from: fromRGBA.blue, to: toRGBA.blue, progress: clampedProgress),
            alpha: lerp(from: fromRGBA.alpha, to: toRGBA.alpha, progress: clampedProgress)
        )
    }

    private var rgbaComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return (red, green, blue, alpha)
        }

        var white: CGFloat = 0
        if getWhite(&white, alpha: &alpha) {
            return (white, white, white, alpha)
        }

        return nil
    }
}
