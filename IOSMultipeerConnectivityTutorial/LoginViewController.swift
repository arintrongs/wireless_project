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
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func doLogin(_ sender: Any) {
        self.username = self.usernameField.text!;
        print(self.username)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is ViewController
        {
            let vc = segue.destination as? ViewController
            vc?.username = self.username
        }
    }

}
