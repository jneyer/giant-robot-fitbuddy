//
//  ExerciseAddViewController.swift
//  FitBuddy
//
//  Created by John Neyer on 4/26/16.
//  Copyright © 2016 jneyer.com. All rights reserved.
//

import Foundation
import CoreData
import FitBuddyCommon
import FitBuddyModel

class ExerciseAddViewController : UIViewController {
    
    @IBOutlet weak var addExerciseField : UITextField?
    @IBOutlet weak var exerciseTypeToggle : UISegmentedControl?
    
    var exerciseArray : NSMutableArray?
    var workoutSet : NSMutableOrderedSet?
    
    override func viewDidLoad() {
        self.navigationItem.titleView = UIImageView(image: UIImage(named: FBConstants.kFITBUDDY))
    }
    
    override func viewDidAppear(animated: Bool) {
        self.addExerciseField?.addTarget(self, action: #selector(self.newExerciseTextFieldFinished(_:)), forControlEvents: UIControlEvents.EditingDidEndOnExit)
    }
    
    func newExerciseTextFieldFinished (sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    override func viewWillAppear(animated: Bool) {
        
    }
    
    func createExercise () {
        
        if self.addExerciseField!.text != "" {
            let context = AppDelegate.sharedAppDelegate().managedObjectContext
            var newExercise: NSManagedObject?
            
            if self.exerciseTypeToggle?.selectedSegmentIndex == 0 {
                newExercise = NSEntityDescription.insertNewObjectForEntityForName(FBConstants.RESISTANCE_EXERCISE_TABLE, inManagedObjectContext: context!)
            } else {
                newExercise = NSEntityDescription.insertNewObjectForEntityForName(FBConstants.CARDIO_EXERCISE_TABLE, inManagedObjectContext: context!)
            }
            
            newExercise?.setValue(self.addExerciseField?.text, forKey: "name")
            self.addExerciseField!.text = ""
            
            do {
                try context?.save()
            } catch let e as NSError? {
                if e != nil {
                    NSLog ("An error occurred saving the exercise \(e.debugDescription)")
                } else {
                    NSLog ("Exercise created")
                }
            }
            
            if self.exerciseArray != nil {
                self.exerciseArray?.addObject(newExercise!)
            }
            
            if self.workoutSet != nil {
                self.workoutSet?.addObject(newExercise!)
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.createExercise()
    }
    
}