//
//  ViewController.swift
//  IOSMultipeerConnectivityTutorial
//
//  Created by Arthur Knopper on 17/05/2019.
//  Copyright © 2019 Arthur Knopper. All rights reserved.
//

import UIKit
import MultipeerConnectivity


class ViewController: UIViewController, MCSessionDelegate, MCBrowserViewControllerDelegate {
    @IBOutlet weak var chatView: UITextView!
    @IBOutlet weak var inputMessage: UITextField!
    @IBOutlet weak var inputUid: UITextField!
    @IBOutlet weak var inputChatUid: UITextField!
    
    var username : String = ""
    var chatWith : String = ""
    var tmp : Int = 0
    
    var isConnected = false
    
    var ts: Int64 = 0
    var peerID: MCPeerID!
    var uid: String = "simul"
    var currentChatUID: String = "ipad"
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCAdvertiserAssistant!
    var messageToSend: String!
    var messagesBox: MessageBox = MessageBox()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(showConnectionMenu))
        
        print(self.username)
        
        
        self.setupAdhoc()
        self.setupChat()
        print("load in to main chat")
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("save")
        print(self.saveChat())
    }
    
    func setupChat(){
        //set username
        self.username = UserDefaults.standard.string(forKey: "username") ?? ""
        print(self.username)
        
        //assign to adhoc uid
        self.inputUid.text = self.username
        self.inputChatUid.text = self.chatWith
        
        print("last chat", self.loadChat())
        
        ts = max(self.messagesBox.getTimeStamp(from: self.username, to: self.chatWith), self.messagesBox.getTimeStamp(from: self.chatWith, to: self.username))
        
    }
   
    func setupAdhoc(){
        //Adhoc part
        peerID = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
        
    }
    
    func testSendMsg(){
        let newMessage = Message(sender: self.uid, receiver: self.currentChatUID, timestamp: self.ts, data: inputMessage.text!)
        
        self.messagesBox.appendMsg(idx: currentChatUID, data: newMessage)
        
        self.updateTextView()
        inputMessage.text = ""
        self.ts += 1
        
        
    }
    
    @IBAction func tapSendButton(_ sender: Any) {
        if inputMessage.text! == "" {
            return
        }
        
        if self.isConnected == false {
            print("Please connect to peer")
            return
        }
        
        self.chatView.text = self.chatView.text + self.inputMessage.text! + "\n"
       
        // Setup UID
        self.uid = inputUid.text!
        self.currentChatUID = inputChatUid.text!
        print(self.uid, self.currentChatUID)
        
//        self.testSendMsg()
        
        
        messageToSend = "\(self.uid):\(self.currentChatUID):\(self.ts):\(inputMessage.text!)"
        let message = messageToSend.data(using: String.Encoding.utf8, allowLossyConversion: false)
        
        do {
            try self.mcSession.send(message!, toPeers: self.mcSession.connectedPeers, with: .unreliable)
            let newMessage = Message(sender: self.uid, receiver: self.currentChatUID, timestamp: self.ts, data: inputMessage.text!)
            
            self.messagesBox.appendMsg(idx: self.currentChatUID, data: newMessage)
            
            self.updateTextView()
            inputMessage.text = ""
            self.ts += 1
            
        }
        catch {
            print("Error sending message")
        }
    }
    
    
    @objc func showConnectionMenu() {
        let ac = UIAlertController(title: "Connection Menu", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Host a session", style: .default, handler: hostSession))
        ac.addAction(UIAlertAction(title: "Join a session", style: .default, handler: joinSession))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if let popoverController = ac.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.maxX - 150, y: 20, width: 0, height: 0)
            //        popoverController.permittedArrowDirections = [UIPopoverArrowDirection.up, UIPopoverArrowDirection.right]
            popoverController.permittedArrowDirections = []
        }
        present(ac, animated: true)
    }
    
    func hostSession(action: UIAlertAction) {
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "ioscreator-chat", discoveryInfo: nil, session: mcSession)
        mcAdvertiserAssistant.start()
    }
    
    func joinSession(action: UIAlertAction) {
        let mcBrowser = MCBrowserViewController(serviceType: "ioscreator-chat", session: mcSession)
        mcBrowser.delegate = self
        present(mcBrowser, animated: true)
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            self.isConnected = true
            self.syncMessages()
            print("Connected: \(peerID.displayName)")
        case .connecting:
            print("Connecting: \(peerID.displayName)")
        case .notConnected:
            self.isConnected = false
            print("Not Connected: \(peerID.displayName)")
        @unknown default:
            print("fatal error")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async { [unowned self] in
            // send chat message
            let message = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)! as String
            
            self.onMessageReceived(data: message)
            
            self.updateTextView()
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func updateTextView(){
        var text = ""
        let sentMessages: [Message] = self.messagesBox.box[self.currentChatUID] ?? []
        let receivedMessages: [Message] = self.messagesBox.box[self.uid] ?? []
        let messages : [Message] = (sentMessages + receivedMessages).sorted {  $0.timestamp < $1.timestamp }
        
        for message:Message in messages {
            if (message.sender == self.uid && message.receiver == self.currentChatUID) || (message.sender == self.currentChatUID && message.receiver == self.uid){
                text += "\(message.sender)  w: \(message.data)\n"
            }
        }
        
        self.chatView.text = text
    
        
    }
    
    func syncMessages(){
        for (_, messages) in self.messagesBox.box{
            for message in messages{
                do {
                    let messageToSend = "\(message.sender):\(message.receiver):\(message.timestamp):\(message.data)"
                    let encoded = messageToSend.data(using: String.Encoding.utf8, allowLossyConversion: false)
                    try self.mcSession.send(encoded!, toPeers: self.mcSession.connectedPeers, with: .unreliable)
                }
                catch {
                    print("Error Syncing message")
                }
            }
        }
    }
    
    func onMessageReceived(data : String){
        let messageArr = data.components(separatedBy: ":")
        let sender = messageArr[0]
        let receiver = messageArr[1]
        var ts = Int64(messageArr[2])!
        let data = messageArr[3]
        
        if ts <= self.ts{
            ts = self.ts + 1
        }
        
        self.ts += 1
        
        let newMessage = Message(sender: sender, receiver: receiver,  timestamp: ts, data: data)
        
        var check = true
        
        if self.messagesBox.box[receiver] == nil{
            self.messagesBox.box[receiver] = []
        }
        for message in self.messagesBox.box[receiver]!{
            if message.data == newMessage.data && message.timestamp == newMessage.timestamp {
                check = false
            }
        }
        if check{
            self.messagesBox.appendMsg(idx: receiver, data: newMessage)
        }
        
        self.updateTextView()
    }
    
    
    
    
    func saveChat() {
        print("save msg")
        // Save to User Defaults
        UserDefaults.standard.set(self.messagesBox.getReadyToSave(), forKey: "msg")
    }

    
    func loadChat() -> Int{
        print("load msg")
        if UserDefaults.standard.dictionary(forKey: "msg") != nil {
            let loadedMsg = UserDefaults.standard.dictionary(forKey: "msg") as! [String : [String]]
            self.messagesBox.loadFromNS(loadedMsg: loadedMsg)
        }
        else{
            self.messagesBox = MessageBox()
        }
        self.updateTextView()
        return self.messagesBox.box.count
    }
}


