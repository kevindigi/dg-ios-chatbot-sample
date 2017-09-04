//
//  ViewController.swift
//  DGChatbotSample
//
//  Created by Kevin B. Adesara on 04/09/17.
//  Copyright © 2017 Digicorp. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import ApiAI
import SwiftyJSON

class ViewController: JSQMessagesViewController {
    
    fileprivate var messages: [JSQMessage] = []
    fileprivate var outgoingBubbleImage: JSQMessagesBubbleImage!
    fileprivate var incomingBubbleImage: JSQMessagesBubbleImage!
    fileprivate var senderAvatarImage: JSQMessagesAvatarImage!
    fileprivate var chatbotAvatarImage: JSQMessagesAvatarImage!
    
    typealias ChatbotResponseCallback = (_ request: AIRequest, _ error:Error?, _ response: JSON?) -> Void

    override func viewDidLoad() {
        super.viewDidLoad()
        self.senderId = "kevin"
        self.senderDisplayName = "Kevin"
        
        /**
         *  Create message bubble images objects.
         *
         *  Be sure to create your bubble images one time and reuse them for good performance.
         *
         */
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImage = bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
        incomingBubbleImage = bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
        
        senderAvatarImage = JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: "KA", backgroundColor: UIColor.jsq_messageBubbleLightGray().withAlphaComponent(0.5), textColor: UIColor.jsq_messageBubbleGreen(), font: UIFont.systemFont(ofSize: 10), diameter: 28)
        chatbotAvatarImage = JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: "DG", backgroundColor: UIColor.jsq_messageBubbleLightGray(), textColor: UIColor.jsq_messageBubbleBlue(), font: UIFont.systemFont(ofSize: 10), diameter: 28)
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        self.messages.append(message!)
        self.finishSendingMessage(animated: true)
        self.showTypingIndicator = true
        sendChatRequestToBot(with: text) { (request, error, response) in
            self.showTypingIndicator = false
            guard let response = response else {
                print("error : \(String(describing: error))")
                return
            }
            
            let replyMessages = response["result"]["fulfillment"]["messages"].arrayValue
            for replyMessage in replyMessages {
                switch replyMessage["type"].intValue {
                case 0: // simple text message
                    if replyMessage["speech"].stringValue.trimmingCharacters(in: .whitespacesAndNewlines).characters.count > 0 {
                        let botReplyMessage = JSQMessage(senderId: "dg_bot", senderDisplayName: "DG-CHATBOT", date: Date(), text: replyMessage["speech"].stringValue)
                        self.messages.append(botReplyMessage!)
                    }
                // case 1: // card message
                    
                default:
                    print("will handle other message cases later")
                }
            }
            
            
            
            
            self.finishReceivingMessage(animated: true)
        }
        
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        let alert = UIAlertController(title: "Alert", message: "Under Development...", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)   
    }
    
    private func sendChatRequestToBot(with text: String, cb: @escaping ChatbotResponseCallback) {
        let request = ApiAI.shared().textRequest()
        request?.query = [text]
        request?.setCompletionBlockSuccess({ (request, response) in
            //let response = response as! AIResponse
            
            let jsonResponse = JSON(response ?? "")
            print(jsonResponse)
            
            if jsonResponse["status"]["code"].intValue == 200 {
                cb(request!, nil, jsonResponse)
            } else {
                // handle error
            }
            
        }, failure: { (request, error) in
            print(error.debugDescription)
            cb(request!, error, nil)
        })
        ApiAI.shared().enqueue(request)
    }
}

// MARK: - JSQMessages CollectionView DataSource
extension ViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        /**
         *  Override point for customizing cells
         */
        let messageCell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        /**
         *  Configure almost *anything* on the cell
         *
         *  Text colors, label text, label colors, etc.
         *
         *
         *  DO NOT set `cell.textView.font` !
         *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
         *
         *
         *  DO NOT manipulate cell layout information!
         *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
         */
        
        messageCell.textView.textColor = UIColor.white
        
        return messageCell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return self.messages[indexPath.row]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let message = self.messages[indexPath.row]
        return message.senderId == self.senderId ? outgoingBubbleImage : incomingBubbleImage
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let message = self.messages[indexPath.row]
        return message.senderId == self.senderId ? senderAvatarImage : chatbotAvatarImage
    }
}

