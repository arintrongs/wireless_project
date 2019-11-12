//
//  AddFriendViewController.swift
//  IOSMultipeerConnectivityTutorial
//
//  Created by Natawat Kwanpoom on 11/11/19.
//  Copyright © 2019 Arthur Knopper. All rights reserved.
//

import UIKit

class AddFriendViewController: UIViewController {

    public var delegate : FriendsViewDelegate?
    
    @IBOutlet weak var friendUsername: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onTapAddButton(_ sender: Any) {
        self.delegate?.addFriend(value: friendUsername.text!)
        self.navigationController?.popViewController(animated: true)
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

protocol FriendsViewDelegate {
  func addFriend(value: String)
}
