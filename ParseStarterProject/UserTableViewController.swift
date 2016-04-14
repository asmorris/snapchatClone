//
//  UserTableViewController.swift
//  andymoChat
//
//  Created by Andrew Morrison on 2016-04-11.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class UserTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var usernames:[String] = []
    var recipientUsername:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: Selector("checkForMessage"), userInfo: nil, repeats: true)

        var query = PFQuery(className: "_User")
        if PFUser.currentUser()?.username != nil {
            
            query.whereKey("username", notEqualTo: (PFUser.currentUser()?.username)!)

            do {
                var users = try query.findObjects()
                
                for user in users {
                    usernames.append(user["username"] as! String)
                }
            } catch {
                
            }

        }
        //        var usersArray = [users]
//        for user in usersArray {
//            usernames.append(user.username)
//        }
        
    }
        
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - TableView data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernames.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        // Configure the cell...
        
        cell.textLabel?.text = usernames[indexPath.row]

        return cell
    }
    
    //MARK: - TableView Delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        recipientUsername = usernames[indexPath.row]
        
        var image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        image.allowsEditing = false
        
        self.presentViewController(image, animated: true, completion: nil)
        
    }
    
    //MARK: - ImagePickerController delegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        
        var imageToSend:PFObject = PFObject(className: "Image")
        imageToSend["photo"] = PFFile(name: "photo.jpg", data: UIImageJPEGRepresentation(image, 0.5)!)
        imageToSend["senderUsername"] = PFUser.currentUser()?.username
        imageToSend["recipientUsername"] = recipientUsername
        
        let acl = PFACL()
        acl.publicWriteAccess = true
        acl.publicReadAccess = true
        
        imageToSend.ACL = acl
        
        imageToSend.saveInBackground()

        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "logoutSegue" {
            print(PFUser.currentUser()?.username)
            PFUser.logOut()
            print(PFUser.currentUser()?.username)
        }
    }
    

    //MARK: - Misc functions
    
    func checkForMessage() {
        var query = PFQuery(className: "Image")
        if PFUser.currentUser()?.username != nil {
            query.whereKey("recipientUsername", equalTo: (PFUser.currentUser()?.username)!)
            do {
                var images =  try query.findObjects()
                
                if let pfObjects = images as? [PFObject] {
                    
                    if pfObjects.count > 0 {

                        var imageView:PFImageView = PFImageView()
                        imageView.file = pfObjects[0]["photo"] as! PFFile
                        imageView.loadInBackground({ (photo, error) in
                            if error == nil {
                                
                                var senderUsername = "Unknown user"
                                
                                if let username = pfObjects[0]["senderUsername"] as? String {
                                    senderUsername = username
                                    
                                }
                                
                                if #available(iOS 8.0, *) {
                                    let alert = UIAlertController(title: "You have a message!", message: "Message from: \(senderUsername)", preferredStyle: UIAlertControllerStyle.Alert)
                                    alert.addAction(UIAlertAction(title: "Okay!", style: UIAlertActionStyle.Default, handler: { (action) in
                                        
                                        let backgroundView = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
                                        backgroundView.backgroundColor = UIColor.blackColor()
                                        backgroundView.alpha = 0.7
                                        backgroundView.contentMode = UIViewContentMode.ScaleAspectFit
                                        backgroundView.tag = 10
                                        self.view.addSubview(backgroundView)

                                        let displayedImage = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
                                        displayedImage.image = photo
                                        displayedImage.contentMode = UIViewContentMode.ScaleAspectFit
                                        displayedImage.tag = 10
                                        self.view.addSubview(displayedImage)
                                        
                                        do {
                                           try pfObjects[0].delete()
                                        } catch {
                                           print("Not deleted")
                                        }
                                        
                                        _ = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("hideMessage"), userInfo: nil, repeats: false)
                                        
                                        
                                    
                                    }))
                                    self.presentViewController(alert, animated: true, completion: nil)
                                } else {
                                    // Fallback on earlier versions
                                }
                                
                            } else {
                                print(error)
                            }
                        })
                    }
                }
            } catch {
            }
        }
    }
    
    func hideMessage() {
        
        for subview in self.view.subviews {
            
            if subview.tag == 10 {
                
                subview.removeFromSuperview()
                
            }
        }
        
    }
}
