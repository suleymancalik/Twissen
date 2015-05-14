//
//  LoginVC.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import Parse

let errorCodeAlreadyExists = 202


class LoginVC: UIViewController {

    //
    
    
    @IBOutlet weak var txtUsername: UITextField!
    
    @IBOutlet weak var txtPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
        if let currentUser = PFUser.currentUser() {
            self.performSegueWithIdentifier("LoginSegue", sender:nil)
        }
        else {
            
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        txtUsername.text = ""
        txtPassword.text = ""
    }
    
    
    
    @IBAction func facebookConnect(sender: UIButton) {

        PFFacebookUtils.logInInBackgroundWithReadPermissions(nil, block: { (user:PFUser?, error:NSError?) -> Void in
            if let fbUser = user {
                self.performSegueWithIdentifier("LoginSegue", sender:nil)
            }
            else {
                
            }
        })
    }
    

    @IBAction func login(sender: UIButton) {
        if count(txtUsername.text) > 0 && count(txtPassword.text) > 0 {
            
            var range = txtUsername.text.rangeOfCharacterFromSet(NSCharacterSet.punctuationCharacterSet(), options: NSStringCompareOptions.allZeros, range: nil)
            if range != nil && !range!.isEmpty {
                println("Hatalı karakter")
                return
            }
            
            
            var user = PFUser()
            user.username = txtUsername.text
            user.password = txtPassword.text
            
            user.signUpInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                if success {
                    self.performSegueWithIdentifier("LoginSegue", sender:nil)
                }
                else {
                    if let signupError = error {
                        if signupError.code == errorCodeAlreadyExists {
                            // login etmeye çalış
                            
                            PFUser.logInWithUsernameInBackground(user.username!, password:user.password!, block: { (loggedInUser:PFUser?, loginError:NSError?) -> Void in
                                if let loggedInUser = loggedInUser {
                                    self.performSegueWithIdentifier("LoginSegue", sender:nil)
                                }
                                else {
                                    println("Giriş işlemi başarısız.")
                                }
                            })
                        }
                        else {
                            println("Giriş işlemi başarısız.")
                        }
                    }
                    else {
                        println("Giriş işlemi başarısız.")
                    }
                }
            })
            
        }
        else {
            println("Boş alan bırakmayınız")
        }
    }

}










