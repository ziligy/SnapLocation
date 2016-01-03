//
//  SnapLocationViewController.swift
//
//  Created by Jeff on 11/11/15.
//  Copyright (c) 2015 Jeff Greenberg. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import AudioToolbox

class SnapLocationViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, HistoryTableDelegate {
    
    var historyTable: HistoryTableViewController!
    
    // MARK: View Objects
    
    /// the map object
    private let mapKitView = MKMapView()
    
    /// label that contains the location text info
    /// its contents is varied by the user settings
    private let infoScreen = UILabelInseted() // private class
    
    /// holds the locate & snap buttons
    private let toolbarStackView = ToolbarStackView()
    
    // MARK: Literals
    
    /// zoom multiplier used with zoomLevel to create the map's regionRadius
    private let zoomFactor = 50.0
    
    /// SystemSoundID make a shutter sound when snap! button os presssed
    private let cameraShutterSoundID: SystemSoundID = 1108
    
    // MARK: Private variables
        
    private var snapLocationObject = SnapLocationObject()
    
    /// stores the formatted display info
    private var infoTextToPaste = ""
    
    /// the main locationManager object
    private let locationManager = CLLocationManager()
    
    private var mapChangedFromUserInteraction = false
    
    let pinAnnotation = MKPointAnnotation()
    
    var lastMapCenter: CLLocationCoordinate2D? = nil
 
    // MARK: Options
    
    /// local access to NSUserDefaults 
    var userOptions = SnapLocationOptions()

    // MARK: Initialize
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init loaction manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        /// need to be sure the user is ok with this app
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // init & add mapkit
        mapKitView.delegate = self
        mapKitView.frame = view.bounds
        mapKitView.zoomEnabled = true
        mapKitView.scrollEnabled = true
        lastMapCenter = self.mapKitView.centerCoordinate
        view.addSubview(mapKitView)
        
        // init & add info overlay
        infoScreen.font = UIFont(name: "Apple SD Gothic Neo", size: 40.0) ?? UIFont.systemFontOfSize(40.0)
        infoScreen.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        infoScreen.textColor = UIColor.whiteColor()
        infoScreen.adjustsFontSizeToFitWidth = true
        view.addSubview(infoScreen)
        
        toolbarStackView.setupActions(self, settings: "settingsTap:", snap: "snapTap:", locate: "locateTap:",  history: "historyTap:")
        view.addSubview(toolbarStackView)
        toolbarStackView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        toolbarStackView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: -10).active = true
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        if userOptions.getMapType() == MKMapType.Standard {
            return UIStatusBarStyle.Default
        }
        return UIStatusBarStyle.LightContent
    }
    
    override func viewWillAppear(animated: Bool) {
        // turn off navbar because child screens turn it on
        navigationController?.navigationBarHidden = true
        
        mapKitView.mapType = userOptions.getMapType()
        
        // redisplay the info which may have changed when returning from settings page
        // unless snapLocationObject has been deleted
        if snapLocationObject.invalidated {
            snapLocationObject = SnapLocationObject()
            infoScreen.hidden = true
        } else {
            infoTextToPaste = ""
            buildInfoScreen(snapLocationObject, size: view.bounds.size)
        }
    
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        mapKitView.frame.size = size
        
        // recalculte info screen for new size
        infoTextToPaste = ""
        buildInfoScreen(snapLocationObject, size: size)
    }
    
    // MARK: Button Actions
    
    /// main func to start the location manager, triggered by tap on locate button
    /// - note: infoTextToPaste is set to null, once filled it the location mananger stops
    func locateTap(sender: JGTapButton) {
        
        infoTextToPaste = ""
        
        if userOptions.locateActionIndex.value() == 0 {
            locationManager.startUpdatingLocation()
        } else {
            locationFromScreen()
        }
    }
    
    /// alerts user with shutter sound feedback and call func to process screen capture
    func snapTap(sender: JGTapButton) {
        
        toolbarStackView.hidden = true
        
        // move to top for screen shot
        infoScreen.frame.origin = CGPoint(x: 0, y: 0)
        
        AudioServicesPlaySystemSound(cameraShutterSoundID)
        saveScreenShot()
        
        // leave a little extra on top when in portrait, zero for landscape
        let topMargin: CGFloat = view.bounds.size.width > view.bounds.size.height ? 0 : 20
        infoScreen.frame.origin = CGPoint(x: 0, y: topMargin)
        
        addHistory()
        
        toolbarStackView.hidden = false
        
        toolbarStackView.buttonsHidden(settings: false, snap: true, locate: false, history: false)
    }
    
    func addHistory() {
        var historyData: HistoryDataSource!
        if userOptions.saveToHistory.value() {
            
            // TODO: not sure if this is best place to do this
            snapLocationObject.viewRadius = getCurrentRadius()
            
            historyData = HistoryDataSource()
            historyData.addNextLocationWithId(snapLocationObject)
        }
    }
    
    /// settings button tapped, call the option settings display controller
    func settingsTap(sender: JGTapButton) {
        performSegueWithIdentifier("settings", sender: self)
        
    }
    
    /// history button tapped, call the option settings display controller
    func historyTap(sender: JGTapButton) {
        performSegueWithIdentifier("history", sender: self)
        historyTable = self.navigationController!.viewControllers.last as! HistoryTableViewController
        historyTable.delegateForHistorySelect = self
    }
    
    // MARK: Functions
    
    /// the location manager's main function to get the current location, load the data, center the map, call the info screen builder
    internal func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        reverseGeocode(manager.location!)
        self.centerMapByLocation(manager.location!, zoomLevel: self.userOptions.zoomLevel.value())
    }
    
    internal func locationFromScreen() {
        lastMapCenter = mapKitView.centerCoordinate
        let location = CLLocation(latitude: (lastMapCenter?.latitude)!, longitude: (lastMapCenter?.longitude)!)
        infoTextToPaste = ""
        reverseGeocode(location)
        self.centerMapByLocation(location)
    }
    
    internal func reverseGeocode(location: CLLocation) {
        
        dispatch_async(dispatch_get_main_queue()) {
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
                
                guard (error == nil),
                    let placemarks = placemarks
                    else {
                        print("Error in geoCoding: \(error!.localizedDescription)")
                        return
                }
                
                if let pm = placemarks.first {
                    // prevent multiple hits
                    if self.infoTextToPaste == "" {
                        
                        self.locationManager.stopUpdatingLocation()
                        
                        self.snapLocationObject = self.loadPlacemarkToLocationObject(pm)
                        
                        self.buildInfoScreen(self.snapLocationObject, size: self.view.bounds.size)
                        
                        if self.userOptions.displayLocationPin.value() {
                            self.displayLocationPin(self.snapLocationObject)
                        } else {
                            self.noLocationPin()
                        }
                        
                        self.toolbarStackView.buttonsHidden(settings: false, snap: false, locate: false, history: false)
                    }
                } else {
                    print("Error with placemarks")
                }
            })
        }
        
    }

    private func displayLocationPin(snapLocationObject: SnapLocationObject) {
        pinAnnotation.coordinate = CLLocationCoordinate2D(
            latitude: Double(snapLocationObject.latitude)!,
            longitude: Double(snapLocationObject.longitude)!
        )
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "h:mm a"
        let timestamp = formatter.stringFromDate(snapLocationObject.timestamp)
        pinAnnotation.title = timestamp
        mapKitView.addAnnotation(pinAnnotation)
    }
    
    private func noLocationPin() {
        mapKitView.removeAnnotation(pinAnnotation)
    }
    
    /// capture the screen and save it
    private func saveScreenShot() {
        
        // first be sure save option is on
        guard userOptions.saveToPhotosAlbum.value() else {return}
        
        //Create the UIImage
        UIGraphicsBeginImageContext(view.bounds.size)
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        //Save it to the camera roll
        if userOptions.saveToPhotosAlbum.value() { UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil) }
        
        UIGraphicsEndImageContext()
    }
    
    /// center the map so location is in the middle of the screen
    /// if zoomLevel is zero then use current map radius otherwise use zoomLevel to calculate the radius
    private func centerMapByLocation(location: CLLocation, zoomLevel: Int = 0, radius: CLLocationDistance = 0.0) {
        
        var regionRadius: CLLocationDistance!
        
        switch radius != 0.0 {
            
        case true:
            regionRadius = radius
            
        case false where zoomLevel == 0:
            regionRadius = getCurrentRadius()
            
        default:
            regionRadius = Double(zoomLevel) * zoomFactor
        }
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius, regionRadius)
        
        mapKitView.setRegion(coordinateRegion, animated: true)
    }
    
    func getCurrentRadius() -> CLLocationDistance {
        let centerCoor: CLLocationCoordinate2D = mapKitView.centerCoordinate
        let centerLocation: CLLocation = CLLocation(latitude: centerCoor.latitude, longitude: centerCoor.longitude)
        let topCenterCoor: CLLocationCoordinate2D = getTopCenterCoordinate()
        let topCenterLocation: CLLocation = CLLocation(latitude: topCenterCoor.latitude, longitude: topCenterCoor.longitude)
        let radius = centerLocation.distanceFromLocation(topCenterLocation)
        return radius
    }
    
    /// get CLLocationCoordinate2D from MapKit frame's CGPoint
    func getTopCenterCoordinate() -> CLLocationCoordinate2D {
        let topCenterCoor: CLLocationCoordinate2D = self.mapKitView.convertPoint(CGPointMake(self.mapKitView.bounds.size.width / 2.0, 0), toCoordinateFromView: self.mapKitView)
        return topCenterCoor
    }

    private func loadPlacemarkToLocationObject(placemark: CLPlacemark) -> SnapLocationObject {
        
        let snapLocationObject = SnapLocationObject()

        snapLocationObject.timestamp = placemark.location!.timestamp
        snapLocationObject.street = placemark.thoroughfare ?? ""
        snapLocationObject.location = "\(placemark.locality ?? ""), \(placemark.administrativeArea ?? "")"
        snapLocationObject.zipcode = placemark.postalCode ?? ""
        
        let precision = "%.5f"
        snapLocationObject.latitude = String(format: precision, placemark.location!.coordinate.latitude  ?? "")
        snapLocationObject.longitude = String(format: precision, placemark.location!.coordinate.longitude  ?? "")
        
        snapLocationObject.altitude = placemark.location!.altitude ?? 0
        snapLocationObject.verticalAccuracy = placemark.location!.verticalAccuracy ?? 0
        snapLocationObject.horizontalAccuracy = placemark.location!.horizontalAccuracy  ?? 0
        
        return snapLocationObject
    }
    
    
    /// build the info display screen using snapLocationObject
    private func buildInfoScreen(snapLocationObject: SnapLocationObject, size: CGSize) {
        
        // require loaded data object and cleared text field inwhich to build
        guard snapLocationObject.location != "" && infoTextToPaste == "" else { return }
        
        infoScreen.numberOfLines = 1
        
        if userOptions.includeAddressInfo.value() {
            addInfoText("street: \(snapLocationObject.street)")
        }
        
        if userOptions.includeLocationInfo.value() {
            addInfoText("location: \(snapLocationObject.location)")
        }
        
        if userOptions.includeZipcodeInfo.value() {
            addInfoText("zipcode: \(snapLocationObject.zipcode)")
        }
        
        if userOptions.includeLatitudeAndLongitudeInfo.value() {
            addInfoText("latitude: \(snapLocationObject.latitude)")
            addInfoText("longitude: \(snapLocationObject.longitude)")
        }
        
        if userOptions.includeGPSDateTimeInfo.value() {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "M/d/yy h:mm a"
            let timestamp = formatter.stringFromDate(snapLocationObject.timestamp)
            addInfoText("gpstime: \(timestamp)")
        }
        
        if userOptions.includeAltitudeInfo.value() {
            addInfoText("altitude: \(snapLocationObject.altitude)")
        }
        
        if userOptions.includeVerticalAccuracyInfo.value() {
            addInfoText("vertical accuracy: \(snapLocationObject.verticalAccuracy)")
        }
        
        if userOptions.includeHorizontalAccuracyInfo.value() {
            addInfoText("horizontal accuracy: \(snapLocationObject.horizontalAccuracy)")
        }
        
        if userOptions.saveToPasteboard.value() {
            UIPasteboard.generalPasteboard().string = infoTextToPaste
        }
        
        if infoTextToPaste != "" {
        
            infoScreen.text = infoTextToPaste
            
            let infoScreenMaxHeight = size.height * 0.32
            var infoScreenHeight = CGFloat(infoScreen.numberOfLines * 24)
            
            if infoScreenHeight > infoScreenMaxHeight { infoScreenHeight = infoScreenMaxHeight }
            
            // leave a little extra on top when in portrait, zero for landscape
            let topMargin: CGFloat = size.width > size.height ? 0 : 20
            infoScreen.frame = CGRectMake(0, topMargin, size.width, infoScreenHeight)
            infoScreen.hidden = false
            
        } else {
            // hide the screen there's nothing to show
            infoScreen.hidden = true
        }
    }
    
    /// helper to format info text lines
    private func addInfoText(text: String) {
        if infoScreen.numberOfLines > 1 {infoTextToPaste += "\r"}
        infoTextToPaste += text
        infoScreen.numberOfLines++
    }
    
    /// location manager error occured
    @objc internal func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error:" + error.localizedDescription)
    }
    
    
    /// moves the buttons to the top of the z-order
    private func resetButtonsOnZTop() {
        toolbarStackView.removeFromSuperview()
        view.addSubview(toolbarStackView)
        
        toolbarStackView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        toolbarStackView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: -10).active = true
    }
    
    /// private class the overrides text insets inside label
    private class UILabelInseted: UILabel {
        override func drawTextInRect(rect: CGRect) {
            super.drawTextInRect(UIEdgeInsetsInsetRect(rect, UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)))
        }
    }
    
    /// Look through gesture recognizers to determine whether this region change is from user interaction
    /// - attribution: headcrash & mobi on stackoverflow
    private func mapViewRegionDidChangeFromUserInteraction() -> Bool {
        let view = self.mapKitView.subviews[0]
        if let gestureRecognizers = view.gestureRecognizers {
            for recognizer in gestureRecognizers {
                if( recognizer.state == UIGestureRecognizerState.Began || recognizer.state == UIGestureRecognizerState.Ended ) {
                    return true
                }
            }
        }
        return false
    }
    
    func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        mapChangedFromUserInteraction = mapViewRegionDidChangeFromUserInteraction()
        if (mapChangedFromUserInteraction) {
            infoScreen.hidden = true
            toolbarStackView.buttonsHidden(settings: false, snap: true, locate: false, history: false)
        }
    }
    
    func didSelectHistorySnapLocation(snapLocation: SnapLocationObject) {
        infoTextToPaste = ""
        self.snapLocationObject = snapLocation
        toolbarStackView.buttonsHidden(settings: false, snap: true, locate: false, history: false)
        let location = CLLocation(latitude: Double(snapLocationObject.latitude)!, longitude: Double(snapLocationObject.longitude)!)
        self.centerMapByLocation(location, zoomLevel: 0, radius: snapLocationObject.viewRadius)
    }

}

extension CLLocationCoordinate2D: Equatable{}

public func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
}

// MARK: SettingsTable Extension

// turn on the nav bar for the settings tableview
extension SettingsTableData {
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }
}






