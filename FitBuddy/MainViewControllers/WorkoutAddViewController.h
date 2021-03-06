//
//  WorkoutAddViewController.h
//  GymBuddy
//
//  Created by John Neyer on 2/8/12.
//  Copyright (c) 2012 jneyer.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

#import "FitBuddy-Swift.h"

@import FitBuddyModel;

@interface WorkoutAddViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *workoutNameTextField;

@property (nonatomic, strong) Workout *workout;
@property (nonatomic, strong) Exercise *exercise;
@property (nonatomic, strong) NSMutableOrderedSet *workoutSet;

-(IBAction) checkboxClicked:(id) sender;

@end
