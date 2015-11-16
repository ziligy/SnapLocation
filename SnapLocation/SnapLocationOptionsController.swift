//
//  OptionsTableViewController.swift
//  SnapLocation
//
//  Created by Jeff on 11/11/15.
//  Copyright © 2015 Jeff Greenberg. All rights reserved.
//

import UIKit
import MapKit

// MARK: Struct

/// struct for user default options stored in NSUserDefaults
public struct SnapLocationOptions {
    
    private let defaultStorage = NSUserDefaults.standardUserDefaults()
    
    public var saveToPhotosAlbum: Bool  {
        get { return defaultStorage.objectForKey("saveToPhotosAlbum") as? Bool ?? true }
    }
    
    public var saveInfoTextToPasteboard: Bool  {
        get { return defaultStorage.objectForKey("saveInfoTextToPasteboard") as? Bool ?? true }
    }
    
    public let mapTypes = [MKMapType.Standard, MKMapType.Satellite, MKMapType.Hybrid]
    public var mapType: Int  {
        get { return defaultStorage.objectForKey("mapTypeIndex") as? Int ?? Int(MKMapType.Hybrid.rawValue) }
    }
    
    public var zoomLevel: Int  {
        get { return defaultStorage.objectForKey("zoomLevel") as? Int ?? 10 }
    }
    
    public var zoomLevelToHideUserLocation: Int {
        get { return defaultStorage.objectForKey("zoomLevelToHideUserLocation") as? Int ?? 6 }
    }

    public var includeLocationInfo: Bool  {
        get { return defaultStorage.objectForKey("includeLocationInfo") as? Bool ?? true }
    }

    public var includeLatitudeAndLongitudeInfo: Bool  {
        get { return defaultStorage.objectForKey("includeLatitudeAndLongitudeInfo") as? Bool ?? true }
    }

    public var includeGPSDateTimeInfo: Bool  {
        get { return defaultStorage.objectForKey("includeGPSDateTimeInfo") as? Bool ?? true }
    }

    public var includeAddressInfo: Bool  {
        get { return defaultStorage.objectForKey("includeAddressInfo") as? Bool ?? false }
    }

    public var includeZipcodeInfo: Bool  {
        get { return defaultStorage.objectForKey("includeZipcodeInfo") as? Bool ?? false }
    }

    public var includeAltitudeInfo: Bool  {
        get { return defaultStorage.objectForKey("includeAltitudeInfo") as? Bool ?? false }
    }

    public var includeVerticalAccuracyInfo: Bool  {
        get { return defaultStorage.objectForKey("includeVerticalAccuracyInfo") as? Bool ?? false }
    }
    
    public var includeHorizontalAccuracyInfo: Bool  {
        get { return defaultStorage.objectForKey("includeHorizontalAccuracyInfo") as? Bool ?? false }
    }
    
}

/// table controller linked to storyboard of user options
class SnapLocationOptionsController: UITableViewController {
    
    // MARK: @IBOutlets
    
    // @IBOutlets for storyboard objects
    @IBOutlet weak var saveToPhotosAlbumSwitch: UISwitch!
    @IBOutlet weak var saveInfoTextToPasteboardSwitch: UISwitch!
    
    @IBOutlet weak var mapTypeSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var zoomLevelStepper: UIStepper!
    @IBOutlet weak var zoomLevelLabel: UILabel!
    
    @IBOutlet weak var zoomLevelToHideUserLocationStepper: UIStepper!
    @IBOutlet weak var zoomLevelToHideUserLocationLabel: UILabel!
    
    @IBOutlet weak var includeLocationInfoSwitch: UISwitch!
    @IBOutlet weak var includeLatitudeAndLongitudeInfoSwitch: UISwitch!
    @IBOutlet weak var includeGPSDateTimeInfoSwitch: UISwitch!
    @IBOutlet weak var includeAddressInfoSwitch: UISwitch!
    @IBOutlet weak var includeZipcodeInfoSwitch: UISwitch!
    
    // MARK: Variables
    
    /// NSUserDefaults storage unit
    let defaultStorage = NSUserDefaults.standardUserDefaults()
    
    /// instance of user options struct
    var userOptions = SnapLocationOptions()
    
    // MARK: Initialize
    
    // set the storyboard options to initial state
    override func viewDidLoad() {
        
        mapTypeSegmentedControl.selectedSegmentIndex = userOptions.mapType
        
        saveToPhotosAlbumSwitch.setOn(userOptions.saveToPhotosAlbum, animated: false)
        saveInfoTextToPasteboardSwitch.setOn(userOptions.saveInfoTextToPasteboard, animated: false)
        
        let zoomLevel = userOptions.zoomLevel
        zoomLevelStepper.value = Double(zoomLevel)
        zoomLevelLabel.text = String(zoomLevel)
        
        let hideLevel = userOptions.zoomLevelToHideUserLocation
        zoomLevelToHideUserLocationStepper.value = Double(hideLevel)
        zoomLevelToHideUserLocationLabel.text = String(hideLevel)
        
        includeLocationInfoSwitch.setOn(userOptions.includeLocationInfo, animated: false)
        includeLatitudeAndLongitudeInfoSwitch.setOn(userOptions.includeLatitudeAndLongitudeInfo, animated: false)
        includeGPSDateTimeInfoSwitch.setOn(userOptions.includeGPSDateTimeInfo, animated: false)
        includeAddressInfoSwitch.setOn(userOptions.includeAddressInfo, animated: false)
        includeZipcodeInfoSwitch.setOn(userOptions.includeZipcodeInfo, animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }
    
    // MARK: @IBActions

    // @IBAction to save state to NSUserDefaults
    
    @IBAction func mapTypeChanged(sender: UISegmentedControl)
    {
        // be sure UISegmentedControl uses same index order as mapTypes
        defaultStorage.setInteger(sender.selectedSegmentIndex, forKey: "mapTypeIndex")
    }
    
    @IBAction func stepperValueChanged(sender: UIStepper) {
        zoomLevelLabel.text = Int(sender.value).description
        defaultStorage.setInteger(Int(sender.value), forKey: "zoomLevel")
    }
    
    @IBAction func zoomLevelToHideUserLocationChanged(sender: UIStepper) {
        zoomLevelToHideUserLocationLabel.text = Int(sender.value).description
        defaultStorage.setInteger(Int(sender.value), forKey: "zoomLevelToHideUserLocation")
    }
    
    @IBAction func saveToPhotosAlbumChanged(sender: UISwitch) {
        defaultStorage.setBool(sender.on, forKey: "saveToPhotosAlbum")
    }
    
    @IBAction func saveInfoTextToPasteboardChanged(sender: UISwitch) {
        defaultStorage.setBool(sender.on, forKey: "saveInfoTextToPasteboard")
    }
    
    @IBAction func includeLocationInfoChanged(sender: UISwitch) {
        defaultStorage.setBool(sender.on, forKey: "includeLocationInfo")
    }
    
    @IBAction func includeLatitudeAndLongitudeInfoChanged(sender: UISwitch) {
        defaultStorage.setBool(sender.on, forKey: "includeLatitudeAndLongitudeInfo")
    }
    
    @IBAction func includeGPSDateTimeInfoChanged(sender: UISwitch) {
        defaultStorage.setBool(sender.on, forKey: "includeGPSDateTimeInfo")
    }
    
    @IBAction func includeAddressInfoChanged(sender: UISwitch) {
        defaultStorage.setBool(sender.on, forKey: "includeAddressInfo")
    }
    
    @IBAction func includeZipcodeInfoChanged(sender: UISwitch) {
        defaultStorage.setBool(sender.on, forKey: "includeZipcodeInfo")
    }

}
