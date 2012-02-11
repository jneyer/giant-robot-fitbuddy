//
//  WorkoutViewController.m
//  GymBuddy
//
//  Created by John Neyer on 2/8/12.
//  Copyright (c) 2012 jneyer.com. All rights reserved.
//

#import "WorkoutViewController.h"
#import "CoreDataHelper.h"
#import "Workout.h"

@implementation WorkoutViewController 

@synthesize editButton = _editButton;
@synthesize document = _document;
@synthesize edit = _edit;

-(void) setupFetchedResultsController
{
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Workout"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"workout_name" ascending:YES]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request 
                                                                        managedObjectContext:self.document.managedObjectContext 
                                                                          sectionNameKeyPath:nil 
                                                                                   cacheName:nil];
}

-(void) setDocument:(UIManagedDocument *)document
{
    if (!self.document)
    {
        _document = document;
    }
    
    [self setupFetchedResultsController];
}

-(void) viewWillAppear:(BOOL)animated
{
    // Setup and initialize
    
    // Visual stuff
    self.navigationItem.title = nil;
    [[self.navigationController navigationBar] setBackgroundImage:[UIImage imageNamed:@"gb-title.png"] forBarMetrics:UIBarMetricsDefault];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"gb-background.png"]];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.editButton.tintColor = [UIColor clearColor];
    self.editButton.enabled = NO;
    
    // Initialize view    
    if (!self.document)    
    {
        [CoreDataHelper openDatabase:@"GymBuddy" usingBlock:^(UIManagedDocument *doc) {
            self.document = doc;
        }]; 
    }
    else
    {
        [self setupFetchedResultsController];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    // Get the Prototypes
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Workout Cell"];
    UILabel *label = (UILabel *)[cell viewWithTag:101];
    
    // Visual stuff
    cell.backgroundView.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"gb-cell.png"]];
    cell.selectedBackgroundView.backgroundColor = [UIColor darkGrayColor];
    
    // Add the data to the cell
    Workout *workout = [self.fetchedResultsController objectAtIndexPath:indexPath];
    label.text = workout.workout_name;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // Return YES to edit
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) 
    {
        //Check if index path is valid
        if(indexPath)
        {
            //Get the cell out of the table view
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            
            //Update the cell or model 
            cell.editing = YES;
            Workout *workout = [self.fetchedResultsController objectAtIndexPath:indexPath];
            [self.document.managedObjectContext deleteObject:workout];
        }
        //[self performFetch];
        [self.tableView reloadData];
    }    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    Workout *workout = nil;
    
    if ([segue.identifier isEqualToString: (@"Add Workout Segue")])
    {
        workout = [NSEntityDescription insertNewObjectForEntityForName:@"Workout" 
                                                inManagedObjectContext:self.document.managedObjectContext];
    }
    else
    {
        workout = [self.fetchedResultsController objectAtIndexPath:indexPath];
        NSLog(@"before segue: %@", workout.workout_name);
    }
    
    if ([segue.destinationViewController respondsToSelector:@selector(setWorkout:)]) 
    {
        [segue.destinationViewController performSelector:@selector(setWorkout:) withObject:workout];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.editButton.enabled = YES;
    self.editButton.tintColor = [UIColor blackColor];
}

- (void)viewDidUnload {
    [self setEditButton:nil];
    [super viewDidUnload];
}
@end
