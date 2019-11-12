//
//  LoginViewController.swift
//  IOSMultipeerConnectivityTutorial
//
//  Created by Natawat Kwanpoom on 10/11/19.
//  Copyright © 2019 Arthur Knopper. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    public var username :String = ""
    
     @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var wannaChatWIthLabel: UILabel!
    @IBOutlet weak var chatWithField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    

    @IBAction func doLogin(_ sender: Any) {
        self.username = self.usernameField.text!;
        UserDefaults.standard.set(self.username, forKey: "username")
        print(self.username)
        
    }
    
   

}
