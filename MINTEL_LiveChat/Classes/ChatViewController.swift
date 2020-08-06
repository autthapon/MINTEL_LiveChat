/*
MIT License

Copyright (c) 2017-2019 MessageKit

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import UIKit
import MessageKit
import InputBarAccessoryView
import Alamofire
import ServiceCore
import ServiceChat
import Photos
import SafariServices

let menuHeight = 45
let orangeColor = "#EF8933"

/// A base class for the example controllers
class ChatViewController: MessagesViewController, MessagesDataSource {
    
    internal static var callCenterUser = MockUser(senderId: "1", displayName: "Agent")
    internal static let user = MockUser(senderId: "2", displayName: "User")
    private var queuePosition:Int = Int.max
    private var salesforceEndChat = false
    private let urlUpload = "https://asia-east2-tmn-chatbot-integration.cloudfunctions.net/uploadFile"
    private var pickerController: UIImagePickerController? = nil
    private var bottomMenuShow = false
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func terminateChat() {
        self.dismiss(animated: true) {
            self.setTypingIndicatorViewHidden(true, animated: false)
            self.realTerminateChat()
        }
    }
    
    func realTerminateChat() {
        
        MINTEL_LiveChat.messageList.removeAll()
        MINTEL_LiveChat.instance.chatSessionDelegate = nil
        MINTEL_LiveChat.instance.chatEventDelegate = nil
        MINTEL_LiveChat.instance.closeButtonHandle()
        
        if (MINTEL_LiveChat.messageList.count == 0) {
            let uniqueID = UUID().uuidString
            let randomSentence = "TrueMoney Care สวัสดีครับ เจ้าหน้าที่ ยินดีให้บริการ สอบถามข้อมูล TrueMoney Wallet แจ้งได้เลยนะครับ"
            let message = MockMessage(text: randomSentence, user: ChatViewController.callCenterUser, messageId: uniqueID, date: Date())
            MINTEL_LiveChat.messageList.append(message)
        }
        
        self.openSurvey()
    }
    
    private func openSurvey() {
        if let urlString = MINTEL_LiveChat.configuration?.surveyFormUrl {
            
            let urlStringWithUserSessionId = urlString.replacingOccurrences(of: "sessionId", with: MINTEL_LiveChat.userId)
            if let url = URL(string: urlStringWithUserSessionId) {
                var vc:UIViewController? = nil
                
                if #available(iOS 11.0, *) {
                    let config = SFSafariViewController.Configuration()
                    config.entersReaderIfAvailable = false
                    vc = SFSafariViewController(url: url, configuration: config)
                } else {
                    vc = SFSafariViewController(url: url)
                }
                
                let currentViewController = UIApplication.shared.keyWindow?.rootViewController
    //            currentViewController?.dismiss(animated: true, completion: nil)

                if self.presentedViewController == nil {
                    currentViewController?.present(vc!, animated: true, completion: nil)
                } else {
                    self.present(vc!, animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc func didTabMenu(_ sender: MyTapGesture? = nil) {
        
        
        if (!MINTEL_LiveChat.chatBotMode) {
            return
        }
        
        let loc:CGPoint = sender!.location(in: sender?.view)
        switch sender?.message?.kind {
        case .custom(let items) :
            
            let item = items as! [String: Any]
            let type = item["type"] as! Int
            if (type == 2) {
            } else {
                let menuItems = item["menuItem"] as? [[String :Any]]
                let text = self.getMessageText(point: loc, message:menuItems ?? [])
                if (text.count > 0) {
                    
                    self.insertMessage(MockMessage(text: text, user: ChatViewController.user, messageId: UUID().uuidString, date: Date()))
                    self.messageInputBar.inputTextView.text = String()
                    self.messageInputBar.invalidatePlugins()
                    self.messageInputBar.sendButton.startAnimating()
                    self.messageInputBar.inputTextView.placeholder = "Sending..."
                    self.messagesCollectionView.scrollToBottom(animated: true)
                    
                    self.setTypingIndicatorViewHidden(false, animated: true, whilePerforming: {
                        
                    }) { (success) in
                        self.sendPost(text: text) { (messages) in
                            DispatchQueue.main.async { [weak self] in
                                self?.setTypingIndicatorViewHidden(true, animated: false, whilePerforming: {
                                    
                                }, completion: { (success) in
                                    self?.messageInputBar.sendButton.stopAnimating()
                                    self?.messageInputBar.inputTextView.placeholder = "พิมพ์ข้อความที่คุณต้องการ"
                                    self?.messagesCollectionView.scrollToBottom(animated: true)
                                })
                            }
                        }
                    }
                }
            }
            
            
            break
        default : break
        }
    }
    
    private func getMessageText(point:CGPoint, message:[[String:Any]]) -> String {
        let position = floor(point.y / CGFloat(menuHeight))
        let item = message[Int(position)]
        let action = item["action"] as? [String:Any] ?? nil
        if (action == nil) {
            return ""
        }
        let text = action?["text"] as? String ?? ""
        return text
    }
    
    /// The `BasicAudioController` controll the AVAudioPlayer state (play, pause, stop) and udpate audio cell UI accordingly.
    open lazy var audioController = BasicAudioController(messageCollectionView: messagesCollectionView)

    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    override func viewDidLoad() {
        
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.barTintColor = UIColor(MyHexString: orangeColor)
        
        self.pickerController = UIImagePickerController()
        self.pickerController?.modalPresentationStyle = .fullScreen
        self.pickerController?.delegate = self
        self.pickerController?.allowsEditing = true
        self.pickerController?.mediaTypes = ["public.image"]
        
        configureMessageCollectionView()
        configureMessageInputBar()
        
        loadFirstMessages()
        title = ChatViewController.self.callCenterUser.displayName
        if (!MINTEL_LiveChat.chatBotMode) {
            self.configureSaleForce()
        }
        
        MINTEL_LiveChat.instance.chatDelegate = self
        
        self.view.backgroundColor = UIColor(MyHexString: "#f1f1f1")
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = ChatViewController.callCenterUser.displayName
    }
    
    private func configureSaleForce() {
        MINTEL_LiveChat.instance.chatSessionDelegate = self
        MINTEL_LiveChat.instance.chatEventDelegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func loadFirstMessages() {
        
        loadAnnouncement()
        
//        DispatchQueue.global(qos: .userInitiated).async {
//
//            if (MINTEL_LiveChat.messageList.count == 0) {
//                let uniqueID = UUID().uuidString
//                let randomSentence = "TrueMoney Care สวัสดีครับ เจ้าหน้าที่ ยินดีให้บริการ สอบถามข้อมูล TrueMoney Wallet แจ้งได้เลยนะครับ"
//                let message = MockMessage(text: randomSentence, user: ChatViewController.callCenterUser, messageId: uniqueID, date: Date())
//                MINTEL_LiveChat.messageList.append(message)
//            }
//            DispatchQueue.main.async {
//                self.messagesCollectionView.reloadData()
//                self.messagesCollectionView.scrollToBottom()
//            }
//        }
    }
    
    func loadAnnouncement() {
        
        let params: Parameters = [:]
        let url = (MINTEL_LiveChat.configuration?.announcementUrl ?? "").replacingOccurrences(of: "sessionId", with: MINTEL_LiveChat.userId)
        let header:HTTPHeaders = [
            "x-api-key": MINTEL_LiveChat.configuration?.xApikey ?? "" // "381b0ac187994f82bdc05c09d1034afa"
        ]
       
        Alamofire
            .request(url, method: .post, parameters: params, encoding: JSONEncoding.init(), headers: header)
            .responseJSON { (response) in
                switch response.result {
                case .success(_):
                    if let json = response.value {
                        debugPrint(json)
                        let dict = json as! [String: Any]
                        let desc = dict["Description__c"] as? String ?? ""
                        
                        if desc.count > 0 {
                            DispatchQueue.global(qos: .userInitiated).async {
                    
                                if (MINTEL_LiveChat.messageList.count == 0) {
                                    let uniqueID = UUID().uuidString
                                    let message = MockMessage(text: desc, user: ChatViewController.callCenterUser, messageId: uniqueID, date: Date())
                                    MINTEL_LiveChat.messageList.append(message)
                                }
                                DispatchQueue.main.async {
                                    self.messagesCollectionView.reloadData()
                                    self.messagesCollectionView.scrollToBottom()
                                }
                            }
                        }
                        
                    }
                    break
                case .failure( _):
                    break
                }
        }
    }
    
    func configureMessageCollectionView() {
        
        let flowLayout = CustomMessagesFlowLayout()
        flowLayout.menuHeight = menuHeight
        messagesCollectionView = MessagesCollectionView(frame: .zero, collectionViewLayout: flowLayout)
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.backgroundColor = UIColor.black
        
        scrollsToBottomOnKeyboardBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
        
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
        }
        
        messagesCollectionView.register(MyCustomCell.self)
    }
    
    func configureMessageInputBar() {
        messageInputBar.delegate = self
        messageInputBar.inputTextView.tintColor = UIColor(MyHexString: "#EF8933")
        messageInputBar.inputTextView.placeholder = "พิมพ์ข้อความที่คุณต้องการ"
        messageInputBar.sendButton.setTitle("", for: .normal)
        messageInputBar.sendButton.image = UIImage(named: "send", in: Bundle(for: ChatViewController.self), compatibleWith: nil)
        messageInputBar.setLeftStackViewWidthConstant(to: 110, animated: true)
        messageInputBar.setRightStackViewWidthConstant(to: 32, animated: false)
        messageInputBar.backgroundColor = UIColor(white: 0.3, alpha: 1)
        
        self.leftMenuWithCloseBottom()
    }
    
    private func leftMenuWithOpenBottom() {
        var leftMenu:[InputBarButtonItem] = []
        leftMenu.append(self.makeCloseButton())
        leftMenu.append(.fixedSpace(5))
        leftMenu.append(self.makeCameraButton())
        leftMenu.append(.fixedSpace(5))
        leftMenu.append(self.makeImageButton())
        
        messageInputBar.setStackViewItems(leftMenu, forStack: .left, animated: false)
    }
    
    private func leftMenuWithCloseBottom() {
        var leftMenu:[InputBarButtonItem] = []
        leftMenu.append(self.makePlusButton())
        leftMenu.append(.fixedSpace(5))
        leftMenu.append(self.makeCameraButton())
        leftMenu.append(.fixedSpace(5))
        leftMenu.append(self.makeImageButton())
        
        messageInputBar.setStackViewItems(leftMenu, forStack: .left, animated: false)
    }
    
    private func setUpBottomView() {
        self.bottomMenuShow = true
        messageInputBar.setStackViewItems([makeFileButton(), .flexibleSpace], forStack: .bottom, animated: false)
        self.leftMenuWithOpenBottom()
        self.messageInputBar.layoutStackViews()
    }
    
    private func hideBottomView() {
        self.bottomMenuShow = false
        messageInputBar.setStackViewItems([], forStack: .bottom, animated: true)
        self.leftMenuWithCloseBottom()
    }
    
    private func makeCloseButton() -> InputBarButtonItem {
        return InputBarButtonItem()
            .configure {
                $0.setSize(CGSize(width: 32, height: 32), animated: false)
                $0.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
                $0.image = UIImage(named: "close", in: Bundle(for: ChatViewController.self), compatibleWith: nil)!
                $0.isHighlighted = false
            }.onTouchUpInside { _ in
                if (self.bottomMenuShow) {
                    self.hideBottomView()
                } else {
                    self.setUpBottomView()
                }
        }
    }
    
    private func makePlusButton() -> InputBarButtonItem {
        return InputBarButtonItem()
            .configure {
                $0.setSize(CGSize(width: 32, height: 32), animated: false)
                $0.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
                $0.image = UIImage(named: "plus", in: Bundle(for: ChatViewController.self), compatibleWith: nil)!
                $0.isHighlighted = false
            }.onTouchUpInside { _ in
                if (self.bottomMenuShow) {
                    self.hideBottomView()
                } else {
                    self.setUpBottomView()
                }
        }
    }
    
    private func makeFileButton() -> InputBarButtonItem {
        return InputBarButtonItem()
                    .configure {
                        $0.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
//                        $0.title = "File"
                        $0.setSize(CGSize(width: 100, height: 100), animated: false)
                        $0.image = UIImage(named: "file", in: Bundle(for: ChatViewController.self), compatibleWith: nil)!
                        $0.isHighlighted = false
                        $0.contentVerticalAlignment = .bottom
                        $0.contentHorizontalAlignment = .center
                    }.onTouchUpInside { _ in
                        
                        let importMenu = UIDocumentPickerViewController(documentTypes: ["com.apple.iwork.pages.pages", "com.apple.iwork.numbers.numbers", "com.apple.iwork.keynote.key","public.image", "com.apple.application", "public.item", "public.content", "public.audiovisual-content", "public.movie", "public.audiovisual-content", "public.video", "public.audio", "public.text", "public.data", "public.zip-archive", "com.pkware.zip-archive", "public.composite-content"], in: .import)
                        importMenu.delegate = self
                        importMenu.modalPresentationStyle = .formSheet
                        importMenu.modalPresentationStyle = .fullScreen
                        self.present(importMenu, animated: true, completion: nil)
                }
    }
    
    private func makeCameraButton() -> InputBarButtonItem {
        return InputBarButtonItem()
            .configure {
             $0.setSize(CGSize(width: 32, height: 32), animated: false)
             $0.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
             $0.image = UIImage(named: "camera", in: Bundle(for: ChatViewController.self), compatibleWith: nil)!
            }.onTouchUpInside { _ in
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    self.pickerController?.sourceType = .camera
                    self.present(self.pickerController!, animated: true)
                } else {
                    // TODO
                }
        }
    }
    
    private func makeImageButton() -> InputBarButtonItem {
        
           return InputBarButtonItem()
               .configure {
                $0.setSize(CGSize(width: 32, height: 32), animated: false)
                $0.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
                $0.image = UIImage(named: "image", in: Bundle(for: ChatViewController.self), compatibleWith: nil)!
               }.onTouchUpInside { _ in
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    self.pickerController?.sourceType = .photoLibrary
                    self.present(self.pickerController!, animated: true)
                } else {
                    // TODO
                }
           }
       }
    
    // MARK: - Helpers
    
    func insertMessage(_ message: MockMessage) {
        MINTEL_LiveChat.messageList.append(message)
        // Reload last section to update header/footer labels and insert a new one
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([MINTEL_LiveChat.messageList.count - 1])
            if MINTEL_LiveChat.messageList.count >= 2 {
                messagesCollectionView.reloadSections([MINTEL_LiveChat.messageList.count - 2])
            }
        }, completion: { [weak self] _ in
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        })
    }
    
    func isLastSectionVisible() -> Bool {
        
        guard !MINTEL_LiveChat.messageList.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: MINTEL_LiveChat.messageList.count - 1)
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    // MARK: - MessagesDataSource
    
    func currentSender() -> SenderType {
        return ChatViewController.user
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return MINTEL_LiveChat.messageList.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
//        debugPrint("Row", indexPath.row,  "Section", indexPath.section)
        if (indexPath.section >= MINTEL_LiveChat.messageList.count) {
            return MINTEL_LiveChat.messageList[MINTEL_LiveChat.messageList.count - 1]
        }
        return MINTEL_LiveChat.messageList[indexPath.section]
    }
    
//    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
//        if indexPath.section % 3 == 0 {
//            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
//        }
//        return nil
//    }
    
//    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
//        return NSAttributedString(string: "Read", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
//    }
    
//    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
//        let name = message.sender.displayName
//        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
//    }
    
//    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
//
//        let dateString = formatter.string(from: message.sentDate)
//        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
//    }
    
    func customCell(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UICollectionViewCell {
        let cell = messagesCollectionView.dequeueReusableCell(MyCustomCell.self, for: indexPath)
        let tapGestureRecognizer = cell.tapGuesture ?? MyTapGesture(target: self, action: #selector(didTabMenu(_:)))
        tapGestureRecognizer.message = message
        cell.configure(with: message, at: indexPath, and: messagesCollectionView, tapGuesture: tapGestureRecognizer)
        return cell
    }
    
    
}

extension ChatViewController : ChatDelegate {
    func terminate() {
        self.realTerminateChat()
    }
}


// MARK: - MessageCellDelegate

extension ChatViewController: MessageCellDelegate {
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
    }
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        print("Image tapped")
    }
    
    func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        print("Top cell label tapped")
    }
    
    func didTapCellBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom cell label tapped")
    }
    
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        print("Top message label tapped")
    }
    
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom label tapped")
    }

    func didTapPlayButton(in cell: AudioMessageCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
            let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) else {
                print("Failed to identify message when audio cell receive tap gesture")
                return
        }
        guard audioController.state != .stopped else {
            // There is no audio sound playing - prepare to start playing for given audio message
            audioController.playSound(for: message, in: cell)
            return
        }
        if audioController.playingMessage?.messageId == message.messageId {
            // tap occur in the current cell that is playing audio sound
            if audioController.state == .playing {
                audioController.pauseSound(for: message, in: cell)
            } else {
                audioController.resumeSound()
            }
        } else {
            // tap occur in a difference cell that the one is currently playing sound. First stop currently playing and start the sound for given message
            audioController.stopAnyOngoingPlaying()
            audioController.playSound(for: message, in: cell)
        }
    }

    func didStartAudio(in cell: AudioMessageCell) {
        print("Did start playing audio sound")
    }

    func didPauseAudio(in cell: AudioMessageCell) {
        print("Did pause audio sound")
    }

    func didStopAudio(in cell: AudioMessageCell) {
        print("Did stop audio sound")
    }

    func didTapAccessoryView(in cell: MessageCollectionViewCell) {
        print("Accessory view tapped")
    }

}

// MARK: - MessageLabelDelegate

extension ChatViewController: MessageLabelDelegate {
    
    func didSelectAddress(_ addressComponents: [String: String]) {
        print("Address Selected: \(addressComponents)")
    }
    
    func didSelectDate(_ date: Date) {
        print("Date Selected: \(date)")
    }
    
    func didSelectPhoneNumber(_ phoneNumber: String) {
        print("Phone Number Selected: \(phoneNumber)")
    }
    
    func didSelectURL(_ url: URL) {
        print("URL Selected: \(url)")
    }
    
    func didSelectTransitInformation(_ transitInformation: [String: String]) {
        print("TransitInformation Selected: \(transitInformation)")
    }

    func didSelectHashtag(_ hashtag: String) {
        print("Hashtag selected: \(hashtag)")
    }

    func didSelectMention(_ mention: String) {
        print("Mention selected: \(mention)")
    }

    func didSelectCustom(_ pattern: String, match: String?) {
        print("Custom data detector patter selected: \(pattern)")
    }

}

// MARK: - MessageInputBarDelegate

extension ChatViewController: InputBarAccessoryViewDelegate {

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {

        let components = inputBar.inputTextView.components
        self.insertMessages(components)
        
        if (MINTEL_LiveChat.chatBotMode) {
            
            self.setTypingIndicatorViewHidden(false, animated: false, whilePerforming: {
                
            }) { (success) in
                self.sendPost(text: text) { (messages) in
                    DispatchQueue.main.async { [weak self] in
                        self?.setTypingIndicatorViewHidden(true, animated: false, whilePerforming: {
                            
                        }, completion: { (success) in
                            self?.showStableStatus()
                        })
                    }
                }
            }
            
        } else {
            ServiceCloud.shared().chatCore.session.isUserTyping = false
            ServiceCloud.shared().chatCore.session.sendMessage(text)
        }
        
        self.showSendingStatus()
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        if (!MINTEL_LiveChat.chatBotMode) {
            if let chatCore = ServiceCloud.shared().chatCore {
                if let chatSession = chatCore.session {
                    chatSession.isUserTyping = text.count != 0
                }
            }
        }
    }
    
    private func showStableStatus() {
        DispatchQueue.main.async {
            self.messageInputBar.sendButton.stopAnimating()
            self.messageInputBar.inputTextView.placeholder = "พิมพ์ข้อความที่คุณต้องการ"
            self.messagesCollectionView.scrollToBottom(animated: true)
        }
    }
    
    private func showSendingStatus() {
        DispatchQueue.main.async {
            self.messageInputBar.inputTextView.text = String()
            self.messageInputBar.invalidatePlugins()
            self.messageInputBar.sendButton.startAnimating()
            self.messageInputBar.inputTextView.placeholder = "Sending..."
        }
    }
    
    func sendPost(text: String, callback: @escaping ([MockMessage]) -> Void) {
        
        let params : Parameters = ["session_id": MINTEL_LiveChat.userId,"text": text]
        let url = String(format: "%@/webhook", MINTEL_LiveChat.configuration?.webHookBaseUrl ?? "")
//        let url = "https://asia-east2-tmn-chatbot-integration.cloudfunctions.net/webhook"
        let header:HTTPHeaders = [
            "x-api-key": MINTEL_LiveChat.configuration?.xApikey ?? "" // "381b0ac187994f82bdc05c09d1034afa"
        ]
       
        Alamofire
            .request(url, method: .post, parameters: params, encoding: JSONEncoding.init(), headers: header)
            .responseJSON { (response) in
                switch response.result {
                    case .success(_):
                        if let json = response.value {
                            debugPrint(json)
                            self.setTypingIndicatorViewHidden(true, animated: false, whilePerforming: {
                                
                            }) { (success) in
                                let dict = json as! [String: Any]
                                let error = dict["error"] as? [String: Any] ?? nil
                                if (error == nil) {
                                    let intent = dict["intent"] as? String ?? ""
                                    if (intent == "08_wait_for_call") {
                                        self.switchToAgentMode()
                                    }
                                    
                                    let messages = dict["messages"] as! [[String: Any]]
                                    messages.forEach { body in
                                        let type = body["type"] as? String ?? ""
                                        let text = body["text"] as? String ?? ""
                                        let quickReply = body["quickReply"] as? [String: Any] ?? nil
                                        if (type == "text") {
                                            self.insertMessage(MockMessage(text: text, user: ChatViewController.callCenterUser, messageId: UUID().uuidString, date: Date()))
                                            if (quickReply != nil) {
                                                let items = quickReply!["items"] as? [[String:Any]] ?? []
                                                let theMessage = ["type": 1, "menuItem" : items] as [String : Any]
                                                self.insertMessage(MockMessage(custom: theMessage, user: ChatViewController.callCenterUser, messageId: UUID().uuidString, date: Date()))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        callback([])
                        break
                    case .failure(let error):
                        callback([])
                        print(error)
                        break
                }
        }
        
        
//        AF.request(URL.init(string: url)!, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { (response) in
//            switch response.result {
//                case .success(_):
//                    if let json = response.value {
//                        self.setTypingIndicatorViewHidden(true, animated: false, whilePerforming: {
//
//                        }) { (success) in
//                            let dict = json as! [String: Any]
//                            let error = dict["error"] as? [String: Any] ?? nil
//                            if (error == nil) {
//                                let messages = dict["messages"] as! [[String: Any]]
//                                messages.forEach { body in
//                                    let type = body["type"] as? String ?? ""
//                                    let text = body["text"] as? String ?? ""
//                                    let quickReply = body["quickReply"] as? [String: Any] ?? nil
//                                    if (type == "text") {
//                                        self.insertMessage(MockMessage(text: text, user: ChatViewController.callCenterUser, messageId: UUID().uuidString, date: Date()))
//                                        if (quickReply != nil) {
//                                            let items = quickReply!["items"] as? [[String:Any]] ?? []
//                                            let theMessage = ["type": 1, "menuItem" : items] as [String : Any]
//                                            self.insertMessage(MockMessage(custom: theMessage, user: ChatViewController.callCenterUser, messageId: UUID().uuidString, date: Date()))
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
//                    callback([])
//                    break
//                case .failure(let error):
//                    callback([])
//                    print(error)
//                    break
//            }
//        }
    }
    
    private func switchToAgentMode() {
        MINTEL_LiveChat.chatBotMode = false
        MINTEL_LiveChat.instance.startSaleForce()
        self.configureSaleForce()
        
        DispatchQueue.main.async {
            let message = MockMessage(text: "Connecting", user: ChatViewController.callCenterUser, messageId: UUID().uuidString, date: Date())
            self.insertMessage(message)
        }
    }

    private func insertMessages(_ data: [Any]) {
        for component in data {
            if let str = component as? String {
                let message = MockMessage(text: str, user: ChatViewController.user, messageId: UUID().uuidString, date: Date())
                insertMessage(message)
            } else if let img = component as? UIImage {
                let message = MockMessage(image: img, user: ChatViewController.user, messageId: UUID().uuidString, date: Date())
                insertMessage(message)
            }
        }
    }
    
    private func upload(imageData: Data?, imageName:String?, fileData: Data?, fileName:String?, parameters: [String : Any]) {
        
        let url = String(format: "%@/uploadFile", MINTEL_LiveChat.configuration?.uploadBaseUrl ?? "") // "https://us-central1-test-tmn-bot.cloudfunctions.net/uploadFile"
        
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data"
        ]
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            
            if let data = fileData {
                let pathExtention = URL(string: fileName!)!.pathExtension
                multipartFormData.append(data, withName: "file", fileName: fileName ?? "", mimeType: pathExtention)
            }
            
            if let data = imageData{
                multipartFormData.append(data, withName: "file", fileName: imageName ?? "", mimeType: self.mimeType(for: data))
            }
            
        }, usingThreshold: UInt64.init(), to: url, method: .post, headers: headers) { (result) in
            switch result{
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    print("Succesfully uploaded")
                    if let err = response.error{
                        debugPrint(err)
                        self.setTypingIndicatorViewHidden(true, animated: false)
                        return
                    }
                    
                    if (!MINTEL_LiveChat.chatBotMode) {
                        
                        if let json = response.value {
                            debugPrint(json)
                            let dict = json as! [String: Any]
                            let url = dict["url"] as? String ?? ""
                            if url.count > 0 {
                                ServiceCloud.shared().chatCore.session.sendMessage(url)
                            }
                        }
                    }
                    
                    self.setTypingIndicatorViewHidden(true, animated: false)
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                 self.setTypingIndicatorViewHidden(true, animated: false)
            }
        }
    }
    
    private func mimeType(for data: Data) -> String {

        var b: UInt8 = 0
        data.copyBytes(to: &b, count: 1)

        switch b {
        case 0xFF:
            return "image/jpeg"
        case 0x89:
            return "image/png"
        case 0x47:
            return "image/gif"
        case 0x4D, 0x49:
            return "image/tiff"
        case 0x25:
            return "application/pdf"
        case 0xD0:
            return "application/vnd"
        case 0x46:
            return "text/plain"
        default:
            return "application/octet-stream"
        }
    }
}

extension ChatViewController : SCSChatSessionDelegate {
    public func session(_ session: SCSChatSession!, didError error: Error!, fatal: Bool) {
        debugPrint("Error : ", error)
    }
    
    public func session(_ session: SCSChatSession!, didUpdateQueuePosition position: NSNumber!, estimatedWaitTime waitTime: NSNumber!) {
        debugPrint("Queue : ", position)
        
        DispatchQueue.main.async {
            if (position.intValue == 0) {
                
            } else if (position.intValue < self.queuePosition) {
                self.queuePosition = position.intValue
                let msg = String(format: "Your place\nin line #%d", position.intValue)
                let message = MockMessage(text: msg, user: ChatViewController.callCenterUser, messageId: UUID().uuidString, date: Date())
                self.insertMessage(message)
            }
        }
    }
    
    public func session(_ session: SCSChatSession!, didEnd endEvent: SCSChatSessionEndEvent!) {
        debugPrint("Session End")
        self.salesforceEndChat = true
        DispatchQueue.main.async {
            let msg = "Session end by agent"
            let msgItems = ["type" : 2, "msg" : msg] as [String : Any]
            let message = MockMessage(custom: msgItems, user: ChatViewController.callCenterUser, messageId: UUID().uuidString, date: Date())
            self.insertMessage(message)
            
            self.messageInputBar.sendButton.isEnabled = false
            self.messageInputBar.setLeftStackViewWidthConstant(to: 0, animated: true)
            self.messageInputBar.inputTextView.isEditable = false
        }
    }
    
    public func session(_ session: SCSChatSession!, didTransitionFrom previous: SCSChatSessionState, to current: SCSChatSessionState) {
        debugPrint("Transition " , previous, current)
    }
}

extension ChatViewController : SCSChatEventDelegate {
    public func session(_ session: SCSChatSession!, agentJoined agentjoinedEvent: SCSAgentJoinEvent!) {
        DispatchQueue.main.async {
            ChatViewController.callCenterUser.displayName = agentjoinedEvent.sender?.name ?? "Agent"
            let msg = String(format: "%@ joined the chat", ChatViewController.callCenterUser.displayName)
            let msgItems = ["type" : 2, "msg" : msg] as [String : Any]
            let message = MockMessage(custom: msgItems, user: ChatViewController.callCenterUser, messageId: UUID().uuidString, date: Date())
            self.insertMessage(message)
            
            self.title = ChatViewController.callCenterUser.displayName
            
            let ignoreMessage = ["Connecting", "agent", "Your place", "TrueMoney Care สวัสดีครับ"]
            
            MINTEL_LiveChat.messageList.forEach { item in
                switch(item.kind) {
                    case .text(let str) :
                        var shouldIgnore = false
                        for i in 0...ignoreMessage.count - 1 {
                            if (str.starts(with: ignoreMessage[i])) {
                                shouldIgnore = true
                                break
                            }
                        }
                        if (!shouldIgnore) {
                            ServiceCloud.shared().chatCore.session.sendMessage(str)
                        }
                    break
                    case .attributedText(_): break
                    case .photo(_): break
                    case .video(_): break
                    case .location(_): break
                    case .emoji(_): break
                    case .audio(_): break
                    case .contact(_): break
                    case .custom(_): break
                }
               
            }
        }
    }
    
    public func session(_ session: SCSChatSession!, agentLeftConference agentLeftConferenceEvent: SCSAgentLeftConferenceEvent!) {
        debugPrint("Agent Left")
        DispatchQueue.main.async {
            let msg = "Agent left from the chat."
            let msgItems = ["type" : 2, "msg" : msg] as [String : Any]
            let message = MockMessage(custom: msgItems, user: ChatViewController.callCenterUser, messageId: UUID().uuidString, date: Date())
            self.insertMessage(message)
        }
    }
    
    public func session(_ session: SCSChatSession!, processedOutgoingMessage message: SCSUserTextEvent!) {
        debugPrint("process Outgoing Message : ", message)
    }
    
    public func session(_ session: SCSChatSession!, didUpdateOutgoingMessageDeliveryStatus message: SCSUserTextEvent!) {
        debugPrint("didUpdateOutgoingMessageDeliveryStatus : ", message)
        self.showStableStatus()
    }
    
    public func session(_ session: SCSChatSession!, didSelectMenuItem menuEvent: SCSChatMenuSelectionEvent!) {
        debugPrint("didSelectMenuItem : ", menuEvent)
    }
    
    public func session(_ session: SCSChatSession!, didReceiveMessage message: SCSAgentTextEvent!) {
        debugPrint("didReceiveMessage : ", message)
        DispatchQueue.main.async {
            self.insertMessage(MockMessage(text: message.text, user: ChatViewController.callCenterUser, messageId: UUID().uuidString, date: Date()))
        }
    }
    
    public func session(_ session: SCSChatSession!, didReceiveChatBotMenu menuEvent: SCSChatBotMenuEvent!) {
        debugPrint("didReceiveChatBotMenu : ", menuEvent)
    }
    
    public func session(_ session: SCSChatSession!, didReceiveFileTransferRequest fileTransferEvent: SCSFileTransferEvent!) {
        debugPrint("didReceiveFileTransferRequest : ", fileTransferEvent)
    }
    
    public func transferToButtonInitiated(with session: SCSChatSession!) {
        debugPrint("transferToButtonInitiated : ", session)
    }
    
    public func transferToButtonCompleted(with session: SCSChatSession!) {
        debugPrint("transferToButtonCompleted : ", session)
    }
    
    public func transferToButtonFailed(with session: SCSChatSession!, error: Error!) {
        debugPrint("transferToButtonFailed : ", session)
    }
}

extension UIImage {
    func toData (options: NSDictionary, type: CFString) -> Data? {
        guard let cgImage = cgImage else { return nil }
        return autoreleasepool { () -> Data? in
            let data = NSMutableData()
            guard let imageDestination = CGImageDestinationCreateWithData(data as CFMutableData, type, 1, nil) else { return nil }
            CGImageDestinationAddImage(imageDestination, cgImage, options)
            CGImageDestinationFinalize(imageDestination)
            return data as Data
        }
    }
}

extension ChatViewController: UIImagePickerControllerDelegate {

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true) {
            
        }
    }

    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        
        let fileName = "file.jpeg"
        // Upload Image
        self.dismiss(animated: true) {
            // Upload Image
            self.insertMessage(MockMessage(image: image, user: ChatViewController.user, messageId: UUID().uuidString, date: Date()))
            
//            self.setTypingIndicatorViewHidden(false, animated: true, whilePerforming: {
//
//            }) { success in
                
                let data = image.jpegData(compressionQuality: 1.0)
                self.upload(imageData: data, imageName: fileName, fileData: nil, fileName: nil, parameters: ["session_id": MINTEL_LiveChat.userId])
//            }
        }
    }
}

extension ChatViewController: UINavigationControllerDelegate {

}

extension ChatViewController : UIDocumentMenuDelegate, UIDocumentPickerDelegate {
    func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        
    }
    
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        self.documentPicker(url: url)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if urls.count > 0 {
            self.documentPicker(url: urls[0])
        }
    }
    
    private func documentPicker(url: URL) {
        debugPrint(url)
        
        self.hideBottomView()
        
        if FileManager.default.fileExists(atPath: url.path){
            
            let filename = (url.absoluteString as NSString).lastPathComponent
            self.insertMessage(MockMessage(text: filename, user: ChatViewController.user, messageId: UUID().uuidString, date: Date()))
            
            do {
                // Get the saved data
                let savedData = try Data(contentsOf: url)
                // Convert the data back into a string
                self.upload(imageData: nil, imageName: nil, fileData: savedData, fileName: filename, parameters: ["session_id": MINTEL_LiveChat.userId])
            } catch {
             // Catch any errors
             print("Unable to read the file")
            }
        }
    }
}
