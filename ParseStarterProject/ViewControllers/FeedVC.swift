//
//  FeedVC.swift
//  Twissen
//
//  Created by Suleyman Calik on 02/05/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

enum FetchType {
    case Initial
    case Newer
    case Older
}


class FeedVC: UITableViewController {
    
    var twists = [Twist]()
    var refresher = UIRefreshControl()
    
    let limit = 5
    var fetching = false
    var allFetched = false

    override func viewDidLoad() {
        super.viewDidLoad()

        var cellNib = UINib(nibName:TwistCellID, bundle:nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier:TwistCellID)
        
        
        refresher.addTarget(self, action:"refreshFeed:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refresher)
        
        
        getTwists(FetchType.Initial)

    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        getTwists(FetchType.Newer)
    }
    
    
    
    func refreshFeed(refresher:UIRefreshControl) {
        getTwists(FetchType.Newer)
    }
    

    // MARK: - Server Methods
    
    func getTwists(type:FetchType) {
        
        if fetching {
            return
        }
        
        if let query = Twist.query() {
            
            var userQuery = PFUser.query()!
            userQuery.whereKey("active", equalTo:true)
            
            query.whereKey("user", matchesQuery:userQuery)

            query.includeKey("user")
            query.orderByDescending("createdAt")
            query.whereKey("active", equalTo:true)
            
            if type == FetchType.Newer {
                if let twist = twists.first {
                    query.whereKey("createdAt", greaterThan:twist.createdAt!)
                }
            }
            else if type == FetchType.Older {
                if let twist = twists.last {
                    query.whereKey("createdAt", lessThan:twist.createdAt!)
                }
            }
            
            
            query.limit = limit
            
            fetching = true
            
            query.findObjectsInBackgroundWithBlock({ (objects:[AnyObject]?, error:NSError?) -> Void in
                if let twists = objects as? [Twist] {
                    println("\(twists.count) adet Twist geldi!")
                    
                    if type == FetchType.Newer {
                        
                        for twist in twists.reverse() {
                            self.twists.insert(twist, atIndex:0)
                        }
                        
                    }
                    else {
                        self.twists.extend(twists)
                        
                        if twists.count < self.limit {
                            self.allFetched = true
                        }
                        
                    }
                    self.tableView.reloadData()
                }
                else {
                    println("Twistler getirilemedi!: \(error)")
                }
                
                self.fetching = false
                self.refresher.endRefreshing()
            })
        }
        else {
            println("Query oluşturulamıyor!")
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
    

    //66
    
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

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == twists.count - 3 {
            if !fetching && !allFetched {
                getTwists(FetchType.Older)
            }
        }
    }
    


}










