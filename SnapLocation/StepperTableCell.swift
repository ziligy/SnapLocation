//
//  StepperTableCell.swift
//  JGSettingsManager
//
//  Created by Jeff on 12/21/15.
//  Copyright © 2015 Jeff Greenberg. All rights reserved.
//

import UIKit

class StepperTableCell: UITableViewCell {
    
    var dataInt: JGUserDefault<Int>!
    
    var dataDouble: JGUserDefault<Double>!
    
    //  MARK: UI
    
    let stepper = UIStepper()
    let label = UILabel()
    
    let stackView = UIStackView()
    
    convenience init (stepperData: JGUserDefault<Int>, minimumValue: Int, maximumValue: Int) {
        self.init()
        
        self.dataInt = stepperData
        self.setupViews()
        self.initializeUIforInt(minimumValue, maximumValue)
    }
    
    convenience init (stepperData: JGUserDefault<Double>, minimumValue: Double, maximumValue: Double) {
        self.init()
        
        self.dataDouble = stepperData
        self.setupViews()
        self.initializeUIforDouble(minimumValue, maximumValue)
    }
    
    func setupViews() {
        
        label.font = UIFont.monospacedDigitSystemFontOfSize(30, weight: UIFontWeightMedium)
        stepper.addTarget(self, action: Selector("save:"), forControlEvents: .ValueChanged)
        
        stackView.spacing = 12.0
        
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(stepper)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
     }
    
    override func layoutSubviews() {
        updateConstraints()
    }
    
    func initializeUIforInt(minimumValue: Int, _ maximumValue: Int) {
        stepper.minimumValue = Double(minimumValue)
        stepper.maximumValue = Double(maximumValue)
        stepper.value = Double(dataInt.value())
        label.text = String(dataInt.value())
     }
    
    func initializeUIforDouble(minimumValue: Double, _ maximumValue: Double) {
        stepper.minimumValue = minimumValue
        stepper.maximumValue = maximumValue
        stepper.value = dataDouble.value()
        label.text = String(dataDouble.value())
    }
    
    func save(sender: UIStepper) {
        if dataDouble == nil {
            label.text = Int(sender.value).description
            dataInt.save(Int(sender.value))
        } else {
            label.text = sender.value.description
            dataDouble.save(sender.value)
        }
    }
    
    //  MARK: Constraints
    
    override func updateConstraints() {
        
        stackView.centerYAnchor.constraintEqualToAnchor(centerYAnchor, constant: 0).active = true
        stackView.centerXAnchor.constraintEqualToAnchor(centerXAnchor, constant: 0).active = true
        
        super.updateConstraints()
    }
    
    
}
