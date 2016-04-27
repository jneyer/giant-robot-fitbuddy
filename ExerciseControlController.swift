//
//  ExerciseControlController.swift
//  FitBuddy
//
//  Created by John Neyer on 4/26/16.
//  Copyright © 2016 jneyer.com. All rights reserved.
//

import Foundation
import CoreData
import FitBuddyModel

@objc
class ExerciseControlController : UIViewController {
    
    @IBOutlet weak var slotOneValue : UILabel!
    @IBOutlet weak var slotTwoValue : UILabel!
    @IBOutlet weak var slotThreeValue : UILabel!
    @IBOutlet weak var slotOneIncrementValue : UILabel!
    @IBOutlet weak var slotOneTitle : UILabel!
    @IBOutlet weak var slotTwoTitle : UILabel!
    @IBOutlet weak var slotThreeTitle : UILabel!
    
    var exercise : Exercise?
    var fetchedResultsController : NSFetchedResultsController?
    
    var calcDistance = true
    
    func setExerciseFromForm () {
        
        if let cardio = self.exercise as? CardioExercise {
            
            cardio.pace = self.slotOneValue!.text!
            cardio.duration = self.slotTwoValue!.text!
            cardio.distance = self.slotThreeValue!.text!
            
        } else if let resistance = self.exercise as? ResistanceExercise {
            
            resistance.weight = self.slotOneValue!.text!
            resistance.reps = self.slotTwoValue!.text!
            resistance.sets = self.slotThreeValue!.text!
            
        }
    }

    func isCardio () -> Bool {
        return (self.exercise as? CardioExercise) != nil
    }
    
    func loadFormDataFromExerciseObject () {
        let desc = self.exercise?.entity
        NSLog ("Entity: \(desc!.name)")
        
        if let cardio = self.exercise as? CardioExercise {
            // Relabel
            self.slotOneTitle!.text = "Pace/hr"
            self.slotTwoTitle!.text = "Minutes"
            self.slotThreeTitle!.text = "Distance"
            
            var inc = NSUserDefaults.standardUserDefaults().stringForKey("Cardio Increment")
            if  inc == nil {
                inc = "0.5"
            }
            
            self.slotOneValue?.text = cardio.pace
            self.slotOneIncrementValue!.text = inc;
            self.slotTwoValue?.text = cardio.duration
            self.calculateSlotThree()
        } else if let resistance = self.exercise as? ResistanceExercise {
            
            self.slotOneTitle!.text = "Weight"
            self.slotTwoTitle!.text = "Reps"
            self.slotThreeTitle!.text = "Sets"
            
            var inc = NSUserDefaults.standardUserDefaults().stringForKey("Resistance Increment")
            if  inc == nil {
                inc = "2.5"
            }
            
            self.slotOneValue!.text = resistance.weight;
            self.slotOneIncrementValue!.text = inc;
            self.slotTwoValue!.text = resistance.reps;
            self.slotThreeValue!.text = resistance.sets;
            
        }
    }
    

    
    func calculateSlotThree () {
    
        if self.isCardio() && Double(self.slotTwoValue!.text!) > 0 {
            self.slotThreeValue!.text! = NSString(format: "%.1f", (Double(self.slotOneValue!.text!)! * Double(self.slotTwoValue!.text!)! / 60.0)) as String
            NSLog("Calculating \(self.slotThreeValue!.text!) *  \(self.slotTwoValue!.text!) / 60.0 = \(self.slotThreeValue!.text!)")
        }
    }
    
    func calculateSlotOne () {
        
        if self.isCardio() && Double(self.slotTwoValue!.text!) > 0 {
            
            self.slotOneValue!.text = String(format: "%.1f", Double(self.slotThreeValue!.text!)! / Double(self.slotTwoValue!.text!)! / 60.0)
            NSLog("Calculating \(self.slotThreeValue!.text!) / \(self.slotTwoValue!.text!) / 60.0 = \(self.slotOneValue!.text!)")
            
        }
    }
    
    @IBAction func slotOneIncrement (sender: UIButton) {
        
        let increment = Double (self.slotOneIncrementValue!.text!)
        var val: Double = Double (self.slotOneValue!.text!)!
        
        if "+" == sender.currentTitle {
            val += increment!
        }
        if "-" == sender.currentTitle {
            val -= increment!
            if val < 0 {
                val = 0
            }
        }

        self.slotOneValue!.text = String (format: "%g", val)
        self.calculateSlotThree()
        calcDistance = true
        
    }
    
    @IBAction func slotTwoIncrement (sender: UIButton) {
        
        var val: Double = Double(self.slotTwoValue!.text!)!
        
        if "+" == sender.currentTitle {
            val += 1
        }
        
        if "-" == sender.currentTitle {
            val -= 1
            if val < 0 {
                val = 0
            }
        }
        
        self.slotTwoValue!.text = String(format: "%g", val)
        
        if calcDistance {
            self.calculateSlotThree()
        } else {
            self.calculateSlotOne()
        }
    }
    
    @IBAction func slotThreeIncrement (sender: UIButton) {
        
        var increment = Double(1)
        
        if self.isCardio() {
            increment = Double(self.slotOneIncrementValue!.text!)!
        }
        
        var val = Double(self.slotThreeValue!.text!)!
        
        if "+" == sender.currentTitle {
            val += increment
        }
        if "-" == sender.currentTitle {
            val -= increment
            if val < 0 {
                val = 0
            }
        }
        
        self.slotThreeValue!.text = String(format:"%g", val)
        self.calculateSlotOne()
        calcDistance = false
        
    }
    
    @IBAction func undoAllDataChangesSinceLastSave () {
        self.loadFormDataFromExerciseObject()
    }
    
}