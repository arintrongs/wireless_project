//
//  FriendsViewController.swift
//  IOSMultipeerConnectivityTutorial
//
//  Created by Natawat Kwanpoom on 11/11/19.
//  Copyright © 2019 Arthur Knopper. All rights reserved.
//

import UIKit

class FriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var username: String = ""
    var friend : Friend = Friend()
    public var data: [String] = []
    
    @IBOutlet weak var friendTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendTable.delegate = self
        friendTable.isUserInteractionEnabled = true
        friendTable.dataSource = self
        friendTable.allowsSelection = true
        
        
        // Do any  additional setup after loading the view.
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = friendTable.dequeueReusableCell(withIdentifier: "friendCell")! //1.
        
        let text = data[indexPath.row] //2.
        
        cell.textLabel?.text = text //3.
        
        return cell //4.
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    
    
    var valueToPass:String = "Hello"
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
        
        // Get Cell Label
        let indexPath = tableView.indexPathForSelectedRow!
        let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
        
        self.valueToPass = currentCell.textLabel!.text!
        //        print(valueToPass)
        performSegue(withIdentifier: "showChat", sender: self)
    }
    
     
    @IBAction func onTapAddFriend(_ sender: Any) {
        performSegue(withIdentifier: "addFriend", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is ChatViewController
        {
            let vc = segue.destination as? ChatViewController
            vc?.chatWith = self.valueToPass
        }
        if segue.destination is AddFriendViewController{
            let vc = segue.destination as? AddFriendViewController
            vc?.delegate = self
        }
    }
}



extension FriendsViewController: FriendsViewDelegate{
    func addFriend(value: String) {
        data.append(value)
        self.friendTable.reloadData()
        print(data)
    }
}
