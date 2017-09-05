//
//  ChatTableViewCell.swift
//  DGChatbotSample
//
//  Created by Kevin B. Adesara on 05/09/17.
//  Copyright © 2017 Digicorp. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
    @IBOutlet weak var lblChat: UILabel!
    
    func update(_ chat: Chat) {
        lblChat.text = chat.message
    }
}
