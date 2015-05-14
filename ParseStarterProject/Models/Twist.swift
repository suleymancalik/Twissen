//
//  Twist.swift
//  Twissen
//
//  Created by Suleyman Calik on 03/05/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class Twist: PFObject, PFSubclassing {
   
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "Twist"
    }
    
    
    @NSManaged var message:String
    @NSManaged var user:PFUser
    @NSManaged var active:Bool
    
}











