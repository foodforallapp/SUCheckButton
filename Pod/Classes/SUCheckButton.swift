//
//  SUCheckButton.swift
//  SUCheckButtonTest
//
//  Created by Suguru Kishimoto on 2015/11/03.
//  Copyright © 2015年 SFIDANTE Inc. All rights reserved.
//

import UIKit

@IBDesignable
public class SUCheckButton: UIControl {
    static let DefaultHeight: CGFloat = 30.0
    
    @IBInspectable var checked: Bool = false {
        didSet { self.setNeedsDisplay() }
    }
    var isChecked: Bool {
        get { return checked }
    }
    
    @IBInspectable var checkStrokeWidth: CGFloat = 1.5 {
        didSet { checkStrokeWidth = max(0.0, checkStrokeWidth) }
    }
    
    @IBInspectable var borderWidth: CGFloat = 1.0 {
        didSet { borderWidth = max(0.0, borderWidth) }
    }

    @IBInspectable var checkedColor: UIColor? = UIColor.whiteColor()
    @IBInspectable var checkedFillColor: UIColor? = UIColor(red: 0.078, green: 0.435, blue: 0.875, alpha: 1.0)
    @IBInspectable var checkedBorderColor: UIColor? = UIColor.whiteColor()

    @IBInspectable var uncheckedColor: UIColor? = UIColor(white: 0.8, alpha: 1.0)
    @IBInspectable var uncheckedFillColor: UIColor? = UIColor(white: 1.0, alpha: 0.6)
    @IBInspectable var uncheckedBorderColor: UIColor? = UIColor.whiteColor()
    
    @IBInspectable var shadowColor: UIColor? = UIColor.blackColor()
    
    @IBInspectable var animationEnabled : Bool = true
    @IBInspectable var animationScale: CGFloat = 1.05
    
    @IBInspectable var highlightColor: UIColor? = UIColor(white: 0.5, alpha: 0.3)
    
    typealias DidPressHandler = ((checked: Bool) -> Void)
    var didPressHandler: DidPressHandler?
    
    convenience init() {
        self.init(frame: CGRect(x: 0.0, y: 0.0, width: self.dynamicType.DefaultHeight, height: self.dynamicType.DefaultHeight))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
    }
    
    override public func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        if isChecked {
            drawForChecked()
        } else {
            drawForUnchecked()
        }
        if self.tracking {
            drawHighLight(color: self.highlightColor)
        }
    }
    
    private func drawForChecked() {
        drawOval(fillColor: self.checkedFillColor, borderColor: self.checkedBorderColor)
        drawCheckMark(checkMarkColor: self.checkedColor)
    }
    
    private func drawForUnchecked() {
        drawOval(fillColor: self.uncheckedFillColor, borderColor: self.uncheckedBorderColor)
        drawCheckMark(checkMarkColor: self.uncheckedColor)
    }
    
    private func getOvalFrame() -> CGRect {
        let f = self.bounds
        let dx: CGFloat = 4.0
        let dy: CGFloat = 4.0
        return CGRect(
            x: CGRectGetMinX(f) + dx,
            y: CGRectGetMinY(f) + dy,
            width: CGRectGetWidth(f) - dx * 2,
            height: CGRectGetHeight(f) - dy * 2
        )
    }
    
    private func drawOval(fillColor fillColor: UIColor?, borderColor: UIColor?) {
        let ovalRect = getOvalFrame()
        let ovalPath = UIBezierPath(ovalInRect: ovalRect)
        let context = UIGraphicsGetCurrentContext()
        let shadowOffset = CGSize(width: 0.1, height: -0.1)
        let shadowBlurRadius: CGFloat = 3.0
        
        CGContextSaveGState(context)
        CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, self.shadowColor?.CGColor)
        fillColor?.setFill()
        ovalPath.fill()
        CGContextRestoreGState(context)
        let borderInset = max(0.0, CGFloat(self.borderWidth/2 - 0.5))
        let borderPath = UIBezierPath(ovalInRect: CGRectInset(ovalRect, borderInset, borderInset))
        borderColor?.setStroke()
        borderPath.lineWidth = self.borderWidth
        borderPath.stroke()
    }
    
    private func drawCheckMark(checkMarkColor checkMarkColor: UIColor?) {
        let path = UIBezierPath()
        let ovalRect = getOvalFrame()
        let x = CGRectGetMinX(ovalRect)
        let y = CGRectGetMinY(ovalRect)
        let w = CGRectGetWidth(ovalRect)
        let h = CGRectGetHeight(ovalRect)
        path.moveToPoint(CGPoint(x: x + w * 0.27, y: y + 0.54 * h))
        path.addLineToPoint(CGPoint(x: x + 0.42 * w, y: y + 0.69 * h))
        path.addLineToPoint(CGPoint(x: x + 0.75 * w, y: y + 0.35 * h))
        path.lineCapStyle = .Square
        checkMarkColor?.setStroke()
        path.lineWidth = self.checkStrokeWidth
        path.stroke()
    }
    
    private func drawHighLight(color color: UIColor?) {
        let ovalRect = getOvalFrame()
        let ovalPath = UIBezierPath(ovalInRect: ovalRect)
        color?.setFill()
        ovalPath.fill()
    }
    
    private func scaleAnimation() {
        UIView.animateWithDuration(0.15, delay: 0.0, options: .BeginFromCurrentState, animations: { [weak self] in
            let scale = self?.animationScale ?? 1.0
            self?.transform = CGAffineTransformMakeScale(scale, scale)
        }, completion: { _ in
            UIView.animateWithDuration(0.15, delay: 0.0, options: .BeginFromCurrentState, animations: { [weak self] in
                self?.transform = CGAffineTransformIdentity
            }, completion: { _ in
            })
        })
    }
    
    // MARK: override tracking
    
    override public func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        self.setNeedsDisplay()
        super.beginTrackingWithTouch(touch, withEvent: event)
        return true
    }
    
    override public func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        self.setNeedsDisplay()
        super.continueTrackingWithTouch(touch , withEvent: event)
        return true
    }
    
    override public func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        self.checked = !self.isChecked
        self.sendActionsForControlEvents(.ValueChanged)
        //TODO: blocks
        self.didPressHandler?(checked: self.isChecked)
        self.setNeedsDisplay()
        if self.animationEnabled {
            scaleAnimation()
        }
        super.endTrackingWithTouch(touch, withEvent: event)
    }
    
    override public func cancelTrackingWithEvent(event: UIEvent?) {
        super.cancelTrackingWithEvent(event)
    }
}
