//
//  MainCollectionVC.swift
//  DGChatbotSample
//
//  Created by Kevin B. Adesara on 05/09/17.
//  Copyright © 2017 Digicorp. All rights reserved.
//

import UIKit
import ApiAI
import SwiftyJSON

class MainVC: UIViewController {
    
    let userId: String = "kevin"
    let botId: String = "dg_bot"
    
    typealias ChatbotResponseCallback = (_ request: AIRequest, _ error:Error?, _ response: JSON?) -> Void
    
    @IBOutlet weak var tblChat: UITableView!
    
    @IBOutlet weak var vBottomBarContainer: UIView!    
    @IBOutlet weak var vBottomBarBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var btnHideKeyboard: UIButton!
    
    // textview
    let minTextViewHeight: CGFloat = 34
    let maxTextViewHeight: CGFloat = 96
    @IBOutlet weak var txtQuestion: UITextView!
    @IBOutlet weak var txtQuestionHeightConstraint: NSLayoutConstraint?
    
    // chat data
    var chatData: [Chat] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupControls()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        removeKeyboardNotifications()
        addKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeKeyboardNotifications()
        super.viewWillDisappear(animated)
    }
    
    private func setupControls() {
        tblChat.rowHeight = UITableViewAutomaticDimension
        tblChat.estimatedRowHeight = 44
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainVC.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        txtQuestion.resignFirstResponder()
    }
    
    private func addKeyboardNotifications() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    private func removeKeyboardNotifications() {
        let center = NotificationCenter.default
        center.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        center.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    private func endSendingChat() {
        txtQuestion.text = ""
        textViewDidChange(txtQuestion)
        let indexPath = IndexPath(row: chatData.count-1, section: 0)
        updateTableInsertion(indexPaths: [indexPath])
        tblChat.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    private func endReceivingChat(indexPaths: [IndexPath]) {
        updateTableInsertion(indexPaths: indexPaths)
        tblChat.scrollToRow(at: indexPaths[0], at: .top, animated: true)
    }
    
    private func updateTableInsertion(indexPaths: [IndexPath]) {
        tblChat.beginUpdates()
        tblChat.insertRows(at: indexPaths, with: UITableViewRowAnimation.top)
        tblChat.endUpdates()
        tblChat.reloadData()
    }
    
    private func sendChatRequestToBot(with text: String, cb: @escaping ChatbotResponseCallback) {
        let request = ApiAI.shared().textRequest()
        request?.query = [text]
        request?.setCompletionBlockSuccess({ (request, response) in
            let jsonResponse = JSON(response ?? "")
            print(jsonResponse)
            cb(request!, nil, jsonResponse)
        }, failure: { (request, error) in
            print(error.debugDescription)
            cb(request!, error, nil)
        })
        ApiAI.shared().enqueue(request)
    }
    
    // MARK: - Keyboard show/hide methods
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            print(keyboardSize)
            if vBottomBarBottomConstraint.constant == 0 {
                vBottomBarBottomConstraint.constant = keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        if let _ = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if vBottomBarBottomConstraint.constant != 0 {
                vBottomBarBottomConstraint.constant = 0
            }
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func sendAction(_ sender: UIButton) {
        let chat = Chat(senderId: userId, senderDisplayName: "Kevin", message: txtQuestion.text, date: Date())
        chatData.append(chat)
        
        endSendingChat()
        
        sendChatRequestToBot(with: chat.message) { (request, error, response) in
            guard let response = response else {
                print("error : \(String(describing: error))")
                return
            }
            
            let replyMessages = response["result"]["fulfillment"]["messages"].arrayValue
            var indexPaths:[IndexPath] = []
            for replyMessage in replyMessages {
                switch replyMessage["type"].intValue {
                case 0: // simple text message
                    if replyMessage["speech"].stringValue.trimmingCharacters(in: .whitespacesAndNewlines).characters.count > 0 {
                        let botChat = Chat(senderId: self.botId, senderDisplayName: "Bot", message: replyMessage["speech"].stringValue, date: Date())
                        self.chatData.append(botChat)
                        indexPaths.append(IndexPath(row: self.chatData.count-1, section: 0))
                    }
                case 1: // card message
                    let botChat = Chat(senderId: self.botId, senderDisplayName: "Bot", cardImageUrl: replyMessage["imageUrl"].string, message: replyMessage["title"].stringValue, cardActionTitle: replyMessage["buttons"][0]["text"].stringValue, cardActionUrl: replyMessage["buttons"][0]["postback"].stringValue, date: Date())
                    self.chatData.append(botChat)
                    indexPaths.append(IndexPath(row: self.chatData.count-1, section: 0))
                default:
                    print("will consider other types later")
                }
            }
            self.endReceivingChat(indexPaths: indexPaths)
        }
    }
}

extension MainVC: UITableViewDelegate, UITableViewDataSource {
    
    func cellReuseIdentifier(for chat: Chat) -> String {
        var reuseIdentifier = ""
        if chat.senderId == userId {
            reuseIdentifier = "UserSimpleCell"
        } else {
            // bot chat
            switch chat.chatType {
            case .card:
                reuseIdentifier = "BotCardCell"
            default:
                reuseIdentifier = "BotSimpleCell"
            }
        }
        return reuseIdentifier
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatData.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let chat = self.chatData[indexPath.row]
        let reuseIdentifier = cellReuseIdentifier(for: chat)
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ChatBaseTableViewCell
        cell.update(chat)
        return cell
    }
}

// MARK: - TextView delegate

extension MainVC: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        var height = ceil(textView.contentSize.height) // ceil to avoid decimal
        
        if (height < minTextViewHeight + 5) { // min cap, + 5 to avoid tiny height difference at min height
            height = minTextViewHeight
        }
        if (height > maxTextViewHeight) { // max cap
            height = maxTextViewHeight
        }
        
        if height != txtQuestionHeightConstraint?.constant { // set when height changed
            txtQuestionHeightConstraint?.constant = height // change the value of NSLayoutConstraint
            textView.setContentOffset(CGPoint.zero, animated: false) // scroll to top to avoid "wrong contentOffset" artefact when line count changes
        }
        
        if textView.text.characters.count >= 1 {
            btnSend?.isEnabled = true
        } else {
            btnSend?.isEnabled = false
            txtQuestionHeightConstraint?.constant = minTextViewHeight
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.characters.count == 0 {
            btnSend?.isEnabled = false
        } else {
            btnSend?.isEnabled = true
        }
    }
}
