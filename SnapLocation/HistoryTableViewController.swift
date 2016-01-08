//
//  HistoryTableViewController.swift
//  SnapLocation
//
//  Created by Jeff on 12/4/15.
//  Copyright © 2015 Jeff Greenberg. All rights reserved.
//

import UIKit

protocol HistoryTableDelegate{
    func didSelectHistorySnapLocation(snapLocation: SnapLocationObject)
}

class HistoryTableViewController: UITableViewController
{
    private var historyData = HistoryDataSource()
    
    let photoAlbum = SnapLocationPhotoAlbum.sharedInstance
    
    internal var delegateForHistorySelect: HistoryTableDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        
        let trashButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Trash, target: self, action: "clearAll")
        navigationItem.setRightBarButtonItem(trashButton, animated: true)
        
        let blurredBackgroundView = BlurredBackgroundView(frame: CGRectZero, img: UIImage(named: "BlurBackground")!)
        tableView.backgroundView = blurredBackgroundView
        tableView.separatorEffect = UIVibrancyEffect(forBlurEffect: blurredBackgroundView.getBlurEffect())
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyData.count()
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! HistoryTableViewCell
        cell.loadLocationObject(historyData.getHistoryDataByIndex(indexPath.row)!)
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! HistoryTableViewCell
            
            photoAlbum.deleteImageByLocalIdentifier([cell.imageUUID])
            
            historyData.removeHistoryAtIndex(indexPath.row)
            
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            tableView.endUpdates()
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
            let selectedCell = tableView.cellForRowAtIndexPath(indexPath) as! HistoryTableViewCell
        
        let snapLocation = historyData.getHistoryDataByPrimaryKey( selectedCell.snapLocationId )
        
        self.delegateForHistorySelect?.didSelectHistorySnapLocation(snapLocation!)
        
        navigationController?.popViewControllerAnimated(true)
    }

    
    func clearAll() {
        
        let actionSheetController: UIAlertController = UIAlertController(title: "Delete All?", message: "This action will delete all history. To delete single items: swipe individual cells.", preferredStyle: .ActionSheet)
        
        //Create and add clear action
        let clearAllAction: UIAlertAction = UIAlertAction(title: "Clear All History", style: .Default) { action -> Void in
            
            // get array of UUIDs for the data
            let imageUUIDs = self.historyData.getAllImagesUUIDArray()
            // delete the images
            self.photoAlbum.deleteImageByLocalIdentifier(imageUUIDs)
            
            // delete the history
            self.historyData.clearAllHistoryData()
            
            // reload the empty page
            self.tableView.reloadData()
        }
        
        actionSheetController.addAction(clearAllAction)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        
        //Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
}


