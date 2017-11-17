//
//  MatchesViewController.swift
//  Tinder-clone
//
//  Created by Tanin on 17/11/2017.
//  Copyright © 2017 landtanin. All rights reserved.
//

import UIKit
import Parse

class MatchesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    var images : [UIImage] = []
    var userIds : [String] = []
    var messages : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        if let query = PFUser.query(){
            
            query.whereKey("accepted", contains: PFUser.current()?.objectId)
            
            if let acceptedPeeps = PFUser.current()?["accepted"] as? [String] {
                
                query.whereKey("objectId", containedIn: acceptedPeeps)
                
                query.findObjectsInBackground(block: { (objects, error) in
                    
                    if let users = objects {
                        
                        for user in users {
                            
                            if let theUser = user as? PFUser {
                                
                                if let imageFile = theUser["photo"] as? PFFile {
                                    
                                    imageFile.getDataInBackground(block: { (data, error) in
                                        
                                        if let imageData = data {
                                            
                                            if let image = UIImage(data: imageData){
                                                
                                                if let objectId = theUser.objectId {
                                                    
                                                    let messagesQuery = PFQuery(className: "Message")
                                                    
                                                    messagesQuery.whereKey("recipient", equalTo: PFUser.current()?.objectId as Any)
                                                    messagesQuery.whereKey("sender", equalTo: theUser.objectId as Any)
                                                    
                                                    messagesQuery.findObjectsInBackground(block: { (objects, error) in
                                                        
                                                        var messagetext = "No message from this user."
                                                        if let objects = objects {
                                                            for message in objects {
                                                                if let content = message["content"] as? String {
                                                                    messagetext = content
                                                                }
                                                            }
                                                        }
                                                        
                                                        self.messages.append(messagetext)
                                                        self.images.append(image)
                                                        self.userIds.append(objectId)
                                                        self.tableView.reloadData()
                                                        
                                                    })
                                                    
                                                } // if let objectId = theUser.objectId {
                                                
                                            } // if let image = UIImage(data: imageData){
                                            
                                        } // if let imageData = data
                                        
                                    }) // imageFile.getDataInBackground(block: { (data, error) in
                                    
                                } // if let imageFile = theUser["photo"] as? PFFile
                                
                            } // if let theUser = user as? PFUser
                            
                        } // for user in users {
                        
                    } // if let users = objects {
                    
                }) // query.findObjectsInBackground(block: { (objects, error) in
                
            } // if let acceptedPeeps = PFUser.current()?["accepted"] as? [String]
            
        } // if let query = PFUser.query(){
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "matchCell", for: indexPath) as? MatchTableViewCell{
            cell.messageLabel.text = "You haven't received a message yet"
            cell.profileImageView.image = images[indexPath.row]
            cell.recipientObjectId = userIds[indexPath.row]
            cell.messageLabel.text = messages[indexPath.row]
            return cell
            
        }
        return UITableViewCell()
    }
    
    @IBAction func backTapped(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
}
