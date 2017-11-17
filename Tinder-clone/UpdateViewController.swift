//
//  UpdateViewController.swift
//  Tinder-clone
//
//  Created by Tanin on 15/11/2017.
//  Copyright © 2017 landtanin. All rights reserved.
//

import UIKit
import Parse

class UpdateViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var userGenderSwitch: UISwitch!
    @IBOutlet var interestedGenderSwitch: UISwitch!
    @IBOutlet var errorMsg: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        errorMsg.isHidden = true
        
        if let isFemale = PFUser.current()?["isFemale"] as? Bool {
            userGenderSwitch.setOn(isFemale, animated: false)
        }
    
        if let isInterestedInWomen = PFUser.current()?["isInterestedInWomen"] as? Bool {
            interestedGenderSwitch.setOn(isInterestedInWomen, animated: false)
        }
        
        if let photo = PFUser.current()?["photo"] as? PFFile {
            photo.getDataInBackground(block: { (data, error) in
                if let imageData = data {
                    if let image = UIImage(data: imageData){
                        self.profileImageView.image = image
                    }
                }
            })
        }
        

        
    }
    
    func manuallyCreateWomenUsers(){
        
        let imageUrls = ["https://upload.wikimedia.org/wikipedia/en/7/76/Edna_Krabappel.png","https://static.comicvine.com/uploads/scale_small/0/40/235856-101359-ruth-powers.png","http://vignette3.wikia.nocookie.net/simpsons/images/f/fb/Serious-sam--cover.jpg/revision/latest?cb=20131109214146","https://s-media-cache-ak0.pinimg.com/736x/e4/42/5a/e4425aad73f01d36ace4c86c3156dcdc.jpg","http://www.simpsoncrazy.com/content/pictures/onetimers/LurleenLumpkin.gif","https://vignette2.wikia.nocookie.net/simpsons/images/b/bc/Becky.gif/revision/latest?cb=20071213001352","http://vignette3.wikia.nocookie.net/simpsons/images/b/b0/Woman_resembling_Homer.png/revision/latest?cb=20141026204206"]
        
        var counter = 0
        
        for imageUrl in imageUrls {
            counter += 1
            if let url = URL(string: imageUrl) {
                if let data = try? Data(contentsOf: url) {
                    let imageFile = PFFile(name: "photo.png", data: data)
                    
                    let user = PFUser()
                    user["photo"] = imageFile
                    user.username = String(counter)
                    user.password = "abc123"
                    user["isFemale"] = true
                    user["isInterestedInWomen"] = false
                    
                    user.signUpInBackground(block: { (success, error) in
                        if success {
                            print("Women User created!")
                        }
                    })
                }
            }
        }
        
    }

    @IBAction func updateImageTapped(_ sender: UIButton) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            profileImageView.image = image
            
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func updateTapped(_ sender: UIButton) {
        
        PFUser.current()?["isFemale"] = userGenderSwitch.isOn
        PFUser.current()?["isInterestedInWomen"] = interestedGenderSwitch.isOn
        
        if let image = profileImageView.image {
            
            if let imageData = UIImagePNGRepresentation(image) {
                
                PFUser.current()?["photo"] = PFFile(name: "profile.png", data: imageData)
                
                // save
                PFUser.current()?.saveInBackground(block: { (success, error) in
                    
                    if error != nil {
                        var errorMessage = "Update Failed - try again"
                        
                        // get error message
                        if let newError = error as NSError? {
                            
                            if let detailError = newError.userInfo["error"] as? String {
                                
                                errorMessage = detailError
                                
                            } // check castin NSError to String done
                            
                        } // check error is NSError done
                        
                        self.errorMsg.isHidden = false
                        self.errorMsg.text = errorMessage
                        
                    } else {
                        
                        print("Update Successful")
                        
                        self.performSegue(withIdentifier: "updateToSwipeSegue", sender: nil)
                        
                    }
                    
                })
                
            }
            
        }
        
    }
    
}
