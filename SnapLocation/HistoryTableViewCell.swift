//
//  HistoryTableViewCell.swift
//  SnapLocation
//
//  Created by Jeff on 12/5/15.
//  Copyright © 2015 Jeff Greenberg. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
    
    var snapLocationId = -1
    
    var imageUUID = ""
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var gpsLabel: UILabel!
    
    @IBOutlet weak var timestampLabel: UILabel!
    
    @IBOutlet weak var streetLabel: UILabel!
    
    @IBOutlet weak var zipcodeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clearColor()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setTextWords (word: String) {
        textLabel?.text = word
    }
    
    func loadLocationObject(snapLocationObject: SnapLocationObject) {
        
        snapLocationId = snapLocationObject.id
        
        imageUUID = snapLocationObject.imageUUID
        
        locationLabel.text  = snapLocationObject.location
        streetLabel.text  = snapLocationObject.street
        zipcodeLabel.text  = snapLocationObject.zipcode
        
        gpsLabel.text  = "\(snapLocationObject.latitude), \(snapLocationObject.longitude)"
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "M/d/yy h:mm a"
        let timestamp = formatter.stringFromDate(snapLocationObject.timestamp)
        timestampLabel.text  = "\(timestamp)"
        
    }

}
