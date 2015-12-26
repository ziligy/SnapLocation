//
//  HistoryTableDatasource.swift
//  SnapLocation
//
//  Created by Jeff on 12/5/15.
//  Copyright © 2015 Jeff Greenberg. All rights reserved.
//

import Foundation
import RealmSwift


/// history data source - realm database
class HistoryDataSource {
    
    var locations: Results<SnapLocationObject>
    
    var realm: Realm!
    
    init() {
        realm = try! Realm()
        locations = realm.objects(SnapLocationObject)
    }
    
    /// find and return next Id number
    internal func getNextId() -> Int {
        if let maxId: Int = locations.max("id") {
            return maxId + 1
        }
        return (0)
    }
    
    /// get new Id and adds SnapLocationObject to realm history db
    internal func addNextLocationWithId(object: SnapLocationObject) {
        object.id =  getNextId()
        do {
            try realm.write {
                self.realm.add(object)
            }
        } catch {
            print("HistoryDataSource: addLocation failed")
        }
    }

    internal func removeLocationAtIndex(index: Int) {
        do {
            try realm.write {
                self.realm.delete(self.locations[index])
            }
        } catch {
            print("HistoryDataSource: removeLocationAtIndex failed")
        }
     }
    
    /// cell count used by table controller to
    /// determine number of location/history cells
    /// - returns: locations count as Int
    internal func count() -> Int {
        return locations.count
    }
    
    /// get and return location as SnapLocationObject
    /// - parameter index: as integer, used to sync with cell
    /// - returns: location as SnapLocationObject or nil
    internal func getHistoryDataByIndex(index: Int) -> SnapLocationObject? {
        
        if index >= locations.count {
            return nil
        }
        
        return locations[index]
    }
    
    internal func clearAllHistoryData() {
        do {
            try realm.write {
                self.realm.delete(self.locations)
            }
        } catch {
            print("clearAllHistoryData failed")
        }
    }
    
}
