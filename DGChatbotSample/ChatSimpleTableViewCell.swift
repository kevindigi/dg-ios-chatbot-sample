//
//  ChatTableViewCell.swift
//  DGChatbotSample
//
//  Created by Kevin B. Adesara on 05/09/17.
//  Copyright © 2017 Digicorp. All rights reserved.
//

import UIKit

class ChatSimpleTableViewCell: ChatBaseTableViewCell {
    @IBOutlet weak var lblChat: UILabel!
    
    override func update(_ chat: Chat?) {
        super.update(chat)
        lblChat.text = chat?.message
    }
}
