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

protocol ChatDelegate{
    func terminate()
}

internal enum SaleforceAgentState {
    case start
    case waiting
    case joined
    case end
}

public class MINTEL_LiveChat: UIView {
    
    internal static var configuration:LiveChatConfiguration? = nil
    internal static var userId = UUID().uuidString
    internal static var userName = ""
    internal static var chatPanelOpened = false
    internal static var chatStarted = false
    internal static var instance:MINTEL_LiveChat!
    internal static var agentName:String = ""
    internal static var agentState:SaleforceAgentState = .start
    internal static var chatBotMode = true
    internal static var items = [MyMessage]()
    
    
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
    
    private var beginLocation: CGPoint?
    private var closeButton:UIButton!
    private var userImageView:UIImageView!
    private var queueTitleLabel:UILabel!
    private var queueLabel:UILabel!
    private var callCenterLabel:UILabel!
    
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
        self.layer.zPosition = 1
        if (MINTEL_LiveChat.chatBotMode) {
            self.userImageView.isHidden = false
            self.callCenterLabel.isHidden = false
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
                self.userImageView.isHidden = false
                self.callCenterLabel.isHidden = false
                self.callCenterLabel.text = "TMN Chat"
                self.queueTitleLabel.isHidden = true
                self.queueLabel.isHidden = true
                break
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
    
    public func startChat(config:LiveChatConfiguration) {
        
        notification.userRequest()
        if (MINTEL_LiveChat.chatStarted) {
            return
        }
        
        self.layer.zPosition = 1
        MINTEL_LiveChat.chatStarted = true
        MINTEL_LiveChat.userId = UUID().uuidString
        MINTEL_LiveChat.configuration = config
        MINTEL_LiveChat.userName = config.userName
        MINTEL_LiveChat.chatInProgress = true
        MINTEL_LiveChat.agentState = .start
        self.loadFirstMessage()
        self.isHidden = false
        UIApplication.shared.keyWindow?.bringSubviewToFront(self)
        
        if (MINTEL_LiveChat.configuration?.salesforceFirst ?? false) {
            MINTEL_LiveChat.items.append(MyMessage(systemMessageType2: "กรุณารอสักครู่"))
            MINTEL_LiveChat.chatBotMode = false
            MINTEL_LiveChat.instance.startSaleForce()
        } else {
            self.tapAction(sender: NSObject())
        }
    }
    
    public func stopChat() {
        self.closeButtonHandle()
        self.reallyEndChat()
    }
    
    internal func reallyEndChat() {
        
        if (!MINTEL_LiveChat.chatInProgress) {
            return
        }
        
        MINTEL_LiveChat.chatInProgress = false
        MINTEL_LiveChat.userId = UUID().uuidString
        
        // Check saleforce
        switch(MINTEL_LiveChat.agentState) {
        case .joined :
            ServiceCloud.shared().chatCore.stopSession()
            break
        default:
            break
        }
        
        if (MINTEL_LiveChat.agentState != .start) {
            ServiceCloud.shared().chatCore.stopSession()
            MINTEL_LiveChat.chatBotMode = true
        }
        
        ServiceCloud.shared().chatCore.remove(delegate: self)
        ServiceCloud.shared().chatCore.removeEvent(delegate: self)
        MINTEL_LiveChat.agentState = .end
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        let date24 = dateFormatter.string(from: date)
        
        MINTEL_LiveChat.items.append(MyMessage(systemMessageType1: String(format: "Chat ended %@", date24)))
        NotificationCenter.default.post(name: Notification.Name(MINTELNotifId.reallyExitChat),
                                        object: nil,
                                        userInfo:nil)
        
        self.openSurvey(bot: MINTEL_LiveChat.chatBotMode)
    }
    
    fileprivate func openSurvey(bot:Bool) {
        
        var surveyUrl:String = ""
        if (bot) {
            surveyUrl = MINTEL_LiveChat.configuration?.surveyChatbotUrl ?? ""
        } else {
            surveyUrl = MINTEL_LiveChat.configuration?.surveyFormUrl ?? ""
        }
        
        surveyUrl = surveyUrl.replacingOccurrences(of: "sessionId", with: MINTEL_LiveChat.userId)
        
        
        // Open Survey Url
        guard let url = URL(string: surveyUrl) else { return }
        if (UIApplication.shared.canOpenURL(url)) {
            var vc:UIViewController? = nil
            
            if #available(iOS 11.0, *) {
                let config = SFSafariViewController.Configuration()
                config.entersReaderIfAvailable = false
                vc = SFSafariViewController(url: url, configuration: config)
            } else {
                vc = SFSafariViewController(url: url)
            }
            
            let currentViewController = self.topViewController()
            if let cu = currentViewController {
                cu.present(vc!, animated: true, completion: nil)
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
        
        MINTEL_LiveChat.items.append(MyMessage(systemMessageType1: String(format: "เริ่มการสนทนา %@", date24)))
        if (!(MINTEL_LiveChat.configuration?.salesforceFirst ?? false)) {
            self.getAnnouncementMessage()
            MINTEL_LiveChat.sendOnNewSession()
        }
        
        MINTEL_LiveChat.checkTime()
    }
    
    public func sendToFront() {
        UIApplication.shared.keyWindow?.bringSubviewToFront(self)
    }
    
    internal func startSaleForce() {
        
        self.configureSaleForce()
    }
    
    private func configureSaleForce() {
        
        if let config = SCSChatConfiguration(liveAgentPod: MINTEL_LiveChat.configuration?.salesforceLiveAgentPod,
                                             orgId: MINTEL_LiveChat.configuration?.salesforceOrdID,
                                             deploymentId: MINTEL_LiveChat.configuration?.salesforceDeployID,
                                             buttonId: MINTEL_LiveChat.configuration?.salesforceButtonID) {
            
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
            
            let csatUuid = UUID().uuidString
            let uniqueFiled = SCSPrechatObject(label: "Unique_ID__c", value: csatUuid)
            let uniqueEntityField = SCSPrechatEntityField(fieldName: "Unique_ID__c", label: "Unique_ID__c")
            uniqueEntityField.doCreate = true
            csatEntity.entityFieldsMaps.add(uniqueEntityField)
            
            config.prechatFields = [firstNameField, lastNameField, emailField, phoneFiled, tmnIdFiled, uniqueFiled] as [SCSPrechatObject]
            // Update config object with the entity mappings
            config.prechatEntities = [contactEntity, csatEntity]
//            config.allowBackgroundNotifications = false
            
            ServiceCloud.shared().chatCore.determineAvailability(with: config) { (error, available, waitingTime) in
                
                ServiceCloud.shared().chatCore.add(delegate: self)
                ServiceCloud.shared().chatCore.addEvent(delegate: self)
                ServiceCloud.shared().chatCore.startSession(with: config) { (error, chat) in
                    
                }
            }
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
        
        self.callCenterLabel = UILabel(frame: CGRect(x: 0, y: self.userImageView.frame.origin.y + self.userImageView.frame.size.height, width: self.frame.size.width, height: 25))
        self.callCenterLabel.font = UIFont.systemFont(ofSize: 14)
        self.callCenterLabel.text = "TMN Chat"
        self.callCenterLabel.textAlignment = .center
        self.addSubview(self.callCenterLabel)
        
        let titleHeight = (self.frame.size.height * 60) / 200
        self.queueTitleLabel = UILabel(frame: CGRect(x: 0, y: self.closeButton.frame.origin.y + self.closeButton.frame.size.height + 8, width: self.frame.size.width, height: titleHeight))
        self.queueTitleLabel.text = "Your place in line"
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
            self.tapAction(sender: sender as AnyObject)
        }
    }
    
    @objc func closeButtonHandle() {
        self.isHidden = true
       
        MINTEL_LiveChat.agentState = .start
        MINTEL_LiveChat.chatStarted = false
        UIApplication.shared.keyWindow?.sendSubviewToBack(self)
        MINTEL_LiveChat.items.removeAll()
    }
    
    // MARK: Actions
    @objc func tapAction(sender: AnyObject) {
        DispatchQueue.main.async {
            if (!self.singleTapBeenCanceled && !self.dragging)  {
                self.layer.zPosition = 0
                let bundle = Bundle(for: type(of: self))
                let storyboard = UIStoryboard(name: "ChatBox", bundle: bundle)
                let vc = storyboard.instantiateInitialViewController()!
                let viewController = UIApplication.shared.windows.first!.rootViewController!
                viewController.modalPresentationStyle = .fullScreen
                viewController.present(vc, animated: true, completion: nil)
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
            if (self.queueLabel.tag < Int.max && position.intValue > 0) {
                MINTEL_LiveChat.items.removeLast()
            }
            if (self.queueLabel.tag == Int.max) {
                self.queueLabel.tag = position.intValue
                self.queueLabel.text = ""
            } else if (position.intValue <= self.queueLabel.tag) {
                self.queueLabel.tag = position.intValue
                self.queueLabel.text = String(format: "#%d", self.queueLabel.tag)
            }
            
            
            MINTEL_LiveChat.agentState = .waiting
            
            if (position.intValue <= self.queueLabel.tag && position.intValue > 0) {
                
                MINTEL_LiveChat.items.append(MyMessage(systemMessageType1: String(format: "คิวของคุณคือลำดับที่ %d", position.intValue)))
            }
            
            NotificationCenter.default.post(name: Notification.Name(SalesForceNotifId.didUpdatePosition),
                                            object: nil,
                                            userInfo:["session": session, "position": position.intValue])
        }
        
        
        
    }
    
    public func session(_ session: SCSChatSession!, didEnd endEvent: SCSChatSessionEndEvent!) {
        debugPrint("Session End")
        MINTEL_LiveChat.agentState = .waiting
        NotificationCenter.default.post(name: Notification.Name(SalesForceNotifId.didEnd),
                                        object: nil,
                                        userInfo:["session": session, "event": endEvent])
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
                        if json is [String:Any] {
                            let dict = json as! [String: Any]
                            let desc = dict["Description__c"] as? String ?? ""
                            
                            if desc.count > 0 {
                                DispatchQueue.global(qos: .userInitiated).async {
                                    MINTEL_LiveChat.items.append(MyMessage(text: desc, agent: true))
                                    DispatchQueue.main.async {
                                        MINTEL_LiveChat.sendPost(text: "สวัสดี")
                                    }
                                    
                                    NotificationCenter.default.post(name: Notification.Name(MINTELNotifId.botTyped),
                                                                    object: nil,
                                                                    userInfo:nil)
                                }
                            }
                            
                            
                        } else if let items = json as? [[String:Any]] {
                            if items.count > 0 {
                                items.forEach { (item) in
                                    let desc = item["Description__c"] as? String ?? ""
                                    if desc.count > 0 {
                                        //                                    DispatchQueue.global(qos: .userInitiated).async {
                                        MINTEL_LiveChat.items.append(MyMessage(text: desc, agent: true))
                                        //                                    }
                                    }
                                }
                                
                                // Display Menu
                                //                            DispatchQueue.global(qos: .userInitiated).async {
                                let menus:[[String:Any]] = [["action" : ["label" : "จบการสนทนา", "text" : "__00_app_endchat", "display" : false]], ["action" : [ "label" : "เริ่มการสนทนา", "text" : "__00_home_greeting", "display" : false]]]
                                MINTEL_LiveChat.items.append(MyMessage(text: "", agent: true, menu: menus))
                                //                            }
                                
                                
                                NotificationCenter.default.post(name: Notification.Name(MINTELNotifId.botTyped),
                                                                object: nil,
                                                                userInfo:nil)
                            } else {
                                DispatchQueue.global(qos: .userInitiated).async {
                                    DispatchQueue.main.async {
                                        MINTEL_LiveChat.sendPost(text: "__00_home__greeting")
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
        let url = String(format: "%@onNewSessionMobile", MINTEL_LiveChat.configuration?.webHookBaseUrl ?? "")
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
        MINTEL_LiveChat.first2MinutesTimer = Timer.scheduledTimer(withTimeInterval: 2 * 60, repeats: false) { (timer) in
            // Send Notification
            let notif = MINTEL_Notifications()
            notif.scheduleNotification(message: "ขณะนี้ท่านมีรายการสนทนากับศูนย์บริการทรูมันนี่อยู่")
            print("First notif fired.")

            MINTEL_LiveChat.lastAMinuteTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: false, block: { (timer2) in
                self.items.append(MyMessage(text: "หากคุณลูกค้าไม่อยู่ในการสนทนา ผมขอจบการสนทนาเพื่อดูแลลูกค้าท่านอื่นต่อครับ หากต้องการข้อมูลสอบถามข้อมูลเพิ่มเติม สามารถติดต่อเข้ามาใหม่ได้ตลอด 24 ชั่วโมง ขอบคุณที่ใช้บริการทรูมันนี่ สวัสดีครับ", agent: false, bot: true))
                notif.scheduleNotification(message: "ขอบคุณสำหรับการสนทนา หากมีข้อสงสัยเพิ่มเติมสามารถเริ่มต้นแชทอีกครั้งเพื่อสอบถามข้อมูล")
                MINTEL_LiveChat.instance.reallyEndChat()
                print("Second notif fired.")
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
    
    internal static func sendPost(text: String) {
        
        let params : Parameters = ["session_id": MINTEL_LiveChat.userId,"text": text]
        let url = String(format: "%@/webhook", MINTEL_LiveChat.configuration?.webHookBaseUrl ?? "")
        let header:HTTPHeaders = [
            "x-api-key": MINTEL_LiveChat.configuration?.xApikey ?? "" // "381b0ac187994f82bdc05c09d1034afa"
        ]
        
        Alamofire
            .request(url, method: .post, parameters: params, encoding: JSONEncoding.init(), headers: header)
            .responseJSON { (response) in
                
                self.checkTime()
                
                switch response.result {
                case .success(_):
                    var goToAgentMode = false
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
                                debugPrint(dict["message"])
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
                                    if (type == "text") {
                                        if (quickReply != nil) {
                                            let items = quickReply!["items"] as? [[String:Any]] ?? []
                                            MINTEL_LiveChat.items.append(MyMessage(text: quickReplyTitle, agent: true, menu: items))
                                        } else {
                                            MINTEL_LiveChat.items.append(MyMessage(text: quickReplyTitle, agent: true))
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
                case .failure(let error):
                    print(error)
                    break
                }
        }
    }
}

extension MINTEL_LiveChat : SCSChatEventDelegate {
    
    public func session(_ session: SCSChatSession!, agentJoined agentjoinedEvent: SCSAgentJoinEvent!) {
        let agentName = agentjoinedEvent.sender?.name ?? "agent"
        MINTEL_LiveChat.agentName = agentName
        MINTEL_LiveChat.items.append(MyMessage(agentJoin: true, agentName: agentName))
        MINTEL_LiveChat.agentState = .joined
        
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
        MINTEL_LiveChat.items.append(MyMessage(text: message.text, agent: true, bot: false))
        NotificationCenter.default.post(name: Notification.Name(SalesForceNotifId.didReceiveMessage),
                                        object: nil,
                                        userInfo:["session": session, "message": message])
        
        MINTEL_LiveChat.checkTime()
        
//        notification.scheduleNotification(message: String(format: "%@:%@", MINTEL_LiveChat.agentName, message.text))
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
    
    fileprivate func sendChatbotMessage() {
        let ignoreMessage = ["Connecting", "agent", "Your place", "TrueMoney Care สวัสดีครับ"]
        
        var allMsg = ""
        MINTEL_LiveChat.items.forEach { (item) in
            var shouldIgnore = false
            var txtToSend = ""
            switch item.kind {
            case .text(let txt):
                txtToSend = txt
                for i in 0...ignoreMessage.count - 1 {
                    if (txt.starts(with: ignoreMessage[i])) {
                        shouldIgnore = true
                        break
                    }
                }
                break
            default:
                break
            }
            
            if (!shouldIgnore && txtToSend.count > 0) {
                if (item.bot || item.agent) {
                    allMsg = String(format: "%@\nทรูมันนี่: %@", allMsg, txtToSend)
                } else {
                    
                    var name = ""
                    if (MINTEL_LiveChat.configuration?.phone.count ?? 0 > 0) {
                        name = "Customer";
                    } else {
                        name = "Visitor"
                    }
                     
                    
                    allMsg = String(format: "%@\n%@: %@", allMsg, name, txtToSend)
                }
            }
        }
        
        if (allMsg.count > 0) {
            ServiceCloud.shared().chatCore.session.sendMessage(allMsg)
        }
    }
    
}
