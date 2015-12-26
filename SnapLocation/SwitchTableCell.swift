//
//  SwitchTableCell.swift
//  JGSettingsManager
//
//  Created by Jeff on 12/13/15.
//  Copyright © 2015 Jeff Greenberg. All rights reserved.
//

import UIKit

class SwitchTableCell: UITableViewCell {
    
    var data: JGUserDefault<Bool>!
    
    //  MARK: UI
    
    let boolSwitch = UISwitch()
    let label = UILabel()
    
    convenience init (switchData: JGUserDefault<Bool>, label: String) {
        self.init()
        
        self.data = switchData
        self.setupViews()
        self.initializeUI(label)
    }
    
    func setupViews() {
        addSubview(label)
        addSubview(boolSwitch)
        boolSwitch.addTarget(self, action: Selector("save:"), forControlEvents: .ValueChanged)
        
        boolSwitch.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func layoutSubviews() {
        updateConstraints()
    }
    
    func initializeUI(title: String) {
        label.text = title
        boolSwitch.setOn(data.value(), animated: false)
    }
    
    func save(sender: UISwitch) {
        data.save(sender.on)
    }
    
    //  MARK: Constraints
    
    override func updateConstraints() {
        
        label.leadingAnchor.constraintEqualToAnchor(leadingAnchor, constant: 10).active = true
        label.centerYAnchor.constraintEqualToAnchor(centerYAnchor, constant: 0).active = true
        
        boolSwitch.trailingAnchor.constraintEqualToAnchor(trailingAnchor, constant: -10).active = true
        boolSwitch.centerYAnchor.constraintEqualToAnchor(centerYAnchor, constant: 0).active = true

        super.updateConstraints()
    }

 
}
