//
//  SnapLocationPhotoAlbum.swift
//
//  Created by Jeff on 1/4/16.
//  Copyright © 2016 Jeff Greenberg. All rights reserved.
//

import Photos

protocol SnapLocationPhotoAlbumDelegate{
    func saveImageCompleted(imageUUID: String)
    func deleteImageCompleted(success: Bool, _ error: NSError?)
}

class SnapLocationPhotoAlbum: NSObject {
    static let albumName = "Snap!Location"
    
    internal var delegate: SnapLocationPhotoAlbumDelegate?
    
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
        guard assetCollection != nil else { return }
        
        var assetPlaceHolderUUID: String!
        
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
            assetChangeRequest.hidden = true
            let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: self.assetCollection)
            assetPlaceHolderUUID = assetPlaceHolder?.localIdentifier
            
            albumChangeRequest!.addAssets([assetPlaceHolder!])
            }, completionHandler: { success, error in
                if success {
                    self.delegate?.saveImageCompleted(assetPlaceHolderUUID)
                } else {
                    print("error saving image \(error)")
                }
        })
    }
    
    func deleteImageByLocalIdentifier(localIdentifiers: [String]) {
        guard assetCollection != nil else { return }
        
        let options = PHFetchOptions()
        options.includeHiddenAssets = true
        
        let phAssets = PHAsset.fetchAssetsWithLocalIdentifiers(localIdentifiers, options: options)
        
        guard phAssets.count > 0 else { print("couldn't find localIdentifiers"); return }
        
        PHPhotoLibrary.sharedPhotoLibrary().performChanges( {
            PHAssetChangeRequest.deleteAssets(phAssets)},
            completionHandler: { success, error in
                self.delegate?.deleteImageCompleted(success, error)
        })
    }
    
    
    func readLastImageAsset() -> PHAsset? {
        guard assetCollection != nil else { return nil }
        
        return PHAsset.fetchAssetsInAssetCollection(assetCollection, options: nil).lastObject as? PHAsset
    }
    
    func readImageAssetByIndex(index: Int) -> PHAsset? {
        guard assetCollection != nil else { return nil }
        
        let phAssests = PHAsset.fetchAssetsInAssetCollection(assetCollection, options: nil)
        
        if index < 0 || index >= phAssests.count { return nil }
        return phAssests[index] as? PHAsset
    }
    
    func readImageAssetByLocalIdentifier(localIdentifier: String) -> PHAsset? {
        guard assetCollection != nil else { return nil }
        
        return PHAsset.fetchAssetsWithLocalIdentifiers([localIdentifier], options: nil).firstObject as? PHAsset
    }
    
}