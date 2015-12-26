//
//  BlurredBackgroundView.swift
//
//  Created by Jeff on 12/4/15.
//  Copyright © 2015 Jeff Greenberg. All rights reserved.
//

import UIKit

/// UIView that's a blurred image for background display
public class BlurredBackgroundView: UIView {

    private var imageView: UIImageView!
    private var effectView: UIVisualEffectView!
    
    public func getBlurEffect() -> UIBlurEffect {
        return (self.effectView.effect as! UIBlurEffect)
    }
    
    convenience init(frame: CGRect, img: UIImage) {
        self.init(frame: frame)
        self.setImageWithBlurEffect(img)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public convenience required init?(coder aDecoder: NSCoder) {
        self.init(frame: CGRectZero)
    }
    
    /// create blurred background based on image
    /// adds image & effect as subviews
    private func setImageWithBlurEffect(img: UIImage) {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        effectView = UIVisualEffectView(effect: blurEffect)
        imageView = UIImageView(image: img)
        
        addSubview(imageView)
        addSubview(effectView)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        effectView.frame = bounds
    }

}
