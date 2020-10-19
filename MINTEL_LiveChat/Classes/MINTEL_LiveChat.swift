//
//  iOSChatHead.swift
//  iOSChatHead
//
//  Created by iMac on 10/23/18.
//  Copyright © 2018 jriosdev. All rights reserved.
//
import UIKit
import ServiceCore
import ServiceChat
import Alamofire
import SafariServices
import UserNotifications

let autoDockingDuration: Double = 0.2
let doubleTapTimeInterval: Double = 0.36
var firstTimerDuration: Int = 2
var secondTimerDuration: Int = 1

protocol ChatDelegate{
    func terminate()
}

internal enum SaleforceAgentState {
    case start
    case waiting
    case joined
    case end
}

fileprivate let timeout:TimeInterval = 10
fileprivate var retryTimeoutTimes = 0

public class MINTEL_LiveChat: UIView {
    
    fileprivate static var userImageFrame:CGRect = CGRect()
    internal static var configuration:LiveChatConfiguration? = nil
    internal static var userId = ""
    internal static var userName = ""
    internal static var chatPanelOpened = false
    internal static var chatStarted = false
    internal static var chatCanTyped = false
    internal static var chatUserTypedIn = false
    internal static var surveyMode = false
    internal static var instance:MINTEL_LiveChat!
    internal static var agentName:String = ""
    internal static var agentState:SaleforceAgentState = .start
    internal static var chatBotMode = true
    internal static var chatMenus:[[String:Any]] = []
    internal static var unreadMessage:Int = 0
    //    internal static var items = [MyMessage]()
    
    fileprivate static var first2MinutesTimer:Timer? = nil
    fileprivate static var lastAMinuteTimer:Timer? = nil
    private var notification:MINTEL_Notifications = MINTEL_Notifications()
    private var draggable: Bool = true
    private var dragging: Bool = false
    private var autoDocking: Bool = true
    private var singleTapBeenCanceled: Bool = false
    
    private let viewHeight = CGFloat(200)
    private let closeButtonHeight = CGFloat(65)
    internal static var chatInProgress = false
    internal static var openConfirmExitPage = false
    
    private var beginLocation: CGPoint?
    private var closeButton:UIButton!
    private var userImageView:UIImageView!
    private var queueTitleLabel:UILabel!
    private var queueLabel:UILabel!
    private var callCenterLabel:UILabel!
    private var badgeLabel:UILabel!
    private var surveyView:MINTEL_SurveyController!
    
    private var longPressGestureRecognizer: UILongPressGestureRecognizer?
    private var tapGestureRecognizer:UITapGestureRecognizer?
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.translatesAutoresizingMaskIntoConstraints = true
        self.configDefaultSettingWithType()
        self.setupView()
        UIApplication.shared.keyWindow?.bringSubviewToFront(self)
        self.isHidden = true
        MINTEL_LiveChat.instance = self
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addButtonToKeyWindow()
        self.configDefaultSettingWithType()
        self.setupView()
        UIApplication.shared.keyWindow?.bringSubviewToFront(self)
        self.isHidden = true
        MINTEL_LiveChat.instance = self
    }
    
    public static func applicationWillTerminate(_ application: UIApplication) {
        if (!MINTEL_LiveChat.chatBotMode) {
            MINTEL_LiveChat.instance.closeButtonHandle()
        }
    }
    
    public func reLayoutView() {
        DispatchQueue.main.async {
            if (!MINTEL_LiveChat.chatPanelOpened) {
                self.layer.zPosition = 1
                self.isHidden = false
            }
            if (!MINTEL_LiveChat.chatInProgress || MINTEL_LiveChat.agentState == .end) {
                self.userImageView.image = UIImage(named: "end", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil)
                self.userImageView.frame = CGRect(x: self.userImageView.frame.origin.x + (self.userImageView.frame.size.width / 2) - 20, y:  self.userImageView.frame.origin.y + 10, width: 40, height: 40)
                self.userImageView.isHidden = false
                self.callCenterLabel.isHidden = false
                self.callCenterLabel.text = "จบการสนทนา"
                self.queueTitleLabel.isHidden = true
                self.queueLabel.isHidden = true
            } else if (MINTEL_LiveChat.chatBotMode) {
                self.userImageView.image = UIImage(named: "user", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil)
                self.userImageView.frame = MINTEL_LiveChat.userImageFrame
                self.userImageView.isHidden = false
                self.callCenterLabel.isHidden = false
                self.callCenterLabel.text = "แชทบอท"
                self.queueTitleLabel.isHidden = true
                self.queueLabel.isHidden = true
            } else {
                switch MINTEL_LiveChat.agentState {
                case .start:
                    self.userImageView.isHidden = true
                    self.callCenterLabel.isHidden = true
                    self.queueTitleLabel.isHidden = false
                    self.queueLabel.isHidden = false
                    break
                case .waiting:
                    self.userImageView.isHidden = true
                    self.callCenterLabel.isHidden = true
                    self.queueTitleLabel.isHidden = false
                    self.queueLabel.isHidden = false
                    break
                case .end:
                    self.userImageView.isHidden = true
                    self.callCenterLabel.isHidden = true
                    self.queueTitleLabel.isHidden = false
                    self.queueLabel.isHidden = false
                    break
                case .joined:
                    self.userImageView.image = UIImage(named: "agent", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil)
                    self.userImageView.frame = MINTEL_LiveChat.userImageFrame
                    self.userImageView.isHidden = false
                    self.callCenterLabel.isHidden = false
                    self.callCenterLabel.text = MINTEL_LiveChat.agentName
                    self.queueTitleLabel.isHidden = true
                    self.queueLabel.isHidden = true
                    break
                }
            }
        }
    }
    
    fileprivate func checkNotificationPermission() {
        
        
        let notificationCenter = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        notificationCenter.requestAuthorization(options: options) {
            (didAllow, error) in
            if !didAllow {
                print("User has declined notifications")
            }
        }
    }
    
    public func isSessionActive() -> Bool {
        return MINTEL_LiveChat.chatStarted
    }
    
    public func getSDKVersion() -> String {
        if let version = Bundle(identifier: "org.cocoapods.MINTEL-LiveChat")?.infoDictionary?["CFBundleShortVersionString"] as? String {
            print(version)
            return version
        }
        
        return ""
    }
    
    public func startChat(config:LiveChatConfiguration) {
        
        notification.userRequest()
        if (MINTEL_LiveChat.chatInProgress) {
            
            if (config.phone == MINTEL_LiveChat.configuration?.phone) {
                if (self.isHidden == true) {
                    self.isHidden = false
                    self.tapAction(sender: UIButton(), survey: MINTEL_LiveChat.surveyMode)
                    return
                }
            } else {
                self.cleanChat()
            }
        } else if (MINTEL_LiveChat.chatStarted) {
            return
        }
        
        self.layer.zPosition = 1
        MINTEL_LiveChat.openConfirmExitPage = false
        MINTEL_LiveChat.userId = UUID().uuidString
        MINTEL_LiveChat.configuration = config
        MINTEL_LiveChat.userName = config.userName
        MINTEL_LiveChat.chatBotMode = true
        MINTEL_LiveChat.chatStarted = false
        MINTEL_LiveChat.chatInProgress = true
        MINTEL_LiveChat.chatCanTyped = false
        MINTEL_LiveChat.chatUserTypedIn = false
        MINTEL_LiveChat.unreadMessage = 0
        MINTEL_LiveChat.agentState = .start
        retryTimeoutTimes = 0
        self.loadFirstMessage()
        self.isHidden = false
        UIApplication.shared.keyWindow?.bringSubviewToFront(self)
        
        let bundle = Bundle(for: type(of: self))
        let storyboard = UIStoryboard(name: "ChatBox", bundle: bundle)
        self.surveyView = storyboard.instantiateViewController(withIdentifier: "survey") as? MINTEL_SurveyController
        
        if (MINTEL_LiveChat.configuration?.disableBotMode ?? false) {
            
            MessageList.add(item: MyMessage(systemMessageType2: "กรุณารอสักครู่"), remove: true)
            MINTEL_LiveChat.chatBotMode = false
            MINTEL_LiveChat.instance.startSaleForce()
            MINTEL_LiveChat.stopTimer()
        } else {
            self.tapAction(sender: NSObject(), survey: false)
        }
        
        self.reLayoutView()
    }
    
    fileprivate func setupNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateBadge(_:)),
                                               name: Notification.Name(MINTELNotifId.updateUnreadMessageCount),
                                               object: nil)
    }
    
    fileprivate func removeNotification() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(MINTELNotifId.updateUnreadMessageCount), object: nil)
    }
    
    @objc fileprivate func updateBadge(_ notification: Notification) {
        DispatchQueue.main.async {
            if (MINTEL_LiveChat.unreadMessage == 0) {
                self.badgeLabel.isHidden = true
            } else {
                self.badgeLabel.text = String(format: "%d", MINTEL_LiveChat.unreadMessage)
                self.badgeLabel.isHidden = false
            }
        }
    }
    
    public func hideChat() {
        if (MINTEL_LiveChat.chatPanelOpened) {
            let currentViewController = self.topViewController()
            if let cu = currentViewController {
                cu.dismiss(animated: false) {
                    self.isHidden = true
                }
            }
        } else {
            self.isHidden = true
        }
    }
    
    public func stopChat() {
        self.reallyEndChat()
    }
    
    fileprivate func cleanChat() {
        self.removeNotification()
        if #available(iOS 9.0, *) {
            Alamofire.SessionManager.default.session.getAllTasks { (tasks) in
                tasks.forEach{ $0.cancel() }
            }
        } else {
            Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
                sessionDataTask.forEach { $0.cancel() }
                uploadData.forEach { $0.cancel() }
                downloadData.forEach { $0.cancel() }
            }
        }
        
        MINTEL_LiveChat.chatInProgress = false
        
        ServiceCloud.shared().chatCore.stopSession()
        ServiceCloud.shared().chatCore.remove(delegate: self)
        ServiceCloud.shared().chatCore.removeEvent(delegate: self)
        
        MINTEL_LiveChat.agentState = .start
        MINTEL_LiveChat.chatStarted = false
        MessageList.clear()
    }
    
    internal func reallyEndChat() {
        
        self.removeNotification()
        
        if (!MINTEL_LiveChat.chatInProgress) {
            self.exitApp()
            return
        }
        
        if #available(iOS 9.0, *) {
            Alamofire.SessionManager.default.session.getAllTasks { (tasks) in
                tasks.forEach{ $0.cancel() }
            }
        } else {
            Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
                sessionDataTask.forEach { $0.cancel() }
                uploadData.forEach { $0.cancel() }
                downloadData.forEach { $0.cancel() }
            }
        }
        
        MINTEL_LiveChat.chatInProgress = false
        ServiceCloud.shared().chatCore.stopSession()
        ServiceCloud.shared().chatCore.remove(delegate: self)
        ServiceCloud.shared().chatCore.removeEvent(delegate: self)
        MINTEL_LiveChat.agentState = .end
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        let date24 = dateFormatter.string(from: date)
        
        let _ = MessageList.add(item: MyMessage(systemMessageType1: String(format: "Chat ended %@", date24)))
        NotificationCenter.default.post(name: Notification.Name(MINTELNotifId.reallyExitChat),
                                        object: nil,
                                        userInfo:nil)
        
        self.reLayoutView()
        if (MINTEL_LiveChat.chatStarted) {
            self.openSurvey(bot: MINTEL_LiveChat.chatBotMode)
        } else {
            let currentViewController = self.topViewController()
            if let cu = currentViewController {
                cu.dismiss(animated: false) {
                    self.exitApp()
                }
            }
        }
        
        MINTEL_LiveChat.agentState = .start
        MINTEL_LiveChat.chatStarted = false
        MessageList.clear()
    }
    
    internal func checkAgentMode() {
        let url = String(format: "%@/botconfig", MINTEL_LiveChat.configuration?.webHookBaseUrl ?? "")
        let header:HTTPHeaders = [
            "x-api-key": MINTEL_LiveChat.configuration?.xApikey ?? "" // "381b0ac187994f82bdc05c09d1034afa"
        ]
        
        Alamofire
            .request(url, method: .get, parameters: nil, encoding: JSONEncoding.init(), headers: header)
            .responseJSON(completionHandler: { response in
                //                debugPrint(response)
                
                if let json = response.value {
                    let dict = json as! [String:Any]
                    let disableBotMode = dict["disableBotMode"] as? Bool ?? false
                    if (disableBotMode) {
                        MINTEL_LiveChat.stopTimer()
                        
                        // REmove previous กรุณารอสักครู่
                        MessageList.add(item: MyMessage(systemMessageType2: "กรุณารอสักครู่"), remove: true)
                        MINTEL_LiveChat.chatBotMode = false
                        MINTEL_LiveChat.instance.startSaleForce()
                    } else {
                        firstTimerDuration = (dict["activeChatReminder"] as? Int ?? 120) / 60
                        secondTimerDuration = (dict["chatTimeout"] as? Int ?? 60) / 60
                        MINTEL_LiveChat.chatUserTypedIn = true
                        MINTEL_LiveChat.sendPost(text: "__00_home__greeting", menu: false)
                    }
                }
            })
    }
    
    fileprivate func openSurvey(bot:Bool) {
        
        DispatchQueue.main.async {
            self.isHidden = false
            
            if (MINTEL_LiveChat.surveyMode) {
                let appViewController = UIApplication.shared.windows.first!.rootViewController!
                let navigationController = UINavigationController(rootViewController: self.surveyView)
                navigationController.modalPresentationStyle = .fullScreen
                appViewController.present(navigationController, animated: true, completion: nil)
                return
            }
            
            var surveyUrl:String = ""
            if (bot) {
                surveyUrl = MINTEL_LiveChat.configuration?.surveyChatbotUrl ?? ""
            } else {
                surveyUrl = MINTEL_LiveChat.configuration?.surveyFormUrl ?? ""
            }
            
            surveyUrl = surveyUrl.replacingOccurrences(of: "sessionId", with: MINTEL_LiveChat.userId)
            
            debugPrint("Survey Url : " ,surveyUrl)
            
            // Open Survey Url
            guard let url = URL(string: surveyUrl) else { return }
            if (UIApplication.shared.canOpenURL(url)) {
                let currentViewController = self.topViewController()
                if let cu = currentViewController {
                    cu.dismiss(animated: false) {
                        let appViewController = UIApplication.shared.windows.first!.rootViewController!

                        let navigationController = UINavigationController(rootViewController: self.surveyView)
                        navigationController.modalPresentationStyle = .fullScreen
                        
                        MINTEL_LiveChat.surveyMode = true
                        self.surveyView.url = url
                        appViewController.present(navigationController, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    
    fileprivate func topViewController(_ viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = viewController as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = viewController as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = viewController?.presentedViewController {
            return topViewController(presented)
        }
        return viewController
    }
    
    internal func loadFirstMessage() {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let date24 = dateFormatter.string(from: date)
        
        let _ = MessageList.add(item: MyMessage(systemMessageType1: String(format: "เริ่มการสนทนา %@", date24)))
        if (!(MINTEL_LiveChat.configuration?.disableBotMode ?? false)) {
            self.getAnnouncementMessage()
            MINTEL_LiveChat.sendOnNewSession()
        }
        
        MINTEL_LiveChat.sendPost(text: "สวัสดี", menu: true)
        MINTEL_LiveChat.checkTime()
    }
    
    public func sendToFront() {
        UIApplication.shared.keyWindow?.bringSubviewToFront(self)
    }
    
    internal  func checkTransferQueue() {
        let params : Parameters = ["session_id": MINTEL_LiveChat.userId]
        debugPrint("Url : " , params)
        let url = String(format: "%@/transferqueue", MINTEL_LiveChat.configuration?.webHookBaseUrl ?? "")
        let headers:HTTPHeaders = [
            "x-api-key": MINTEL_LiveChat.configuration?.xApikey ?? "" // "edf1ca88a09546f8a0667c81c93d1f31"
        ]
        
        do {
            let jsonEncode = JSONEncoding.init()
            let originalRequest:URLRequest? = try URLRequest(url: url, method: .post, headers: headers)
            let encodedURLRequest = try jsonEncode.encode(originalRequest!, with: params)
            Alamofire
                .request(encodedURLRequest)
                .responseJSON { (response) in
                    
                    switch response.result {
                    case .success(_):
                        if let json = response.value {
                            if let item = json as? [String:Any] {
                                let buttonId = item["buttonId"] as? String ?? "default"
                                if (buttonId != "default") {
                                    self.configureSaleForce(buttonId: buttonId)
                                    return
                                }
                            }
                        }
                        
                        self.configureSaleForce(buttonId: MINTEL_LiveChat.configuration?.salesforceButtonID ?? "")
                        break
                    case .failure( _):
                        break
                    }
            }
        } catch {
            debugPrint("Error In Catch")
        }
    }
    
    internal func startSaleForce() {
        self.setupNotification()
        self.checkTransferQueue()
    }
    
    private func configureSaleForce(buttonId: String) {
        
        if let config = SCSChatConfiguration(liveAgentPod: MINTEL_LiveChat.configuration?.salesforceLiveAgentPod,
                                             orgId: MINTEL_LiveChat.configuration?.salesforceOrdID,
                                             deploymentId: MINTEL_LiveChat.configuration?.salesforceDeployID,
                                             buttonId: buttonId) {
            
            config.visitorName = String(format:"%@ %@", MINTEL_LiveChat.configuration?.firstname ?? "", MINTEL_LiveChat.configuration?.lastname ?? "")
            config.queueStyle = .position // Fixed
            
            let firstNameField = SCSPrechatObject(label: "First Name", value: MINTEL_LiveChat.configuration?.firstname ?? "")
            let lastNameField = SCSPrechatObject(label: "Last Name", value: MINTEL_LiveChat.configuration?.lastname ?? "")
            let emailField = SCSPrechatObject(label: "Email", value: MINTEL_LiveChat.configuration?.email ?? "")
            let phoneFiled = SCSPrechatObject(label: "Phone", value: MINTEL_LiveChat.configuration?.phone ?? "")
            let tmnIdFiled = SCSPrechatObject(label: "TMN_ID_CLT__c", value: MINTEL_LiveChat.configuration?.tmnId ?? "")
            let contactEntity = SCSPrechatEntity(entityName: "Contact")
            contactEntity.saveToTranscript = "Contact"
            
            let firstNameEntityField = SCSPrechatEntityField(fieldName: "FirstName", label: "First Name")
            firstNameEntityField.doFind = false
            firstNameEntityField.isExactMatch = false
            firstNameEntityField.doCreate = true
            contactEntity.entityFieldsMaps.add(firstNameEntityField)
            
            let lastNameEntityField = SCSPrechatEntityField(fieldName: "LastName", label: "Last Name")
            lastNameEntityField.doFind = false
            lastNameEntityField.isExactMatch = false
            lastNameEntityField.doCreate = true
            contactEntity.entityFieldsMaps.add(lastNameEntityField)
            
            let emailEntityField = SCSPrechatEntityField(fieldName: "Email", label: "Email")
            emailEntityField.doFind = true
            emailEntityField.isExactMatch = true
            emailEntityField.doCreate = true
            contactEntity.entityFieldsMaps.add(emailEntityField)
            
            let phoneEntityField = SCSPrechatEntityField(fieldName: "Phone", label: "Phone")
            phoneEntityField.doFind = false
            phoneEntityField.isExactMatch = false
            phoneEntityField.doCreate = true
            contactEntity.entityFieldsMaps.add(phoneEntityField)
            
            let tmnIdEntityField = SCSPrechatEntityField(fieldName: "TMN_ID_CLT__c", label: "TMN_ID_CLT__c")
            tmnIdEntityField.doFind = false
            tmnIdEntityField.isExactMatch = false
            tmnIdEntityField.doCreate = true
            contactEntity.entityFieldsMaps.add(tmnIdEntityField)
            
            // Create an entity mapping for a Case record type
            let csatEntity = SCSPrechatEntity(entityName: "CSAT_Score__c")
            csatEntity.saveToTranscript = "CSAT_Score__c"
            csatEntity.showOnCreate = true
            //csatEntity.linkToEntityName = "Case"
            //csatEntity.linkToEntityField = "ContactId"   // Link this entity to Case.ContactId
            
            // Add one field mappings to our Case entity
            
            let csatUuid = MINTEL_LiveChat.userId
            debugPrint("User Session id : " , csatUuid)
            let uniqueFiled = SCSPrechatObject(label: "Unique_ID__c", value: csatUuid)
            let uniqueEntityField = SCSPrechatEntityField(fieldName: "Unique_ID__c", label: "Unique_ID__c")
            uniqueEntityField.doCreate = true
            csatEntity.entityFieldsMaps.add(uniqueEntityField)
            
            config.prechatFields = [firstNameField, lastNameField, emailField, phoneFiled, tmnIdFiled, uniqueFiled] as [SCSPrechatObject]
            // Update config object with the entity mappings
            config.prechatEntities = [contactEntity, csatEntity]
            //            config.allowBackgroundNotifications = false
            
            ServiceCloud.shared().chatCore.remove(delegate: self)
            ServiceCloud.shared().chatCore.removeEvent(delegate: self)
            
            //            ServiceCloud.shared().chatCore.determineAvailability(with: config) { (error, available, waitingTime) in
            
            ServiceCloud.shared().chatCore.add(delegate: self)
            ServiceCloud.shared().chatCore.addEvent(delegate: self)
            ServiceCloud.shared().chatCore.startSession(with: config) { (error, chat) in
                
                MINTEL_LiveChat.chatStarted = true
                MINTEL_LiveChat.chatInProgress = true
                MINTEL_LiveChat.chatBotMode = false
                MINTEL_LiveChat.chatCanTyped = true
                //                    debugPrint(error ?? nil)
            }
            //            }
        }
    }
    
    fileprivate func setupView() {
        let cornerRadius = 10
        let buttonHeight = (self.frame.size.height * closeButtonHeight) / viewHeight
        self.closeButton = UIButton.init(type: .custom)
        self.closeButton.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: buttonHeight)
        self.addSubview(self.closeButton)
        self.closeButton.setImage(UIImage(named: "close", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil), for: .normal)
        self.closeButton.setTitleColor(UIColor.black, for: .normal)
        self.closeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        self.closeButton.backgroundColor = UIColor(MyHexString: "#F08833")
        self.closeButton.MyRoundCorners([.topLeft, .topRight], radius: CGFloat(cornerRadius))
        self.closeButton.isUserInteractionEnabled = false
        
        let image = UIImage(named: "user", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil)
        self.userImageView = UIImageView(image: image)
        self.userImageView.contentMode = .scaleAspectFit
        self.userImageView.frame = CGRect(x: 0, y: self.closeButton.frame.origin.y + self.closeButton.frame.size.height, width: self.frame.size.width, height: self.frame.size.height - (self.closeButton.frame.origin.y + self.closeButton.frame.size.height + 25))
        self.addSubview(self.userImageView)
        MINTEL_LiveChat.userImageFrame = self.userImageView.frame
        
        self.callCenterLabel = UILabel(frame: CGRect(x: 0, y: self.userImageView.frame.origin.y + self.userImageView.frame.size.height, width: self.frame.size.width, height: 25))
        self.callCenterLabel.font = UIFont.systemFont(ofSize: 14)
        self.callCenterLabel.text = "แชทบอท"
        self.callCenterLabel.textAlignment = .center
        self.addSubview(self.callCenterLabel)
        
        let titleHeight = (self.frame.size.height * 60) / 200
        self.queueTitleLabel = UILabel(frame: CGRect(x: 0, y: self.closeButton.frame.origin.y + self.closeButton.frame.size.height + 8, width: self.frame.size.width, height: titleHeight))
        self.queueTitleLabel.text = " คิวของคุณคือลำดับที่  "
        self.queueTitleLabel.numberOfLines = 2
        self.queueTitleLabel.textAlignment = .center
        self.queueTitleLabel.font = UIFont.systemFont(ofSize: 14)
        self.queueTitleLabel.isHidden = true
        self.addSubview(self.queueTitleLabel)
        
        let queueHeight = (self.frame.size.height * (200 - 80 - 60)) / 200
        self.queueLabel = UILabel(frame: CGRect(x: 0, y: self.queueTitleLabel.frame.origin.y  + self.queueTitleLabel.frame.size.height, width: self.frame.size.width, height: queueHeight))
        self.queueLabel.text = ""
        self.queueLabel.textAlignment = .center
        self.queueLabel.font = UIFont.systemFont(ofSize: 18)
        self.queueLabel.tag = 0
        self.queueLabel.isHidden = true
        self.addSubview(self.queueLabel)
        
        self.badgeLabel = UILabel(frame: CGRect(x: 40, y: 50, width: 30, height: 20))
        self.badgeLabel.text = ""
        self.badgeLabel.textAlignment = .center
        self.badgeLabel.font = UIFont.systemFont(ofSize: 10)
        self.badgeLabel.isHidden = true
        self.badgeLabel.layer.cornerRadius = 10
        self.badgeLabel.layer.masksToBounds = true
        self.badgeLabel.textColor = UIColor.white
        self.badgeLabel.backgroundColor = UIColor(MyHexString: "#0000FF")
        self.addSubview(self.badgeLabel)
        
        self.backgroundColor = UIColor(MyHexString: "#F1F1F1")
        self.layer.cornerRadius = CGFloat(cornerRadius)
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 5
    }
    
    private func addButtonToKeyWindow() {
        
        let obj = UIApplication.shared.windows.first
        obj?.addSubview(self)
        
        self.layer.zPosition = 1
        //        UIApplication.shared.keyWindow?.addSubview(self)
        
        //        let keyWindow = UIApplication.shared.connectedScenes
        //            .filter({$0.activationState == .foregroundActive})
        //            .map({$0 as? UIWindowScene})
        //            .compactMap({$0})
        //            .first?.windows
        //            .filter({$0.isKeyWindow}).first
        //
        //        keyWindow.addSubview(self)
        
        //        if let keyWindow = UIApplication.shared.keyWindow {
        //            keyWindow.addSubview(self)
        //        } else if (UIApplication.shared.windows.first != nil) {
        //            UIApplication.shared.windows.first?.addSubview(self)
        //        }
    }
    
    private func removeButtonFromKeyWindow() {
        if UIApplication.shared.keyWindow != nil {
            self.removeFromSuperview()
        } else if (UIApplication.shared.windows.first != nil) {
            self.removeFromSuperview()
        }
    }
    
    private func configDefaultSettingWithType() {
        
        // gestures
        self.longPressGestureRecognizer = UILongPressGestureRecognizer.init()
        if let longPressGestureRecognizer = self.longPressGestureRecognizer {
            longPressGestureRecognizer.allowableMovement = 0
            self.addGestureRecognizer(longPressGestureRecognizer)
        }
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        if let tapGuesture = self.tapGestureRecognizer {
            tapGuesture.numberOfTapsRequired = 1
            self.addGestureRecognizer(tapGuesture)
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        // handling code
        let loc:CGPoint = sender!.location(in: sender?.view)
        let buttonHeight = (self.frame.size.height * closeButtonHeight) / viewHeight
        if loc.y <= buttonHeight {
            //            if (self.chatDelegate != nil) {
            //                self.chatDelegate?.terminate()
            //            } else {
            self.closeButtonHandle()
            //            }
        } else {
            self.tapAction(sender: sender as AnyObject, survey: false)
        }
    }
    
    @objc func closeButtonHandle() {
        
        if (MINTEL_LiveChat.surveyMode) {
            self.exitApp()
        } else {
            if (!MINTEL_LiveChat.chatStarted) {
                self.exitApp()
            } else {
                if (MINTEL_LiveChat.chatInProgress) {
                    MINTEL_LiveChat.openConfirmExitPage = true
                    self.tapAction(sender: UIButton(), survey: false)
                } else {
                    self.exitApp()
                }
            }
        }
    }
    
    fileprivate func exitApp() {
        MINTEL_LiveChat.surveyMode = false
        MINTEL_LiveChat.agentState = .start
        MINTEL_LiveChat.chatStarted = false
        UIApplication.shared.keyWindow?.sendSubviewToBack(self)
        MessageList.clear()
        DispatchQueue.main.async {
            self.isHidden = true
        }
    }
    
    // MARK: Actions
    @objc func tapAction(sender: AnyObject, survey: Bool) {
        DispatchQueue.main.async {
            if (!self.singleTapBeenCanceled && !self.dragging)  {
                
                if (MINTEL_LiveChat.surveyMode) {
                    self.openSurvey(bot: MINTEL_LiveChat.chatBotMode)
                } else {
                    let bundle = Bundle(for: type(of: self))
                    let storyboard = UIStoryboard(name: "ChatBox", bundle: bundle)
                    let vc = storyboard.instantiateInitialViewController()!
                    let viewController = UIApplication.shared.windows.first!.rootViewController!
                    viewController.modalPresentationStyle = .fullScreen
                    viewController.present(vc, animated: true) {
                        self.isHidden = true
                    }
                }
            }
        }
    }
    
    // MARK: Touch
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.dragging = false
        super.touchesBegan(touches, with: event)
        let touch: UITouch? = (touches as NSSet).anyObject() as? UITouch
        if touch?.tapCount == 2 {
            self.singleTapBeenCanceled = true
        } else {
            self.singleTapBeenCanceled = false
        }
        self.beginLocation = ((touches as NSSet).anyObject() as AnyObject).location(in:self)
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?){
        if self.draggable  {
            self.dragging = true
            let touch: UITouch? = (touches as NSSet).anyObject() as? UITouch
            let currentLocation: CGPoint? = touch?.location(in: self)
            
            let offsetX: CGFloat? = (currentLocation?.x)! - (self.beginLocation?.x)!
            let offsetY: CGFloat? = (currentLocation?.y)! - (self.beginLocation?.y)!
            self.center = CGPoint(x: self.center.x + offsetX!, y: self.center.y + offsetY!)
            //self.center = CGPoint(self.center.x + offsetX!, self.center.y + offsetY!)
            
            let superviewFrame: CGRect? = self.superview?.frame
            let frame: CGRect = self.frame
            let leftLimitX: CGFloat = frame.size.width / 2.0
            let rightLimitX: CGFloat = (superviewFrame?.size.width)! - leftLimitX
            let topLimitY: CGFloat = frame.size.height / 2.0
            let bottomLimitY: CGFloat = (superviewFrame?.size.height)! - topLimitY
            
            if (self.center.x > rightLimitX) {
                self.center = CGPoint(x:rightLimitX, y:self.center.y)
            } else if (self.center.x <= leftLimitX) {
                self.center = CGPoint(x:leftLimitX, y:self.center.y)
            }
            
            if (self.center.y > bottomLimitY) {
                self.center = CGPoint(x:self.center.x, y:bottomLimitY)
            } else if (self.center.y <= topLimitY) {
                self.center = CGPoint(x:self.center.x, y:topLimitY)
            }
        }
    }
    
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if (self.dragging && self.autoDocking) {
            let superviewFrame: CGRect? = self.superview?.frame
            let frame: CGRect = self.frame
            let middleX: CGFloat? = (superviewFrame?.size.width)! / 2.0
            if (self.center.x >= middleX!) {
                UIView.animate(withDuration: autoDockingDuration,
                               animations: {
                                self.center = CGPoint(x:(superviewFrame?.size.width)! - frame.size.width / 2.0, y:self.center.y)
                },
                               completion: { (finished) in
                                self.singleTapBeenCanceled = true
                })
            } else {
                UIView.animate(withDuration: autoDockingDuration,
                               animations: {
                                self.center = CGPoint(x:frame.size.width / 2, y:self.center.y)
                },
                               completion: { (finished) in
                                self.singleTapBeenCanceled = true
                })
            }
        }
        self.dragging = false
        
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dragging = false
        super.touchesCancelled(touches, with:event)
    }
    
    // MARK: Remove
    class func removeAllFromKeyWindow() {
        if let subviews = UIApplication.shared.keyWindow?.subviews {
            for view: AnyObject in subviews {
                if view.isKind(of: MINTEL_LiveChat.self) {
                    view.removeFromSuperview()
                }
            }
        }
    }
    
    class func removeAllFromView(superView : AnyObject) {
        if let subviews = superView.subviews {
            for view: AnyObject in subviews {
                if view.isKind(of: MINTEL_LiveChat.self) {
                    view.removeFromSuperview()
                }
            }
        }
    }
    
    private static var bundle:Bundle {
        let podBundle = Bundle(for: MINTEL_LiveChat.self)
        
        let bundleURL = podBundle.url(forResource: "ChatBox", withExtension: "bundle")
        return Bundle(url: bundleURL!)!
    }
}

extension MINTEL_LiveChat : SCSChatSessionDelegate {
    public func session(_ session: SCSChatSession!, didError error: Error!, fatal: Bool) {
        debugPrint("Error : ", error)
    }
    
    public func session(_ session: SCSChatSession!, didUpdateQueuePosition position: NSNumber!, estimatedWaitTime waitTime: NSNumber!) {
        debugPrint("Queue : ", position)
        
        DispatchQueue.main.async {
            
            if (self.queueLabel.tag == Int.max) {
                self.queueLabel.tag = position.intValue
                self.queueLabel.text = String(format : "%d", self.queueLabel.tag)
            } else if (position.intValue <= self.queueLabel.tag && position.intValue > 0) {
                self.queueLabel.tag = position.intValue
                self.queueLabel.text = String(format: "%d", self.queueLabel.tag)
            }
            
            MINTEL_LiveChat.agentState = .waiting
            self.reLayoutView()
            
            if (position.intValue <= self.queueLabel.tag && position.intValue > 0) {
                MessageList.add(item: MyMessage(systemMessageType1: String(format: "คิวของคุณคือลำดับที่ %d", position.intValue)), remove: true)
            }
            
            NotificationCenter.default.post(name: Notification.Name(SalesForceNotifId.didUpdatePosition),
                                            object: nil,
                                            userInfo:["session": session, "position": position.intValue])
        }
        
        
        
    }
    
    public func session(_ session: SCSChatSession!, didEnd endEvent: SCSChatSessionEndEvent!) {
        debugPrint("Session End")
        DispatchQueue.main.async {
            MINTEL_LiveChat.agentState = .end
            let _ = MessageList.add(item: MyMessage(systemMessageType1: "จบการสนทนา"))
            NotificationCenter.default.post(name: Notification.Name(SalesForceNotifId.didEnd),
                                            object: nil,
                                            userInfo:["session": session, "event": endEvent])
            
            DispatchQueue.main.async {
                self.reLayoutView()
            }
        }
    }
    
    public func session(_ session: SCSChatSession!, didTransitionFrom previous: SCSChatSessionState, to current: SCSChatSessionState) {
        if previous == SCSChatSessionState.connecting && current == SCSChatSessionState.queued {
            DispatchQueue.main.async {
                self.queueLabel.tag = Int.max
            }
        }
    }
}

extension MINTEL_LiveChat  {
    internal func getAnnouncementMessage() {
        let params: Parameters = [:]
        let url = (MINTEL_LiveChat.configuration?.announcementUrl ?? "").replacingOccurrences(of: "sessionId", with: MINTEL_LiveChat.userId)
        
        debugPrint("Url " , url)
        
        let headers:HTTPHeaders = [
            "x-api-key": MINTEL_LiveChat.configuration?.xApikey ?? "" // "381b0ac187994f82bdc05c09d1034afa"
        ]
        
        do {
            let jsonEncode = JSONEncoding.init()
            var originalRequest:URLRequest? = try URLRequest(url: url, method: .post, headers: headers)
            originalRequest?.timeoutInterval = 30
            let encodedURLRequest = try jsonEncode.encode(originalRequest!, with: params)
            Alamofire
                .request(encodedURLRequest)
                .responseJSON { (response) in
                    switch response.result {
                    case .success(_):
                        
                        if let json = response.value {
                            debugPrint(json)
                            if json is [String:Any] {
                            } else if let items = json as? [[String:Any]] {
                                
                                if items.count > 0 {
                                    items.forEach { (item) in
                                        let desc = item["Description__c"] as? String ?? ""
                                        if desc.count > 0 {
                                            let _ = MessageList.add(item: MyMessage(text: desc, agent: false, bot: true))
                                        }
                                    }
                                    
                                    let menus:[[String:Any]] = [["action" : ["label" : "จบการสนทนา", "text" : "__00_app_endchat", "display" : false]], ["action" : [ "label" : "เริ่มการสนทนา", "text" : "__00_home__greeting", "display" : false]]]
                                    let _ = MessageList.add(item: MyMessage(text: "", agent: false, bot: true, menu: menus))
                                    NotificationCenter.default.post(name: Notification.Name(MINTELNotifId.botTyped),
                                                                    object: nil,
                                                                    userInfo:nil)
                                } else {
                                    
                                    MINTEL_LiveChat.chatCanTyped = true
                                    DispatchQueue.global(qos: .userInitiated).async {
                                        DispatchQueue.main.async {
                                            self.checkAgentMode()
                                            //                                        MINTEL_LiveChat.sendPost(text: "__00_home__greeting", menu: false)
                                        }
                                        
                                        NotificationCenter.default.post(name: Notification.Name(MINTELNotifId.botTyped),
                                                                        object: nil,
                                                                        userInfo:nil)
                                    }
                                }
                            }
                        }
                        break
                    case .failure(let error):
                        debugPrint(error)
                        break
                    }
            }
        } catch {
            // return request(originalRequest, failedWith: error)
        }
        
    }
    
    fileprivate func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
                return json
            } catch {
                print("Something went wrong")
            }
        }
        return nil
    }
    
    fileprivate static func sendOnNewSession() {
        let params : Parameters = [
            "session_id": MINTEL_LiveChat.userId,
            "first_name": MINTEL_LiveChat.configuration?.firstname ?? "",
            "last_name" : MINTEL_LiveChat.configuration?.lastname ?? "",
            "phone" : MINTEL_LiveChat.configuration?.phone ?? "",
            "email" : MINTEL_LiveChat.configuration?.email ?? "",
            "tmnid" : MINTEL_LiveChat.configuration?.tmnId ?? ""
        ]
        let url = String(format: "%@/onNewSessionMobile", MINTEL_LiveChat.configuration?.webHookBaseUrl ?? "")
        let header:HTTPHeaders = [
            "x-api-key": MINTEL_LiveChat.configuration?.xApikey ?? "" // "381b0ac187994f82bdc05c09d1034afa"
        ]
        
        
        Alamofire
            .request(url, method: .post, parameters: params, encoding: JSONEncoding.init(), headers: header)
            .responseString(completionHandler: { response in
                debugPrint(response)
            })
    }
    
    internal static func checkTime() {
        // Timer 2 minutes
        self.stopTimer()
        
        MINTEL_LiveChat.first2MinutesTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(firstTimerDuration * 60), repeats: false) { (timer) in
            // Send Notification
            let notif = MINTEL_Notifications()
            notif.scheduleNotification(message: "ขณะนี้ท่านมีรายการสนทนากับศูนย์บริการทรูมันนี่อยู่")
            print("First notif fired.")
            
            MINTEL_LiveChat.lastAMinuteTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(secondTimerDuration * 60), repeats: false, block: { (timer2) in
                let _ = MessageList.add(item: MyMessage(text: "หากคุณลูกค้าไม่อยู่ในการสนทนา ผมขอจบการสนทนาเพื่อดูแลลูกค้าท่านอื่นต่อครับ หากต้องการข้อมูลสอบถามข้อมูลเพิ่มเติม สามารถติดต่อเข้ามาใหม่ได้ตลอด 24 ชั่วโมง ขอบคุณที่ใช้บริการทรูมันนี่ สวัสดีครับ", agent: false, bot: true))
                let _ = MessageList.add(item: MyMessage(systemMessageType1: "จบการสนทนา"))
                notif.scheduleNotification(message: "ขอบคุณสำหรับการสนทนา หากมีข้อสงสัยเพิ่มเติมสามารถเริ่มต้นแชทอีกครั้งเพื่อสอบถามข้อมูล")
                print("Second notif fired.")
                MINTEL_LiveChat.chatCanTyped = false
                MessageList.disableOnMenu()
                NotificationCenter.default.post(name: Notification.Name(MINTELNotifId.botTyped),
                object: nil,
                userInfo:nil)
                NotificationCenter.default.post(name: Notification.Name(MINTELNotifId.reallyExitChat),
                        object: nil,
                        userInfo:nil)
            })
        }
    }
    
    internal static func stopTimer() {
        if (MINTEL_LiveChat.first2MinutesTimer != nil) {
            MINTEL_LiveChat.first2MinutesTimer?.invalidate()
            MINTEL_LiveChat.first2MinutesTimer = nil
        }
        if (MINTEL_LiveChat.lastAMinuteTimer != nil) {
            MINTEL_LiveChat.lastAMinuteTimer?.invalidate()
            MINTEL_LiveChat.lastAMinuteTimer = nil
        }
    }
    
    fileprivate static func removeTyping() {
        MessageList.removeTyping()
        NotificationCenter.default.post(name: Notification.Name(MINTELNotifId.botTyped),
                                        object: nil,
                                        userInfo:nil)
    }
    
    internal static func sendPost(text: String, menu: Bool) {
        
        self.removeTyping()
        
        let _ = MessageList.add(item: MyMessage(typing: true, agent: !MINTEL_LiveChat.chatBotMode))
        //        DispatchQueue.main.async {
        //            NotificationCenter.default.post(name: Notification.Name(MINTELNotifId.botTyped),
        //            object: nil,
        //            userInfo:nil)
        //        }
        debugPrint("=== Send Post " , text)
        if ("__00_home__greeting" == text) {
            
            if MINTEL_LiveChat.configuration?.phone.count == 0 {
                let _ = MessageList.add(item: MyMessage(text: "สวัสดีครับ", agent: false, bot: true))
            } else {
                let _ = MessageList.add(item: MyMessage(text: String(format: "สวัสดีครับ คุณ%@", MINTEL_LiveChat.configuration?.firstname ?? ""), agent: false, bot: true))
            }
//            MINTEL_LiveChat.chatStarted = true
            MINTEL_LiveChat.chatCanTyped = true
            NotificationCenter.default.post(name: Notification.Name(MINTELNotifId.botTyped),
                                            object: nil,
                                            userInfo:nil)
        } else {
            if (!menu) {
                MINTEL_LiveChat.chatStarted = true
            }
        }
        
        let params : Parameters = ["session_id": MINTEL_LiveChat.userId,"text": text]
        debugPrint("Url : " , params)
        let url = String(format: "%@/webhook", MINTEL_LiveChat.configuration?.webHookBaseUrl ?? "")
        let headers:HTTPHeaders = [
            "x-api-key": MINTEL_LiveChat.configuration?.xApikey ?? "" // "edf1ca88a09546f8a0667c81c93d1f31"
        ]
        
        do {
            let jsonEncode = JSONEncoding.init()
            var originalRequest:URLRequest? = try URLRequest(url: url, method: .post, headers: headers)
            if (!menu) {
                originalRequest?.timeoutInterval = timeout
            }
            let encodedURLRequest = try jsonEncode.encode(originalRequest!, with: params)
            Alamofire
                .request(encodedURLRequest)
                .responseJSON { (response) in
                    
                    self.checkTime()
                    
                    // Remove Typing
                    self.removeTyping()
                    
                    switch response.result {
                    case .success(_):
                        var goToAgentMode = false
                        retryTimeoutTimes = 0
                        if let json = response.value {
                            debugPrint(json)
                            let dict = json as! [String: Any]
                            let error = dict["error"] as? [String: Any] ?? nil
                            if (error == nil) {
                                let intent = dict["intent"] as? String ?? ""
                                if (intent == "08_wait_for_call") {
                                    goToAgentMode = true
                                }
                                
                                if dict["message"] is String {
                                } else {
                                    
                                    let messages = dict["messages"] as! [[String: Any]]
                                    for i in 0..<messages.count {
                                        let body = messages[i]
                                        let type = body["type"] as? String ?? ""
                                        let intent = body["intent"] as? String ?? ""
                                        if "06_rate" == intent {
                                            MINTEL_LiveChat.instance.reallyEndChat()
                                            return
                                        }
                                        let quickReplyTitle = body["text"] as? String ?? ""
                                        let quickReply = body["quickReply"] as? [String: Any] ?? nil
                                        if (menu) {
                                            if (type == "text") {
                                                if (quickReply != nil) {
                                                    let items = quickReply!["items"] as? [[String:Any]] ?? []
                                                    MINTEL_LiveChat.chatMenus = items
                                                    NotificationCenter.default.post(name: Notification.Name(MINTELNotifId.chatMenuAvailable),
                                                                                    object: nil,
                                                                                    userInfo:nil)
                                                    debugPrint(items)
                                                    print("Menus Session")
                                                }
                                            }
                                        } else {
                                            if (type == "text") {
                                                if (quickReply != nil) {
                                                    let items = quickReply!["items"] as? [[String:Any]] ?? []
                                                    let _ = MessageList.add(item: MyMessage(text: quickReplyTitle, agent: true, menu: items))
                                                } else {
                                                    let _ = MessageList.add(item: MyMessage(text: quickReplyTitle, agent: true, bot: true))
                                                }
                                            }
                                        }
                                    }
                                    
                                    NotificationCenter.default.post(name: Notification.Name(MINTELNotifId.botTyped),
                                                                    object: nil,
                                                                    userInfo:nil)
                                }
                            }
                        }
                        
                        
                        if (goToAgentMode) {
                            NotificationCenter.default.post(name: Notification.Name(MINTELNotifId.toAgentMode),
                                                            object: nil,
                                                            userInfo:nil)
                        }
                        
                        
                        
                        break
                    case .failure( _):
                        if (!menu) {
                            self.retrySendPost(text: text, menu: menu)
                        }
                        break
                    }
            }
        } catch {
            debugPrint("Error In Catch")
        }
    }
    
    internal static func retrySendPost(text: String, menu: Bool) {
        debugPrint("Retry : ", text, "Retry Times : " , retryTimeoutTimes)
        retryTimeoutTimes = retryTimeoutTimes + 1
        if (retryTimeoutTimes == 2) {
            NotificationCenter.default.post(name: Notification.Name(MINTELNotifId.toAgentMode),
                                            object: nil,
                                            userInfo:nil)
        } else {
            
            MessageList.add(item: MyMessage(text: "กรุณารอสักครู่", agent: false, bot: true), remove: true)
            MINTEL_LiveChat.sendPost(text: text, menu: menu)
        }
    }
}

extension MINTEL_LiveChat : SCSChatEventDelegate {
    
    public func session(_ session: SCSChatSession!, agentJoined agentjoinedEvent: SCSAgentJoinEvent!) {
        
        MessageList.remove(item: MyMessage(systemMessageType1: String(format: "คิวของคุณคือลำดับที่ 0")), remove: true)
        
        let agentName = agentjoinedEvent.sender?.name ?? "agent"
        MINTEL_LiveChat.agentName = agentName
        let _ = MessageList.add(item: MyMessage(agentJoin: true, agentName: agentName))
        MINTEL_LiveChat.agentState = .joined
        
        self.reLayoutView()
        self.sendChatbotMessage()
        
        NotificationCenter.default.post(name: Notification.Name(SalesForceNotifId.agentJoined),
                                        object: nil,
                                        userInfo:["session": session, "event": agentjoinedEvent])
    }
    
    public func session(_ session: SCSChatSession!, agentLeftConference agentLeftConferenceEvent: SCSAgentLeftConferenceEvent!) {
        MINTEL_LiveChat.agentState = .waiting
        debugPrint("Agent Left")
        
        NotificationCenter.default.post(name: Notification.Name(SalesForceNotifId.agentLeftConference),
                                        object: nil,
                                        userInfo:["session": session, "event": agentLeftConferenceEvent])
    }
    
    public func session(_ session: SCSChatSession!, processedOutgoingMessage message: SCSUserTextEvent!) {
        debugPrint("process Outgoing Message : ", message)
    }
    
    public func session(_ session: SCSChatSession!, didUpdateOutgoingMessageDeliveryStatus message: SCSUserTextEvent!) {
        debugPrint("didUpdateOutgoingMessageDeliveryStatus : ", message)
    }
    
    public func session(_ session: SCSChatSession!, didSelectMenuItem menuEvent: SCSChatMenuSelectionEvent!) {
        debugPrint("didSelectMenuItem : ", menuEvent)
    }
    
    public func session(_ session: SCSChatSession!, didReceiveMessage message: SCSAgentTextEvent!) {
        debugPrint("didReceiveMessage : ", message)
        let _ = MessageList.add(item: MyMessage(text: message.text, agent: true, bot: false))
        NotificationCenter.default.post(name: Notification.Name(SalesForceNotifId.didReceiveMessage),
                                        object: nil,
                                        userInfo:["session": session, "message": message])
        
        
        MINTEL_LiveChat.stopTimer()
        if (!MINTEL_LiveChat.chatPanelOpened) {
            MINTEL_LiveChat.unreadMessage = MINTEL_LiveChat.unreadMessage + 1
        } else {
            MINTEL_LiveChat.unreadMessage = 0
        }
        
        NotificationCenter.default.post(name: Notification.Name(MINTELNotifId.updateUnreadMessageCount),
                                        object: nil,
                                        userInfo:["session": session, "message": message])
    }
    
    fileprivate func checkAndSendNotification(message: String) {
        if (!MINTEL_LiveChat.chatPanelOpened) {
            
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
    
    public func agentBeganTyping(with session: SCSChatSession!) {
        debugPrint("agentBeganTyping : ")
        DispatchQueue.main.async {
            MessageList.add(item: MyMessage(typing: true, agent: true), remove: true)
            
            NotificationCenter.default.post(name: Notification.Name(MINTELNotifId.botTyped),
                                            object: nil,
                                            userInfo:nil)
        }
    }
    
    public func agentFinishedTyping(with session: SCSChatSession!) {
        debugPrint("agentFinishedTyping : ")
        DispatchQueue.main.async {
            MessageList.removeTyping()
            NotificationCenter.default.post(name: Notification.Name(MINTELNotifId.botTyped),
                                            object: nil,
                                            userInfo:nil)
        }
    }
    
    fileprivate func sendChatbotMessage() {
        
        let allMsg = MessageList.getMessageForAgent()
        if (allMsg.count > 0) {
            ServiceCloud.shared().chatCore.session.sendMessage(allMsg)
        }
    }
    
}
