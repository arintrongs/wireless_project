//
//  User.swift
//  IOSMultipeerConnectivityTutorial
//
//  Created by TomFoolery on 12/11/2562 BE.
//  Copyright © 2562 Arthur Knopper. All rights reserved.
//

import MessengerKit

struct User: MSGUser {
    
    var username: String
    
    var displayName: String
    
    var avatar: UIImage?
    
    var avatarUrl: URL?
    
    var isSender: Bool
    
}
