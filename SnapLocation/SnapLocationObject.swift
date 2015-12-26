//
//  SnapLocationObject.swift
//
//  Created by Jeff on 12/3/15.
//  Copyright © 2015 Jeff Greenberg. All rights reserved.
//

import Foundation
import RealmSwift

/// realm object to store history information
class SnapLocationObject: Object {
    
    dynamic var id = 0
    dynamic var timestamp = NSDate(timeIntervalSince1970: 0)
    dynamic var street = ""
    dynamic var location = ""
    dynamic var zipcode = ""
    dynamic var latitude = ""
    dynamic var longitude = ""
    dynamic var altitude: Double = 0
    dynamic var verticalAccuracy: Double = 0
    dynamic var horizontalAccuracy: Double = 0
        
    override class func primaryKey() -> String? {
        return "id"
    }
}
