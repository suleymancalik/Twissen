//
//  SettingsVC.swift
//  Twissen
//
//  Created by Suleyman Calik on 02/05/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class SettingsVC: UIViewController {

    
    @IBOutlet weak var imgPicture: UIImageView!
    @IBOutlet weak var btnPicture: UIButton!
    @IBOutlet weak var txtFirstname: UITextField!
    @IBOutlet weak var txtLastname: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        var user = PFUser.currentUser()!
        txtFirstname.text = user["firstName"] as? String
        txtLastname.text = user["lastName"] as? String
        
        if let file = user["picture"] as? PFFile {
            
            file.getDataInBackgroundWithBlock({ (data:NSData?, error:NSError?) -> Void in
                if let picData = data {
                    var image = UIImage(data:picData)
                    self.imgPicture.image = image
                }
                else {
                    println("PFFile çekilemedi! \(error)")
                }
            })
            
        }
        
        
    }

    
    //MARK: - IBAction Methods

    
    var imagePicker = UIImagePickerController()
    @IBAction func changePicture(sender: UIButton) {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        presentViewController(imagePicker, animated:true, completion:nil)
    }
    
    @IBAction func save(sender: UIBarButtonItem) {
        
        var user = PFUser.currentUser()!
        user["firstName"] = txtFirstname.text
        user["lastName"] = txtLastname.text
        user.saveInBackgroundWithBlock { (saved:Bool, error:NSError?) -> Void in
            if saved {
                println("User başarıyla güncellendi")
            }
            else {
                println("User güncellenemedi! \(error)")
            }
        }
        
    }

    @IBAction func logout(sender: UIBarButtonItem) {
        
        PFUser.logOutInBackgroundWithBlock { (error:NSError?) -> Void in
            if let logoutError = error {
                println("Çıkış yaparken hata oluştu")
            }
            else {
                self.dismissViewControllerAnimated(true, completion:nil)
            }
        }
        
    }

    
}


//MARK: - ImagePicker Methods
extension SettingsVC:UIImagePickerControllerDelegate , UINavigationControllerDelegate  {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            if let data = UIImagePNGRepresentation(image) {
                var file = PFFile(data:data, contentType:"png")
                file.saveInBackgroundWithBlock({ (saved:Bool, error:NSError?) -> Void in
                    if saved {
                        var user = PFUser.currentUser()!
                        user["picture"] = file
                        user.saveInBackgroundWithBlock({ (userSaved:Bool, userError:NSError?) -> Void in
                            if userSaved {
                                println("Profil resmi değişti!")
                                self.imgPicture.image = image
                            }
                            else {
                                println("User kaydedilemedi")
                            }
                        })
                    }
                    else {
                        println("image upload edilemedi")
                    }
                })
            }
            else {
                println("image'dan data oluşmadı")
            }

        }
        else {
            println("Picker'dan image gelmedi")
        }
        
        dismissViewControllerAnimated(true, completion:nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion:nil)
    }
    
}



















