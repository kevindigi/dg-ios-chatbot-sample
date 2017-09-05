//
//  Chat.swift
//  DGChatbotSample
//
//  Created by Kevin B. Adesara on 05/09/17.
//  Copyright © 2017 Digicorp. All rights reserved.
//

import Foundation

public enum ChatType {
    case simple
    case card
}

struct Chat {
    var senderId:String!
    var senderDisplayName: String!
    var date:Date?
    var message: String!
    var chatType: ChatType!
    
    var cardImageUrl: String?
    var cardActionTitle: String?
    var cardActionUrl: String?
    
    init(senderId: String!, senderDisplayName: String!, message: String!, date: Date!, chatType: ChatType!) {
        self.senderId = senderId
        self.senderDisplayName = senderDisplayName
        self.message = message
        self.date = date
        self.chatType = chatType
    }
}
