//
//  ExerciseEditViewController.swift
//  FitBuddy
//
//  Created by John Neyer on 4/26/16.
//  Copyright © 2016 jneyer.com. All rights reserved.
//

import Foundation
import FitBuddyCommon


class ExerciseEditViewController : ExerciseControlController {
    
    @IBOutlet weak var nameLabel : UITextField?
    
    func setupFetchedResultsController () {
        let request = NSFetchRequest(entityName: FBConstants.EXERCISE_TABLE)
        request.sortDescriptors = NSArray(objects: NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))) as? [NSSortDescriptor]
        request.predicate = NSPredicate(format: "name = %@", argumentArray: [self.exercise!.name])
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: AppDelegate.sharedAppDelegate().managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    override func loadFormDataFromExerciseObject() {
        self.nameLabel!.text = self.exercise?.name
        super.loadFormDataFromExerciseObject()
    }
    
    override func setExerciseFromForm () {
        self.exercise!.name = self.nameLabel!.text!
        super.setExerciseFromForm()
        NSLog ("Updating exercise : \(self.exercise!.name)")
        do {
            try AppDelegate.sharedAppDelegate().managedObjectContext?.save()
        } catch let e as NSError? {
            if e != nil {
                NSLog ("Error in setExerciseFromForm : \(e.debugDescription)")
            }
        }
        
    }
    
    override var exercise : Exercise? {
        
        willSet {
            super.exercise = exercise
        }
        
        didSet {
            self.setupFetchedResultsController()
        }
    }
    
    override func viewDidLoad() {
        self.navigationItem.titleView = UIImageView.init(image: UIImage(named: FBConstants.kFITBUDDY))
    }
    
    override func viewWillAppear(animated: Bool) {
        self.nameLabel?.addTarget(self, action: Selector("finishedEditingNameLabel:"), forControlEvents: UIControlEvents.EditingDidEndOnExit)
        self.loadFormDataFromExerciseObject()
    }
    
    func finishedEditingNameLabel (sender: AnyObject?) {
        self.nameLabel?.resignFirstResponder()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController.respondsToSelector(Selector("setExercise:")) {
            segue.destinationViewController.performSelector(Selector("setExercise:"), withObject: self.exercise)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.setExerciseFromForm()
    }
}