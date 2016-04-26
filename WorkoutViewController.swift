//
//  WorkoutViewController.swift
//  FitBuddy
//
//  Created by john.neyer on 4/26/15.
//  Copyright (c) 2015 jneyer.com. All rights reserved.
//

import Foundation
import UIKit
import FitBuddyCommon
import CoreData
import FitBuddyModel
import CloudKit

class WorkoutViewController : CoreDataTableController, CloudKitOperationDelegate {
    
    @IBOutlet weak var editButton: UIBarButtonItem?
    @IBOutlet weak var startButton: UIButton?
    var edit = false
    
    func setupFetchedResultsController () {
        self.setupFetchedResultsControllerWithContext(AppDelegate.sharedAppDelegate().managedObjectContext!)
        
    }
    
    func setupFetchedResultsControllerWithContext (context: NSManagedObjectContext) {
        let request = NSFetchRequest(entityName: FBConstants.WORKOUT_TABLE)
        
        request.sortDescriptors = [NSSortDescriptor(key: "last_workout", ascending: false)]
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
    }
    
    func inializeDefaults () {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if defaults.stringForKey("Cardio Increment") == nil {
            defaults.setValue("0.5", forKey: "Cardio Increment")
        }
        
        if defaults.stringForKey("Resistance Increment") == nil {
            defaults.setValue("2.5", forKey: "Resistance Increment")
        }
        
        if defaults.stringForKey("Use iCloud") == nil {
            defaults.setValue("No", forKey: "Use iCloud")
        }
        
        if defaults.stringForKey("firstrun") == nil {
            defaults.setValue("0", forKey: "firstrun")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = UIImageView(image: UIImage(named: FBConstants.kFITBUDDY))
    }
    
    override func viewWillAppear(animated: Bool) {
        self.inializeDefaults()
        self.setupFetchedResultsController()
        
        self.startButton?.setBackgroundImage(UIImage(named: FBConstants.kSTARTDISABLED), forState: UIControlState.Disabled)
        self.startButton?.setBackgroundImage(UIImage(named: FBConstants.kSTART), forState: UIControlState.Normal)
        self.enableButtons(false)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector(setupFetchedResultsController()), name: FBConstants.kUBIQUITYCHANGED, object: AppDelegate.sharedAppDelegate().coreDataConnection)
        
        // CloudKit test
        let ccc = CloudKitConnection()
        let ccmm = CloudKitModelManager.init(connection: ccc)
        ccmm.getRecords("Workout", condition: nil, delegate: self)
        
        super.viewWillAppear(animated)
    }
    
    func operationCompleted(results: [AnyObject?]) {
        if results.count > 0 {
            let ccmm = CloudKitModelManager.init(connection: CloudKitConnection())
            for result in results {
                ccmm.deleteRecord(result)
                
            }
        }
    }
    
    // TableView Implementation
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (debug) {
            NSLog("Building cell")
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Workout Cell")
        let label = cell?.viewWithTag(101) as! UILabel
        let dateLabel = cell?.viewWithTag(200) as! UILabel
        
        let workout = self.fetchedResultsController?.objectAtIndexPath(indexPath) as! Workout
        
        label.text = workout.workout_name
        dateLabel.text = AppDelegate.sharedAppDelegate().modelManager.getLastWorkoutDate(workout, withFormat: "dd MMM YYYY")
        
        return cell!
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            if (indexPath.row > 0) {
                let cell = self.tableView?.cellForRowAtIndexPath(indexPath)
                cell?.editing = true
                let workout = self.fetchedResultsController?.objectAtIndexPath(indexPath) as! Workout
                AppDelegate.sharedAppDelegate().managedObjectContext?.deleteObject(workout)
                
                do {
                    try AppDelegate.sharedAppDelegate().managedObjectContext?.save()
                } catch _ {
                }
            }
            
            self.enableButtons(false)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
        self.enableButtons(true)
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.enableButtons(false)
    }
    
    // UI Actions
    func enableButtons(enable: Bool) {
        
        self.editButton!.enabled = enable;
        self.startButton!.enabled = enable;
        
        if (enable)
        {
            self.startButton!.titleLabel!.text = "Start";
            self.editButton!.tintColor = UIColor.whiteColor()
        }
        else
        {
            self.startButton!.titleLabel!.text = "";
            self.editButton!.tintColor = UIColor.clearColor()
        }
    }
    
    @IBAction func startButtonPressed (sender: UIButton) {
        
        let workout = (self.fetchedResultsController?.objectAtIndexPath(self.tableView!.indexPathForSelectedRow!) as? Workout)
        
        if (workout != nil && workout!.exercises.count == 0) {
            let alert = UIAlertView(title: "There are no exercises for this workout.", message: "Edit this workout to add some exercises to log. Then come back and start workout mode.", delegate: nil, cancelButtonTitle: "Got it!")
            alert.show()
            
        } else {
            self.performSegueWithIdentifier(FBConstants.START_WORKOUT_SEGUE, sender: self)
        }
        
    }
    
    // Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let indexPath = self.tableView?.indexPathForSelectedRow
        var workout: Workout? = nil
        
        if (debug) {
            NSLog("In prepare for segue")
        }
        
        if segue.identifier == FBConstants.ADD_WORKOUT_SEGUE {
            NSLog("In add workout segue")
            workout = NSEntityDescription.insertNewObjectForEntityForName(FBConstants.WORKOUT_TABLE, inManagedObjectContext: AppDelegate.sharedAppDelegate().managedObjectContext!) as? Workout
        } else if segue.identifier == FBConstants.START_WORKOUT_SEGUE {
            NSLog("In start workout segue")
            
            // [((WorkoutModeParentController2 *)[segue.destinationViewController topViewController]) setWorkout:workout];
            
            if let workout = self.fetchedResultsController?.objectAtIndexPath(self.tableView!.indexPathForSelectedRow!) as? Workout {
                if let destination = segue.destinationViewController.childViewControllers[0] as? WorkoutModeParentController2 {
                    destination.workout = workout
                }
            }
            
        } else {
            workout = self.fetchedResultsController?.objectAtIndexPath(indexPath!) as? Workout
        }
        
        let sel = Selector("setWorkout:")
        if segue.destinationViewController.respondsToSelector(sel) {
            segue.destinationViewController.performSelector(sel, withObject: workout)
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionTitle = self.tableView(tableView, titleForHeaderInSection: section)
            
        if sectionTitle == nil {
            return nil
        }
        
        let labelView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 60.0))
        labelView.backgroundColor = UIColor.whiteColor()
        labelView.autoresizesSubviews = true
        
        // Create label with section title
        let label = UILabel(frame: CGRect(x: 15, y: 10, width: tableView.frame.size.width, height: 60.0))
        label.text = "WORKOUTS"
        label.font = UIFont.systemFontOfSize(14.0)
        label.textColor = FBConstants.kCOLOR_DKGRAY
        labelView.addSubview(label)
        
        return labelView
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Workouts"
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    // Reordering
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        
    }
    
    func setOrderFromCells () {
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        super.viewDidDisappear(animated)
    }
    
    
}