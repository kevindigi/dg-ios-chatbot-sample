//
//  CardCell.swift
//  DGChatbotSample
//
//  Created by Kevin B. Adesara on 04/09/17.
//  Copyright © 2017 Digicorp. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import SDWebImage

class CardCell: UICollectionViewCell {
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var btnAction1: UIButton!
    
    @IBOutlet weak var cellTopLabel: JSQMessagesLabel?
    @IBOutlet weak var messageBubbleTopLabel: JSQMessagesLabel?
    @IBOutlet weak var cellBottomLabel: JSQMessagesLabel?
    @IBOutlet weak var messageBubbleContainerView: UIView?
    @IBOutlet weak var messageBubbleImageView: UIImageView?
    @IBOutlet weak var textView: JSQMessagesCellTextView!
    @IBOutlet weak var avatarImageView: UIImageView?
    @IBOutlet weak var avatarContainerView: UIView?
    
    private var item: JSQCardItem!
    
    class func nib() -> UINib {
        return UINib (nibName: "CardCell", bundle: Bundle.main)
    }
    
    class func cellReuseIdentifier() -> String {
        return "CardCell"
    }
    
    func update(_ item: JSQCardItem) {
        self.item = item
        self.textView.text = item.textDescription
        self.img.sd_setImage(with: URL(string: item.imageUrl))
    }
    
    class func heightForCard(item: JSQCardItem, width: CGFloat) -> CGFloat {
        let viewArray = Bundle.main.loadNibNamed("CardCell", owner: nil, options: nil)
        let cell: CardCell = (viewArray![0] as? CardCell)!
        
        cell.update(item)
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        
        cell.bounds = CGRect(x: 0.0, y: 0.0, width: width, height: cell.bounds.height)
        
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        var height = cell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        
        height += 1.0
        return height
    }
}
