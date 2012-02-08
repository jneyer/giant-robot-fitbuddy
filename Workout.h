//
//  Workout.h
//  GymBuddy
//
//  Created by John Neyer on 2/7/12.
//  Copyright (c) 2012 jneyer.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Workout : NSManagedObject

@property (nonatomic, retain) NSString * workout_name;
@property (nonatomic, retain) NSNumber * workout_id;
@property (nonatomic, retain) NSNumber * exercise_id;
@property (nonatomic, retain) NSNumber * deleted;
@property (nonatomic, retain) NSNumber * sequence;

@end