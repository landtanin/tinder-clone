//
//  ViewController.swift
//  Tinder-clone
//
//  Created by Tanin on 09/11/2017.
//  Copyright © 2017 landtanin. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {
    
    var displayUserID = ""
    
    //    @IBOutlet var swipeLabel: UILabel!
    @IBOutlet var matchImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //        let testObject = PFObject(className: "Testing")
        //        testObject["foo"] = "bar"
        //        testObject.saveInBackground { (success, error) in
        //
        //            print("object has been saved")
        //
        //        }
        
        // add panGestureRecognizer
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged(gestureRecognizer:)))
        matchImageView.addGestureRecognizer(gesture)
        
        updateImage()
        
    }
    
    @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
        
        PFUser.logOut()
        performSegue(withIdentifier: "logoutSegue", sender: nil)
        
    }
    
    @objc func wasDragged(gestureRecognizer: UIPanGestureRecognizer){
        
        // let us know that interaction has been made
        let labelPoint = gestureRecognizer.translation(in: view)
        
        // change matchImageView center point according to user interaction
        matchImageView.center = CGPoint(x: view.bounds.width/2 + labelPoint.x, y: view.bounds.height/2 + labelPoint.y)
        
        // calculate rotation value, how much we want it to rotate
        let xFromCenter = view.bounds.width / 2 - matchImageView.center.x
        
        // prepare rotation variable to rotate the label a little as the user swipe
        var rotation = CGAffineTransform(rotationAngle: xFromCenter/200)
        
        // calculate scale value, min value equal to 1, never go negative
        let scale = min(100 / abs(xFromCenter), 1)
        
        // attach scale capability to the defined rotation variable
        var scaledAndRotated = rotation.scaledBy(x: scale, y: scale)
        
        // apply scaledAndRotated
        matchImageView.transform = scaledAndRotated
        
        // track on user interaction, ended means when they lift their fingers up
        if gestureRecognizer.state == .ended {
            
            var acceptedOrRejected = ""
            
            // see if they go far enough to the left (center - 100 to the left)
            if matchImageView.center.x < (view.bounds.width / 2 - 100) {
                print("Not Interested")
                acceptedOrRejected = "rejected"
            }
            
            // see if they go far enough to the right (center + 100 to the right)
            if matchImageView.center.x > (view.bounds.width / 2 + 100) {
                print("Interested")
                acceptedOrRejected = "accepted"
            }
            
            if acceptedOrRejected != "" && displayUserID != "" {
                PFUser.current()?.addUniqueObject(displayUserID, forKey: acceptedOrRejected)
                
                PFUser.current()?.saveInBackground(block: { (success, error) in
                    if success {
                        self.updateImage()
                    }
                })
            }
            
            // reset label to normal position
            rotation = CGAffineTransform(rotationAngle: 0)
            scaledAndRotated = rotation.scaledBy(x: 1, y: 1)
            matchImageView.transform = scaledAndRotated
            matchImageView.center = CGPoint(x: view.bounds.width/2, y: view.bounds.height/2)
        }
    }
    
    func updateImage() {
        
        if let query = PFUser.query(){
            
            if let isInterestedInWomen = PFUser.current()?["isInterestedInWomen"] {
                
                query.whereKey("isFemale", equalTo: isInterestedInWomen)
                
            }
            
            // check gender
            if let isFemale = PFUser.current()?["isFemale"] {
                
                query.whereKey("isInterestedInWomen", equalTo: isFemale)
                
            }
            
            var ignoredUsers : [String] = []
            
            if let acceptedUsers = PFUser.current()?["accepted"] as? [String] {
                ignoredUsers += acceptedUsers
            }
            
            if let rejectedUsers = PFUser.current()?["rejected"] as? [String] {
                ignoredUsers += rejectedUsers
            }
            
            query.whereKey("objectId", notContainedIn: ignoredUsers)
            
            // query one user at a time
            query.limit = 1
            
            query.findObjectsInBackground { (objects, error) in
                
                if let users = objects {
                    
                    for object in users{
                        
                        if let user = object as? PFUser{
                            
                            if let imageFile = user["photo"] as? PFFile {
                                
                                // download photo (PFFile)
                                imageFile.getDataInBackground(block: { (data, error) in
                                    
                                    if let imageData = data {
                                        
                                        self.matchImageView.image = UIImage(data: imageData)
                                        
                                        if let objectID = object.objectId{
                                        
                                            self.displayUserID = objectID
                                            
                                        }
                                        
                                    } // if let imageData = data
                                    
                                }) // imageFile.getDataInBackground
                                
                            } // if let imageFile = user["photo"] as? PFFile
                            
                        } // if let user = object as? PFUser
                        
                    } // for object in users
                    
                } // if let users = objects
                
            } // query.findObjectInBackground
            
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

