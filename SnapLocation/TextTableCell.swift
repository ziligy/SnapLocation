//
//  TextTableCell.swift
//  JGSettingsManager
//
//  Created by Jeff on 12/21/15.
//  Copyright © 2015 Jeff Greenberg. All rights reserved.
//

import UIKit

class TextTableCell: UITableViewCell, UITextFieldDelegate {
    
    var data: JGUserDefault<String>!
    
    //  MARK: UI
    
    let textField = UITextField()
    
    convenience init (textData: JGUserDefault<String>, placeholder: String) {
        self.init()
        
        self.data = textData
        self.setupViews()
        self.initializeUI(placeholder)
    }
    
    func setupViews() {
        textField.delegate = self
        addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.endEditing(true)
        save()
        return false
    }
    
    override func layoutSubviews() {
        updateConstraints()
    }
    
    func initializeUI(placeholder: String) {
        textField.placeholder = placeholder
        textField.text = data.value()
    }
    
    func save() {
        data.save(textField.text!)
    }
    
    //  MARK: Constraints
    
    override func updateConstraints() {
        
        textField.leadingAnchor.constraintEqualToAnchor(leadingAnchor, constant: 10).active = true
        textField.centerYAnchor.constraintEqualToAnchor(centerYAnchor, constant: 0).active = true
        
        super.updateConstraints()
    }
    
    
}

