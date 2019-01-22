//
//  MessageViewController.swift
//  Zalonin
//
//  Created by Sahil Dhawan on 25/05/18.
//  Copyright © 2018 Sahil Dhawan. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import FirebaseDatabase
import FirebaseStorage

class MessageViewController: JSQMessagesViewController {
    
    lazy var incomingBubbleView  = self.setupIncomingBubble()
    lazy var outgoingBubbleView  = self.setupOutgoingBubble()
    lazy var storageRef : StorageReference = Storage.storage().reference(forURL: "gs://salon-ee42e.appspot.com")
    lazy var ref : DatabaseReference = Database.database().reference()
    
    private let imageURLNotSetKey = "NOT SET"
    
    var photoMessageMap = [String : JSQPhotoMediaItem]()
    
    var chatUser : String = ""
    var messagesArray : [JSQMessage] = []
    var messageDataArray : [[String : Any]] = []
    var imageArray : [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.senderId = "ME"
        view.backgroundColor = Colors.grayColor3
        self.senderDisplayName = UserDetails.userName
        self.collectionView.backgroundColor = Colors.grayColor3
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        setupMessages()
        
        self.navigationItem.title = chatUser
    }
    
    func sendPhotoMessage() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMddHHmmssSS"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    private func addPhotoMessage(withId: String, key: String, mediaItem : JSQPhotoMediaItem){
        if let message = JSQMessage(senderId: withId, displayName: "", media: mediaItem) {
            self.messagesArray.append(message)
        }
    }
    
    func setupIncomingBubble() -> JSQMessagesBubbleImage {
        return JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: Colors.whiteColor)
    }
    
    func setupOutgoingBubble() -> JSQMessagesBubbleImage{
        return JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: Colors.whiteColor)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    func setupMessages(){
        
        let userId = UserDefaults.standard.value(forKey: "user_id") as! String
        UserDetails.userId = userId
        
        let childAddress = "USER/\(UserDetails.userId)/CHATS/\(chatUser)"
        
        ref.child(childAddress).observe(.childAdded) { (snapshot) in
            if let messageValue = snapshot.value as? [String: Any] {
                let message = messageValue
                
                let dateString = message["date"] as! String
                let msg = message["msg"] as! String
                let name = message["name"] as! String
                let img = message["im"] as! Int
                let subDateString = dateString.prefix(12)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyMMddHHmmss"
                let date = dateFormatter.date(from: String(subDateString))
                
                if img == 1 {
                    let path = msg
                    self.storageRef.child(path).downloadURL(completion: { (url, error) in
                        if error == nil {
                            do {
                                let imageData = try Data(contentsOf: url!)
                                let image = UIImage(data: imageData)
                                let mediaItem = JSQPhotoMediaItem(image: image)
                                self.addPhotoMessage(withId: name, key: dateString, mediaItem: mediaItem!)
                                self.collectionView.reloadData()
                            } catch {
                                print("image data")
                            }
                        }
                    })
                } else {
                    let jsqMessage = JSQMessage(senderId: name, senderDisplayName: name, date: date, text: msg)
                    
                    self.messagesArray.append(jsqMessage!)
                }

                self.imageArray.append(img)
                self.messageDataArray.append(message)
                self.finishSendingMessage()
            }
        }
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messagesArray[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messagesArray.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messagesArray[indexPath.item]
        let name = message.senderId
        if name == "ME" {
            return outgoingBubbleView
        } else {
            return incomingBubbleView
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        cell.textView.textColor = Colors.blackColor
        
       
        return cell
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        var message = [String : Any]()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMddHHmmssSS"
        let dateString = dateFormatter.string(from: date)
        
        message["date"] = dateString
        message["name"] = "ME"
        message["im"] = 0
        message["msg"] = text
        
        FirebaseMethods().createMessage(message: message, chatUser: chatUser)
        self.finishSendingMessage()
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        let picker = UIImagePickerController()
        picker.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = UIImagePickerControllerSourceType.camera
        } else {
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        }
        self.present(picker, animated: true, completion: nil)
    }
}

extension MessageViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let key = sendPhotoMessage()
        let imageData = UIImageJPEGRepresentation(image, 0.2)
        let imagePath = "\(UserDetails.userId)/images/content:/media/external/file/\(key).jpg"
        
        storageRef.child(imagePath).putData(imageData!, metadata: nil) { (metadata, error) in
            if let error = error {
                self.showAlert(msg: error.localizedDescription)
                return
            } else {
                var message = [String : Any]()
                let path = metadata?.path
                
                message["date"] = key
                message["name"] = "ME"
                message["im"] = 1
                message["msg"] = path!
                FirebaseMethods().createMessage(message: message, chatUser: self.chatUser)
                
                self.finishSendingMessage()
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
}

