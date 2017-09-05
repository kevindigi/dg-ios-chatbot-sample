//
//  Chat.swift
//  DGChatbotSample
//
//  Created by Kevin B. Adesara on 05/09/17.
//  Copyright © 2017 Digicorp. All rights reserved.
//

import Foundation

enum ChatType {
    case simple
    case card
}

struct Chat {
    var senderId:String!
    var senderDisplayName: String!
    var date:Date?
    var message: String!
    private(set) var chatType: ChatType
    
    var cardImageUrl: String?
    var cardActionTitle: String?
    var cardActionUrl: String?
    
    init(senderId: String!, senderDisplayName: String!, message: String!, date: Date!) {
        self.senderId = senderId
        self.senderDisplayName = senderDisplayName
        self.message = message
        self.date = date
        self.chatType = .simple
    }
    
    init(senderId: String!, senderDisplayName: String!, cardImageUrl: String?, message: String!, cardActionTitle: String?, cardActionUrl: String?, date: Date!) {
        
        self.senderId = senderId
        self.senderDisplayName = senderDisplayName
        self.message = message
        self.date = date
        self.chatType = .card
        
        self.cardImageUrl = cardImageUrl
        self.cardActionTitle = cardActionTitle
        self.cardActionUrl = cardActionUrl
    }
}
