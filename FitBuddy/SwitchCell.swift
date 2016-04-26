//
//  SwitchCell.swift
//  FitBuddy
//
//  Created by John Neyer on 4/25/16.
//  Copyright © 2016 jneyer.com. All rights reserved.
//

import Foundation
import FitBuddyCommon


protocol SwitchCellDelegate {
    func didSwitch (switchState: Bool)
    
}

class SwitchCell : UITableViewCell {
    
    
    @IBOutlet weak var name : UILabel?
    @IBOutlet weak var icon : UIImageView?
    @IBOutlet weak var checkbox : UISwitch?
    
    
    @IBAction func switched(sender: AnyObject?) {
        NSNotificationCenter.defaultCenter() .postNotificationName(FBConstants.kCHECKBOXTOGGLED, object: self)
        
    }
    
    
}