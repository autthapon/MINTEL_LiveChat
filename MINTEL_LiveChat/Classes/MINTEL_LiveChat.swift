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

let autoDockingDuration: Double = 0.2
let doubleTapTimeInterval: Double = 0.36

public class MINTEL_LiveChat: UIView {
    
    internal static var configuration:LiveChatConfiguration? = nil
    internal static var userId = UUID().uuidString
    internal static var userName = ""
    internal static var chatStarted = false
    internal static var instance:MINTEL_LiveChat!
    internal static var agentState = 1
    internal static var chatBotMode = true
    internal static var messageList: [MockMessage] = []
    
    private var draggable: Bool = true
    private var dragging: Bool = false
    private var autoDocking: Bool = true
    private var singleTapBeenCanceled: Bool = false
    
    private let viewHeight = CGFloat(200)
    private let closeButtonHeight = CGFloat(65)
    
    private var beginLocation: CGPoint?
    private var closeButton:UIButton!
    private var userImageView:UIImageView!
    private var queueTitleLabel:UILabel!
    private var queueLabel:UILabel!
    private var callCenterLabel:UILabel!
    
    internal var chatSessionDelegate:SCSChatSessionDelegate? = nil
    internal var chatEventDelegate:SCSChatEventDelegate? = nil
    
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
        if (MINTEL_LiveChat.chatBotMode) {
            self.userImageView.isHidden = false
            self.callCenterLabel.isHidden = false
            self.queueTitleLabel.isHidden = true
            self.queueLabel.isHidden = true
        } else {
            if (MINTEL_LiveChat.agentState == 5) {
                self.userImageView.isHidden = false
                self.callCenterLabel.isHidden = false
                self.callCenterLabel.text = ChatViewController.callCenterUser.displayName
                self.queueTitleLabel.isHidden = true
                self.queueLabel.isHidden = true
            } else {
                self.userImageView.isHidden = true
                self.callCenterLabel.isHidden = true
                self.queueTitleLabel.isHidden = false
                self.queueLabel.isHidden = false
            }
        }
    }
    
    public func startChat(config:LiveChatConfiguration) {
        
        if (MINTEL_LiveChat.chatStarted) {
            return
        }
        
        MINTEL_LiveChat.chatStarted = true
        
        MINTEL_LiveChat.configuration = config
        MINTEL_LiveChat.userName = config.userName
        self.isHidden = false
        UIApplication.shared.keyWindow?.bringSubviewToFront(self)
        
        if (!MINTEL_LiveChat.chatBotMode) {
            self.startSaleForce()
        } else {
            self.tapAction(sender: UIButton())
        }
    }
    
    internal func startSaleForce() {
        
        self.configureSaleForce()
    }
    
    private func configureSaleForce() {

        if let config = SCSChatConfiguration(liveAgentPod: MINTEL_LiveChat.configuration?.salesforceLiveAgentPod,
                                                     orgId: MINTEL_LiveChat.configuration?.salesforceOrdID,
                                                     deploymentId: MINTEL_LiveChat.configuration?.salesforceDeployID,
                                                     buttonId: MINTEL_LiveChat.configuration?.salesforceButtonID) {

            config.visitorName = MINTEL_LiveChat.userName // Make Argument
            config.queueStyle = .position // Fixed
            
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
        self.closeButton.backgroundColor = UIColor(hexString: "#F08833")
        self.closeButton.roundCorners([.topLeft, .topRight], radius: CGFloat(cornerRadius))
        self.closeButton.isUserInteractionEnabled = false
        
        let image = UIImage(named: "user", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil)
        self.userImageView = UIImageView(image: image)
        self.userImageView.contentMode = .scaleAspectFit
        self.userImageView.frame = CGRect(x: 0, y: self.closeButton.frame.origin.y + self.closeButton.frame.size.height, width: self.frame.size.width, height: self.frame.size.height - (self.closeButton.frame.origin.y + self.closeButton.frame.size.height + 25))
        self.addSubview(self.userImageView)
        
        self.callCenterLabel = UILabel(frame: CGRect(x: 0, y: self.userImageView.frame.origin.y + self.userImageView.frame.size.height, width: self.frame.size.width, height: 25))
        self.callCenterLabel.font = UIFont.systemFont(ofSize: 14)
        self.callCenterLabel.text = ChatViewController.callCenterUser.displayName
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
        
        self.backgroundColor = UIColor(hexString: "#F1F1F1")
        self.layer.cornerRadius = CGFloat(cornerRadius)
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 5
    }
    
    private func addButtonToKeyWindow() {
        
        if let keyWindow = UIApplication.shared.keyWindow {
            keyWindow.addSubview(self)
        } else if (UIApplication.shared.windows.first != nil) {
            UIApplication.shared.windows.first?.addSubview(self)
        }
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
            self.closeButtonHandle()
        } else {
            self.tapAction(sender: sender as AnyObject)
        }
    }
    
    @objc func closeButtonHandle() {
        self.isHidden = true
        MINTEL_LiveChat.agentState = 1
        MINTEL_LiveChat.chatStarted = false
        UIApplication.shared.keyWindow?.sendSubviewToBack(self)
        if (!MINTEL_LiveChat.chatBotMode) {
            ServiceCloud.shared().chatCore.remove(delegate: self)
            ServiceCloud.shared().chatCore.removeEvent(delegate: self)
            ServiceCloud.shared().chatCore.stopSession { (error, chat) in
            }
            
            MINTEL_LiveChat.chatBotMode = true
        }
    }
    
    // MARK: Actions
    @objc func tapAction(sender: AnyObject) {
        DispatchQueue.main.async {
            if (!self.singleTapBeenCanceled && !self.dragging)  {
                
//                var isOpen = true
//                if (ChatBox.chatBotMode) {
//                    isOpen = true
//                } else {
//                    if (ChatBox.agentState == 5) {
//                        isOpen = true
//                    }
//                }
                
//                if (isOpen) {
                    let bundle = Bundle(for: type(of: self))
                    let storyboard = UIStoryboard(name: "ChatBox", bundle: bundle)
                    let vc = storyboard.instantiateInitialViewController()!
                    let viewController = UIApplication.shared.windows.first!.rootViewController!
                    viewController.modalPresentationStyle = .fullScreen
                    viewController.present(vc, animated: true, completion: nil)
//                }
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
        if (self.chatSessionDelegate != nil) {
            self.chatSessionDelegate?.session(session, didError: error, fatal: fatal)
        }
    }
    
    public func session(_ session: SCSChatSession!, didUpdateQueuePosition position: NSNumber!, estimatedWaitTime waitTime: NSNumber!) {
        debugPrint("Queue : ", position)
        DispatchQueue.main.async {
            if (self.queueLabel.tag == Int.max) {
                self.queueLabel.tag = position.intValue
                self.queueLabel.text = ""
            } else if (position.intValue <= self.queueLabel.tag) {
                self.queueLabel.tag = position.intValue
                self.queueLabel.text = String(format: "#%d", self.queueLabel.tag)
            }
        }
        
        if (self.chatSessionDelegate != nil) {
            self.chatSessionDelegate?.session?(session, didUpdateQueuePosition: position, estimatedWaitTime: waitTime)
        }
    }
    
    public func session(_ session: SCSChatSession!, didEnd endEvent: SCSChatSessionEndEvent!) {
        debugPrint("Session End")
        MINTEL_LiveChat.agentState = 1
        if (self.chatSessionDelegate != nil) {
            self.chatSessionDelegate?.session?(session, didEnd: endEvent)
        }
    }
    
    public func session(_ session: SCSChatSession!, didTransitionFrom previous: SCSChatSessionState, to current: SCSChatSessionState) {
//        debugPrint("Transition " , previous, current)
        if (self.chatSessionDelegate != nil) {
            self.chatSessionDelegate?.session?(session, didTransitionFrom: previous, to: current)
        } else {
            if previous == SCSChatSessionState.connecting && current == SCSChatSessionState.queued {
                DispatchQueue.main.async {
                    self.queueLabel.tag = Int.max
                }
            }
        }
    }
}

extension MINTEL_LiveChat : SCSChatEventDelegate {
    public func session(_ session: SCSChatSession!, agentJoined agentjoinedEvent: SCSAgentJoinEvent!) {
        MINTEL_LiveChat.agentState = 5
        if (self.chatEventDelegate != nil) {
            self.chatEventDelegate?.session(session, agentJoined: agentjoinedEvent)
        } else {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                
                let bundle = Bundle(for: type(of: self))
                let storyboard = UIStoryboard(name: "ChatBox", bundle: bundle)
                let vc = storyboard.instantiateInitialViewController()!
                let viewController = UIApplication.shared.windows.first!.rootViewController!
                viewController.modalPresentationStyle = .fullScreen
                viewController.present(vc, animated: true, completion: nil)
            }
        }
        
    }
    
    public func session(_ session: SCSChatSession!, agentLeftConference agentLeftConferenceEvent: SCSAgentLeftConferenceEvent!) {
        MINTEL_LiveChat.agentState = 1
        debugPrint("Agent Left")
        if (self.chatEventDelegate != nil) {
            self.chatEventDelegate?.session(session, agentLeftConference: agentLeftConferenceEvent)
        }
    }
    
    public func session(_ session: SCSChatSession!, processedOutgoingMessage message: SCSUserTextEvent!) {
        debugPrint("process Outgoing Message : ", message)
        if (self.chatEventDelegate != nil) {
            self.chatEventDelegate?.session(session, processedOutgoingMessage: message)
        }
    }
    
    public func session(_ session: SCSChatSession!, didUpdateOutgoingMessageDeliveryStatus message: SCSUserTextEvent!) {
        debugPrint("didUpdateOutgoingMessageDeliveryStatus : ", message)
        if (self.chatEventDelegate != nil) {
            self.chatEventDelegate?.session(session, didUpdateOutgoingMessageDeliveryStatus: message)
        }
    }
    
    public func session(_ session: SCSChatSession!, didSelectMenuItem menuEvent: SCSChatMenuSelectionEvent!) {
        debugPrint("didSelectMenuItem : ", menuEvent)
        if (self.chatEventDelegate != nil) {
            self.chatEventDelegate?.session(session, didSelectMenuItem: menuEvent)
        }
    }
    
    public func session(_ session: SCSChatSession!, didReceiveMessage message: SCSAgentTextEvent!) {
        debugPrint("didReceiveMessage : ", message)
        if (self.chatEventDelegate != nil) {
            self.chatEventDelegate?.session(session, didReceiveMessage: message)
        }
    }
    
    public func session(_ session: SCSChatSession!, didReceiveChatBotMenu menuEvent: SCSChatBotMenuEvent!) {
        debugPrint("didReceiveChatBotMenu : ", menuEvent)
        if (self.chatEventDelegate != nil) {
            self.chatEventDelegate?.session(session, didReceiveChatBotMenu: menuEvent)
        }
    }
    
    public func session(_ session: SCSChatSession!, didReceiveFileTransferRequest fileTransferEvent: SCSFileTransferEvent!) {
        debugPrint("didReceiveFileTransferRequest : ", fileTransferEvent)
        if (self.chatEventDelegate != nil) {
            self.chatEventDelegate?.session(session, didReceiveFileTransferRequest: fileTransferEvent)
        }
    }
    
    public func transferToButtonInitiated(with session: SCSChatSession!) {
        debugPrint("transferToButtonInitiated : ", session)
        if (self.chatEventDelegate != nil) {
            self.chatEventDelegate?.transferToButtonInitiated(with: session)
        }
    }
    
    public func transferToButtonCompleted(with session: SCSChatSession!) {
        debugPrint("transferToButtonCompleted : ", session)
        if (self.chatEventDelegate != nil) {
            self.chatEventDelegate?.transferToButtonCompleted(with: session)
        }
    }
    
    public func transferToButtonFailed(with session: SCSChatSession!, error: Error!) {
        debugPrint("transferToButtonFailed : ", session)
        if (self.chatEventDelegate != nil) {
            self.chatEventDelegate?.transferToButtonFailed(with: session, error: error)
        }
    }
    
    
}
