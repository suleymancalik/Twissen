//
//  NewPostVC.swift
//  Twissen
//
//  Created by Suleyman Calik on 03/05/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class NewPostVC: UIViewController {

    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func cancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion:nil)
    }

    @IBAction func sendPost(sender: UIBarButtonItem) {
        
        var newTwist = Twist.new()
        newTwist.message = textView.text
        newTwist.user = PFUser.currentUser()!
        newTwist.saveInBackgroundWithBlock { (success:Bool, error:NSError?) -> Void in
            if success {
                self.dismissViewControllerAnimated(true, completion:nil)
            }
            else {
                println("Yeni Twist oluşturulamadı!")
            }
        }        
        
    }

}











