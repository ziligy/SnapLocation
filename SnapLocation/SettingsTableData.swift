//
//  SettingsTableData.swift
//
//  Created by Jeff on 12/22/15.
//  Copyright © 2015 Jeff Greenberg. All rights reserved.
//

import UIKit
import MapKit
import JGSettingsManager

/// settings storage model
struct SnapLocationOptions {
    
    let mapTypeIndex = JGUserDefault (key: "mapTypeIndex", defaultValue: 2)
    
    let zoomLevel = JGUserDefault (key: "zoomLevel", defaultValue: 10)
    
    let saveToPhotosAlbum = JGUserDefault (key: "saveToPhotosAlbum", defaultValue: true)
    
    let saveToPasteboard = JGUserDefault (key: "saveToPasteboard", defaultValue: true)
    
    let saveToHistory = JGUserDefault (key: "saveToHistory", defaultValue: true)
    
    /// used to determine the operation of the Locate button
    /// - value 0: = locate acquires the location value based on user's current location
    /// - value 1: = locate acquires the location value based on the center point of the displayed screen
    let locateActionIndex = JGUserDefault (key: "locateActionIndex", defaultValue: 1)
    
    let displayLocationPin = JGUserDefault (key: "displayLocationPin", defaultValue: true)
    
    let includeLocationInfo = JGUserDefault (key: "includeLocationInfo", defaultValue: true)
    
    let includeLatitudeAndLongitudeInfo = JGUserDefault (key: "includeLatitudeAndLongitudeInfo", defaultValue: true)
    
    let includeGPSDateTimeInfo = JGUserDefault (key: "includeGPSDateTimeInfo", defaultValue: true)
    
    let includeAddressInfo = JGUserDefault (key: "includeAddressInfo", defaultValue: false)
    
    let includeZipcodeInfo = JGUserDefault (key: "includeZipcodeInfo", defaultValue: false)
    
    let includeAltitudeInfo = JGUserDefault (key: "includeAltitudeInfo", defaultValue: false)
    
    let includeVerticalAccuracyInfo = JGUserDefault (key: "includeVerticalAccuracyInfo", defaultValue: false)
    
    let includeHorizontalAccuracyInfo = JGUserDefault (key: "includeHorizontalAccuracyInfo", defaultValue: false)
    
    func getMapType() -> MKMapType {
        let mapTypes = [MKMapType.Standard, MKMapType.Satellite, MKMapType.Hybrid]
        return mapTypes[mapTypeIndex.value()]
    }
}


class SettingsTableData: JGSettingsTableController, SettingsSectionsData {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableSections = loadSectionsConfiguration()
    }
    
    /// loads and returns the sections array 
    /// used by JGSettingManager - TableController to build settings display
    func loadSectionsConfiguration() -> [Section] {
        
        let userDefaults = SnapLocationOptions()
        
        let sections = [
            
            Section (
                header: "Map Display",
                footer: "",
                settingsCells: [
                    SegmentedControlTableCell(index: userDefaults.mapTypeIndex, segments: ["standard","satellite","hybrid"]),
                    SwitchTableCell (switchData: userDefaults.displayLocationPin, label: "Display location pin")
                ],
                heightForFooter: 10.0
            ),
            
            
            Section (
                header: "Locate Action",
                footer: "Locate button press acquires the location value based on the user's location or the center point of the displayed screen",
                settingsCells: [
                    SegmentedControlTableCell(index: userDefaults.locateActionIndex, segments: ["user location","screen display"])
                ],
                heightForFooter: 100.0
            ),
            
            Section (
                header: "Snap Actions",
                footer: "The actions that occur when the Snap button is pressed",
                settingsCells: [
                    SwitchTableCell (switchData: userDefaults.saveToPhotosAlbum, label: "Save Snaps to Photos album"),
                    SwitchTableCell (switchData: userDefaults.saveToPasteboard, label: "Save Snaps text to pasteboard"),
                    SwitchTableCell (switchData: userDefaults.saveToHistory, label: "Save Snaps info to History")
                ],
                heightForFooter: 60.0
            ),
            
            Section (
                header: "Text Display",
                footer: "Select the text elements to display on the screen when Snap is pressed",
                settingsCells: [
                    SwitchTableCell (switchData: userDefaults.includeLocationInfo, label: "Include city & state"),
                    SwitchTableCell (switchData: userDefaults.includeLatitudeAndLongitudeInfo, label: "Include latitude & longitute"),
                    SwitchTableCell (switchData: userDefaults.includeGPSDateTimeInfo, label: "Include GPS time & date"),
                    SwitchTableCell (switchData: userDefaults.includeAddressInfo, label: "Include address"),
                    SwitchTableCell (switchData: userDefaults.includeZipcodeInfo, label: "Include zipcode")
                ],
                heightForFooter: 80.0
            ),
            
            Section (
                header: "Map Zoom Level",
                footer: "Initial zoom level for map",
                settingsCells: [
                    StepperTableCell(stepperData: userDefaults.zoomLevel, minimumValue: 1, maximumValue: 30)
                ]
            )

        ]

        return sections
    }
    
}
