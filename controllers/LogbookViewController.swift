//
//  LogbookViewController.swift
//  FitBuddy
//
//  Created by john.neyer on 5/16/15.
//  Copyright (c) 2015 jneyer.com. All rights reserved.
//

import Foundation
import UIKit
import FitBuddyModel
import FitBuddyCommon

class LogbookViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var logbookTableView: UITableView!
    
    var parentController : LogbookViewController?
    
    //Logbook array data
    var tableData : [LogbookEntry]?
    
    let logbookCellIdentifier = "Exercise Cell"
    let workoutCellIdentifier = "Workout Cell"
    
    var tableStyle = LogbookStyle.WORKOUT
    
    var chartLabels = NSMutableArray()
    
    var chartData = LogbookChartData()
    var logbookTableData = LogbookTableData()

    var workoutSection = 0
    var workoutIndex = 0
    
    var needsRedraw = true
    
    lazy var chart : LineChart = {
        var chart = LineChart()
        chart.y.labels.visible = false
        chart.x.axis.inset = 20.0
        chart.y.axis.visible = false
        chart.x.labels.visible = true
        chart.frame = self.chartView.frame
        chart.frame.origin.x = 0
        chart.area = false
        chart.x.grid.visible = false
        chart.y.grid.visible = false
        chart.showZeros = false
        chart.lineWidth = 0.0
        
        return chart
    }()
   
    override func viewDidLoad() {
        self.navigationItem.titleView = UIImageView(image: UIImage(named:FBConstants.kFITBUDDY))
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setupFetchedResultsController", name: FBConstants.kUBIQUITYCHANGED, object: nil)
    }

    override func viewWillAppear(animated: Bool) {
        self.loadData()
    }
    
    func redrawChart () {
        
        self.layoutChartView()
        
        if self.needsRedraw {
            // Initialize the chart
            chart.clearAll()
            
            //Set chart values
            self.chartLabels = NSMutableArray(array: chartData.lastThirty())
            
            let first = self.chartLabels.firstObject as! String
            
            //remove every fifth element day string
            for index in 1...self.chartLabels.count {
                if index % 5 != 0 {
                    self.chartLabels[self.chartLabels.count - 1 - index] =  ""
                }
            }
            
            self.chartLabels[0] = first
            
            chart.x.labels.values = self.chartLabels as [AnyObject] as! [String]
            
            chart.addLine(chartData.normalizedCardioArray() as [AnyObject] as! [CGFloat])
            chart.addLine(chartData.normalizedResistanceArray() as [AnyObject] as! [CGFloat])
        }

        self.needsRedraw = false
    }
    
    func layoutChartView () {
        
        self.chart.removeFromSuperview()
        self.chart.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.chartView.addSubview(self.chart)
        
        var viewsDict = ["insertedView" : self.chart]
        
        var horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[insertedView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDict)
        var verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[insertedView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDict)
        self.chartView.addConstraints(horizontalConstraints)
        self.chartView.addConstraints(verticalConstraints)
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        self.loadData()
    }
    
    func loadData() {
        self.tableData = AppDelegate.sharedAppDelegate().modelManager.getAllLogbookEntries()
        self.chartData.setLogbookData(tableData!)
        self.logbookTableData.setData(tableData!)
        self.redrawChart()
        self.logbookTableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if tableStyle == LogbookStyle.WORKOUT {
            return logbookTableData.numberOfSections()
        }
        
        if tableStyle == LogbookStyle.EXERCISE {
            return 1
        }
        
        return 0
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableStyle == LogbookStyle.WORKOUT {
            return logbookTableData.numberOfRowsInSection(section)
        }
            
        if  tableStyle == LogbookStyle.EXERCISE {
            return logbookTableData.numberOfExercisesInWorkout(workoutSection, index: workoutIndex)
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var text = ""
        
        if tableStyle == LogbookStyle.WORKOUT {
            text = logbookTableData.sectionAtIndex(section)
        }
        
        if tableStyle == LogbookStyle.EXERCISE {
            text = logbookTableData.sectionAtIndex(workoutSection)
        }
        
        let labelView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 35.0))
        labelView.backgroundColor = FBConstants.kCOLOR_LTGRAY
        labelView.autoresizesSubviews = false
        
        let label = UILabel(frame: CGRectMake(15, 0, tableView.frame.size.width, 35.0))
        label.font = UIFont.systemFontOfSize(12.0)
        label.text = text.uppercaseString
        label.textColor = FBConstants.kCOLOR_DKGRAY
        
        labelView.addSubview(label)
        return labelView
        
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if tableStyle == LogbookStyle.EXERCISE {
            return exerciseCellAtIndexPath(indexPath)
        }
        
        return workoutCellAtIndexPath(indexPath)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        if tableStyle == LogbookStyle.EXERCISE {
            return true
        }
        
        return false
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        return nil
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return 0
    }
    
    func exerciseCellAtIndexPath (indexPath:NSIndexPath) -> ExerciseLogCell {
        
        let cell = logbookTableView.dequeueReusableCellWithIdentifier(logbookCellIdentifier) as! ExerciseLogCell
    
        let entry = logbookTableData.exerciseForWorktoutAtIndex(workoutSection, workoutIndex: workoutIndex, exerciseIndex: indexPath.row)
        
        if entry.distance != nil {
            cell.setCellValues(name: entry.exercise_name, workout: entry.workout_name, value: entry.distance, valueType: "distance", exerciseType: ExerciseType.CARDIO)
        } else {
            cell.setCellValues(name: entry.exercise_name, workout: entry.workout_name, value: entry.weight, valueType: "weight", exerciseType: ExerciseType.RESISTANCE)
        }
        
        return cell
    }
    
    func workoutCellAtIndexPath (indexPath:NSIndexPath) -> WorkoutLogCell {
    
        let cell = logbookTableView.dequeueReusableCellWithIdentifier(workoutCellIdentifier) as! WorkoutLogCell
        let value = logbookTableData.workoutAtIndex(indexPath.section, index: indexPath.row)
        cell.setCellValues(name: value.name, date: value.date)
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.logbookTableView.deselectRowAtIndexPath(indexPath, animated: true)
        if tableStyle == LogbookStyle.WORKOUT {
            self.workoutSection = indexPath.section
            self.workoutIndex = indexPath.row
            self.performSegueWithIdentifier("WorkoutDetailsSeque", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let controller = segue.destinationViewController as! LogbookViewController
        if segue.identifier == "WorkoutDetailsSeque" {
            controller.title = "Exercises"
            controller.tableStyle = LogbookStyle.EXERCISE
            controller.workoutSection = self.workoutSection
            controller.workoutIndex = self.workoutIndex
            controller.parentController = self
        }
        else {
            controller.title = "Workouts"
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete
        {
            if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                let numberOfRows = logbookTableData.numberOfExercisesInWorkout(workoutSection, index: workoutIndex)
                cell.editing = true
                let entry = logbookTableData.exerciseForWorktoutAtIndex(workoutSection, workoutIndex: workoutIndex, exerciseIndex: indexPath.row)
                
                //set last workout date to nil to force recalculation
                if let workout = entry.workout {
                    AppDelegate.sharedAppDelegate().modelManager.deleteDataObject(entry)
                    workout.last_workout = nil
                    
                    var error : NSError?
                    workout.managedObjectContext?.save(&error)
                    
                    if error != nil {
                        NSLog("Error updating last workout date: %@", error!)
                    }
                }
                else {
                    AppDelegate.sharedAppDelegate().modelManager.deleteDataObject(entry)
                }
                
                //if this was the last row pop to root
                if numberOfRows == 1 {
                    self.navigationController?.popToRootViewControllerAnimated(true)
                }
            }
            
            self.needsRedraw = true
            self.parentController!.needsRedraw = true
            self.loadData()
        }
    }
}

enum LogbookStyle {
    case WORKOUT
    case EXERCISE
}

