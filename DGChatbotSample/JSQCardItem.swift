//
//  CardMediaItem.swift
//  DGChatbotSample
//
//  Created by Kevin B. Adesara on 04/09/17.
//  Copyright © 2017 Digicorp. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class JSQCardItem: NSObject, JSQMessageData {
    
    var sid: String!
    var sDisplayName: String!
    var dt: Date!
    
    var imageUrl: String!
    var textDescription: String!
    
    var action1Text: String?
    var action1Url: String?
    
    init(senderId: String,
         senderDisplayName: String,
         date: Date!,
         imageUrl: String?,
         textDescription: String,
         action1Text: String?,
         action1Url: String?) {
        
        self.sid = senderId
        self.sDisplayName = senderDisplayName
        self.dt = date
        
        self.imageUrl = imageUrl
        self.textDescription = textDescription
        
        self.action1Url = action1Url
        self.action1Text = action1Text
    }
    
    func senderId() -> String! {
        return sid
    }
    
    func senderDisplayName() -> String! {
        return sDisplayName
    }
    
    func isMediaMessage() -> Bool {
        return false
    }
    
    func text() -> String! {
        return textDescription
    }
    
    func date() -> Date! {
        return dt
    }
    
    func messageHash() -> UInt {
        return UInt(self.senderId().hash ^ self.imageUrl.hash ^ self.textDescription.hash);
    }
}
