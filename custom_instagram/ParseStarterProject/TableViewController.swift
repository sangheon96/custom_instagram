//
//  TableViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Stan Lee on 2016. 5. 14..
//  Copyright © 2016년 Parse. All rights reserved.
//

import UIKit
import Parse

class TableViewController: UITableViewController, UIToolbarDelegate {
    
    var usernames = [""]
    var userids = [""]
    var isFollowing = ["":false]
    
    var refresher: UIRefreshControl!
    
    func refresh() {
        
        let query = PFUser.query()
        
        query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            if let users = objects {
                
                self.usernames.removeAll(keepCapacity: true)
                self.userids.removeAll(keepCapacity: true)
                self.isFollowing.removeAll(keepCapacity: true)
                
                for object in users {
                    
                    if let user = object as? PFUser {
                        
                        if user.objectId! != PFUser.currentUser()?.objectId{
                            
                            //Appending username and objectId into the array usernames and userids
                            
                            self.usernames.append(user.username!)
                            self.userids.append(user.objectId!)
                            
                            let query = PFQuery(className: "followers")
                            
                            query.whereKey("follower", equalTo: PFUser.currentUser()!.objectId!)
                            query.whereKey("following", equalTo: user.objectId!)
                            
                            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in  //running query
                                
                                if let objects = objects { //if objects exist => user must be following the other user
                                    
                                    if objects.count > 0 {
                                        
                                        self.isFollowing[user.objectId!] = true
                                        
                                        
                                    } else {
                                        
                                        self.isFollowing[user.objectId!] = false
                                    }
                                }
                                
                                
                                if self.isFollowing.count == self.usernames.count {
                                    
                                    self.tableView.reloadData()
                                    self.refresher.endRefreshing()
                                    
                                }
                                
                            })
                            
                        }
                    }
                    
                }
                
                
                
            }
            
            
        })

        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //--------------------- REFRESHER -------------------//
        
        refresher = UIRefreshControl()
        
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        
        refresher.addTarget(self, action: #selector(TableViewController.refresh), forControlEvents: UIControlEvents.ValueChanged)
        
        self.tableView.addSubview(refresher)
        
        refresh()
        
        self.tableView.sendSubviewToBack(refresher)
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
//        if let navController = self.navigationController {
//            
//            navController.navigationBarHidden = true
//            self.navigationController?.toolbarHidden = true
//            
//        }
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernames.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //listing all users according to indexpath.row
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)

        cell.textLabel?.text = usernames[indexPath.row]
        
        let followedObjectId = userids[indexPath.row]
        
        if isFollowing[followedObjectId] == true {
            
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark //checkmark accessory

        } else {
            
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        return cell
    }
 

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        
        let followedObjectId = userids[indexPath.row]
        
        
        if isFollowing[followedObjectId] == false {
            //when currentUser was not following a indexPath.row user and now following
            
            isFollowing[followedObjectId] = true
            
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark //checkmark accessory
            
            let following = PFObject(className: "followers")
            following["following"] = userids[indexPath.row]
            following["follower"] = PFUser.currentUser()?.objectId
        
            following.saveInBackground()
        
        } else {
            //when currentUser was following a indexPath.row user and now unfollowing
            
            isFollowing[followedObjectId] = false
            cell.accessoryType = UITableViewCellAccessoryType.None //get rid of checkmark
            
            let query = PFQuery(className: "followers")
            
            query.whereKey("follower", equalTo: PFUser.currentUser()!.objectId!)
            query.whereKey("following", equalTo: userids[indexPath.row])
            
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in  //running query
                
                if let objects = objects { //if objects exist => user must be following the other user so delete to unfollow!
                    
                    for object in objects {
                        
                        object.deleteInBackground()
                    }
                }
               
                
            })
        }
    }
    
    
    @IBAction func logOut(sender: AnyObject) {
        
        if PFUser.currentUser()?.objectId != nil {
            
            PFUser.logOut()
            self.performSegueWithIdentifier("logout", sender: self)
            
        }
    }
    

}
