//
//  WorkoutModeParentController2.swift
//  FitBuddy
//
//  Created by John Neyer on 4/26/16.
//  Copyright © 2016 jneyer.com. All rights reserved.
//

import Foundation
import FitBuddyModel
import FitBuddyCommon


class WorkoutModeParentController : UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIAlertViewDelegate {
    
    var pageViewController : UIPageViewController!
    
    @IBOutlet weak var pageControl : UIPageControl!
    @IBOutlet weak var progressBar : UIProgressView!
    @IBOutlet weak var finishButton : UIBarButtonItem!
    @IBOutlet weak var notesButton : UIBarButtonItem!
    @IBOutlet weak var skipitButton : UIButton!
    @IBOutlet weak var logitButton : UIButton!
    @IBOutlet weak var workoutControlPanel : UIView!
    
    var exerciseArray : NSMutableArray?
    var workout : Workout?
    
    lazy var logbookEntries : NSMutableDictionary = {
        return NSMutableDictionary()
    }()
    
    lazy var skippedEntries : NSMutableOrderedSet = {
        return NSMutableOrderedSet()
    }()
    
    var currentViewController : WorkoutModeViewController?
    
    var rotating : Bool = false
    var page : Int = 0
    var pageControlUsed : Bool = false
    
    func loadExerciseArray () {
        
        let context = AppDelegate.sharedAppDelegate().managedObjectContext
        let request = NSFetchRequest(entityName: FBConstants.WORKOUT_SEQUENCE)
        let predicate = NSPredicate(format: "workout = %@", self.workout!)
        request.predicate = predicate
        request.sortDescriptors = [NSSortDescriptor(key:"sequence", ascending:  true)]
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context!, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try frc.performFetch()
        } catch let e as NSError? {
            if e != nil {
                NSLog ("An error occured while loading the exercise array: \(e.debugDescription)")
            
            }
        }
                
        let workoutSequence = NSMutableArray(array: frc.fetchedObjects!)
        self.exerciseArray = NSMutableArray()
        
        for wo in workoutSequence {
            self.exerciseArray?.addObject(wo.exercise)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadExerciseArray()
        
        self.pageViewController = self.storyboard!.instantiateViewControllerWithIdentifier("PageViewController") as! UIPageViewController
        self.pageViewController?.dataSource = self
        
        let startingViewController = self.viewControllerAtIndex(0)! as WorkoutModeViewController
        let viewControllers = [startingViewController]
        self.pageViewController?.setViewControllers(viewControllers, direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        
        self.pageViewController!.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height - 30)
        
        self.addChildViewController(pageViewController!)
        self.view.addSubview(pageViewController!.view)
        self.pageViewController!.didMoveToParentViewController(self)
        
        self.pageControl!.numberOfPages = self.exerciseArray!.count
        self.pageControl!.currentPage = 0
        self.progressBar!.setProgress(0, animated: false)
        
        self.view.bringSubviewToFront(self.workoutControlPanel!)
        
        self.logitButton!.backgroundColor = FBConstants.kCOLOR_GRAY
        self.skipitButton!.backgroundColor = FBConstants.kCOLOR_GRAY
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateInterface:"), name: "WorkoutWillAppear", object: nil)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        currentViewController = self.viewControllerAtIndex(0)! as WorkoutModeViewController
        self.setExerciseTypeIcon()
    }
    
    func setExerciseTypeIcon () {
        
        if (self.currentViewController!.exercise as? CardioExercise) != nil {
            self.navigationItem.titleView = UIImageView(image: UIImage(named: FBConstants.kCARDIOWHITE))
        } else {
            self.navigationItem.titleView = UIImageView(image: UIImage(named: FBConstants.kRESISTANCEWHITE))
        }
        
    }
    
    func initialSetupOfFormWithWorkout (workout: Workout) {
        self.workout = workout
        skippedEntries = NSMutableOrderedSet()
    }
    
    func viewControllerAtIndex (index : Int) -> WorkoutModeViewController? {
        
        if self.exerciseArray!.count == 0 || index >= self.exerciseArray!.count {
            return nil
        }
        
        let pageContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("WorkoutContentViewController") as! WorkoutModeViewController
        pageContentViewController.initialSetupOfFormWithExercise(self.exerciseArray![index] as! Exercise, andLogbook: self.logbookEntries.objectForKey(index) as! LogbookEntry?, forWorkout: self.workout!)
        pageContentViewController.pageIndex = index
        var _ = pageContentViewController.view
        
        return pageContentViewController
    }
    
    func setExerciseLogToggleValue (logged: Bool) {
        
        // Reset the colors
        self.logitButton!.backgroundColor = FBConstants.kCOLOR_GRAY
        self.skipitButton!.backgroundColor = FBConstants.kCOLOR_GRAY
        
        NSLog("Logging")
        if logged {
            self.logitButton!.tintColor = FBConstants.GYMBUDDY_GREEN
            self.logitButton!.backgroundColor = FBConstants.GYMBUDDY_GREEN
        } else {
            self.skipitButton!.tintColor = FBConstants.GYMBUDDY_YELLOW;
            self.skipitButton!.backgroundColor = FBConstants.GYMBUDDY_YELLOW;
        }
    }
    
    func updateInterface (sender: NSNotification) {
        NSLog("Updating UI for parent controller")
        self.currentViewController = sender.object as! WorkoutModeViewController
        self.logitButton.backgroundColor = FBConstants.kCOLOR_GRAY
        self.skipitButton.backgroundColor = FBConstants.kCOLOR_GRAY
        
        self.pageControl.currentPage = currentViewController!.pageIndex
        
        if let logbookEntry = self.logbookEntries.objectForKey(currentViewController!.pageIndex) {
            self.setExerciseLogToggleValue(logbookEntry.completed.boolValue)
        }
        
        self.setExerciseTypeIcon()
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WorkoutModeViewController).pageIndex
        
        if index == 0 || index == NSNotFound {
            return nil
        }
        
        index -= 1
        
        return self.viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WorkoutModeViewController).pageIndex
        
        if index == NSNotFound {
            return nil
        }
        
        index += 1
        
        if index == self.exerciseArray!.count {
            return nil
        }
        
        return self.viewControllerAtIndex(index)
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.exerciseArray!.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func setExerciseLogToggle (logged: Bool) {
        
        
    }
    
    func setProgressBarProgress () {
        
        var butColor : UIColor!
        
        if self.skippedEntries.count == 0 {
            self.progressBar.progressTintColor = FBConstants.GYMBUDDY_GREEN
            butColor = FBConstants.GYMBUDDY_GREEN
        } else if self.skippedEntries.count == self.exerciseArray!.count {
            self.progressBar.progressTintColor = FBConstants.GYMBUDDY_RED
            butColor = FBConstants.GYMBUDDY_RED
        } else if self.skippedEntries.count > 0 {
            self.progressBar.progressTintColor = FBConstants.GYMBUDDY_YELLOW
            butColor = FBConstants.GYMBUDDY_YELLOW
        }
        
        let completed = (self.logbookEntries.allValues as NSArray).indexesOfObjectsPassingTest({
            (obj: AnyObject!, idx: Int, stop: UnsafeMutablePointer<ObjCBool>) -> Bool in
            
            if let lbe = obj as? LogbookEntry {
                if lbe.completed ==  NSNumber(bool: true) {
                    return true
                }
            }
            
            return false
        })
        
        let skipped = self.skippedEntries.count
        
        
        let prog = Float(completed.count + skipped) / Float(self.exerciseArray!.count) as Float
        self.progressBar.progress = prog
    }

    
    @IBAction func skipitButtonPressed (sender: UIButton) {
        currentViewController!.logbookEntry.completed = NSNumber(bool: false)
        self.skippedEntries.addObject(currentViewController!.logbookEntry)
        self.logbookEntries.setObject(currentViewController!.logbookEntry, forKey: currentViewController!.pageIndex)
        
        self.setExerciseLogToggleValue(false)
        self.setProgressBarProgress()
        self.currentViewController!.saveLogbookEntry()
        
        
    }
    
    @IBAction func logitButtonPressed (sender: UIButton) {
        currentViewController!.logbookEntry.completed = NSNumber(bool: true)
        currentViewController!.saveLogbookEntry()
        self.skippedEntries.removeObject(currentViewController!.logbookEntry)
        self.logbookEntries.setObject(currentViewController!.logbookEntry, forKey: currentViewController!.pageIndex)
        
        self.setExerciseLogToggleValue(true)
        self.setProgressBarProgress()
        currentViewController!.saveLogbookEntry()
        AppDelegate.sharedAppDelegate().modelManager.save()
    }
    
    @IBAction func goHomeButtonPressed (sender: UIBarButtonItem) {
        
        if self.progressBar.progress < 1 || self.skippedEntries.count > 0 {
            
            let alert = UIAlertView(title: "Complete Workout?",
                                    message: "Some exercies haven't been completed. Tap Finish to exit and save to the log or Cancel to return to workout.\n\n(swipe to go to the next exercise)",
                                    delegate: self,
                                    cancelButtonTitle: "Cancel",
                                    otherButtonTitles: "Finish")
            
            alert.show()
        } else {
            self.performSegueWithIdentifier(FBConstants.GO_HOME_SEGUE, sender: self)
        }
    
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            self.performSegueWithIdentifier(FBConstants.GO_HOME_SEGUE, sender: self)
        }
    }
    
    func homeButtonCleanup () {
        
        currentViewController!.saveLogbookEntry()
        let logValues = self.logbookEntries.allValues
        
        let count = (logValues as NSArray).indexesOfObjectsPassingTest({
            (obj: AnyObject!, idx: Int, stop: UnsafeMutablePointer<ObjCBool>) -> Bool in
            
            if let lbe = obj as? LogbookEntry {
                if lbe.completed !=  NSNumber(bool: true) {
                    return true
                }
            }
            
            return false
        })
        
        if count.count > 0 {
            let array = (logValues as NSArray).objectsAtIndexes(count)
            
            for lbe in array as! [LogbookEntry] {
                AppDelegate.sharedAppDelegate().managedObjectContext?.deleteObject(lbe)
            }
            
            let keys = self.logbookEntries.keysOfEntriesPassingTest({
                (key: AnyObject!, obj: AnyObject!, stop: UnsafeMutablePointer<ObjCBool>) -> Bool in
                
                if (array as NSArray).containsObject(obj) {
                    return true
                }
                
                return false
                
            })
            
            self.logbookEntries.removeObjectsForKeys(Array(keys))
        }
        
    }
    
    func nextPage () {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        NSLog("Starting segue to final results")
        
        // TODO : For some reason the current view controller isn't initialized when the workout is closed
        self.currentViewController!.setExerciseFromForm()
        
        if segue.destinationViewController.respondsToSelector("setFinalProgress:") {
            if self.logbookEntries.count > 0 {
                self.workout!.last_workout = self.logbookEntries.allValues.last!.date
            }
            
            let progressValue = NSNumber(float: self.progressBar.progress)
            segue.destinationViewController.performSelector(Selector("setFinalProgress:"), withObject: progressValue)
            segue.destinationViewController.performSelector(Selector("setLogbookEntries:"), withObject: self.logbookEntries)
            
            if segue.identifier == FBConstants.GO_HOME_SEGUE {
                self.homeButtonCleanup()
            }
            
            if segue.identifier == FBConstants.NOTES_SEGUE {
                segue.destinationViewController.performSelector(Selector("setExercise:"), withObject: self.currentViewController!.exercise)
            }
            
        }
    }
    
}