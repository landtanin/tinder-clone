//
//  MatchTableViewCell.swift
//  Tinder-clone
//
//  Created by Tanin on 17/11/2017.
//  Copyright © 2017 landtanin. All rights reserved.
//

import UIKit
import Parse

class MatchTableViewCell: UITableViewCell {

    var recipientObjectId = ""
    
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var messageTextField: UITextField!
    @IBOutlet var profileImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func sendTapped(_ sender: UIButton) {
        
        let message = PFObject(className: "Message")
        
        message["sender"] = PFUser.current()?.objectId
        message["recipient"] = recipientObjectId
        message["content"] = messageTextField.text
        
        message.saveInBackground()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
