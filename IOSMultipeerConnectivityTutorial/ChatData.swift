//
//  ChatData.swift
//  IOSMultipeerConnectivityTutorial
//
//  Created by Natawat Kwanpoom on 10/11/19.
//  Copyright © 2019 Arthur Knopper. All rights reserved.
//

import Foundation
extension ChatData{
//    var messagesBox : [String: [Message]] = [:]
//
//    func appendChat(to: String, newMessage : Message) -> Int{
//        if self.messagesBox[to] == nil{
//            self.messagesBox[to] = []
//        }
//        self.messagesBox[to]!.append(newMessage)
//        return self.messagesBox[to]?.count ?? -1
//    }
//
    func saveChat() {
        print("load msg")
        UserDefaults.standard.set(messagesBox, forKey: "messageBox")
    }

    func loadChat() -> Int{
        print("load msg")
        if UserDefaults.standard.dictionary(forKey: "messageBox") != nil {
            self.messagesBox = UserDefaults.standard.dictionary(forKey: "messageBox") as! [String : [Message]]
        }
        else{
            let emptyDict = Dictionary<String, [Message]>()
            self.messagesBox = emptyDict
        }
        return self.messagesBox.count
    }

    
}

