//
//  JGUserDefault.swift
//
//  Created by Jeff on 12/17/15.
//  Copyright © 2015 Jeff Greenberg. All rights reserved.
//

import Foundation

/// Generic struct to retrieve & save to NSUserDefaults
public struct JGUserDefault<T> {
    internal let key: String
    internal let defaultValue: T
    
    internal func value(storage: NSUserDefaults = NSUserDefaults.standardUserDefaults()) -> T {
        return (storage.objectForKey(self.key) as? T ?? self.defaultValue)
    }
    
    internal func save(newValue: T, storage: NSUserDefaults = NSUserDefaults.standardUserDefaults()) {
        storage.setObject((newValue as! AnyObject), forKey: self.key)
    }
}