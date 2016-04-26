//
//  NotesEditorViewController.swift
//  FitBuddy
//
//  Created by John Neyer on 4/26/16.
//  Copyright © 2016 jneyer.com. All rights reserved.
//

import Foundation
import CoreData
import FitBuddyModel
import FitBuddyCommon

class NotesEditorViewController : UIViewController {
    
    @IBOutlet weak var notesTextView : UITextView?
    
    var exercise : Exercise?
    var fetchedResultsController : NSFetchedResultsController?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: Selector("doneAction:"))
        self.navigationItem.titleView = UIImageView(image: UIImage(named: FBConstants.kFITBUDDY))
    }
    
    
    func doneAction (sender: AnyObject?) {
        self.notesTextView?.resignFirstResponder()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.notesTextView!.text = self.exercise?.notes
        NSLog ("Loaded notes data for \(self.exercise!.name)")
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.exercise!.notes = self.notesTextView?.text
        do {
            try self.exercise?.managedObjectContext?.save()
        } catch let e as NSError? {
            if e != nil {
                NSLog("An error occured while saving notes: \(e.debugDescription)")
            }
        }
    }
}