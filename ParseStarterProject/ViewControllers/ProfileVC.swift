//
//  ProfileVC.swift
//  Twissen
//
//  Created by Suleyman Calik on 02/05/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class ProfileVC: UITableViewController {

    
    var twists = [Twist]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        var cellNib = UINib(nibName:TwistCellID, bundle:nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier:TwistCellID)

    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        getTwists()
    }
    
    
    func getTwists() {
        
        if let query = Twist.query() {
            twists.removeAll(keepCapacity:false)
            
            query.whereKey("user", equalTo:PFUser.currentUser()!)
            query.includeKey("user")
            query.orderByDescending("createdAt")
            query.whereKey("active", equalTo:true)
            query.findObjectsInBackgroundWithBlock({ (objects:[AnyObject]?, error:NSError?) -> Void in
                if let twists = objects as? [Twist] {
                    println("\(twists.count) adet Twist geldi!")
                    self.twists.extend(twists)
                    self.tableView.reloadData()
                }
                else {
                    println("Twistler getirilemedi!: \(error)")
                }
            })
            
            
        }
        else {
            println("Query oluşturulamıyor!")
        }
        
    }
    
    func deleteTwist(index:Int) {
        if twists.count > index  {
            var twist = twists[index]
            twist.active = false
            twist.saveEventually()
            
            twists.removeAtIndex(index)
            tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow:index, inSection:0)], withRowAnimation:UITableViewRowAnimation.Automatic)
        }
    }
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return twists.count
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var twist = twists[indexPath.row]
        
        var font = UIFont.systemFontOfSize(14)
        var attributes = [NSFontAttributeName:font]
        
        //sizeWithAttributes(attributes)
        
        
        var cell = tableView.dequeueReusableCellWithIdentifier(TwistCellID) as! TwistCell
        
        var width = cell.txtTwist.frame.width
        var size = CGSize(width:width, height:CGFloat.max)
        var rect = (twist.message as NSString).boundingRectWithSize(size, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes:attributes, context:nil)
        
        
        var messageHeight = rect.size.height
        
        return 80 + messageHeight
        
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TwistCellID, forIndexPath: indexPath) as! TwistCell
        
        var twist = twists[indexPath.row]
        
        var firstName = twist.user["firstName"] as? String
        var lastName = twist.user["lastName"] as? String
        
        if  firstName != nil && lastName != nil {
            cell.lblUsername.text = firstName! + " " + lastName!
        }
        else {
            cell.lblUsername.text = twist.user.username
        }
        
        var dateString = NSDateFormatter.localizedStringFromDate(twist.createdAt!, dateStyle:NSDateFormatterStyle.MediumStyle, timeStyle:NSDateFormatterStyle.ShortStyle)
        cell.lblDate.text = dateString
        cell.txtTwist.text = twist.message
        
        cell.imgPicture.layer.cornerRadius = cell.imgPicture.frame.width / 2
        cell.imgPicture.clipsToBounds = true
        cell.imgPicture.image = nil
        if let file = twist.user["picture"] as? PFFile {
            file.getDataInBackgroundWithBlock({ (data:NSData?, error:NSError?) -> Void in
                if let picData = data {
                    var image = UIImage(data:picData)
                    cell.imgPicture.image = image
                }
                else {
                    println("PFFile çekilemedi! \(error)")
                }
            })
            
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            deleteTwist(indexPath.row)
        }
    }
    
    

}








