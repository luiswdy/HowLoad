//
//  Gauge.swift
//  HowLoud
//
//  Created by Luis Wu on 5/18/16.
//  Copyright © 2016 Luis Wu. All rights reserved.
//

import UIKit

@IBDesignable
public class Gauge: UIControl {
    private var _value: CGFloat = 0
    
    // Main gauge layer
    private var gaugeLayer: CALayer!
    // other layers
    private var arcLayer: CAShapeLayer!
    private var outlineLayer: CAShapeLayer!
    private var graduationLayer: CAShapeLayer!
    private var needleLayer: CAShapeLayer!
    
    private struct Consts {
        static let Pi = CGFloat(M_PI)
        static let StartAngle = Gauge.degreeToRadian(210)
        static let EndAngle = Gauge.degreeToRadian(330)
        static let DefaultArcWidth: CGFloat = 10
        static let NeedleSpace: CGFloat = 1
        static let DefaultMaxValue: CGFloat = 100
        static let DefaultMinValue: CGFloat = 0
        static let DefaultNeedleWidth: CGFloat = 1
        static let DefaultRoundUpValue = false
        static let DefaultGraduationUnit:CGFloat = 10
        static let DefaultGraduationLength: Int = 10
        static let DefaultAdditionalNeedleLength: Int = 0
        static let AnimationDuration: CFTimeInterval = 0.1  // in sec
    }
    
    @IBInspectable public var maxValue: CGFloat = Consts.DefaultMaxValue
    @IBInspectable public var minValue: CGFloat = Consts.DefaultMinValue
    @IBInspectable public var arcColor: UIColor  = UIColor.orangeColor()
    @IBInspectable public var arcOutlineColor: UIColor  = UIColor.whiteColor()
    @IBInspectable public var needleColor: UIColor = UIColor.redColor()
    @IBInspectable public var arcWidth: CGFloat = Consts.DefaultArcWidth
    @IBInspectable public var arcOutlineWidth: CGFloat = Consts.DefaultArcWidth
    @IBInspectable public var needleWidth: CGFloat = Consts.DefaultNeedleWidth
    @IBInspectable public var roundUpValue: Bool = Consts.DefaultRoundUpValue
    @IBInspectable public var graduationUnit: CGFloat = Consts.DefaultGraduationUnit
    @IBInspectable public var graduationLength: Int = Consts.DefaultGraduationLength
    @IBInspectable public var additionalNeedleLength: Int = Consts.DefaultGraduationLength
    @IBInspectable public var value: CGFloat {
        get { return _value }
        set (newValue) {
            let oldValue = _value
            let newValue = newValue > maxValue ? maxValue : ( newValue < minValue ? minValue : newValue )
            
            let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
            rotateAnimation.fillMode = kCAFillModeForwards
            rotateAnimation.fromValue = valueToAngle(roundUpValue ? round(oldValue) : oldValue)
            rotateAnimation.toValue = valueToAngle(roundUpValue ? round(newValue) : newValue)
            rotateAnimation.duration = Consts.AnimationDuration
            rotateAnimation.removedOnCompletion = false
            
            print("needleLayer = \(needleLayer?.frame), \(needleLayer?.anchorPoint)")
            needleLayer?.addAnimation(rotateAnimation, forKey: "Rotate")
            
            _value = newValue > maxValue ? maxValue : ( newValue < minValue ? minValue : newValue ) // update _value
            
        }
    }
    
    func getGauge() -> CAShapeLayer {
        let gaugeLayer = CAShapeLayer()
        gaugeLayer.frame = self.bounds
        
        if arcLayer == nil {
            arcLayer = getArcLayer()
        }
        
        if graduationLayer == nil {
            graduationLayer = getGraduationLayer()
        }
        
        if outlineLayer == nil {
            outlineLayer = getOutlineLayer()
        }
        
        if needleLayer == nil {
            needleLayer = getNeedleLayer()
        }
        
        // Processing main gauge layer
        gaugeLayer.addSublayer(arcLayer)
        gaugeLayer.addSublayer(outlineLayer)
        gaugeLayer.addSublayer(graduationLayer)
        gaugeLayer.addSublayer(needleLayer)
        
        return gaugeLayer
    }
    
    func resetLayers() {
        layer.sublayers = nil
        gaugeLayer = nil
        arcLayer = nil
        outlineLayer = nil
        graduationLayer = nil
        needleLayer?.removeAllAnimations()
        needleLayer = nil
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        resetLayers()
        gaugeLayer = getGauge()
        layer.addSublayer(gaugeLayer)
    }
    
    private func valueToAngle(value: CGFloat) -> CGFloat {
        return value  * ((Consts.EndAngle - Consts.StartAngle) / (maxValue - minValue))
    }
    
    private static func degreeToRadian(degree: CGFloat) -> CGFloat {
        return degree / 180 * Consts.Pi
    }
    
    private func getRadius() -> CGFloat {
        if self.bounds.size.width >= self.bounds.size.height * 2 {  // for a rectangle of 2(or more):1, use height as radius
            return self.bounds.size.height - arcWidth / 2
        } else {    // use width / 2 as radius
            return self.bounds.size.width / 2 - arcWidth / 2
        }
    }
    
    private func getArcLayer() -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.frame = self.bounds
        layer.fillColor = UIColor.clearColor().CGColor // to keep the layer clean (or it would fill with black)
        layer.strokeColor = arcColor.CGColor
        layer.lineWidth = CGFloat(arcWidth)
        layer.path = getArcPath(getRadius())
        return layer
    }
    
    private func getArcPath(radius: CGFloat) -> CGPath {
        return UIBezierPath(arcCenter: getAnchorPoint(),
                            radius: radius,
                            startAngle: CGFloat(Consts.StartAngle),
                            endAngle: CGFloat(Consts.EndAngle),
                            clockwise: true).CGPath
    }
    
    private func getGraduationLayer() -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.frame = self.bounds
        layer.fillColor = UIColor.clearColor().CGColor
        layer.strokeColor = arcOutlineColor.CGColor
        layer.lineWidth = CGFloat(arcOutlineWidth)
        layer.path = getGraduationPath(getRadius())
        return layer
    }
    
    private func getGraduationPath(radius: CGFloat) -> CGPath {
        let unitAngle = (Consts.EndAngle - Consts.StartAngle) / (maxValue - minValue)
        let graduationPath = UIBezierPath()
        if (graduationUnit > 0) {
            for i in (minValue + graduationUnit).stride(to: maxValue, by: graduationUnit) {
                print("i = \(i)")
                let xStart = getAnchorPoint().x + (radius - CGFloat(arcWidth) / 2) * cos(CGFloat(Consts.StartAngle + i * unitAngle))
                let yStart = getAnchorPoint().y + (radius - CGFloat(arcWidth) / 2) * sin(CGFloat(Consts.StartAngle + i * unitAngle))
                let xEnd = xStart + CGFloat(graduationLength) * cos(CGFloat(Consts.StartAngle + i * unitAngle))
                let yEnd = yStart + CGFloat(graduationLength) * sin(CGFloat(Consts.StartAngle + i * unitAngle))
                print("xStart = \(xStart), xEnd = \(xEnd), yStart = \(yStart), yEnd = \(yEnd)")
                graduationPath.moveToPoint(CGPoint(x: xStart, y: yStart))
                graduationPath.addLineToPoint(CGPoint(x: xEnd, y: yEnd))
                
            }
        }
        return graduationPath.CGPath
    }
    
    private func getOutlineLayer() -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.frame = self.bounds
        layer.fillColor = UIColor.clearColor().CGColor
        layer.strokeColor = arcOutlineColor.CGColor
        layer.lineWidth = CGFloat(arcOutlineWidth)
        layer.path = getOutletPath(getRadius())
        return layer
    }
    
    private func getOutletPath(radius: CGFloat) -> CGPath {
        // inner arc
        let outlinePath = UIBezierPath(arcCenter: getAnchorPoint(),
                                       radius: radius - CGFloat(arcWidth) / 2,
                                       startAngle: CGFloat(Consts.StartAngle),
                                       endAngle: CGFloat(Consts.EndAngle),
                                       clockwise: true)
        // outer arc
        outlinePath.addArcWithCenter(getAnchorPoint(),
                                     radius: radius + CGFloat(arcWidth / 2),
                                     startAngle: CGFloat(Consts.EndAngle),
                                     endAngle: CGFloat(Consts.StartAngle),
                                     clockwise: false)
        outlinePath.closePath()
        return outlinePath.CGPath
    }
    
    private func getNeedleLayer() -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.frame = self.bounds
        layer.path = getNeedlePath(getRadius())
        layer.fillColor = UIColor.clearColor().CGColor
        layer.strokeColor = needleColor.CGColor
        layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        layer.frame = self.bounds // restore layer's frame so that it's position won't change after changing its anchorPoint
        layer.lineCap = kCALineCapRound
        layer.lineWidth = CGFloat(needleWidth)
        return layer
    }
    
    private func getNeedlePath(radius: CGFloat) -> CGPath {
        let needlePath = UIBezierPath()
        let needleLength = radius + CGFloat(additionalNeedleLength)
        needlePath.moveToPoint(getAnchorPoint())  // move to the center of the view
        needlePath.addLineToPoint( CGPoint(x: getAnchorPoint().x + needleLength * CGFloat(cos(Consts.StartAngle)),
            y: getAnchorPoint().y + needleLength * CGFloat(sin(Consts.StartAngle))))
        return needlePath.CGPath
    }
    
    private func getAnchorPoint() -> CGPoint {
        return CGPoint(x: self.bounds.size.width / 2 , y: self.bounds.size.height)
    }
}