//
//  ChatCardTableViewCell.swift
//  DGChatbotSample
//
//  Created by Kevin B. Adesara on 05/09/17.
//  Copyright © 2017 Digicorp. All rights reserved.
//

import UIKit
import SDWebImage

class ChatCardTableViewCell: ChatBaseTableViewCell {

    @IBOutlet weak var imgCard: UIImageView!
    @IBOutlet weak var lblChat: UILabel!
    @IBOutlet weak var btnCardAction: UIButton!
    
    override func update(_ chat: Chat?) {
        super.update(chat)
        imgCard.sd_setImage(with: URL(string: (chat?.cardImageUrl!)!))
        lblChat.text = chat?.message
        btnCardAction.setTitle(chat?.cardActionTitle, for: .normal)
    }

    @IBAction func cardAction(_ sender: UIButton) {
        if let cardActionUrl = self.chat.cardActionUrl {
            let url = URL(string: cardActionUrl)!
            UIApplication.shared.openURL(url)
        }
    }
}
