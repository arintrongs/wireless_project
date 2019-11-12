//
//  Message.swift
//  IOSMultipeerConnectivityTutorial
//
//  Created by Natawat Kwanpoom on 10/11/19.
//  Copyright © 2019 Arthur Knopper. All rights reserved.
//

import Foundation

class Message {
    var sender : String
    var receiver : String
    var timestamp : Int64
    var data : String
    
    init(code : String){
        let messageArr = code.components(separatedBy: "$")
        self.sender = messageArr[0]
        self.receiver = messageArr[1]
        self.timestamp = Int64(messageArr[2])!
        self.data = messageArr[3]
    }
    
    init (sender: String, receiver: String,  timestamp: Int64, data: String){
        self.sender = sender
        self.receiver = receiver
        self.timestamp = timestamp
        self.data = data
    }
    
    func getString() -> String{
        var out : String = ""
        out += self.sender+"$"
        out += self.receiver+"$"
        out += String(self.timestamp)+"$"
        out += self.data
        return out
    }
    
    
}

class MessageBox{
    var box : [String: [Message]] = [:]
    
    func appendMsg(idx : String, data : Message) {
        if self.box[idx] == nil{
            self.box[idx] = []
        }
        self.box[idx]!.append(data)
    }
    
    func getReadyToSave() -> [String:[String]]{
        var dictionary : [String: [String]] = [:]
        for (k,v) in self.box{
            var l : [String] = []
            for m in v{
                l.append(m.getString())
            
            }
            print(l)
            dictionary[k] = l
        }
        return dictionary
    }
    
    func loadFromNS(loadedMsg : [String:[String]]){
        for (k,v) in loadedMsg{
            for msg in v{
                self.appendMsg(idx: k, data: Message(code : msg))
            }
        }
    }
    
    func getTimeStamp(from : String, to :String) -> Int64 {
        var max:Int64 = 0
        let all = (self.box[from] ?? []) + (self.box[to] ?? [])
        for msg in all {
            if msg.sender == from && msg.receiver == to{
                if msg.timestamp > max {
                    max = msg.timestamp
                }
            }
        }
        return max
    }
}
