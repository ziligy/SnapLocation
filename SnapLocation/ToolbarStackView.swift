//
//  ToolbarStackView.swift
//  SnapLocation
//
//  Created by Jeff on 12/7/15.
//  Copyright © 2015 Jeff Greenberg. All rights reserved.
//

import UIKit

class ToolbarStackView: UIStackView {
    
    /// button to start the locationManager
    private let locateButton = JGTapButton(frame: CGRect(x: 0,y: 0,width: 60,height: 60))
    
    /// button to trigger screen capture
    private let snapButton = JGTapButton(frame: CGRect(x: 0,y: 0,width: 60,height: 60))
    
    /// button to bring up the settings screen
    private let settingsButton  = JGTapButton(frame: CGRect(x: 0,y: 0,width: 60,height: 60))
    
    /// button to bring up the history screen
    private let historyButton  = JGTapButton(frame: CGRect(x: 0,y: 0,width: 60,height: 60))
    
    
    func setupActions(target: AnyObject?, settings: Selector,  snap: Selector, locate: Selector, history: Selector) {
        self.axis = UILayoutConstraintAxis.Horizontal
        self.distribution = UIStackViewDistribution.Fill
        self.alignment = UIStackViewAlignment.Center
        self.spacing = 20.0
        
        settingsButton.title = "Settings"
        settingsButton.fontsize = 13.0
        settingsButton.raised = true
        settingsButton.mainColor = UIColor(red: 0, green: 0, blue: 255, alpha: 0.6)
        settingsButton.addTarget(target, action: settings, forControlEvents: UIControlEvents.TouchUpInside)
        
        snapButton.title = "Snap!"
        snapButton.fontsize = 18.0
        snapButton.raised = true
        snapButton.mainColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.6)
        snapButton.addTarget(target, action: snap, forControlEvents: UIControlEvents.TouchUpInside)
        
        locateButton.title = "Locate"
        locateButton.fontsize = 18.0
        locateButton.raised = true
        locateButton.mainColor = UIColor(red: 0, green: 255, blue: 0, alpha: 0.6)
        locateButton.addTarget(target, action: locate, forControlEvents: UIControlEvents.TouchUpInside)
        
        historyButton.title = "History"
        historyButton.fontsize = 13.0
        historyButton.raised = true
        historyButton.mainColor = UIColor(red: 128, green: 0, blue: 128, alpha: 0.6)
        historyButton.addTarget(target, action: history, forControlEvents: UIControlEvents.TouchUpInside)
        
        self.addArrangedSubview(settingsButton)
        self.addArrangedSubview(snapButton)
        self.addArrangedSubview(locateButton)
        self.addArrangedSubview(historyButton)
        
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func buttonsHidden(settings settings: Bool, snap: Bool, locate: Bool, history: Bool) {
        settingsButton.hidden = settings
        snapButton.hidden = snap
        locateButton.hidden = locate
        historyButton.hidden = history
        layoutIfNeeded()
    }
}
