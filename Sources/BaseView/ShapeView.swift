import Foundation
import UIKit
import BaseToolbox

/// Shape-backed view that exposes common `CAShapeLayer` properties through view APIs.
open class ShapeView: BaseView {
    public override class var layerClass: AnyClass {
        CAShapeLayer.self
    }

    public var shapeLayer: CAShapeLayer {
        layer as! CAShapeLayer
    }

    public var path: UIBezierPath? {
        didSet {
            shapeLayer.path = path?.cgPath
        }
    }

    public var fillColor: UIColor? {
        didSet {
            guard fillColor != oldValue else { return }
            setNeedsUpdateProperties()
        }
    }

    public var strokeColor: UIColor? {
        didSet {
            guard strokeColor != oldValue else { return }
            setNeedsUpdateProperties()
        }
    }

    @Proxy(\.shapeLayer.fillRule)
    public var fillRule: CAShapeLayerFillRule

    @Proxy(\.shapeLayer.strokeStart)
    public var strokeStart: CGFloat

    @Proxy(\.shapeLayer.strokeEnd)
    public var strokeEnd: CGFloat

    @Proxy(\.shapeLayer.lineWidth)
    public var lineWidth: CGFloat

    @Proxy(\.shapeLayer.miterLimit)
    public var miterLimit: CGFloat

    @Proxy(\.shapeLayer.lineCap)
    public var lineCap: CAShapeLayerLineCap

    @Proxy(\.shapeLayer.lineJoin)
    public var lineJoin: CAShapeLayerLineJoin

    @Proxy(\.shapeLayer.lineDashPhase)
    public var lineDashPhase: CGFloat

    @Proxy(\.shapeLayer.lineDashPattern)
    public var lineDashPattern: [NSNumber]?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (view: Self, previousTraitCollection) in
            if view.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                view.setNeedsUpdateProperties()
            }
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func updateProperties() {
        super.updateProperties()
        shapeLayer.fillColor = fillColor?.resolvedColor(with: traitCollection).cgColor
        shapeLayer.strokeColor = strokeColor?.resolvedColor(with: traitCollection).cgColor
    }
}
