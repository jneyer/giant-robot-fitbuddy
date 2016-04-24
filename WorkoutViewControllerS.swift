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

class WorkoutViewControllerS : CoreDataTableControllerS {
    
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
        
        super.viewWillAppear(animated)
    }

    
    func enableButtons(enable: Bool) {
        
    }
}
