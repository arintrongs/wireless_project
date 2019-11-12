//
//  Friend.swift
//  IOSMultipeerConnectivityTutorial
//
//  Created by Natawat Kwanpoom on 11/11/19.
//  Copyright © 2019 Arthur Knopper. All rights reserved.
//

import Foundation

class Friend{
    var known : Set<String>  = Set<String>()
    var me : String = ""
    
//    init(name : String){
//        self.me = name
//    }
    
    func add(name: String){
        self.known.insert(name)
    }
    
    func getFriendList() -> [String]{
        return Array(self.known)
    }
    
}
