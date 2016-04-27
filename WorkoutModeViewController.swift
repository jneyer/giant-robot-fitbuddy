//
//  WorkoutModeViewController.swift
//  FitBuddy
//
//  Created by John Neyer on 4/26/16.
//  Copyright © 2016 jneyer.com. All rights reserved.
//

import Foundation
import FitBuddyModel
import FitBuddyCommon
import CoreData

@objc
class WorkoutModeViewController : ExerciseControlController {
    
    @IBOutlet weak var exerciseLabel : UILabel?
    
    var workout : Workout?
    var pageIndex : Int = 0;
    
    var _logbookEntry : LogbookEntry?
    var logbookEntry : LogbookEntry {
        
        get {
            if _logbookEntry == nil {
                _logbookEntry = self.initializeLogbookEntry()
                return _logbookEntry!
            }
            return _logbookEntry!
        }
        
        set (newVal) {
            _logbookEntry = newVal
        }
    }

    
    func getPageIndex () -> Int {
        return pageIndex
    }
    
    func loadFormDataFromExercise () {
        self.navigationItem.title = self.exercise!.name
        self.exerciseLabel!.text = self.exercise!.name
        super.loadFormDataFromExerciseObject()
    }
    
    func initialSetupOfFormWithExercise (exercise: Exercise,  andLogbook logbookEntry: LogbookEntry?, forWorkout workout: Workout) {
        self.exercise = exercise
        
        if logbookEntry == nil {
            self.logbookEntry = initializeLogbookEntry()
        } else {
            self.logbookEntry = logbookEntry!
        }
        
        self.workout = workout
    }
    
    func initializeLogbookEntry () -> LogbookEntry {
        let newEntry = NSEntityDescription.insertNewObjectForEntityForName(FBConstants.LOGBOOK_TABLE, inManagedObjectContext: AppDelegate.sharedAppDelegate().managedObjectContext!)
        NSLog("Added a new logbook entry for Exercise \(self.exercise!.name)")
        
        return newEntry as! LogbookEntry
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadFormDataFromExercise()
    }
    
    override func viewDidAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().postNotificationName("WorkoutWillAppear", object: self)
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.setExerciseFromForm()
    }
    
    func saveLogbookEntry () {
        self.logbookEntry.date = NSDate()
        self.logbookEntry.workout_name = self.workout!.workout_name
        self.logbookEntry.exercise_name = self.exercise!.name
        self.logbookEntry.notes = self.exercise!.notes
        
        if let cardio = self.exercise as? CardioExercise {
            self.logbookEntry.pace = cardio.pace
            self.logbookEntry.distance = cardio.distance
            self.logbookEntry.duration = cardio.duration
        }
        
        if let resistance = self.exercise as? ResistanceExercise {
            self.logbookEntry.reps = resistance.reps
            self.logbookEntry.sets = resistance.sets
            self.logbookEntry.weight = resistance.weight
        }
        
        self.logbookEntry.workout = self.workout
        
        let tempSet = self.workout!.logbookEntries.mutableCopy()
        tempSet.addObject(self.logbookEntry)
        self.workout!.logbookEntries = tempSet as! NSOrderedSet
        
        AppDelegate.sharedAppDelegate().modelManager.save()
    }
    
    override func setExerciseFromForm () {
        
        if let cardio = self.exercise as? CardioExercise {
            cardio.pace = self.slotOneValue.text!
            cardio.duration = self.slotTwoValue.text!
            cardio.distance = self.slotThreeValue.text!
        }
        
        if let resistance = self.exercise as? ResistanceExercise {
            resistance.weight = self.slotOneValue.text!
            resistance.reps = self.slotTwoValue.text!
            resistance.sets = self.slotThreeValue.text!
        }
        
    }

}

