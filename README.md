# ![icon](https://raw.githubusercontent.com/ziligy/SnapLocation/master/snapLocation-github.png "icon") Snap!Location

Snap!Location is a micro-app written in Swift that snaps location info and optionally writes it to pasteboard, saves a photo image, and/or stores a history.

#### Saved Photo Example:

![example](https://raw.githubusercontent.com/ziligy/SnapLocation/master/SnapLocationPhotoExample.jpg "example")


#### Saved To Pasteboard:
```
street: Independence Ave NW
location: Washington, DC
zipcode: 20037
latitude: 38.88930
longitude: -77.05001
gpstime: 11/15/15 3:26 PM
```

## Features
- get location info based on user's location or from the center point of the displayed screen
- writes formatted current address & gps point info to the pasteboard
- snaps a map image with or without overlaid location info
- stores location info to history database
- user configuration stored in NSUserDefaults
- settings manager class included

## Update v0.6
- added history
    + realm used for persistence
    + history table & manager
- updated settings manager
    + code based
- clarified button operations
    + locate has choice of two modes
    + snap has three settings
- minimal use of location services
    + location service turned off immediately when locate is complete
- optional location pin
    + ditched the blue dot
- added carthage
    + to load realm framework

## Settings
- Map Display
    + display location pin
    + zoom level
- Locate Action
    + acquire locate info by user's location or screen display
- Snap Actions
    + save Snaps to Photos album
    + save Snaps text to pasteboard
    + save Snaps info to history
- Text Display
    + include city & state
    + include latitude & longitude
    + include GPS date/time
    + include address & zipcode

## How to install

1) Clone the repository

```
$ git clone https://github.com/ziligy/SnapLocation.git

```

2) Change directory

```
$ cd SnapLocation
```

3) Install pods

```
$ pod install
```

Use SnapLocation.xcworkspace to open project

## Dependencies
- [Realm](https://github.com/realm/realm-cocoa)

## Requirements
1. Xcode 7.2
2. Swift 2.0
3. iOS 9.0+

