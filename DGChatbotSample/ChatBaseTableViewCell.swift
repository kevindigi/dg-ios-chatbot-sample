//
//  ChatBaseTableViewCell.swift
//  DGChatbotSample
//
//  Created by Kevin B. Adesara on 05/09/17.
//  Copyright © 2017 Digicorp. All rights reserved.
//

import UIKit

class ChatBaseTableViewCell: UITableViewCell {

    var chat: Chat!
    
    public func update(_ chat: Chat!) {
        self.chat = chat
    }

}
