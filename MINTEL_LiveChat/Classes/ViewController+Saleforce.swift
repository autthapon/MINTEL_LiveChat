//
//  ViewController+Saleforce.swift
//  MINTEL_LiveChat
//
//  Created by Autthapon Sukjaroen on 14/8/2563 BE.
//

import UIKit
import ServiceCore
import ServiceChat

extension ViewController {
    
    internal func setupSaleForcesNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(saleForcesDidUpdateQueuePosition(_:)),
                                               name: Notification.Name(SalesForceNotifId.didUpdatePosition),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(saleForcesAgentJoined(_:)),
                                               name: Notification.Name(SalesForceNotifId.agentJoined),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(saleForcesDidReceivedMessage(_:)),
                                               name: Notification.Name(SalesForceNotifId.didReceiveMessage),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(saleForcesAgentLeft(_:)),
                                               name: Notification.Name(SalesForceNotifId.agentLeftConference),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(saleForcesDidEnd(_:)),
                                               name: Notification.Name(SalesForceNotifId.didEnd),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(saleForceUserTyping(_:)),
                                               name: Notification.Name(MINTELNotifId.userIsTyping),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                                selector: #selector(saleForceUserNotTyping(_:)),
                                                name: Notification.Name(MINTELNotifId.userIsNotTyping),
                                                object: nil)
        
        NotificationCenter.default.addObserver(self,
                                                selector: #selector(saleForceSneakPeak(_:)),
                                                name: Notification.Name(MINTELNotifId.sneakPeak),
                                                object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(MINTEL_reallyEndChat(_:)),
                                               name: Notification.Name(MINTELNotifId.reallyExitChat),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillTerminate), name: UIApplication.willTerminateNotification, object: nil)
    }
    
    internal func removeSalesforceNotification() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(SalesForceNotifId.didUpdatePosition), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(SalesForceNotifId.agentJoined), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(SalesForceNotifId.didReceiveMessage), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(SalesForceNotifId.agentLeftConference), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(SalesForceNotifId.didEnd), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(MINTELNotifId.userIsTyping), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(MINTELNotifId.reallyExitChat), object: nil)
    }
    
    @objc func appWillTerminate() {
        switch MINTEL_LiveChat.agentState {
        case .start: break
        case .waiting: break
        case .end: break
        case .joined:
            ServiceCloud.shared().chatCore.stopSession()
            break
        }
    }
    
    @objc func MINTEL_reallyEndChat(_ notification: Notification) {
        self.reallyEndChat()
    }
    
    @objc func saleForceUserTyping(_ notification: Notification) {
        switch MINTEL_LiveChat.agentState {
        case .start: break
        case .waiting: break
        case .end: break
        case .joined:
            ServiceCloud.shared().chatCore.session.isUserTyping = true
            break
        }
        
    }
    
    @objc func saleForceUserNotTyping(_ notification: Notification) {
        switch MINTEL_LiveChat.agentState {
        case .start: break
        case .waiting: break
        case .end: break
        case .joined:
            ServiceCloud.shared().chatCore.session.isUserTyping = false
            break
        }
    }
    
    @objc func saleForceSneakPeak(_ notification: Notification) {
        switch MINTEL_LiveChat.agentState {
        case .start: break
        case .waiting: break
        case .end: break
        case .joined:
            let message:String = notification.userInfo?["message"] as? String ?? ""
            debugPrint("Send Sneak Peak : ", message)
            ServiceCloud.shared().chatCore.session.sendSneakPeek(message)
            break
        }
    }
    
    
    @objc func saleForcesDidUpdateQueuePosition(_ notification: Notification) {
//        let _:SCSChatSession = notification.userInfo?["session"] as! SCSChatSession
//        let position:Int = notification.userInfo?["position"] as! Int
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.scrollToBottom(animated: true)
        }
    }
    
    @objc func saleForcesAgentJoined(_ notification: Notification) {
//        let _:SCSChatSession = notification.userInfo?["session"] as! SCSChatSession
//        let agentJoinEvent:SCSAgentJoinEvent = notification.userInfo?["event"] as! SCSAgentJoinEvent
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.scrollToBottom(animated: true)
        }
        
        self.inputTextView.MINTEL_enable()
        
    }
    
    @objc func saleForcesDidReceivedMessage(_ notification: Notification) {
//        let _:SCSChatSession = notification.userInfo?["session"] as! SCSChatSession
//        let textEvent:SCSAgentTextEvent = notification.userInfo?["message"] as! SCSAgentTextEvent
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.scrollToBottom(animated: true)
        }
    }
    
    @objc func saleForcesAgentLeft(_ notification: Notification) {
        let _:SCSChatSession = notification.userInfo?["session"] as! SCSChatSession
        let _:SCSAgentLeftConferenceEvent = notification.userInfo?["event"] as! SCSAgentLeftConferenceEvent
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.scrollToBottom(animated: true)
        }
        
        self.disableUserInteraction()
        
//        MINTEL_LiveChat.instance.reallyEndChat()
    }
    
    @objc func saleForcesDidEnd(_ notification: Notification) {
        let _:SCSChatSession = notification.userInfo?["session"] as! SCSChatSession
        let _:SCSChatSessionEndEvent = notification.userInfo?["event"] as! SCSChatSessionEndEvent
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.scrollToBottom(animated: false)
            self.disableUserInteraction()
        }
        
       
//        MINTEL_LiveChat.instance.reallyEndChat()
    }
    
    fileprivate func reallyEndChat() {
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.scrollToBottom(animated: true)
            self.hideImagePanel()
            self.inputTextView.textView.resignFirstResponder()
        }
        
        self.viewConfirm.removeFromSuperview()
    }
    
    
    /*
     func session(_ session: SCSChatSession!, didUpdateQueuePosition position: NSNumber!) {
     if (self.queuePosition > position.intValue) {
     self.queuePosition = position.intValue
     self.items.append(MyMessage(systemMessageType1: String(format: "Queue Position:%d", self.queuePosition)))
     self.tableView.reloadData()
     self.tableView.scrollToBottom()
     }
     }
     
     func session(_ session: SCSChatSession!, agentJoined agentjoinedEvent: SCSAgentJoinEvent!) {
     
     }
     
     func session(_ session: SCSChatSession!, agentLeftConference agentLeftConferenceEvent: SCSAgentLeftConferenceEvent!) {
     
     }
     
     func session(_ session: SCSChatSession!, processedOutgoingMessage message: SCSUserTextEvent!) {
     
     }
     
     func session(_ session: SCSChatSession!, didUpdateOutgoingMessageDeliveryStatus message: SCSUserTextEvent!) {
     
     }
     
     func session(_ session: SCSChatSession!, didSelectMenuItem menuEvent: SCSChatMenuSelectionEvent!) {
     
     }
     
     func session(_ session: SCSChatSession!, didReceiveMessage message: SCSAgentTextEvent!) {
     
     }
     
     func session(_ session: SCSChatSession!, didReceiveChatBotMenu menuEvent: SCSChatBotMenuEvent!) {
     
     }
     
     func session(_ session: SCSChatSession!, didReceiveFileTransferRequest fileTransferEvent: SCSFileTransferEvent!) {
     
     }
     
     func transferToButtonInitiated(with session: SCSChatSession!) {
     
     }
     
     func transferToButtonCompleted(with session: SCSChatSession!) {
     
     }
     
     func transferToButtonFailed(with session: SCSChatSession!, error: Error!) {
     
     }
     
     func session(_ session: SCSChatSession!, didError error: Error!, fatal: Bool) {
     
     }
     
     func terminate() {
     
     }
     */
    
    func sendMessageToSaleForce(text: String) {
        ServiceCloud.shared().chatCore.session.sendMessage(text)
    }
    
    func switchToAgentMode() {
        
        debugPrint("Switch To Agent Mode =====")
        
        MINTEL_LiveChat.stopTimer()
        self.disableUserInteraction()
        
        // REmove previous กรุณารอสักครู่
        
        
        DispatchQueue.main.async {
        
            MessageList.add(item: MyMessage(systemMessageType2: "กรุณารอสักครู่"), remove: true)
            self.tableView.reloadData()
            self.disableUserInteraction()
            self.tableView.scrollToBottom(animated: true)
            MINTEL_LiveChat.chatBotMode = false
            MINTEL_LiveChat.instance.startSaleForce()
        }
    }
    
    
    
    
}
