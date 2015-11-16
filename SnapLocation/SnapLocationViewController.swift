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

class SnapLocationViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    // MARK: View Objects
    
    /// the map object
    private let mapKitView = MKMapView()
    
    /// label that contains the location text info
    /// its contents is varied by the user settings
    private let infoScreen = UILabel()
    
    /// button to start the locationManager
    private let locateButton = JGTapButton(frame: CGRect(x: 0,y: 0,width: 60,height: 60))
    
    /// button to trigger screen capture
    private let snapButton = JGTapButton(frame: CGRect(x: 0,y: 0,width: 60,height: 60))
    
    /// button to bring up the settings screen
    private let settingsButton  = JGTapButton(frame: CGRect(x: 0,y: 0,width: 60,height: 60))
    
    /// holds the locate & snap buttons
    private let buttonStackView = UIStackView()
    
    /// the effect container
    private var blurredImageEffectContainer = UIView()
    
    /// the effect imageView
    private var fullScreenBlurredImageView = UIImageView()
    
    // MARK: Literals
    
    /// zoom multiplier used with zoomLevel to create the map's regionRadius
    private let zoomFactor = 50.0
    
    /// SystemSoundID make a shutter sound when snap! button os presssed
    private let cameraShutterSoundID: SystemSoundID = 1108
    
    // MARK: Private variables
    
    /// stores the formatted display info
    private var infoTextToPaste = ""
    
    /// the main locationManager object
    private let locationManager = CLLocationManager()
    
    /// the placemark object from the location manager
    private var placemark: CLPlacemark!
    
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
        mapKitView.frame = view.bounds
        mapKitView.showsUserLocation = true
        mapKitView.zoomEnabled = true
        mapKitView.scrollEnabled = true
        view.addSubview(mapKitView)
        
        // init & add info overlay
        infoScreen.font = UIFont(name: "Apple SD Gothic Neo", size: 40.0) ?? UIFont.systemFontOfSize(40.0)
        infoScreen.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        infoScreen.textColor = UIColor.whiteColor()
        infoScreen.adjustsFontSizeToFitWidth = true
        view.addSubview(infoScreen)
        
        setupButtons()
        
        resetButtonsOnZTop()
    }
    
    override func viewWillAppear(animated: Bool) {
        // turn off navbar because settings turns it on
        navigationController?.navigationBarHidden = true
        
        mapKitView.mapType = userOptions.mapTypes[userOptions.mapType]
        
        // if the placemark is defined use it to redisplay the info which may have changed when returning from settings page
        if let pm = placemark {
            infoTextToPaste = ""
            buildInfoScreen(pm, size: view.bounds.size)
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        mapKitView.frame.size = size
        
        // recalculte info screen for new size
        if let pm = placemark {
            infoTextToPaste = ""
            buildInfoScreen(pm, size: size)
        }
    }
    
    /// initialize screen's buttons
    private func setupButtons() {
        buttonStackView.axis = UILayoutConstraintAxis.Horizontal
        buttonStackView.distribution = UIStackViewDistribution.Fill
        buttonStackView.alignment = UIStackViewAlignment.Center
        buttonStackView.spacing = 30.0
        
        locateButton.title = "Locate!"
        locateButton.fontsize = 18.0
        locateButton.raised = true
        locateButton.mainColor = UIColor(red: 0, green: 255, blue: 0, alpha: 0.6)
        locateButton.addTarget(self, action: "locateTap:", forControlEvents: UIControlEvents.TouchUpInside)
        
        snapButton.title = "Snap!"
        snapButton.fontsize = 18.0
        snapButton.raised = true
        snapButton.mainColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.6)
        snapButton.addTarget(self, action: "snapTap:", forControlEvents: UIControlEvents.TouchUpInside)
        
        settingsButton.title = "Settings!"
        settingsButton.fontsize = 13.0
        settingsButton.raised = true
        settingsButton.mainColor = UIColor(red: 0, green: 0, blue: 255, alpha: 0.6)
        settingsButton.addTarget(self, action: "settingsTap:", forControlEvents: UIControlEvents.TouchUpInside)
        
        buttonStackView.addArrangedSubview(snapButton)
        buttonStackView.addArrangedSubview(locateButton)
        buttonStackView.addArrangedSubview(settingsButton)
        
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: Button Actions
    
    /// main func to start the location manager, triggered by tap on locate button
    /// - note: infoTextToPaste is set to null, once filled it the location mananger stops
    func locateTap(sender: JGTapButton) {
        
        infoTextToPaste = ""
        mapKitView.showsUserLocation = true
        locationManager.startUpdatingLocation()
        
        fullScreenBlurredImageView.removeFromSuperview()
        blurredImageEffectContainer.removeFromSuperview()
        
        userOptions.saveToPhotosAlbum ? snapButton.show() : snapButton.hide()
    }
    
    /// alerts user with shutter sound feedback and call func to process screen capture
    func snapTap(sender: JGTapButton) {
        
        snapButton.hide()
        locateButton.hide()
        settingsButton.hide()
        
        mapKitView.showsUserLocation = userOptions.zoomLevel < userOptions.zoomLevelToHideUserLocation ? false : true
        
        infoScreen.frame.origin = CGPoint(x: 0, y: 0)
        
        AudioServicesPlaySystemSound(cameraShutterSoundID)
        snapScreenShot()
        
        
        
        // leave a little extra on top when in portrait, zero for landscape
        let topMargin: CGFloat = view.bounds.size.width > view.bounds.size.height ? 0 : 20
        infoScreen.frame.origin = CGPoint(x: 0, y: topMargin)
        
        mapKitView.showsUserLocation = false
    }
    
    /// settings button tapped, call the option settings display controller
    func settingsTap(sender: JGTapButton) {
        performSegueWithIdentifier("settings", sender: self)
    }
    
    // MARK: Functions
    
    /// the location manager's main function to get the current location, load the data, center the map, call the info screen builder
    internal func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        dispatch_async(dispatch_get_main_queue(),{
            CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: { (placemarks, error) -> Void in
                
                guard (error == nil),
                    let placemarks = placemarks
                    else {
                        print("Error in geoCoding: \(error!.localizedDescription)")
                        return
                }
                
                if let pm = placemarks.first {
                    self.placemark = pm
                    let currentLocation = CLLocation(latitude: self.placemark.location!.coordinate.latitude, longitude: self.placemark.location!.coordinate.longitude)
                    self.centerMapByLocation(currentLocation)
                    self.buildInfoScreen(self.placemark, size: self.view.bounds.size)
                } else {
                    print("Error with placemarks")
                }
            })
        })
        
    }
    
    /// capture the screen and save it
    private func snapScreenShot() {
        
        //Create the UIImage
        UIGraphicsBeginImageContext(view.bounds.size)
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        //Save it to the camera roll
        if userOptions.saveToPhotosAlbum { UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil) }
        
        UIGraphicsEndImageContext()
        
        (fullScreenBlurredImageView, blurredImageEffectContainer) = makeBlurredImage(viewContainer: view, image: image)
    }
    
    /// center the map so user location is in the middle of the screen
    /// also zoomlevel is processed here
    private func centerMapByLocation(location: CLLocation) {
        
        // calulate the regionRadious number using the zoomLevel set by user & zoomfactor literal
        // smaller number is a closer-in zoom level
        let regionRadius = Double(userOptions.zoomLevel) * zoomFactor
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius, regionRadius)
        mapKitView.setRegion(coordinateRegion, animated: true)
    }
    
    /// build the info display screen using the placemark data provided by the location manager
    /// - note: infoTextToPaste must be null for info update to begin
    private func buildInfoScreen(placemark: CLPlacemark, size: CGSize){
        
        if infoTextToPaste == "" {
            
            locationManager.stopUpdatingLocation()
            
            infoScreen.numberOfLines = 1
            
            if userOptions.includeAddressInfo {
                addInfoText(" street: \(placemark.thoroughfare ?? "")")
            }
            
            if userOptions.includeLocationInfo {
                addInfoText(" location: \(placemark.locality! ?? ""), \(placemark.administrativeArea! ?? "")")
            }
            
            if userOptions.includeZipcodeInfo {
                addInfoText(" zipcode: \(placemark.postalCode ?? "")")
            }
            
            if userOptions.includeLatitudeAndLongitudeInfo {
                let precision = "%.5f"
                let latitude = String(format: precision, placemark.location!.coordinate.latitude  ?? "")
                addInfoText(" latitude: \(latitude)")
                
                let longitude = String(format: precision, placemark.location!.coordinate.longitude  ?? "")
                addInfoText(" longitude: \(longitude)")
            }
            
            if userOptions.includeGPSDateTimeInfo {
                let formatter = NSDateFormatter()
                formatter.dateFormat = "M/d/yy h:mm a"
                let timestamp = formatter.stringFromDate(placemark.location!.timestamp)
                addInfoText(" gpstime: \(timestamp)")
            }
            
            if userOptions.includeAltitudeInfo {
                addInfoText(" altitude: \(placemark.location!.altitude)")
            }
            
            if userOptions.includeVerticalAccuracyInfo {
                addInfoText(" vertical accuracy: \(placemark.location!.verticalAccuracy)")
            }
            
            if userOptions.includeHorizontalAccuracyInfo {
                addInfoText(" horizontal accuracy: \(placemark.location!.horizontalAccuracy)")
            }
            
            if userOptions.saveInfoTextToPasteboard {
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
                
                infoScreen.show()
                
            } else {
                // hide the screen there's nothing to show
                infoScreen.hide()
            }
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
    
    /// creates a blurred image
    /// - returns: tuple => image & effect container
    /// - parameter viewContainer: the main view container
    /// - parameter image: the image to blur
    /// - parameter offsetOriginY: top of screen margin offset
    private func makeBlurredImage(viewContainer viewContainer: UIView, image: UIImage, offsetOriginY: CGFloat = 20) -> (UIImageView, UIView) {
        
        let transparency: CGFloat = 0.85
        let fadeInTime: NSTimeInterval = 3.0
        let blurEffect = UIBlurEffect(style: .ExtraLight)
        
        let imageView = UIImageView()
        
        var offsetScreenBounds = viewContainer.bounds
        offsetScreenBounds.origin.y = offsetOriginY
        
        imageView.frame = offsetScreenBounds
        imageView.image = image
        
        viewContainer.addSubview(imageView)
        
        let effectContainer = UIView(frame: offsetScreenBounds)
        viewContainer.addSubview(effectContainer)
        
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = effectContainer.bounds
        
        effectContainer.addSubview(blurEffectView)
        
        dispatch_async(dispatch_get_main_queue(),{
            UIView.animateWithDuration(fadeInTime, animations: {
                effectContainer.alpha = transparency
                blurEffectView.effect = blurEffect
                }, completion: {(success: Bool) -> () in
                    self.resetButtonsOnZTop()
                    UIView.animateWithDuration(1.0) {
                        self.locateButton.show()
                        self.settingsButton.show()
                    }
            })
        })

        return (imageView, effectContainer)
    }
    
    /// moves the buttons to the top of the z-order
    private func resetButtonsOnZTop() {
        buttonStackView.removeFromSuperview()
        view.addSubview(buttonStackView)
        
        buttonStackView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        buttonStackView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: -10).active = true
    }
    
}

private extension UIView
{
    /// hide the view by setting alpha to 0
    func hide() {
        self.alpha = 0.0
    }
    
    /// display the view  by setting alpha to 1
    func show() {
        self.alpha = 1.0
    }
    
}


