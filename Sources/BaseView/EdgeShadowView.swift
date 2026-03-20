import UIKit

/// Shadow-only view that cuts out its center so underlying content remains visible.
open class EdgeShadowView: BaseView {
    private struct CornerRadii {
        var topLeft: CGFloat
        var topRight: CGFloat
        var bottomRight: CGFloat
        var bottomLeft: CGFloat

        static let zero = CornerRadii(topLeft: 0, topRight: 0, bottomRight: 0, bottomLeft: 0)

        var maxValue: CGFloat {
            max(topLeft, topRight, bottomRight, bottomLeft)
        }

        func scaled(by factor: CGFloat) -> CornerRadii {
            CornerRadii(
                topLeft: topLeft * factor,
                topRight: topRight * factor,
                bottomRight: bottomRight * factor,
                bottomLeft: bottomLeft * factor
            )
        }
    }

    private enum CornerCurveStyle {
        case circular
        case continuous
    }

    private enum Corner {
        case topLeft
        case topRight
        case bottomRight
        case bottomLeft

        func point(x: CGFloat, y: CGFloat, in rect: CGRect, radius: CGFloat) -> CGPoint {
            switch self {
            case .topLeft:
                CGPoint(x: rect.minX + y * radius, y: rect.minY + x * radius)
            case .topRight:
                CGPoint(x: rect.maxX - x * radius, y: rect.minY + y * radius)
            case .bottomRight:
                CGPoint(x: rect.maxX - y * radius, y: rect.maxY - x * radius)
            case .bottomLeft:
                CGPoint(x: rect.minX + x * radius, y: rect.maxY - y * radius)
            }
        }
    }

    private static let continuousEdgeFactor: CGFloat = 1.52866483
    private static let continuousCurve1Control1: CGFloat = 1.08849323
    private static let continuousCurve1Control2: CGFloat = 0.86840689
    private static let continuousCurve1EndX: CGFloat = 0.66993427
    private static let continuousCurve1EndY: CGFloat = 0.06549600
    private static let continuousBridgeX: CGFloat = 0.63149399
    private static let continuousBridgeY: CGFloat = 0.07491100
    private static let continuousCurve2Control1X: CGFloat = 0.37282392
    private static let continuousCurve2Control1Y: CGFloat = 0.16906001
    private static let continuousCurve2Control2X: CGFloat = 0.16906001
    private static let continuousCurve2Control2Y: CGFloat = 0.37282392
    private static let continuousCurve2EndX: CGFloat = 0.07491100
    private static let continuousCurve2EndY: CGFloat = 0.63149399
    private static let continuousCurve3Control1: CGFloat = 0.86840701
    private static let continuousCurve3Control2: CGFloat = 1.08849299
    private let centerMaskView = ShapeView()

    public override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyCalculateShadowPath = false
        backgroundColor = .clear
        isOpaque = false
        clipsToBounds = false

        centerMaskView.backgroundColor = .clear
        centerMaskView.fillRule = .evenOdd
        centerMaskView.fillColor = .white
        centerMaskView.strokeColor = nil
        centerMaskView.isUserInteractionEnabled = false
        mask = centerMaskView
    }

    open override func updateProperties() {
        super.updateProperties()
        updateShadowGeometry()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        updateShadowGeometry()
    }

    private func updateShadowGeometry() {
        guard bounds.width > 0, bounds.height > 0 else {
            centerMaskView.path = nil
            shadowPath = nil
            return
        }

        let innerPath = resolvedRoundedPath(in: bounds)
        shadowPath = innerPath
        let maskFrame = bounds.inset(by: shadowExpansionInsets.inverted)
        centerMaskView.frameWithoutTransform = maskFrame
        centerMaskView.path = cutoutPath(around: innerPath, in: maskFrame)
    }

    private func cutoutPath(around innerPath: UIBezierPath, in maskFrame: CGRect) -> UIBezierPath {
        let cutoutPath = UIBezierPath(rect: centerMaskView.bounds)
        let translatedInnerPath = innerPath.copy() as! UIBezierPath
        translatedInnerPath.apply(CGAffineTransform(translationX: -maskFrame.minX, y: -maskFrame.minY))
        cutoutPath.append(translatedInnerPath)
        return cutoutPath
    }

    private var shadowExpansionInsets: UIEdgeInsets {
        let blurInset = max(0, shadowRadius) * 2
        return UIEdgeInsets(
            top: blurInset + max(0, -shadowOffset.height),
            left: blurInset + max(0, -shadowOffset.width),
            bottom: blurInset + max(0, shadowOffset.height),
            right: blurInset + max(0, shadowOffset.width)
        )
    }

    private func resolvedRoundedPath(in rect: CGRect) -> UIBezierPath {
        let preferredCurveStyle: CornerCurveStyle = cornerCurve == .continuous ? .continuous : .circular
        let resolvedRadii = resolvedCornerRadii()
        let circularRadii = normalizedRadii(resolvedRadii, in: rect, curveStyle: .circular)

        if preferredCurveStyle == .continuous,
           rect.height <= circularRadii.topLeft + circularRadii.bottomLeft + 32 {
            return circularRoundedPath(in: rect, radii: circularRadii)
        }

        switch preferredCurveStyle {
        case .circular:
            return circularRoundedPath(in: rect, radii: circularRadii)
        case .continuous:
            let continuousRadii = normalizedRadii(resolvedRadii, in: rect, curveStyle: .continuous)
            return continuousRoundedPath(in: rect, radii: continuousRadii)
        }
    }

    private func resolvedCornerRadii() -> CornerRadii {
        if #available(iOS 26.0, *) {
            let radii = CornerRadii(
                topLeft: effectiveRadius(corner: .topLeft),
                topRight: effectiveRadius(corner: .topRight),
                bottomRight: effectiveRadius(corner: .bottomRight),
                bottomLeft: effectiveRadius(corner: .bottomLeft)
            )
            if radii.maxValue > 0 {
                return radii
            }
        }

        return CornerRadii(
            topLeft: maskedCorners.contains(.layerMinXMinYCorner) ? cornerRadius : 0,
            topRight: maskedCorners.contains(.layerMaxXMinYCorner) ? cornerRadius : 0,
            bottomRight: maskedCorners.contains(.layerMaxXMaxYCorner) ? cornerRadius : 0,
            bottomLeft: maskedCorners.contains(.layerMinXMaxYCorner) ? cornerRadius : 0
        )
    }

    private func normalizedRadii(_ radii: CornerRadii, in rect: CGRect, curveStyle: CornerCurveStyle) -> CornerRadii {
        guard rect.width > 0, rect.height > 0 else {
            return .zero
        }

        let sanitized = CornerRadii(
            topLeft: max(0, radii.topLeft),
            topRight: max(0, radii.topRight),
            bottomRight: max(0, radii.bottomRight),
            bottomLeft: max(0, radii.bottomLeft)
        )

        let edgeFactor = curveStyle == .continuous ? Self.continuousEdgeFactor : 1
        let scales = [
            sideScale(length: rect.width, radiusSum: sanitized.topLeft + sanitized.topRight, edgeFactor: edgeFactor),
            sideScale(length: rect.height, radiusSum: sanitized.topRight + sanitized.bottomRight, edgeFactor: edgeFactor),
            sideScale(length: rect.width, radiusSum: sanitized.bottomLeft + sanitized.bottomRight, edgeFactor: edgeFactor),
            sideScale(length: rect.height, radiusSum: sanitized.topLeft + sanitized.bottomLeft, edgeFactor: edgeFactor),
        ]
        let scale = scales.min() ?? 1
        return sanitized.scaled(by: scale)
    }

    private func sideScale(length: CGFloat, radiusSum: CGFloat, edgeFactor: CGFloat) -> CGFloat {
        guard radiusSum > 0, edgeFactor > 0 else {
            return 1
        }
        return min(1, length / (radiusSum * edgeFactor))
    }

    private func circularRoundedPath(in rect: CGRect, radii: CornerRadii) -> UIBezierPath {
        let path = UIBezierPath()
        let minX = rect.minX
        let minY = rect.minY
        let maxX = rect.maxX
        let maxY = rect.maxY

        path.move(to: CGPoint(x: minX + radii.topLeft, y: minY))
        path.addLine(to: CGPoint(x: maxX - radii.topRight, y: minY))

        if radii.topRight > 0 {
            path.addArc(
                withCenter: CGPoint(x: maxX - radii.topRight, y: minY + radii.topRight),
                radius: radii.topRight,
                startAngle: -.pi / 2,
                endAngle: 0,
                clockwise: true
            )
        } else {
            path.addLine(to: CGPoint(x: maxX, y: minY))
        }

        path.addLine(to: CGPoint(x: maxX, y: maxY - radii.bottomRight))

        if radii.bottomRight > 0 {
            path.addArc(
                withCenter: CGPoint(x: maxX - radii.bottomRight, y: maxY - radii.bottomRight),
                radius: radii.bottomRight,
                startAngle: 0,
                endAngle: .pi / 2,
                clockwise: true
            )
        } else {
            path.addLine(to: CGPoint(x: maxX, y: maxY))
        }

        path.addLine(to: CGPoint(x: minX + radii.bottomLeft, y: maxY))

        if radii.bottomLeft > 0 {
            path.addArc(
                withCenter: CGPoint(x: minX + radii.bottomLeft, y: maxY - radii.bottomLeft),
                radius: radii.bottomLeft,
                startAngle: .pi / 2,
                endAngle: .pi,
                clockwise: true
            )
        } else {
            path.addLine(to: CGPoint(x: minX, y: maxY))
        }

        path.addLine(to: CGPoint(x: minX, y: minY + radii.topLeft))

        if radii.topLeft > 0 {
            path.addArc(
                withCenter: CGPoint(x: minX + radii.topLeft, y: minY + radii.topLeft),
                radius: radii.topLeft,
                startAngle: .pi,
                endAngle: -.pi / 2,
                clockwise: true
            )
        } else {
            path.addLine(to: CGPoint(x: minX, y: minY))
        }

        path.close()
        return path
    }

    private func continuousRoundedPath(in rect: CGRect, radii: CornerRadii) -> UIBezierPath {
        let path = UIBezierPath()

        path.move(to: Corner.topLeft.point(
            x: 0,
            y: Self.continuousEdgeFactor,
            in: rect,
            radius: radii.topLeft
        ))
        path.addLine(to: Corner.topRight.point(
            x: Self.continuousEdgeFactor,
            y: 0,
            in: rect,
            radius: radii.topRight
        ))

        addContinuousCorner(to: path, corner: .topRight, radius: radii.topRight, in: rect)
        path.addLine(to: Corner.bottomRight.point(
            x: Self.continuousEdgeFactor,
            y: 0,
            in: rect,
            radius: radii.bottomRight
        ))

        addContinuousCorner(to: path, corner: .bottomRight, radius: radii.bottomRight, in: rect)
        path.addLine(to: Corner.bottomLeft.point(
            x: Self.continuousEdgeFactor,
            y: 0,
            in: rect,
            radius: radii.bottomLeft
        ))

        addContinuousCorner(to: path, corner: .bottomLeft, radius: radii.bottomLeft, in: rect)
        path.addLine(to: Corner.topLeft.point(
            x: Self.continuousEdgeFactor,
            y: 0,
            in: rect,
            radius: radii.topLeft
        ))

        addContinuousCorner(to: path, corner: .topLeft, radius: radii.topLeft, in: rect)
        path.close()
        return path
    }

    private func addContinuousCorner(to path: UIBezierPath, corner: Corner, radius: CGFloat, in rect: CGRect) {
        path.addCurve(
            to: corner.point(
                x: Self.continuousCurve1EndX,
                y: Self.continuousCurve1EndY,
                in: rect,
                radius: radius
            ),
            controlPoint1: corner.point(
                x: Self.continuousCurve1Control1,
                y: 0,
                in: rect,
                radius: radius
            ),
            controlPoint2: corner.point(
                x: Self.continuousCurve1Control2,
                y: 0,
                in: rect,
                radius: radius
            )
        )

        path.addLine(to: corner.point(
            x: Self.continuousBridgeX,
            y: Self.continuousBridgeY,
            in: rect,
            radius: radius
        ))

        path.addCurve(
            to: corner.point(
                x: Self.continuousCurve2EndX,
                y: Self.continuousCurve2EndY,
                in: rect,
                radius: radius
            ),
            controlPoint1: corner.point(
                x: Self.continuousCurve2Control1X,
                y: Self.continuousCurve2Control1Y,
                in: rect,
                radius: radius
            ),
            controlPoint2: corner.point(
                x: Self.continuousCurve2Control2X,
                y: Self.continuousCurve2Control2Y,
                in: rect,
                radius: radius
            )
        )

        path.addCurve(
            to: corner.point(
                x: 0,
                y: Self.continuousEdgeFactor,
                in: rect,
                radius: radius
            ),
            controlPoint1: corner.point(
                x: 0,
                y: Self.continuousCurve3Control1,
                in: rect,
                radius: radius
            ),
            controlPoint2: corner.point(
                x: 0,
                y: Self.continuousCurve3Control2,
                in: rect,
                radius: radius
            )
        )
    }
}

private extension UIEdgeInsets {
    var inverted: UIEdgeInsets {
        UIEdgeInsets(top: -top, left: -left, bottom: -bottom, right: -right)
    }
}
