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
    }
    
    @objc func saleForcesDidUpdateQueuePosition(_ notification: Notification) {
        let _:SCSChatSession = notification.userInfo?["session"] as! SCSChatSession
        let position:Int = notification.userInfo?["position"] as! Int
        
        if (self.queuePosition > position && position > 0) {
            self.queuePosition = position
            self.items.append(MyMessage(systemMessageType1: String(format: "Queue Position:%d", self.queuePosition)))
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.scrollToBottom()
            }
        }
    }
    
    @objc func saleForcesAgentJoined(_ notification: Notification) {
        let _:SCSChatSession = notification.userInfo?["session"] as! SCSChatSession
        let _:SCSAgentJoinEvent = notification.userInfo?["event"] as! SCSAgentJoinEvent
        self.items.append(MyMessage(agentJoin: true))
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.scrollToBottom()
        }
    }
    
    @objc func saleForcesDidReceivedMessage(_ notification: Notification) {
        let _:SCSChatSession = notification.userInfo?["session"] as! SCSChatSession
        let textEvent:SCSAgentTextEvent = notification.userInfo?["message"] as! SCSAgentTextEvent
        self.items.append(MyMessage(text: textEvent.text, agent: true, bot: false))
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.scrollToBottom()
        }
    }
    
    @objc func saleForcesAgentLeft(_ notification: Notification) {
        let _:SCSChatSession = notification.userInfo?["session"] as! SCSChatSession
        let _:SCSAgentLeftConferenceEvent = notification.userInfo?["event"] as! SCSAgentLeftConferenceEvent
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        let date24 = dateFormatter.string(from: date)
        
        self.items.append(MyMessage(systemMessageType1: String(format: "Chat ended %@", date24)))
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.scrollToBottom()
        }
    }
    
    @objc func saleForcesDidEnd(_ notification: Notification) {
        let _:SCSChatSession = notification.userInfo?["session"] as! SCSChatSession
        let _:SCSChatSessionEndEvent = notification.userInfo?["event"] as! SCSChatSessionEndEvent
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        let date24 = dateFormatter.string(from: date)
        
        self.items.append(MyMessage(systemMessageType1: String(format: "Chat ended %@", date24)))
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.scrollToBottom()
            self.hideImagePanel()
            self.inputTextView.resignFirstResponder()
        }
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
        self.items.append(MyMessage(systemMessageType2: "Routing you to a Live Agent"))
        self.tableView.reloadData()
        self.tableView.scrollToBottom()
        MINTEL_LiveChat.chatBotMode = false
        MINTEL_LiveChat.instance.startSaleForce()
    }
    
}
