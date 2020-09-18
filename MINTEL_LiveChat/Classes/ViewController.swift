//
//  ViewController.swift
//  SSChat
//
//  Created by Autthapon Sukajaroen on 13/08/2020
//  Copyright © 2020 Autthapon Sukjaroen. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import AVFoundation

internal class CellIds {
    
    static let senderCellId = "senderCellId"
    static let receiverCellId = "receiverCellId"
    static let receiverMenuCellid = "receiverMenuCellid"
    static let systemMessageCellId = "systemMessageCellId"
    static let systemMessageType2CellId = "systemMessageType2CellId"
    static let imageMessageCellId = "imageCellId"
    static let agentJoinCellId = "agentJoinCellId"
    static let fileCellid = "fileCellid"
    static let typingCellId = "typingCellId"
}

internal class MINTELNotifId {
    static let userIsTyping = "MINTEL_userIsTyping"
    static let userIsNotTyping = "MINTEL_userIsNotTyping"
    static let botTyped = "MINTEL_botTyped"
    static let chatMenuAvailable = "MINTEL_chatMenuAvailable"
    static let toAgentMode = "MINTEL_toAgentMode"
    static let reallyExitChat = "MINTEL_reallyExitChat"
    static let hideBottomMenu = "MINTEL_HideBottomMenu"
    static let updateUnreadMessageCount = "MINTEL_updateUnreadMessageCount"
}

internal class SalesForceNotifId {
    static let didUpdatePosition = "saleForceDidUpdatePosition"
    static let agentJoined = "saleForceAgentJoin"
    static let didReceiveMessage = "saleForceDidReceiveMessage"
    static let agentLeftConference = "saleForceAgentLeftConference"
    static let didEnd = "saleForceDidEnd"
}

class ViewController: UIViewController {
    
    // Saleforce
    var queuePosition : Int = 99999
    
    var imagePanel:Bool = false
    var chatMenuPanel:Bool = false
    
    var bottomHeight: CGFloat {
        let window = UIApplication.shared.keyWindow
        
        if #available(iOS 11.0, *) {
            return window?.safeAreaInsets.bottom ?? 0.0
        } else {
            return bottomLayoutGuide.length
        }
    }
    
    let imagePanelHeight:CGFloat = 245.0
    
    var imagePicker: UIImagePickerController!
    var fetchResult: PHFetchResult<PHAsset>!
    var assetCollection: PHAssetCollection!
    @IBOutlet weak var viewConfirm:UIView!
    @IBOutlet weak var btnConfirmExit:UIButton!
    @IBOutlet weak var btnConfirmBack:UIButton!
    var btnClose:UIBarButtonItem!
    
    fileprivate let imageManager = PHCachingImageManager()
    fileprivate var thumbnailSize: CGSize!
    fileprivate var previousPreheatRect = CGRect.zero
    fileprivate var imageSelected:[Int] = []
    internal var uploadDataFiles:Int = 0
    internal var uploadDataText:[String] = [];
    
    var tableView: UITableView = {
        let v = UITableView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var menuTableView: UITableView = {
       let v = UITableView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var inputTextView: InputTextView = {
        let v = InputTextView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var imagePanelView: UICollectionView = {
        
        let flowLayout = UICollectionViewFlowLayout()
        let size = ceil(UIScreen.main.bounds.size.width / 3.0) - 2
        let height = (16.0 * size) / 9.0
        flowLayout.itemSize = CGSize(width: size, height: height)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 3
        flowLayout.sectionInset = UIEdgeInsets(top: 2, left: 1, bottom: 1, right: 1)
        let v = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var inputTextViewBottomConstraint: NSLayoutConstraint!
    
    @IBAction func collapseChat() {
        MINTEL_LiveChat.unreadMessage = 0
        
        NotificationCenter.default.post(name: Notification.Name(MINTELNotifId.updateUnreadMessageCount),
        object: nil,
        userInfo:nil)
        
        MINTEL_LiveChat.instance.isHidden = false
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func closeChat() {
        if (MINTEL_LiveChat.chatInProgress) {
            self.inputTextView.textView.resignFirstResponder()
            self.viewConfirm.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
            self.view.addSubview(self.viewConfirm)
            
            self.btnConfirmBack.layer.borderColor = UIColor(MyHexString: "#F08833").cgColor
            self.btnConfirmBack.layer.borderWidth = 1
            self.btnConfirmBack.setTitleColor(UIColor(MyHexString: "#F08833"), for: .normal)
            self.btnConfirmBack.backgroundColor = UIColor.white

            self.btnClose = UIBarButtonItem(image: UIImage(named: "close", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil), style: .plain, target: self, action: #selector(self.closeChat))
            self.navigationItem.rightBarButtonItem = self.btnClose
            
            self.navigationItem.rightBarButtonItem = nil
            self.navigationItem.titleView = UIImageView(image: UIImage(named: "true_bar_title", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil))
            
        } else {
            self.dismiss(animated: true, completion: nil)
            MINTEL_LiveChat.instance.closeButtonHandle()
        }
    }
    
    @IBAction func hideConfirmExit() {
        self.viewConfirm.removeFromSuperview()
        self.btnClose = UIBarButtonItem(image: UIImage(named: "close", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil), style: .plain, target: self, action: #selector(self.closeChat))
        self.navigationItem.rightBarButtonItem = self.btnClose
        
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "true_bar_title", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil))
        
        
        
        self.btnClose = UIBarButtonItem(image: UIImage(named: "close", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil), style: .plain, target: self, action: #selector(self.closeChat))
        self.navigationItem.rightBarButtonItem = self.btnClose
    }
    
    @IBAction func confirmExitChat() {
        self.btnClose = UIBarButtonItem(image: UIImage(named: "close", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil), style: .plain, target: self, action: #selector(self.closeChat))
        self.navigationItem.rightBarButtonItem = self.btnClose
        
        MINTEL_LiveChat.instance.stopChat()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.btnClose = UIBarButtonItem(image: UIImage(named: "close", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil), style: .plain, target: self, action: #selector(self.closeChat))
        self.navigationItem.rightBarButtonItem = self.btnClose
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "true_bar_title", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil))
        self.view.backgroundColor = UIColor.white
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        self.setupViews()
        
        resetCachedAssets()
        PHPhotoLibrary.shared().register(self)
        
        if fetchResult == nil {
            let allPhotosOptions = PHFetchOptions()
            //            allPhotosOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            //            allPhotosOptions.includeAllBurstAssets = false
            //            allPhotosOptions.includeAssetSourceTypes = [.typeUserLibrary, .typeCloudShared]
            //            allPhotosOptions.includeHiddenAssets = false
            fetchResult = PHAsset.fetchAssets(with: .image, options: allPhotosOptions)
        }
        self.imagePanelView.reloadData()
        self.tableView.reloadData()
        self.tableView.scrollToBottom(animated: true)
        self.setupNotification()
        self.setupSaleForcesNotification()
        
        // Check Waiting agent state
        if (MINTEL_LiveChat.agentState == .waiting) {
            self.disableUserInteraction()
        }
    }
    
    fileprivate func setupNotification() {
        
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(botTyped(_:)),
                                               name: Notification.Name(MINTELNotifId.botTyped),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(toAgentModeFromNotification(_:)),
                                               name: Notification.Name(MINTELNotifId.toAgentMode),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(MINTEL_reallyEndChat(_:)),
                                               name: Notification.Name(MINTELNotifId.reallyExitChat),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                                selector: #selector(MINTEL_hideBottomMenu(_:)),
                                                name: Notification.Name(MINTELNotifId.hideBottomMenu),
                                                object: nil)
        
        NotificationCenter.default.addObserver(self,
                                                    selector: #selector(MINTEL_chatMenuAvailable(_:)),
                                                    name: Notification.Name(MINTELNotifId.chatMenuAvailable),
                                                    object: nil)
        
    }
    
    internal func removeNotification() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(MINTELNotifId.botTyped), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(MINTELNotifId.toAgentMode), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(MINTELNotifId.reallyExitChat), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(MINTELNotifId.hideBottomMenu), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(MINTELNotifId.chatMenuAvailable), object: nil)
    }
    
    
    @objc func MINTEL_chatMenuAvailable(_ notification: Notification) {
        DispatchQueue.main.async {
            self.menuTableView.reloadData()
        }
    }
    
    @objc func MINTEL_hideBottomMenu(_ notification: Notification) {
        DispatchQueue.main.async {
            self.imagePanel = false
            self.chatMenuPanel = false
            self.inputTextView.hideLeftMenu()
            let keyboardFrame = CGSize(width: 0.0, height: 0.0)
            self.inputTextViewBottomConstraint.constant = 0
            let oldOffset = self.tableView.contentOffset
            self.menuTableView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: 180.0)
            self.view.layoutIfNeeded()
            self.tableView.setContentOffset(CGPoint(x: oldOffset.x, y: oldOffset.y - keyboardFrame.height + self.bottomHeight), animated: false)
            self.inputTextView.becomeFirstResponder()
            self.tableView.scrollToBottom(animated: false)
        }
    }
    
    @objc func botTyped(_ notification: Notification) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.scrollToBottom(animated: true)
            if (MINTEL_LiveChat.chatCanTyped) {
                self.inputTextView.MINTEL_enable()
            }
        }
    }
    
    @objc func toAgentModeFromNotification(_ notification: Notification) {
        self.switchToAgentMode()
    }
    
    internal func disableUserInteraction(_ sendEnable:Bool = false) {
        let userInfo:[String: Any] = ["sendEnable" : sendEnable]
        let notif = Notification(name: Notification.Name(rawValue: "TEST"), userInfo: userInfo)
        self.inputTextView.MINTEL_reallyEndChat(notif)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let size = ceil(UIScreen.main.bounds.size.width / 3.0) - 3.0
        thumbnailSize = CGSize(width: size, height: size)
        
        if (MINTEL_LiveChat.agentState == .waiting || MINTEL_LiveChat.agentState == .end) {
            self.disableUserInteraction()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCachedAssets()
        
        if (!MINTEL_LiveChat.chatCanTyped) {
            self.disableUserInteraction()
        }
        MINTEL_LiveChat.chatPanelOpened  = true
        
        if (MINTEL_LiveChat.openConfirmExitPage) {
            MINTEL_LiveChat.openConfirmExitPage = false
            self.closeChat()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        MINTEL_LiveChat.chatPanelOpened = false
        
        self.removeNotification()
        self.removeSalesforceNotification()
    }
    
    func setupViews() {
        self.view.addSubview(tableView)
        tableView.MyEdges([.left, .right, .top], to: self.view, offset: .zero)
        tableView.backgroundColor = UIColor(MyHexString: "#FFFFFF")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CellIds.receiverCellId)
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CellIds.senderCellId)
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CellIds.receiverMenuCellid)
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CellIds.systemMessageCellId)
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CellIds.systemMessageType2CellId)
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CellIds.imageMessageCellId)
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CellIds.agentJoinCellId)
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CellIds.fileCellid)
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CellIds.typingCellId)
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tableViewTapped(recognizer:))))
        
        self.view.addSubview(inputTextView)
        inputTextView.MyEdges([.left, .right], to: self.view, offset: .zero)
        if #available(iOS 11.0, *) {
            inputTextViewBottomConstraint = inputTextView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        } else {
            // TODO
        }
        inputTextViewBottomConstraint.isActive = true
        inputTextView.topAnchor.constraint(equalTo: tableView.bottomAnchor).isActive = true
        inputTextView.delegate = self
        
        self.view.addSubview(imagePanelView)
        imagePanelView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        imagePanelView.backgroundColor = UIColor(MyHexString: "#EBEBEB")
        imagePanelView.delegate = self
        imagePanelView.dataSource = self
        imagePanelView.register(GridViewCell.self, forCellWithReuseIdentifier: String(describing: GridViewCell.self))
        
        // Setup Menu TableView
        self.menuTableView = UITableView()
        self.view.addSubview(self.menuTableView)
        self.menuTableView.delegate = self
        self.menuTableView.dataSource = self
//        self.menuTableView.backgroundColor = UIColor.red
        self.menuTableView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: 180.0)
        self.view.layoutIfNeeded()
    }
    
    @objc func keyboardWillShow(notification:NSNotification){
        let userInfo = notification.userInfo!
        if var keyboardFrame  = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, let keyboardAnimationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval {
            keyboardFrame = self.view.convert(keyboardFrame, from: nil)
            let oldOffset = self.tableView.contentOffset
            self.inputTextViewBottomConstraint.constant = -keyboardFrame.height + bottomHeight
            UIView.animate(withDuration: keyboardAnimationDuration) {
                self.view.layoutIfNeeded()
                self.tableView.setContentOffset(CGPoint(x: oldOffset.x, y: oldOffset.y + keyboardFrame.height - self.bottomHeight), animated: false)
            }
        }
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        let userInfo = notification.userInfo!
        if var keyboardFrame  = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, let keyboardAnimationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval, let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt {
            keyboardFrame = self.view.convert(keyboardFrame, from: nil)
            self.inputTextViewBottomConstraint.constant = 0
            let oldOffset = self.tableView.contentOffset
            UIView.animate(withDuration: keyboardAnimationDuration, delay: 0, options: UIView.AnimationOptions(rawValue: curve), animations: {
                self.view.layoutIfNeeded()
                self.tableView.setContentOffset(CGPoint(x: oldOffset.x, y: oldOffset.y - keyboardFrame.height + self.bottomHeight), animated: false)
            }, completion: nil)
        }
    }
    
    @objc func tableViewTapped(recognizer: UITapGestureRecognizer) {
        if (imagePanel) {
            self.hideImagePanel()
        }
        self.inputTextView.textView.resignFirstResponder()
    }
}

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (tableView == self.menuTableView) {
            return 1
        } else {
            return MessageList.count()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == self.menuTableView) {
            return MINTEL_LiveChat.chatMenus.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (tableView == self.menuTableView) {
            
            let menu = MINTEL_LiveChat.chatMenus[indexPath.row]
            let actions = menu["action"] as! [String:Any]
            let label = actions["label"] as! String
            
            let cell = UITableViewCell(style: .default, reuseIdentifier: "TEST")
            cell.textLabel?.text = label
            cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.lineBreakMode = .byWordWrapping
            cell.accessoryType = .disclosureIndicator
            return cell
            
        } else {
            let item = MessageList.at(index: indexPath.section)
            let agent = item.agent
            let bot = item.bot
            
            var cellIdentifierId:String
            switch item.kind {
            case .systemMessageType1( _):
                cellIdentifierId = CellIds.systemMessageCellId
            case .systemMessageType2( _):
                cellIdentifierId = CellIds.systemMessageType2CellId
            case .text( _):
                cellIdentifierId = agent || bot ? CellIds.receiverCellId : CellIds.senderCellId
            case .file(_, _):
                cellIdentifierId = CellIds.fileCellid
            case .menu( _, _):
                cellIdentifierId = CellIds.receiverMenuCellid
            case .image( _, _):
                cellIdentifierId = CellIds.imageMessageCellId
            case .agentJoin:
                cellIdentifierId = CellIds.agentJoinCellId
            case .typing:
                cellIdentifierId = CellIds.typingCellId
            }
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifierId, for: indexPath) as? CustomTableViewCell {
                cell.selectionStyle = .none
                cell.viewController = self
                
                switch item.kind {
                case .systemMessageType1(let txt):
                    cell.renderSystemMessage(text: txt)
                case .systemMessageType2(let txt):
                    cell.renderSystemMessageType2(text: txt)
                case .text(let txt):
                    
                    if (agent || bot) {
                        cell.renderReceiverCell(txt, item: item, index: indexPath.section, tableView: tableView)
                    } else {
                        cell.renderSender(txt: txt, item: item)
                    }
                case .file(let name, _):
                    cell.renderFileSend(txt: name, item: item, index: indexPath.section)
                case .menu(let title, let menus):
                    cell.setupMenuCell(title, menus, item)
                    let gesture = cell.tapGuesture ?? MyTapGuesture(target: self, action: #selector(didTap(_:)))
                    gesture.message = item
                    cell.addGestureRecognizer(gesture)
                case .image(let img, _):
                    cell.renderImageCell(image: img, time: item.sentDate, item: item, index: indexPath.section)
                    let gesture = cell.tapGuesture ?? MyTapGuesture(target: self, action: #selector(didTap(_:)))
                    gesture.message = item
                    cell.addGestureRecognizer(gesture)
                case .agentJoin(let agentName):
                    cell.renderAgentJoin(agentName)
                case .typing:
                    cell.renderTyping(item: item)
                }
                return cell
            }
            return UITableViewCell()
        }
    }
    
    @objc func didTap(_ sender: MyTapGuesture? = nil) {
        print("Tab")
        let message = sender?.message
        if (message?.disableMenu ?? false) {
            return
        }
        switch message?.kind {
        case .text( _):
            return
        case .menu(let title, let menus):
            if sender?.state == .ended {
                let touchLocation: CGPoint = (sender?.location(in: sender?.view))!
                findMenuOnTap(menus: menus, title: title, yPosition: touchLocation.y, message: message)
            }
        case .image(let image, let imageUrl):
            let temp:[String:Any] = ["image" : image, "imageUrl" : imageUrl]
            self.performSegue(withIdentifier: "previewImage", sender: temp)
        default:
            return
        }
    }
    
    fileprivate func findMenuOnTap(menus:[[String: Any]], title:String, yPosition:CGFloat, message: MyMessage?) {
//        print("yPosition", yPosition)
        
        // Hide InputBar
        self.inputTextView.textView.resignFirstResponder()
        self.hideImagePanel()
        self.hideChatMenuPanel()
        
        if (!MINTEL_LiveChat.chatBotMode) {
            return
        }
        
        if (!MINTEL_LiveChat.chatInProgress) {
            return
        }
        
        var targetAction:[String:Any]? = nil
        var yIndex = CGFloat(0.0)
        let image = UIImage(named: "chatbot", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil)
        let width = UIScreen.main.bounds.size.width - (8.0 + (image?.size.width ?? 0.0) + 10.0 + extraSpacing)
        var height = CGFloat(0.0)
        if (title.count > 0) {
            height = title.MyHeight(withConstrainedWidth: width, font: UIFont.systemFont(ofSize: 16.0))
            height = max(height, 40.0)
            yIndex = yIndex + height + 16
        }
        
        for i in 0..<menus.count {
            let item = menus[i]
            let actions = item["action"] as! [String:Any]
            let labelText = actions["label"] as? String ?? ""
            
            height = labelText.MyHeight(withConstrainedWidth: width, font: UIFont.systemFont(ofSize: 16.0))
            height = max(40.0, height)
            
            if (yPosition >= yIndex) {
                targetAction = actions
            }
            
            yIndex = yIndex + height + 16
        }
        
        if (targetAction != nil) {
            let text = targetAction?["text"] as? String ?? ""
            if (text.count > 0) {
                
                message?.disableMenu = true
                if ("__00_app_endchat" == text) {
                    
                    self.closeChat()
                    
                } else if ("__00_home_greeting" == text) {
                    MINTEL_LiveChat.instance.checkAgentMode()
                } else {
                
                    MINTEL_LiveChat.chatUserTypedIn = true
                    let display = targetAction?["display"] as? Bool ?? true
                    if (display) {
                        MessageList.add(item: MyMessage(text: text, agent: false, bot: false))
                    }
                    self.tableView.reloadData()
                    self.tableView.scrollToBottom(animated: true)
                    MINTEL_LiveChat.sendPost(text: text, menu: false)
                    if (self.imagePanel) {
                        self.hideImagePanel()
                    }
                }
            }
        }
    }
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView == self.menuTableView) {
            self.menuTableView.deselectRow(at: indexPath, animated: false)
            let menu = MINTEL_LiveChat.chatMenus[indexPath.row]
            let actions = menu["action"] as! [String:Any]
            let text = actions["text"] as! String
            let display = actions["display"] as? Bool ?? true
            if (display) {
                MessageList.add(item: MyMessage(text: text, agent: false, bot: false))
            }
            self.tableView.reloadData()
            self.tableView.scrollToBottom(animated: true)
            MINTEL_LiveChat.sendPost(text: text, menu: false)
            
            self.inputTextView.hideLeftMenu()
            self.inputTextView.textView.resignFirstResponder()
            self.MINTEL_hideBottomMenu(Notification(name: Notification.Name(rawValue: "TEST")))
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (tableView == self.menuTableView) {
            return UITableView.automaticDimension
        } else {
        
            let item = MessageList.at(index: indexPath.section)
            
            switch item.kind {
            case .systemMessageType1(let txt):
                return CustomTableViewCell.calcRowHeightSystemMessage(text: txt)
            case .systemMessageType2(let txt):
                return CustomTableViewCell.calcRowHeightSystemMessageType2(text: txt)
            case .text(let txt):
                if (item.bot) {
                    return CustomTableViewCell.calcReceiverCell(txt, item: item)
                } else {
                    return CustomTableViewCell.calcSender(txt: txt, item: item)
                }
            case .file(let fileName, _):
                return CustomTableViewCell.calcSender(txt: fileName, item: item)
            case .menu(let title, let menus):
                return CustomTableViewCell.calMenuCellHeight(title, menus, item)
            case .image(let image, _ ):
                return CustomTableViewCell.calcImageCellHeight(image)
            case .agentJoin:
                return CustomTableViewCell.calcAgentJoinCellHeight()
            case .typing:
                return 40
            }
        }
    }
}

extension UITableView {
    
    func scrollToBottom(animated: Bool){
        
        DispatchQueue.main.async {
            if (self.numberOfSections > 0) {
                let indexPath = IndexPath(
                    row: self.numberOfRows(inSection:  self.numberOfSections-1) - 1,
                    section: self.numberOfSections - 1)
                if self.hasRowAtIndexPath(indexPath: indexPath) {
                    self.scrollToRow(at: indexPath, at: .bottom, animated: animated)
                }
            }
        }
    }
    
    func scrollToTop() {
        
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: 0)
            if self.hasRowAtIndexPath(indexPath: indexPath) {
                self.scrollToRow(at: indexPath, at: .top, animated: false)
            }
        }
    }
    
    func hasRowAtIndexPath(indexPath: IndexPath) -> Bool {
        return indexPath.section < self.numberOfSections && indexPath.row < self.numberOfRows(inSection: indexPath.section)
    }
}

extension ViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "previewImage") {
            let temp = sender as! [String:Any]
            let destination = segue.destination as! ImagePreviewController
            destination.imageUrl = temp["imageUrl"] as? String
            destination.image = temp["image"] as? UIImage
        }
    }
}

extension ViewController: InputTextViewDelegate {
    
    func inputTextViewGotFocus(_ textView: UITextView) {
        self.hideImagePanel()
    }
    
    func didPressSendButton(_ text: String, _ sender: UIButton, _ textView: UITextView) {
        print(text)
        if (text.trimmingCharacters(in: .whitespacesAndNewlines).count > 0) {
            MINTEL_LiveChat.chatUserTypedIn = true
            MessageList.add(item: MyMessage(text: text, agent: false, bot: false))
            self.tableView.reloadData()
            self.tableView.scrollToBottom(animated: true)
            textView.text = ""
            
            if (MINTEL_LiveChat.chatBotMode) {
                MINTEL_LiveChat.sendPost(text: text, menu: false)
            } else {
                self.sendMessageToSaleForce(text: text)
            }
        } else if (self.imagePanel) {
            if (self.imageSelected.count > 0) {
                // Send Image
                self.uploadDataFiles = self.imageSelected.count
                self.imageSelected.forEach { (index) in
                    self.sendImageToWebhook(index: index)
                }
                
                self.imageSelected.removeAll()
                self.imagePanelView.reloadData()
                if (imagePanel) {
                    self.hideImagePanel()
                    self.checkImageSelectedForDisableInput()
                }
            }
        }
    }
    
    func didPressFirstLeftButton(_ sender: UIButton, _ textView: UITextView) {
        
        if (!chatMenuPanel) {
            sender.setImage(UIImage(named: "close", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil), for: .normal)
            self.showChatMenuPanel()
        } else if (imagePanel) {
            sender.setImage(UIImage(named: "image", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil), for: .normal)
            inputTextView.hideLeftMenu()
            textView.becomeFirstResponder()
            self.hideImagePanel()
        }
    }
    
    func didPressSecondLeftButton(_ sender: UIButton, _ textView: UITextView) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            checkCameraAccess()
            return
        }
        selectImageFrom(.camera)
    }
    
    internal func checkCameraAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied:
            print("Denied, request permission from settings")
            presentCameraSettings()
        case .restricted:
            print("Restricted, device owner must approve")
        case .authorized:
            print("Authorized, proceed")
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { success in
                if success {
                    print("Permission granted, proceed")
                } else {
                    print("Permission denied")
                }
            }
        }
    }
    
    func presentCameraSettings() {
        let alertController = UIAlertController(title: "Error",
                                                message: "Camera access is denied",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        alertController.addAction(UIAlertAction(title: "Settings", style: .cancel) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                    // Handle
                })
            }
        })
        
        present(alertController, animated: true)
    }
    
    func presentPhotoSetting() {
        let alertController = UIAlertController(title: "Error",
                                                message: "Photo Library access is denied",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        alertController.addAction(UIAlertAction(title: "Settings", style: .cancel) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                    // Handle
                })
            }
        })
        
        present(alertController, animated: true)
    }
    
    func didPressThirdLeftButton(_ sender: UIButton, _ textView: UITextView) {
        if (imagePanel) {
            sender.setImage(UIImage(named: "image", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil), for: .normal)
            self.hideImagePanel()
            self.tableView.scrollToBottom(animated: false)
        } else {
            sender.setImage(UIImage(named: "image_active", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil), for: .normal)
            self.showImagePanel()
        }
    }
    
    func didPressFourthLeftButton(_ sender: UIButton, _ textView: UITextView) {
        
        self.hideImagePanel()
        
        let importMenu = UIDocumentPickerViewController(documentTypes: ["com.apple.iwork.pages.pages", "com.apple.iwork.numbers.numbers", "com.apple.iwork.keynote.key","public.image", "com.apple.application", "public.item", "public.content", "public.audiovisual-content", "public.movie", "public.audiovisual-content", "public.video", "public.audio", "public.text", "public.data", "public.zip-archive", "com.pkware.zip-archive", "public.composite-content"], in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        importMenu.modalPresentationStyle = .fullScreen
        if #available(iOS 11.0, *) {
            importMenu.allowsMultipleSelection = true;
        }
        self.present(importMenu, animated: true) {
        }
        
        
        //        if FileManager.default.fileExists(atPath: url.path){
        //
        //            let filename = (url.absoluteString as NSString).lastPathComponent
        //            self.insertMessage(MockMessage(text: filename, user: ChatViewController.user, messageId: UUID().uuidString, date: Date()))
        //
        //            do {
        //                // Get the saved data
        //                let savedData = try Data(contentsOf: url)
        //                // Convert the data back into a string
        //                self.upload(imageData: nil, imageName: nil, fileData: savedData, fileName: filename, parameters: ["session_id": MINTEL_LiveChat.userId])
        //            } catch {
        //             // Catch any errors
        //             print("Unable to read the file")
        //            }
        //        }
        
    }
    
    func showChatMenuPanel() {
        
        self.inputTextView.textView.resignFirstResponder()
        self.chatMenuPanel = true
        self.imagePanel = false
        self.menuTableView.isHidden = false
        self.imagePanelView.isHidden = true
        
        let keyboardFrame = CGSize(width: 0, height: imagePanelHeight)
        self.inputTextViewBottomConstraint.constant = -180.0
        let oldOffset = self.tableView.contentOffset
        self.menuTableView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height - imagePanelHeight, width: UIScreen.main.bounds.size.width, height: 180.0)
        self.view.layoutIfNeeded()
        self.tableView.setContentOffset(CGPoint(x: oldOffset.x, y: oldOffset.y + keyboardFrame.height - self.bottomHeight), animated: false)
        self.tableView.scrollToBottom(animated: false)
    }
    
    func hideChatMenuPanel() {
        self.imagePanel = false
        self.chatMenuPanel = false
        self.inputTextView.hideLeftMenu()
        let keyboardFrame = CGSize(width: 0.0, height: 0.0)
        self.inputTextViewBottomConstraint.constant = 0
        let oldOffset = self.tableView.contentOffset
        self.menuTableView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: 180.0)
        self.view.layoutIfNeeded()
        self.tableView.setContentOffset(CGPoint(x: oldOffset.x, y: oldOffset.y - keyboardFrame.height + self.bottomHeight), animated: false)
        self.inputTextView.becomeFirstResponder()
    }
    
    func showImagePanel() {
        
        self.inputTextView.textView.resignFirstResponder()
        self.chatMenuPanel = false
        self.imagePanel = true
        self.imagePanelView.isHidden = false
        self.menuTableView.isHidden = true
        
        let keyboardFrame = CGSize(width: 0, height: imagePanelHeight)
        self.inputTextViewBottomConstraint.constant = -180.0
        let oldOffset = self.tableView.contentOffset
        self.imagePanelView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height - imagePanelHeight, width: UIScreen.main.bounds.size.width, height: 180.0)
        self.view.layoutIfNeeded()
        self.tableView.setContentOffset(CGPoint(x: oldOffset.x, y: oldOffset.y + keyboardFrame.height - self.bottomHeight), animated: false)
        self.tableView.scrollToBottom(animated: false)
    }
    
    func hideImagePanel() {
        self.imagePanel = false
        self.imageSelected.removeAll()
        self.inputTextView.hideLeftMenu()
        let keyboardFrame = CGSize(width: 0.0, height: 0.0)
        self.inputTextViewBottomConstraint.constant = 0
        let oldOffset = self.tableView.contentOffset
        self.imagePanelView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: 180.0)
        self.view.layoutIfNeeded()
        self.tableView.setContentOffset(CGPoint(x: oldOffset.x, y: oldOffset.y - keyboardFrame.height + self.bottomHeight), animated: false)
        self.inputTextView.becomeFirstResponder()
        self.imagePanelView.reloadData()
    }
}

extension ViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    enum ImageSource {
        case photoLibrary
        case camera
    }
    
    func selectImageFrom(_ source: ImageSource){
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        switch source {
        case .camera:
            imagePicker.sourceType = .camera
        case .photoLibrary:
            imagePicker.sourceType = .photoLibrary
        }
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        imagePicker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }
        
        let fileName = "file.jpeg"
        let data = selectedImage.jpegData(compressionQuality: 1.0)
        MessageList.add(item: MyMessage(image: selectedImage, imageUrl: ""))
        self.tableView.reloadData()
        self.tableView.scrollToBottom(animated: true)
        self.upload(imageData: data, imageName: fileName, fileData: nil, fileName: nil, parameters: ["session_id": "1"])
    }
}


extension ViewController : UIDocumentMenuDelegate, UIDocumentPickerDelegate {
    func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
    }
    
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        self.uploadDataFiles = 1;
        self.documentPicker(url: url)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if urls.count > 0 {
            self.uploadDataFiles = urls.count;
            urls.forEach { url in
                self.documentPicker(url: url)
            }
        }
    }
    
    private func documentPicker(url: URL) {
        debugPrint(url)
        
        if FileManager.default.fileExists(atPath: url.path){
            
            let filename = (url.absoluteString as NSString).lastPathComponent
            MessageList.add(item: MyMessage(fileName: filename, fileURL: url))
            self.tableView.reloadData()
            self.tableView.scrollToBottom(animated: true)
            do {
                // Get the saved data
                let savedData = try Data(contentsOf: url)
                // Convert the data back into a string
                self.upload(imageData: nil, imageName: nil, fileData: savedData, fileName: filename, parameters: ["session_id": "1"])
            } catch {
                // Catch any errors
                print("Unable to read the file")
            }
        }
    }
}

// Agent Mode


extension ViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return thumbnailSize
    }
    
    @objc fileprivate func didSelectImage(_ sender: Checkbox) {
        if (sender.isChecked) {
            self.imageSelected.append(sender.tag)
        } else {
            self.imageSelected = self.imageSelected.filter { $0 != sender.tag }
        }
        self.imageSelected = self.imageSelected.sorted()
        debugPrint(self.imageSelected)
        self.checkImageSelectedForDisableInput()
    }
    
    fileprivate func checkImageSelectedForDisableInput() {
        if (self.imageSelected.count > 0) {
            self.inputTextView.MINTEL_inputTextForImageSelectedState(enable: false)
        } else {
            self.inputTextView.MINTEL_inputTextForImageSelectedState(enable: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = fetchResult.object(at: indexPath.item)
        
        debugPrint(asset, asset.mediaSubtypes.rawValue, PHAssetMediaType.audio)
        
        // Dequeue a GridViewCell.
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: GridViewCell.self), for: indexPath) as? GridViewCell
            else { fatalError("unexpected cell in collection view") }
        
        // Add a badge to the cell if the PHAsset represents a Live Photo.
        //        if asset.mediaSubtypes.contains(.photoLive) {
        //           cell.livePhotoBadgeImage = PHLivePhotoView.livePhotoBadgeImage(options: .overContent)
        //        }
        
        // Request an image for the asset from the PHCachingImageManager.
        cell.representedAssetIdentifier = asset.localIdentifier
        cell.checkbox.tag = indexPath.item
        cell.checkbox.addTarget(self, action: #selector(self.didSelectImage(_:)), for: .valueChanged)
        cell.checkbox.isChecked = self.imageSelected.contains(indexPath.item)
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        //        options.isSynchronous = true
        //        options.isNetworkAccessAllowed = true
        let requestSize = CGSize(width: 500, height: 500)
        imageManager.requestImage(for: asset, targetSize: requestSize, contentMode: .aspectFill, options: options, resultHandler: { image, _ in
            // The cell may have been recycled by the time this handler gets called;
            // set the cell's thumbnail image only if it's still showing the same asset.
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.thumbnailImage = image
            } else {
                print("NONONO")
            }
        })
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.sendImageToWebhook(index: indexPath.item)
        if (imagePanel) {
            self.hideImagePanel()
            self.checkImageSelectedForDisableInput()
        }
    }
    
    fileprivate func sendImageToWebhook(index: Int) {
        let asset = fetchResult.object(at: index)
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .none
        options.isSynchronous = true
        options.isNetworkAccessAllowed = true
        imageManager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize , contentMode: .aspectFill, options: options) { (image, info) in
            let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
            if isDegraded {
                return
            }
    
            if (image != nil) {
                let fileName = "file.jpeg"
                let data = image!.jpegData(compressionQuality: 1.0)
                MessageList.add(item: MyMessage(image: image!, imageUrl: ""))
                self.tableView.reloadData()
                self.tableView.scrollToBottom(animated: true)
                self.upload(imageData: data, imageName: fileName, fileData: nil, fileName: nil, parameters: ["session_id": "1"])
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (fetchResult == nil) {
            return 0
        }
        return fetchResult.count
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCachedAssets()
    }
    
    fileprivate func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
    
    fileprivate func updateCachedAssets() {
        // Update only if the view is visible.
        guard isViewLoaded && view.window != nil else { return }
        
        // The preheat window is twice the height of the visible rect.
        let visibleRect = CGRect(origin: imagePanelView.contentOffset, size: imagePanelView.bounds.size)
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
        
        // Update only if the visible area is significantly different from the last preheated area.
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > view.bounds.height / 3 else { return }
        
        // Compute the assets to start caching and to stop caching.
        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        let addedAssets = addedRects
            .flatMap { rect in self.imagePanelView.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        let removedAssets = removedRects
            .flatMap { rect in self.imagePanelView.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        
        // Update the assets the PHCachingImageManager is caching.
        imageManager.startCachingImages(for: addedAssets,
                                        targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        imageManager.stopCachingImages(for: removedAssets,
                                       targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        
        // Store the preheat rect to compare against in the future.
        previousPreheatRect = preheatRect
    }
    
    fileprivate func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                 width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                 width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                   width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                   width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }
    
}

private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}

extension ViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        guard let changes = changeInstance.changeDetails(for: fetchResult)
            else { return }
        
        // Change notifications may be made on a background queue. Re-dispatch to the
        // main queue before acting on the change as we'll be updating the UI.
        DispatchQueue.main.sync {
            // Hang on to the new fetch result.
            fetchResult = changes.fetchResultAfterChanges
            if changes.hasIncrementalChanges {
                // If we have incremental diffs, animate them in the collection view.
                self.imagePanelView.performBatchUpdates({
                    // For indexes to make sense, updates must be in this order:
                    // delete, insert, reload, move
                    if let removed = changes.removedIndexes, removed.count > 0 {
                        self.imagePanelView.deleteItems(at: removed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    if let inserted = changes.insertedIndexes, inserted.count > 0 {
                        self.imagePanelView.insertItems(at: inserted.map({ IndexPath(item: $0, section: 0) }))
                    }
                    if let changed = changes.changedIndexes, changed.count > 0 {
                        self.imagePanelView.reloadItems(at: changed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    changes.enumerateMoves { fromIndex, toIndex in
                        self.imagePanelView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                     to: IndexPath(item: toIndex, section: 0))
                    }
                })
            } else {
                // Reload the collection view if incremental diffs are not available.
                self.imagePanelView.reloadData()
            }
            resetCachedAssets()
        }
    }
}
