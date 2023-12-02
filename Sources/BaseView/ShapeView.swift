import Foundation
import UIKit
import BaseToolbox

open class ShapeView: View {
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
            shapeLayer.fillColor = fillColor?.cgColor
        }
    }
    
    public var strokeColor: UIColor? {
        didSet {
            shapeLayer.strokeColor = strokeColor?.cgColor
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

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            shapeLayer.fillColor = fillColor?.cgColor
            shapeLayer.strokeColor = strokeColor?.cgColor
        }
    }
}
