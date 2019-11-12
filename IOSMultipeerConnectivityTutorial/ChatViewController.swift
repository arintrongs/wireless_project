//
//  ChatViewController.swift
//  Messenger
//
//  Created by Stephen Radford on 08/06/2018.
//  Copyright © 2018 Cocoon Development Ltd. All rights reserved.
//

import UIKit
import MessengerKit
import MultipeerConnectivity

class ChatViewController: MSGMessengerViewController, MCSessionDelegate, MCBrowserViewControllerDelegate {
    
    var tmp : Int = 0
    
    var isConnected = false
    
    var ts: Int64 = 0
    var peerID: MCPeerID!
    var chatWith : String = ""
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCAdvertiserAssistant!
    var messageToSend: String!
    var messagesBox: MessageBox = MessageBox()
    
    var sender : User!
    var receiver : User!
    
    lazy var messages: [[MSGMessage]] = {return []}()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(showConnectionMenu))
        
        self.setupAdhoc()
        self.setupChat()
        
        dataSource = self
        delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        collectionView.scrollToBottom(animated: false)
    }
    override func viewWillDisappear(_ animated: Bool) {
        print("save")
        print(self.saveChat())
        UserDefaults.standard.set(self.messagesBox.getId(), forKey: "message_id")

    }
    
    func setupChat(){
        let username = UserDefaults.standard.string(forKey: "username") ?? ""
        self.sender = User(username: username, displayName: username, isSender: true)
        self.receiver = User(username: self.chatWith, displayName: self.chatWith, isSender: false)
        
        title = self.receiver.username
        
        self.ts = max(self.messagesBox.getTimeStamp(from: username, to: self.chatWith), self.messagesBox.getTimeStamp(from: self.chatWith, to: username))
        print("last chat", self.loadChat())
    }
    
    func setupAdhoc(){
        //Adhoc part
        peerID = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
        
    }
    
    override func inputViewPrimaryActionTriggered(inputView: MSGInputView) {
        
        if inputView.message.count == 0 {
            return
        }
        
        let id = self.messagesBox.getId()
        
        let body: MSGMessageBody = (inputView.message.containsOnlyEmoji && inputView.message.count < 5) ? .emoji(inputView.message) : .text(inputView.message)
        
        let message = MSGMessage(id: Int(id), body: body, user: sender, sentAt: Date())
        
        let newMessage = Message(id: id, sender: self.sender.username, receiver: self.receiver.username,  timestamp: ts, data: inputView.message)
        
        self.messagesBox.appendMsg(idx: self.receiver.username, data: newMessage)
        
        let messageToSend = "\(id):\(self.sender.username):\(self.receiver.username):\(self.ts):\(inputView.message)"
        let encoded = messageToSend.data(using: String.Encoding.utf8, allowLossyConversion: false)
        
        do {
            try self.mcSession.send(encoded!, toPeers: self.mcSession.connectedPeers, with: .unreliable)
            self.ts += 1
            self.messagesBox.incId()
        }
        catch {
            print("Error sending message")
        }
        insert(message)
        
    }
    
    override func insert(_ message: MSGMessage) {
        
        collectionView.performBatchUpdates({
            if let lastSection = self.messages.last, let lastMessage = lastSection.last, lastMessage.user.displayName == message.user.displayName {
                self.messages[self.messages.count - 1].append(message)
                
                let sectionIndex = self.messages.count - 1
                let itemIndex = self.messages[sectionIndex].count - 1
                self.collectionView.insertItems(at: [IndexPath(item: itemIndex, section: sectionIndex)])
                
            } else {
                self.messages.append([message])
                let sectionIndex = self.messages.count - 1
                self.collectionView.insertSections([sectionIndex])
            }
        }, completion: { (_) in
            self.collectionView.scrollToBottom(animated: true)
            self.collectionView.layoutTypingLabelIfNeeded()
        })
        
    }
    
    override func insert(_ messages: [MSGMessage], callback: (() -> Void)? = nil) {
        
        collectionView.performBatchUpdates({
            for message in messages {
                if let lastSection = self.messages.last, let lastMessage = lastSection.last, lastMessage.user.displayName == message.user.displayName {
                    self.messages[self.messages.count - 1].append(message)
                    
                    let sectionIndex = self.messages.count - 1
                    let itemIndex = self.messages[sectionIndex].count - 1
                    self.collectionView.insertItems(at: [IndexPath(item: itemIndex, section: sectionIndex)])
                    
                } else {
                    self.messages.append([message])
                    let sectionIndex = self.messages.count - 1
                    self.collectionView.insertSections([sectionIndex])
                }
            }
        }, completion: { (_) in
            self.collectionView.scrollToBottom(animated: false)
            self.collectionView.layoutTypingLabelIfNeeded()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                callback?()
            }
        })
        
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
            let message = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)! as String
            self.onMessageReceived(data: message)
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
        let sentMessages: [Message] = self.messagesBox.box[self.receiver.username] ?? []
        let receivedMessages: [Message] = self.messagesBox.box[self.sender.username] ?? []
        let messages : [Message] = (sentMessages + receivedMessages).sorted {  $0.timestamp < $1.timestamp }
        
        for message:Message in messages {
            
            if (message.sender == self.sender.username && message.receiver == self.receiver.username){
                let body: MSGMessageBody = (message.data.containsOnlyEmoji && message.data.count < 5) ? .emoji(message.data) : .text(message.data)
                insert(MSGMessage(id: Int(message.id), body: body, user: self.sender, sentAt: Date()))
            }
            if( message.sender == self.receiver.username && message.receiver == self.sender.username ){
                let body: MSGMessageBody = (message.data.containsOnlyEmoji && message.data.count < 5) ? .emoji(message.data) : .text(message.data)
                insert(MSGMessage(id: Int(message.id), body: body, user: self.receiver, sentAt: Date()))
            }
        }
        
        
        
        
    }
    
    func syncMessages(){
        for (_, messages) in self.messagesBox.box{
            for message in messages{
                do {
                    let messageToSend = "\(message.id):\(message.sender):\(message.receiver):\(message.timestamp):\(message.data)"
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
        let id = Int64(messageArr[0])!
        let sender = messageArr[1]
        let receiver = messageArr[2]
        var ts = Int64(messageArr[3])!
        let data = messageArr[4]
        
        
        
        var newMessage = Message(id: id, sender: sender, receiver: receiver,  timestamp: ts, data: data)
        
        var check = true
        
        if self.messagesBox.box[receiver] == nil{
            self.messagesBox.box[receiver] = []
        }
        for message in self.messagesBox.box[receiver]!{
            if message.id == newMessage.id && message.sender == newMessage.sender && message.receiver == newMessage.receiver && message.data == newMessage.data {
                check = false
            }
        }
        if check{
            if ts <= self.ts{
                ts = self.ts + 1
            }
            
            self.ts += 1
            
            self.messagesBox.appendMsg(idx: receiver, data: newMessage)
            
            newMessage = Message(id: id, sender: sender, receiver: receiver,  timestamp: ts, data: data)
            
            if(sender == self.receiver.username && receiver == self.sender.username ){
                let body: MSGMessageBody = (data.containsOnlyEmoji && data.count < 5) ? .emoji(data) : .text(data)
                insert(MSGMessage(id: Int(id), body: body, user: self.receiver, sentAt: Date()))
            }
            if(sender == self.sender.username && receiver == self.receiver.username){
                let body: MSGMessageBody = (data.containsOnlyEmoji && data.count < 5) ? .emoji(data) : .text(data)
                insert(MSGMessage(id: Int(id), body: body, user: self.sender, sentAt: Date()))
            }
        }
        
        
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
        DispatchQueue.main.async { [unowned self] in
            self.updateTextView()
        }
        return self.messagesBox.box.count
    }
    
}

// MARK: - Overrides

extension ChatViewController {
    
}

// MARK: - MSGDataSource

extension ChatViewController: MSGDataSource {
    
    func numberOfSections() -> Int {
        return messages.count
    }
    
    func numberOfMessages(in section: Int) -> Int {
        return messages[section].count
    }
    
    func message(for indexPath: IndexPath) -> MSGMessage {
        return messages[indexPath.section][indexPath.item]
    }
    
    func footerTitle(for section: Int) -> String? {
        return ""
    }
    
    func headerTitle(for section: Int) -> String? {
        return messages[section].first?.user.displayName
    }
    
}

// MARK: - MSGDelegate

extension ChatViewController: MSGDelegate {
    
    func linkTapped(url: URL) {
        print("Link tapped:", url)
    }
    
    func avatarTapped(for user: MSGUser) {
        print("Avatar tapped:", user)
    }
    
    func tapReceived(for message: MSGMessage) {
        print("Tapped: ", message)
    }
    
    func longPressReceieved(for message: MSGMessage) {
        print("Long press:", message)
    }
    
    func shouldDisplaySafari(for url: URL) -> Bool {
        return true
    }
    
    func shouldOpen(url: URL) -> Bool {
        return true
    }
    
}

// Mark: - Date Formatter
extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
}
