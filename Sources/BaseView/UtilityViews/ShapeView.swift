//
//  ShapeView.swift
//  shuffles
//
//  Created by Luke Zhao on 8/4/21.
//

import Foundation
import UIKit

open class ShapeView: View {
  public override class var layerClass: AnyClass {
    return CAShapeLayer.self
  }

  public var shapeLayer: CAShapeLayer {
    return layer as! CAShapeLayer
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
  
  open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
      shapeLayer.fillColor = fillColor?.cgColor
      shapeLayer.strokeColor = strokeColor?.cgColor
    }
  }
}
