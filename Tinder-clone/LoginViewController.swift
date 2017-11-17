//
//  LoginViewController.swift
//  Tinder-clone
//
//  Created by Tanin on 14/11/2017.
//  Copyright © 2017 landtanin. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    @IBOutlet var usernameTxtField: UITextField!
    @IBOutlet var passwordTxtField: UITextField!
    @IBOutlet var logInSignUpBtn: UIButton!
    @IBOutlet var changeLogInSignUpBtn: UIButton!
    @IBOutlet var errorMsg: UILabel!
    
    var signUpMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        errorMsg.isHidden = true
        
    }

    @IBAction func logInSignUpTapped(_ sender: UIButton) {
        
        if signUpMode {
            
            let user = PFUser()
            
            user.username = usernameTxtField.text
            user.password = passwordTxtField.text
            
            user.signUpInBackground(block: { (success, error) in
                
                if error != nil {
                    var errorMessage = "Sign Up Failed - try again"
                    
                    // get error message
                    if let newError = error as NSError? {
                        
                        if let detailError = newError.userInfo["error"] as? String {
                            
                            errorMessage = detailError
                            
                        }
                        
                    }
                    
                    self.errorMsg.isHidden = false
                    self.errorMsg.text = errorMessage
                    
                } else {
                    
                    print("Sign up Successful")
                    self.performSegue(withIdentifier: "updateSegue", sender: nil)
                    
                }
                
            })
            
        } else { // login
            
            if let username = usernameTxtField.text {
                
                if let password = passwordTxtField.text {
                    
                    PFUser.logInWithUsername(inBackground: username, password: password, block: { (user, error) in
                        
                        if error != nil {
                            var errorMessage = "Log In Failed - try again"
                            
                            // get error message
                            if let newError = error as NSError? {
                                
                                if let detailError = newError.userInfo["error"] as? String {
                                    
                                    errorMessage = detailError
                                    
                                } // check castin NSError to String done
                                
                            } // check error is NSError done
                            
                            self.errorMsg.isHidden = false
                            self.errorMsg.text = errorMessage
                            
                        } else {
                            
                            print("Log In Successful")
                            
                            if let thisUser = user {
                            
                                if thisUser["isFemale"] != nil {
                                    
                                    self.performSegue(withIdentifier: "loginToSwippingSegue", sender: nil)
                                    
                                } else {
                                    
                                    self.performSegue(withIdentifier: "updateSegue", sender: nil)
                                    
                                }
                                
                            }
                            
                        }
                        
                    })
                    
                } // check password exist done
                
            } // check username exist done
            
        } // else login done
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // check if they've logged in
        if PFUser.current() != nil {
            
            if PFUser.current()?["isFemale"] != nil {
            
                self.performSegue(withIdentifier: "loginToSwippingSegue", sender: nil)
                
            } else {
            
                self.performSegue(withIdentifier: "updateSegue", sender: nil)
                
            }
            
        }
        
    }
    
    @IBAction func changeLogInSignUpTapped(_ sender: UIButton) {
        
        if signUpMode {
            logInSignUpBtn.setTitle("Log In", for: [])
            changeLogInSignUpBtn.setTitle("Sign Up", for:.normal)
            signUpMode = false
        } else {
            logInSignUpBtn.setTitle("Sign Up", for: [])
            changeLogInSignUpBtn.setTitle("Log In", for:.normal)
            signUpMode = true
        }
        
    }
}
