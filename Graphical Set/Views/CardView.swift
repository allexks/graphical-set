//
//  CardView.swift
//  Graphical Set
//
//  Created by Aleksandar Ignatov on 27.05.19.
//  Copyright © 2019 MentorMate. All rights reserved.
//

import UIKit

class CardView: UIView {
  
  private static let distanceBetweenStripes: CGFloat = 4
  private static let padding = CGFloat(10.percent) // of the respective side of bounds
  private static let distanceBetweenShapes = CGFloat(5.percent) // of the inner rectangle
  private static let shapeWidth = CGFloat(25.percent) // of the inner rectangle
  
  var card: Card? /*TEST*/= Card(number: .three, shape: .squiggle, shading: .striped, color: .purple) {
    didSet {
      setNeedsDisplay()
      setNeedsLayout()
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    setNeedsDisplay()
  }
  
  override func draw(_ rect: CGRect) {
    let drawingRectangles = generateDrawingRectangles()
    
    for rectangle in drawingRectangles {
      if let path = createPathWithCorrectShape() {
        transformPath(path, toFitIn: rectangle)
        setColors()
        path.lineWidth = 2.0
        path.stroke()
        fillPath(path)
      }
    }
  }
  
  private func generateDrawingRectangles() -> [CGRect] {
    guard let card = card else { return [] }
    
    var result: [CGRect] = []
    
    let innerRectangle = CGRect(x: CardView.padding * bounds.width,
                                y: CardView.padding * bounds.height,
                                width: (1 - 2 * CardView.padding) * bounds.width,
                                height: (1 - 2 * CardView.padding) * bounds.height)
    
    let numberOfRects = CGFloat(card.number.rawValue)
    let rectanglesSmallerSide = CardView.shapeWidth * innerRectangle.longerSide
    let rectanglesLongerSide = innerRectangle.smallerSide
    let distanceBetweenRectangles = CardView.distanceBetweenShapes * innerRectangle.longerSide
    
    let rectanglesSmallerSidesTotal = numberOfRects * rectanglesSmallerSide
    let distancesBetweenRectanglesTotal = (numberOfRects - 1) * distanceBetweenRectangles
    let excessDistanceOnBothSides = (innerRectangle.longerSide - rectanglesSmallerSidesTotal - distancesBetweenRectanglesTotal) / 2
    
    let rectanglesWidth: CGFloat
    let rectanglesHeight: CGFloat
    switch innerRectangle.orientation {
    case .horizontal:
      rectanglesWidth = rectanglesSmallerSide
      rectanglesHeight = rectanglesLongerSide
    case .vertical:
      rectanglesWidth = rectanglesLongerSide
      rectanglesHeight = rectanglesSmallerSide
    }

    var currentOrigin: CGPoint
    switch innerRectangle.orientation {
    case .horizontal:
      currentOrigin = CGPoint(x: innerRectangle.origin.x + excessDistanceOnBothSides, y: innerRectangle.origin.y)
    case .vertical:
      currentOrigin = CGPoint(x: innerRectangle.origin.x, y: innerRectangle.origin.y + excessDistanceOnBothSides)
    }
    
    for _ in 1...card.number.rawValue {
      result.append(CGRect(origin: currentOrigin,
                           size: CGSize(width: rectanglesWidth, height: rectanglesHeight)))
      
      switch innerRectangle.orientation {
      case .horizontal:
        currentOrigin.x = currentOrigin.x + distanceBetweenRectangles + rectanglesSmallerSide
      case .vertical:
        currentOrigin.y = currentOrigin.y + distanceBetweenRectangles + rectanglesSmallerSide
      }
    }

    return result
  }
  
  private func createPathWithCorrectShape() -> UIBezierPath? {
    guard let card = card else { return nil }
    
    switch card.shape {
    case .diamond:
      return createDiamondPath()
    case .squiggle:
      return createSquigglePath()
    case .stadium:
      return createStadiumPath()
    }
  }
  
  private func setColors() {
    guard let card = card else { return }
    
    let correctColor: UIColor
    switch card.color {
    case .green:
      correctColor = #colorLiteral(red: 0.1019397757, green: 0.7645118199, blue: 0.08407260661, alpha: 1)
    case .purple:
      correctColor = #colorLiteral(red: 0.3630034349, green: 0.3452784866, blue: 0.9686274529, alpha: 1)
    case .red:
      correctColor = #colorLiteral(red: 1, green: 0.1942618935, blue: 0.4433173934, alpha: 1)
    }
    correctColor.setFill()
    correctColor.setStroke()
  }
  
  private func fillPath(_ path: UIBezierPath) {
    guard let card = card else { return }
    
    switch card.shading {
    case .open:
      break
    case .solid:
      path.fill()
    case .striped:
      fillWithStripes(path)
    }
  }
  
  private func createSquigglePath() -> UIBezierPath {
    let path = UIBezierPath()
    path.move(to: CGPoint(x: 104, y: 15))
    path.addCurve(to: CGPoint(x: 63, y: 54), controlPoint1: CGPoint(x: 113, y: 37), controlPoint2: CGPoint(x: 90, y: 61))
    path.addCurve(to: CGPoint(x: 27, y: 53), controlPoint1: CGPoint(x: 52, y: 51), controlPoint2: CGPoint(x: 42, y: 42))
    path.addCurve(to: CGPoint(x: 5, y: 40), controlPoint1: CGPoint(x: 10, y: 66), controlPoint2: CGPoint(x: 6, y: 58))
    path.addCurve(to: CGPoint(x: 36, y: 12), controlPoint1: CGPoint(x: 5, y: 22), controlPoint2: CGPoint(x: 19, y: 10))
    path.addCurve(to: CGPoint(x: 89, y: 14), controlPoint1: CGPoint(x: 59, y: 15), controlPoint2: CGPoint(x: 62, y: 32))
    path.addCurve(to: CGPoint(x: 104, y: 15), controlPoint1: CGPoint(x: 95, y: 10), controlPoint2: CGPoint(x: 101, y: 7))
    return path
  }
  
  private func createDiamondPath() -> UIBezierPath {
    let path = UIBezierPath()
    path.move(to: CGPoint(x: 0, y: 30))
    path.addLine(to: CGPoint(x: 54, y: 0))
    path.addLine(to: CGPoint(x: 108, y: 30))
    path.addLine(to: CGPoint(x: 54, y: 60))
    path.addLine(to: CGPoint(x: 0, y: 30))
    return path
  }
  
  private func createStadiumPath() -> UIBezierPath {
    let path = UIBezierPath()
    path.move(to: CGPoint(x: 10, y: 10))
    path.addLine(to: CGPoint(x: 30, y: 10))
    path.addArc(withCenter: CGPoint(x: 30, y: 20), radius: 10, startAngle: -CGFloat.pi / 2, endAngle: CGFloat.pi / 2, clockwise: true)
    path.addLine(to: CGPoint(x: 10, y: 30))
    path.addArc(withCenter: CGPoint(x: 10, y: 20), radius: 10, startAngle: CGFloat.pi / 2, endAngle: -CGFloat.pi / 2, clockwise: true)
    return path
  }
  
  private func transformPath(_ path: UIBezierPath, toFitIn rect: CGRect) {
    if rect.orientation == .vertical {
      path.apply(CGAffineTransform(rotationAngle: .pi / 2))
    }
    
    let scaleX = rect.width / path.bounds.width
    let scaleY = rect.height / path.bounds.height
    path.apply(CGAffineTransform(scaleX: scaleX, y: scaleY))
    
    let translationX = rect.midX - path.bounds.width/2 - path.bounds.minX
    let translationY = rect.midY - path.bounds.height/2 - path.bounds.minY
    path.apply(CGAffineTransform(translationX: translationX, y: translationY))
  }
  
  private func fillWithStripes(_ path: UIBezierPath) {
    let context = UIGraphicsGetCurrentContext()
    context?.saveGState()
    
    path.addClip()
    
    switch path.bounds.orientation {
    case .horizontal:
      for x in stride(from: path.bounds.minX, to: path.bounds.maxX, by: CardView.distanceBetweenStripes) {
        path.move(to: CGPoint(x: x, y: path.bounds.minY))
        path.addLine(to: CGPoint(x: x, y: path.bounds.maxY))
      }
    case .vertical:
      for y in stride(from: path.bounds.minY, to: path.bounds.maxY, by: CardView.distanceBetweenStripes) {
        path.move(to: CGPoint(x: path.bounds.minX, y: y))
        path.addLine(to: CGPoint(x: path.bounds.maxX, y: y))
      }
    }
    
    path.lineWidth = 1.0
    path.stroke()
    
    context?.restoreGState()
  }
}

extension CGRect {
  enum Orientation {
    case horizontal, vertical
  }
  
  var orientation: Orientation {
    return width > height ? .horizontal : .vertical
  }
  
  var longerSide: CGFloat {
    switch orientation {
    case .horizontal:
      return width
    case .vertical:
      return height
    }
  }
  
  var smallerSide: CGFloat {
    switch orientation {
    case .horizontal:
      return height
    case .vertical:
      return width
    }
  }
}
