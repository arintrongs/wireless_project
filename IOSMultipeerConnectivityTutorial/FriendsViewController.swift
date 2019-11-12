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
    private var data: [String] = []
    
    @IBOutlet weak var friendTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0...5 {
             data.append("\(i)")
        }
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

//       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(indexPath)
//        print("selectRow")
////        let vc =  storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
////        self.navigationController?.pushViewController(vc, animated: true)
//
//
//       }
    
    var valueToPass:String = "Hello"

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")

        // Get Cell Label
        let indexPath = tableView.indexPathForSelectedRow!
        let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell

        valueToPass = currentCell.textLabel!.text!
//        print(valueToPass)
        performSegue(withIdentifier: "toChatSegue", sender: self)
    }

//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
//
//        if (segue.identifier == "yourSegueIdentifer") {
//            // initialize new view controller and cast it as your view controller
//            var viewController = segue.destinationViewController as AnotherViewController
//            // your new view controller should have property that will store passed value
//            viewController.passedValue = valueToPass
//        }
//    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
       {
           if segue.destination is ViewController
           {
               let vc = segue.destination as? ViewController
            vc?.chatWith = self.valueToPass
           }
       }
}


extension ViewController: UITableViewDelegate {

   
}
