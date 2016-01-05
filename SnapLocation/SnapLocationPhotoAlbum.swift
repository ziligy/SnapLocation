//
//  SnapLocationPhotoAlbum.swift
//
//  Created by Jeff on 1/4/16.
//  Copyright © 2016 Jeff Greenberg. All rights reserved.
//

import Photos

class SnapLocationPhotoAlbum: NSObject {
    static let albumName = "Snap!Location"
    
    static let sharedInstance: SnapLocationPhotoAlbum = {
        let instance = SnapLocationPhotoAlbum()
        
        if let assetCollection = instance.fetchAssetCollectionForAlbum() {
            instance.assetCollection = assetCollection
            return instance
        }
        
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.Authorized {
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
                status
            })
        }

        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.Authorized {
            instance.createAlbum()
        } else {
            PHPhotoLibrary.requestAuthorization(instance.requestAuthorizationHandler)
        }

        return instance
    }()
    
    var assetCollection: PHAssetCollection!
    
    private override init() {}
    
    func requestAuthorizationHandler(status: PHAuthorizationStatus) {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.Authorized {
            // ideally this ensures the creation of the photo album even if authorization wasn't prompted till after init was done
            print("trying again to create the album")
            self.createAlbum()
        } else {
            print("no authorization was granted")
        }
    }
    
    func createAlbum() {
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(SnapLocationPhotoAlbum.albumName)
            // create an asset collection with the album name
            }) { success, error in
                if success {
                    self.assetCollection = self.fetchAssetCollectionForAlbum()
                } else {
                    print("error \(error)")
                }
        }
    }
    
    func fetchAssetCollectionForAlbum() -> PHAssetCollection! {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", SnapLocationPhotoAlbum.albumName)
        let collection = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: fetchOptions)
        
        if let _: AnyObject = collection.firstObject {
            return collection.firstObject as! PHAssetCollection
        }
        return nil
    }
    
    func saveImage(image: UIImage) {
        if assetCollection == nil {
            return // if there was an error upstream, skip the save
        }
        
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
            let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: self.assetCollection)
            albumChangeRequest!.addAssets([assetPlaceHolder!])
            }, completionHandler: nil)
    }
    
}