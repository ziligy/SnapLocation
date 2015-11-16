//
//  JGTapButton.swift
//
//  Created by Jeff on 8/20/15.
//  Copyright © 2015 Jeff Greenberg. All rights reserved.
//

import UIKit

enum TapButtonShape {
    case Round
    case Rectangle
}

enum TapButtonStyle {
    case Raised
    case Flat
}

@IBDesignable
public class JGTapButton: UIButton {
    
    // MARK: Inspectables
    
    // select round or rectangle button shape
    @IBInspectable public var round: Bool = true {
        didSet {
            buttonShape = (round ? .Round : .Rectangle)
        }
    }
    
    // select raised or flat style
    @IBInspectable public var raised: Bool = true {
        didSet {
            buttonStyle = (raised ? .Raised : .Flat)
        }
    }
    
    // set title caption for button
    @IBInspectable public var title: String = "JGTapButton" {
        didSet {
            buttonTitle = title
        }
    }
    
    // optional button image
    @IBInspectable public var image: UIImage=UIImage() {
        didSet {
            iconImageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))
            iconImageView.image = self.image
        }
    }
    
    // main background button color
    @IBInspectable public var mainColor: UIColor = UIColor.redColor() {
        didSet {
            buttonColor = mainColor
        }
    }
    
    // title font size
    @IBInspectable public var fontsize: CGFloat = 22.0 {
        didSet {
            titleFontSize = fontsize
        }
    }
    
    @IBInspectable public var fontColor: UIColor = UIColor.whiteColor()

    
    // MARK: Private variables
    
    private var buttonShape = TapButtonShape.Round
    
    private var buttonStyle = TapButtonStyle.Flat
    
    private var buttonTitle = ""
    
    private var buttonColor = UIColor.redColor()
    
    private var titleFontSize: CGFloat = 22.0
    
    private var tapButtonFrame = CGRectMake(0, 0, 100, 100)
    
    // outline shape of button from draw
    private var outlinePath = UIBezierPath()
    
    // variables for glow animation
    private let tapGlowView = UIView()
    private let tapGlowBackgroundView = UIView()
    
    private var tapGlowColor = UIColor(white: 0.9, alpha: 1)
    private var tapGlowBackgroundColor = UIColor(white: 0.95, alpha: 1)
    
    private var tapGlowMask: CAShapeLayer? {
        get {
            let maskLayer = CAShapeLayer()
            
            maskLayer.path = outlinePath.CGPath
            
            return maskLayer
        }
    }
    
    // optional image for
    private var iconImageView = UIImageView(frame: CGRectMake(0, 0, 40, 40))

    
    // MARK: Initialize
    func initMaster() {
        self.backgroundColor = UIColor.clearColor()
        self.addSubview(iconImageView)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initMaster()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initMaster()
    }
    
    override public func prepareForInterfaceBuilder() {
        invalidateIntrinsicContentSize()
        self.backgroundColor = UIColor.clearColor()
    }
    
    
    // MARK: Layout
    override public func layoutSubviews() {
        super.layoutSubviews()
        iconImageView.layer.mask = tapGlowMask
        tapGlowBackgroundView.layer.mask = tapGlowMask
    }
    
    // override intrinsic size for uibutton
    public override func intrinsicContentSize() -> CGSize {
        return bounds.size
    }
    
    
    // MARK: draw 
    override public func drawRect(rect: CGRect) {
        outlinePath = drawTapButton(buttonShape, buttonTitle: buttonTitle, fontsize: titleFontSize)
        tapGlowSetup()
    }
        
    private func tapGlowSetup() {
        
        tapGlowBackgroundView.backgroundColor = tapGlowBackgroundColor
        tapGlowBackgroundView.frame = bounds
        layer.addSublayer(tapGlowBackgroundView.layer)
        tapGlowBackgroundView.layer.addSublayer(tapGlowView.layer)
        tapGlowBackgroundView.alpha = 0
    }
    
    private func drawTapButton(buttonShape: TapButtonShape, buttonTitle: String, fontsize: CGFloat) -> UIBezierPath {
        
        var bezierPath: UIBezierPath!
        
        if buttonStyle == .Raised {
            tapButtonFrame = CGRectMake(1, 1, CGRectGetWidth(self.bounds) - 2, CGRectGetHeight(self.bounds) - 2)
        } else {
            tapButtonFrame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))
        }
        
        let context = UIGraphicsGetCurrentContext()
        
        if buttonShape == .Round {
            bezierPath = UIBezierPath(ovalInRect: tapButtonFrame)
        } else {
            bezierPath = UIBezierPath(rect: tapButtonFrame)
        }
            
        buttonColor.setFill()
        bezierPath.fill()
        
        let shadow = UIColor.blackColor().CGColor
        let shadowOffset = CGSizeMake(3.1, 3.1)
        let shadowBlurRadius: CGFloat = 7
        
        if buttonStyle == .Raised {
            CGContextSaveGState(context)
            CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow)
            fontColor.setStroke()
            bezierPath.lineWidth = 1
            bezierPath.stroke()
            CGContextRestoreGState(context)
        }
        
        // MARK: Title Text
        if image == "" || iconImageView.image == nil {
            let buttonTitleTextContent = NSString(string: buttonTitle)
            CGContextSaveGState(context)
            
            if buttonStyle == .Raised {
                CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow)
            }
            
            let buttonTitleStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
            buttonTitleStyle.alignment = NSTextAlignment.Center
            
            let buttonTitleFontAttributes = [NSFontAttributeName: UIFont(name: "AppleSDGothicNeo-Regular", size: fontsize)!, NSForegroundColorAttributeName: fontColor, NSParagraphStyleAttributeName: buttonTitleStyle]
            
            let buttonTitleTextHeight: CGFloat = buttonTitleTextContent.boundingRectWithSize(CGSizeMake(tapButtonFrame.width, CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: buttonTitleFontAttributes, context: nil).size.height
            CGContextSaveGState(context)
            CGContextClipToRect(context, tapButtonFrame);
            buttonTitleTextContent.drawInRect(CGRectMake(tapButtonFrame.minX, tapButtonFrame.minY + (tapButtonFrame.height - buttonTitleTextHeight) / 2, tapButtonFrame.width, buttonTitleTextHeight), withAttributes: buttonTitleFontAttributes)
            CGContextRestoreGState(context)
            CGContextRestoreGState(context)
        }
        
        return bezierPath
    }
    
    // MARK: Tap events
    override public func beginTrackingWithTouch(touch: UITouch,
        withEvent event: UIEvent?) -> Bool {
            
            UIView.animateWithDuration(0.1, animations: {
                self.tapGlowBackgroundView.alpha = 1
                }, completion: nil)
            
            return super.beginTrackingWithTouch(touch, withEvent: event)
    }
    
    override public func endTrackingWithTouch(touch: UITouch?,
        withEvent event: UIEvent?) {
            super.endTrackingWithTouch(touch, withEvent: event)
            
            UIView.animateWithDuration(0.1, animations: {
                self.tapGlowBackgroundView.alpha = 1
                }, completion: {(success: Bool) -> () in
                    UIView.animateWithDuration(0.6 , animations: {
                        self.tapGlowBackgroundView.alpha = 0
                        }, completion: nil)
            })
    }

}
