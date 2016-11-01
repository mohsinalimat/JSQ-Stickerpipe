//
//  ViewController.swift
//  AntichatDemo
//
//  Created by vlad on 10/24/16.
//  Copyright © 2016 com.908. All rights reserved.
//

import UIKit

class ViewController: JSQMessagesViewController, STKStickerControllerDelegate {
    var stickerController: STKStickerController!

    override func viewDidLoad() {
        super.viewDidLoad()

        let statusBar = UIView()
        statusBar.translatesAutoresizingMaskIntoConstraints = false
        statusBar.backgroundColor = UIColor.white
        statusBar.alpha = 0.95
        view.addSubview(statusBar)
        
        statusBar.addConstraint(NSLayoutConstraint(item: statusBar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 20.0))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[statusBar]|", options: [], metrics: nil, views: ["statusBar": statusBar]))
        view.addConstraint(NSLayoutConstraint(item: statusBar, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0))

        changeStyle()
        
        STKStickersManager.initWithApiKey("a575ae0e0b50ccc8ced80cabb9e20984")
        STKStickersManager.setStartTimeInterval()
        STKStickersManager.setUserKey(userId())

        stickerController = STKStickerController()
        stickerController.delegate = self
        stickerController.textInputView = keyboardController.textView

        addHardcodeData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        changeStyle()
        collectionView.reloadData()

        keyboardController.textView.becomeFirstResponder()
        
        collectionView.collectionViewLayout.minimumLineSpacing = 10
    }

    private func changeStyle() {
        let outgoingColor = UIColor(red:0.60, green:0.36, blue:0.71, alpha:1.00)
        let incomingColor = UIColor(red:0.95, green:0.61, blue:0.17, alpha:1.00)
        
        outgoingBubbleImage = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: outgoingColor)!
        incomingBubbleImage = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: incomingColor)!
        
        collectionView.backgroundColor = UIColor.black
    }

    private func addHardcodeData() {
        let yesterday = Date(timeInterval: -60*60*24, since: Date())
        let preYesterday = Date(timeInterval: -60*60*24*2, since: Date())

        messages.append(JSQMessage(senderId: incomingSenderId, senderDisplayName: incomingDisplayName, date: preYesterday, text: "Customs in Toronto"))
        messages.append(JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: preYesterday, text: "Sweet. Thx brah"))
        
        messages.append(JSQMessage(senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: yesterday, text: "Sup b"))
        messages.append(JSQMessage(senderId: self.incomingSenderId, senderDisplayName: self.incomingDisplayName, date: yesterday, text: "Just chillin' and build'. Assets for the PSDs are almost done. Just have about a dozen items left."))
    }

    private func addAndShowSuggests() {
        let layout = UICollectionViewFlowLayout()

        let suggestCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        suggestCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(suggestCollectionView)

        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|suggestCollectionView|", options: [], metrics: nil, views: ["suggestCollectionView": suggestCollectionView]))
        
        suggestCollectionView.addConstraint(NSLayoutConstraint(item: suggestCollectionView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 80.0))
        
        view.addConstraint(NSLayoutConstraint(item: suggestCollectionView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0))

        stickerController.suggestCollectionView = suggestCollectionView
        stickerController.showSuggests = true
    }

    private func userId() -> String? {
        let kKeychainKey = "a575ae0e0b50ccc8ced80cabb9e20984"
        
        if let curPassData = SAMKeychain.passwordData(forService: kKeychainKey, account: "Antichat") {
            return String.init(data: curPassData, encoding: String.Encoding.utf8)
        } else {
            let currentDeviceId = UIDevice.current.identifierForVendor?.uuidString
            
            SAMKeychain.setPassword(currentDeviceId!, forService: kKeychainKey, account: "Antichat")
            
            return currentDeviceId
        }
    }

    func showStickersCollection() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.scrollToBottom(animated: true)
        }
    }

    private class AntichatMediaItem: JSQPhotoMediaItem {
        override func mediaView() -> UIView! {
            let view = super.mediaView()

            view?.contentMode = .scaleAspectFit

            return view
        }
    }

    func stickerController(_ stickerController: STKStickerController!, didSelectStickerWithMessage message: String!) {
        stickerController.imageManager.getImageForStickerMessage(message, withProgress: nil) {
            (error: Error?, image: UIImage?) in
            let mediaData = AntichatMediaItem(image: image!)

            if let imageView = mediaData?.mediaView() as? UIImageView {
                imageView.contentMode = .scaleAspectFit
            }

            let msg = JSQMessage(senderId: self.senderId, displayName: self.senderDisplayName, media: mediaData)!
            
            self.messages.append(msg)
            
            self.finishSendingMessage(animated: true)
        }
    }

    public func stickerControllerViewControllerForPresentingModalView() -> UIViewController! {
        return self
    }
    

    var incomingDisplayName = "Mona"
    var incomingSenderId = "Mona"

    var messages = [JSQMessage]()
    
    
    var outgoingBubbleImage: JSQMessagesBubbleImage!
    var incomingBubbleImage: JSQMessagesBubbleImage!


    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }


    // MARK: JSQMessagesCollectionViewDataSource

    override var senderDisplayName: String! {
        get {
            return "Me"
        }
        set {
            super.senderDisplayName = newValue
        }
    }

    override var senderId: String! {
        get {
            return "senderId"
        }
        set {
            super.senderDisplayName = newValue
        }
    }

    private func textForCell(atIndexPath indexPath: IndexPath) -> String? {
        let message = messages[indexPath.row]
        let components = NSCalendar.current.dateComponents([.day , .month , .year], from: message.date)
        let previousDay = indexPath.row == 0 ? nil : messages[indexPath.row - 1].date
        
        if previousDay == nil || NSCalendar.current.dateComponents([.day], from: previousDay!).day != components.day {
            let dateString = "\(components.day!).\(components.month!).\(components.year!)"
            
            return dateString
        }
        
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let text = textForCell(atIndexPath: indexPath)
        
        return text == nil ? nil : NSAttributedString(string: text!)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return textForCell(atIndexPath: indexPath) == nil ? 0 : 20.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didDeleteMessageAt indexPath: IndexPath!) {

    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        var bubble: UIImage

        if messages[indexPath.row].senderId == senderId {
            bubble = outgoingBubbleImage.messageBubbleImage
        } else {
            bubble = incomingBubbleImage.messageBubbleImage
        }

        return JSQMessagesBubbleImage(messageBubble: bubble, highlightedImage: bubble)
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        var img: UIImage

        if messages[indexPath.row].senderId == senderId {
            img = UIImage(named: "di.png")!
        } else {
            img = UIImage(named: "mona.png")!
        }

        let avatar = JSQMessagesAvatarImageFactory.circularAvatarImage(img, withDiameter: 30)

        return JSQMessagesAvatarImage.avatar(with: avatar)
    }


    // MARK: JSQMessagesViewController

    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        if let msg = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text) {
            messages.append(msg)

            finishSendingMessage(animated: true)

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                if let answer = JSQMessage(senderId: self.incomingSenderId, senderDisplayName: self.incomingDisplayName, date: date, text: text) {
                    self.messages.append(answer)
                    
                    self.finishSendingMessage(animated: true)
                }
            }
        }
    }
}

