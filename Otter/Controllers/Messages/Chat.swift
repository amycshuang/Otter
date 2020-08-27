//
//  Chat.swift
//  Otter
//
//  Created by Amy Chin Siu Huang on 7/24/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import UIKit
import SnapKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseFirestore

class Chat: UIViewController {
    
    var otterUserInfoButton: UIBarButtonItem!
    
    var messages: [Message] = []
    var groupedMessagesByDate: [[Message]] = []
    var dateKeys: [Date] = []
    var chatTableView: UITableView!
    let chatMessageReuseIdentifier = "chatMessageReuseIdentifier"
    var friend: OtherUser!
    
    var chatInputContainerView: UIView!
    var attachPhotoButton: UIButton!
    var sendButton: UIButton!
    var chatInputTextField: UITextField!
    var separatorView: UIView!
    
    var zoomedImageView: UIImageView!
    var backgroundView: UIScrollView!
    var imageStartFrame: CGRect!
    var unzoomButton: UIButton!
    var saveImageButton: UIButton!
    var saveImagePopup: SaveImagePopup!
    var saveImageMessage: MessagePopup!
    
    init(friend: OtherUser) {
        super.init(nibName: nil, bundle: nil)
        self.friend = friend
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.hideKeyboardWhenViewTapped()
        title = friend.name
        
        otterUserInfoButton = UIBarButtonItem(image: UIImage(named: "chatinfoicon"), style: .plain, target: self, action: #selector(showOtherUser))
        navigationItem.rightBarButtonItem = otterUserInfoButton
        
        chatTableView = UITableView()
        chatTableView.separatorStyle = .none
        chatTableView.register(ChatMessageTableViewCell.self, forCellReuseIdentifier: chatMessageReuseIdentifier)
        chatTableView.dataSource = self
        chatTableView.delegate = self
        view.addSubview(chatTableView)
        
        getChatMessages()
        setUpChatInput()
        setUpConstraints(keyboardHeight: 0)
        setUpKeyboard()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self)
    }
    
    func setUpChatInput() {
        chatInputContainerView = UIView()
        chatInputContainerView.backgroundColor = .white
        view.addSubview(chatInputContainerView)
        
        chatInputTextField = UITextField()
        chatInputTextField.attributedPlaceholder = NSAttributedString(string: "type your message...",
        attributes: [NSAttributedString.Key.foregroundColor: Constants.blue, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular)])
        chatInputTextField.delegate = self
        chatInputContainerView.addSubview(chatInputTextField)
        
        attachPhotoButton = UIButton()
        attachPhotoButton.setImage(UIImage(named: "attachphotoicon"), for: .normal)
        attachPhotoButton.addTarget(self, action: #selector(presentPhotoPicker), for: .touchUpInside)
        chatInputContainerView.addSubview(attachPhotoButton)
        
        sendButton = UIButton()
        sendButton.setImage(UIImage(named: "sendicon"), for: .normal)
        sendButton.addTarget(self, action: #selector(sendText), for: .touchUpInside)
        chatInputContainerView.addSubview(sendButton)
        
        separatorView = UIView()
        separatorView.backgroundColor = Constants.lightGray
        chatInputContainerView.addSubview(separatorView)
        
    }
    
    func setUpKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func showKeyboard(notification: Notification) {
        if let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if #available(iOS 11.0, *) {
                if let keywindow =  UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
                    let bottom = keywindow.safeAreaInsets.bottom
                    let height = -keyboardFrame.height + bottom + Constants.tabBarHeight
                    setUpConstraints(keyboardHeight: height)
                }
            } else {
                let height = -keyboardFrame.height + Constants.tabBarHeight
                setUpConstraints(keyboardHeight: height)
            }
        }
        
        guard let keyBoardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        UIView.animate(withDuration: keyBoardDuration, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        if self.messages.count > 0 {
            guard var bottomRow = self.groupedMessagesByDate.last?.count else { return }
            bottomRow = bottomRow - 1
            DispatchQueue.main.async {
                self.chatTableView.reloadData()
                let bottomSection = self.groupedMessagesByDate.count - 1
                self.scrollToRow(row: bottomRow, section: bottomSection)
            }
        }
            
    }
    
    @objc func hideKeyboard(notification: Notification) {
        setUpConstraints(keyboardHeight: 0)
        guard let keyBoardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        UIView.animate(withDuration: keyBoardDuration, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func showOtherUser() {
        let vc = OtterUserProfile(user: friend, barButtonHidden: true)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func getChatMessages() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let frienduid = friend.uid
        DatabaseManager.databaseRef.child("User-Messages").child(uid).child(frienduid).observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messageRef = DatabaseManager.databaseRef.child("Messages").child(messageId)
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                self.getMessages(snapshot: snapshot)
            }, withCancel: nil)
        }, withCancel: nil)
        
    }
    
    func getMessages(snapshot: DataSnapshot) {
        let message = Message(snapshot: snapshot)
        self.messages.append(message)
        DispatchQueue.main.async {
            self.groupMessagesByDate()
        }
    }
    
    func groupMessagesByDate() {
        self.groupedMessagesByDate = []
        let groupedMessages = Dictionary(grouping: messages) { (message) -> Date in
            var day = NSDate()
            if let time = message.time, let timeSince1970 = Double(time) {
                day = NSDate(timeIntervalSince1970: timeSince1970)
            }
            var date = day as Date
            date = Utilities.stripTimeOffDate(from: date)
            return date
        }
        
        let sortedKeys = groupedMessages.keys.sorted()
        sortedKeys.forEach { (key) in
            let values = groupedMessages[key]
            self.groupedMessagesByDate.append(values ?? [])
        }
        
        dateKeys = sortedKeys
        guard var bottomRow = self.groupedMessagesByDate.last?.count else { return }
        bottomRow = bottomRow - 1
        DispatchQueue.main.async {
            self.chatTableView.reloadData()
            let bottomSection = self.groupedMessagesByDate.count - 1
            self.scrollToRow(row: bottomRow, section: bottomSection)
        }
    }
    
    @objc func presentPhotoPicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        self.view.window?.rootViewController?.present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func sendText() {
        guard let message = chatInputTextField.text else { return }
        if message != "" {
            let messageData = ["message": message]
            sendMessage(data: messageData)
            chatInputTextField.text = ""
        }
    }
    
    @objc func sendMessage(data: [String: Any]) {
        let recipientUid = friend.uid
        guard let senderUid = User.uid else { return }
        let timeStamp  = String(NSDate().timeIntervalSince1970)
        var values: [String: Any] = [
            "recipientUid": recipientUid,
            "senderUid": senderUid,
            "time": timeStamp,
        ]
        data.forEach { (key, value) in
            values[key] = value
        }
        let databaseRef = DatabaseManager.databaseRef.child("Messages").childByAutoId()
        databaseRef.updateChildValues(values) { (error, reference) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let messageId = databaseRef.key else { return }
            
            let userMessagesRef = DatabaseManager.databaseRef.child("User-Messages").child(senderUid).child(recipientUid)
            userMessagesRef.updateChildValues([messageId: 1])
            let recipientMessagesRef = DatabaseManager.databaseRef.child("User-Messages").child(recipientUid).child(senderUid)
            recipientMessagesRef.updateChildValues([messageId: 1])
        }
    }
    
    func scrollToRow(row: Int, section: Int) {
        DispatchQueue.main.async {
            self.chatTableView.reloadData()
            let indexPath = IndexPath(row: row, section: section)
            if self.chatTableView.validIndexPath(indexPath: indexPath) {
                self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }

    func setUpConstraints(keyboardHeight: CGFloat) {
        let chatInputContainerHeight: CGFloat = 50
        let chatInputButtonSize: CGFloat = 35
        
        chatInputContainerView.snp.remakeConstraints { (make) in
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.height.equalTo(chatInputContainerHeight)
            if keyboardHeight == 0 {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            }
            else {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(keyboardHeight)
            }
        }
        
        chatTableView.snp.remakeConstraints { (make) in
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(chatInputContainerView.snp.top)
        }
        
        attachPhotoButton.snp.makeConstraints { (make) in
            make.leading.equalTo(chatInputContainerView.snp.leading).offset(10)
            make.centerY.equalTo(chatInputContainerView.snp.centerY)
            make.height.width.equalTo(chatInputButtonSize)
        }
        
        sendButton.snp.makeConstraints { (make) in
            make.trailing.equalTo(chatInputContainerView.snp.trailing).offset(-10)
            make.centerY.equalTo(chatInputContainerView.snp.centerY)
            make.width.height.equalTo(chatInputButtonSize)
        }
        
        chatInputTextField.snp.makeConstraints { (make) in
            make.leading.equalTo(attachPhotoButton.snp.trailing).offset(10)
            make.trailing.equalTo(sendButton.snp.leading).offset(-10)
            make.centerY.equalTo(chatInputContainerView.snp.centerY)
            make.height.equalTo(chatInputContainerHeight)
        }
        
        separatorView.snp.makeConstraints { (make) in
            make.leading.equalTo(chatInputContainerView.snp.leading)
            make.trailing.equalTo(chatInputContainerView.snp.trailing)
            make.top.equalTo(chatInputContainerView.snp.top)
            make.height.equalTo(1)
        }
    }
}

extension Chat: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendText()
        return true
    }
    
}

extension Chat: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return groupedMessagesByDate.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupedMessagesByDate[section].count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let containerView = UIView()
        let dateLabel = DateHeaderLabel()
        dateLabel.setDateString(section: section, dateKeys: dateKeys)
        containerView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(containerView.snp.centerX)
            make.centerY.equalTo(containerView.snp.centerY)
        }
        
        return containerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatTableView.dequeueReusableCell(withIdentifier: chatMessageReuseIdentifier, for: indexPath) as! ChatMessageTableViewCell
        let message = groupedMessagesByDate[indexPath.section][indexPath.row]
        cell.configure(for: message, for: friend)
        cell.imageZoomDelegate = self
        cell.selectionStyle = .none
        return cell 
    }
    
}

extension Chat: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = groupedMessagesByDate[indexPath.section][indexPath.row]
        if message.imageUrl != nil, let height = message.imageHeight, let width = message.imageWidth {
            let imageHeight = CGFloat(height/width * 200)
            if imageHeight > CGFloat(210) {
                return 210
            }
            else {
                return imageHeight
            }
        }
        else {
            return message.getMessageHeight()
        }
    }
}

extension Chat: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImage: UIImage = UIImage()
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImage = editedImage
        }
        else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        uploadPhotoMessageToFirebase(image: selectedImage)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func uploadPhotoMessageToFirebase(image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.1) else { return }
        let photoID = UUID().uuidString
        let photoReference = DatabaseManager.storageRef.child("Message-Images").child(photoID)
        photoReference.putData(data, metadata: nil) { (metadata, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            photoReference.downloadURL { (url, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                guard let url = url else {
                    return
                }
                let imageUrl = url.absoluteString
                self.sendImage(imageUrl: imageUrl, image: image)
            }
        }
    }
    
    func sendImage(imageUrl: String, image: UIImage) {
        let data: [String: Any] = [
            "imageUrl": imageUrl,
            "imageWidth": image.size.width,
            "imageHeight": image.size.height
        ]
        sendMessage(data: data)
    }

}

extension Chat: ZoomImageProtocol {
    
    func zoomImage(for imageView: UIImageView) {
        
        imageStartFrame = imageView.superview?.convert(imageView.frame, from: nil)
        zoomedImageView = UIImageView(frame: imageStartFrame)
        zoomedImageView.image = imageView.image
        zoomedImageView.isUserInteractionEnabled = true
        setUpImageGestures()
        
        unzoomButton = UIButton()
        unzoomButton.setImage(UIImage(named: "exitzoomicon"), for: .normal)
        unzoomButton.clipsToBounds = true
        unzoomButton.addTarget(self, action: #selector(closeDismissPhoto), for: .touchUpInside)
        
        saveImageButton = UIButton()
        saveImageButton.setImage(UIImage(named: "saveimageicon"), for: .normal)
        saveImageButton.clipsToBounds = true
        saveImageButton.addTarget(self, action: #selector(saveImage), for: .touchUpInside)
        
        if let keyWindow = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
            backgroundView = UIScrollView(frame: keyWindow.frame)
            backgroundView.backgroundColor = .black
            backgroundView.alpha = 0
            backgroundView.minimumZoomScale = 1
            backgroundView.maximumZoomScale = 5
            backgroundView.isUserInteractionEnabled = true
            backgroundView.bounces = false
            backgroundView.contentSize = zoomedImageView.bounds.size
            backgroundView.isScrollEnabled = true
            backgroundView.delegate = self
            keyWindow.addSubview(backgroundView)
            
            backgroundView.addSubview(zoomedImageView)
            backgroundView.addSubview(unzoomButton)
            backgroundView.addSubview(saveImageButton)
            setUpZoomViewConstraints()
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.backgroundView.alpha = 1
                let imageHeight = self.imageStartFrame.height / self.imageStartFrame.width * keyWindow.frame.width
                self.zoomedImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: imageHeight)
                self.zoomedImageView.center = keyWindow.center
            }, completion: nil)
        }
        
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return zoomedImageView
    }
    
    func setUpImageGestures() {
        let unzoomPhotoUp = UISwipeGestureRecognizer(target: self, action: #selector(swipeDismissPhoto))
        unzoomPhotoUp.direction = .up
        let unzoomPhotoDown = UISwipeGestureRecognizer(target: self, action: #selector(swipeDismissPhoto))
        unzoomPhotoDown.direction = .down
        zoomedImageView.addGestureRecognizer(unzoomPhotoUp)
        zoomedImageView.addGestureRecognizer(unzoomPhotoDown)
        
        let saveImagePress = UILongPressGestureRecognizer(target: self, action: #selector(presentSaveOptions))
        saveImagePress.minimumPressDuration = 0.5
        zoomedImageView.addGestureRecognizer(saveImagePress)
        
    }
    
    @objc func presentSaveOptions(press: UILongPressGestureRecognizer) {
        if press.state == .began {
            saveImagePopup = SaveImagePopup()
            saveImagePopup.saveImageDelegate = self
            saveImagePopup.alpha = 0
            backgroundView.addSubview(saveImagePopup)
            setUpPopup()
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                self.saveImagePopup.alpha = 1
                self.saveImagePopup.center.y = self.view.center.y
            }, completion: nil)
        }
    }
    
    func setUpPopup() {
        saveImagePopup.snp.makeConstraints { (make) in
            make.centerX.equalTo(view.snp.centerX)
            make.centerY.equalTo(view.snp.centerY)
            make.height.equalTo(230)
            make.width.equalTo(260)
        }
    }
    
    @objc func saveImage() {
        guard let image = zoomedImageView.image else { return }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error != nil {
            showSaveMessage(message: "Save Failed")

        } else {
            showSaveMessage(message: "Image Saved")
        }
    }
    
    func showSaveMessage(message: String) {
        saveImageMessage = MessagePopup()
        saveImageMessage.text = message
        backgroundView.addSubview(saveImageMessage)
        
        saveImageMessage.snp.makeConstraints { (make) in
            make.centerX.equalTo(view.snp.centerX)
            make.centerY.equalTo(view.snp.centerY)
            make.width.equalTo(170)
            make.height.equalTo(40)
        }
    
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(dismissSaveMessage), userInfo: nil, repeats: false)
    }
    
    @objc func dismissSaveMessage() {
        if saveImageMessage != nil {
            saveImageMessage.removeFromSuperview()
        }
    }
    
    @objc func closeDismissPhoto() {
        unzoomPhoto(imageView: zoomedImageView)
    }
    
    @objc func swipeDismissPhoto(swipe: UISwipeGestureRecognizer) {
        if let zoomedOutImageView = swipe.view as? UIImageView {
            unzoomPhoto(imageView: zoomedOutImageView)
        }
    }
    
    func unzoomPhoto(imageView: UIImageView) {
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            imageView.frame = self.imageStartFrame
            self.backgroundView.alpha = 0
        }) { (Bool) in
            self.backgroundView.removeFromSuperview()
        }
    }
    
    func setUpZoomViewConstraints() {
        
        let verticalPadding: CGFloat = 50
        let horizontalPadding: CGFloat = 20
        let buttonSize: CGFloat = 35
        
        unzoomButton.snp.makeConstraints { (make) in
            make.left.equalTo(view.snp.left).offset(horizontalPadding)
            make.top.equalTo(view.snp.top).offset(-verticalPadding)
            make.width.height.equalTo(buttonSize)
        }
        
        saveImageButton.snp.makeConstraints { (make) in
            make.right.equalTo(view.snp.right).offset(-horizontalPadding)
            make.top.equalTo(view.snp.top).offset(-verticalPadding)
            make.width.height.equalTo(buttonSize)
        }
    }
    
}

extension Chat: SaveImageProtocol {
    
    func saveImageToLibrary() {
        guard let image = zoomedImageView.image else { return }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        cancelSaveImage()
    }
    
    func cancelSaveImage() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            self.saveImagePopup.center.y = self.view.frame.height
            self.saveImagePopup.alpha = 0
        }) { (Bool) in
            self.saveImagePopup.removeFromSuperview()
        }
    }
    
}

