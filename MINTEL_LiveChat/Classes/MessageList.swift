//
//  MessageList.swift
//  MINTEL_LiveChat
//
//  Created by Autthapon Sukjaroen on 13/9/2563 BE.
//

import Foundation

class MessageList {
    
    fileprivate static var items = [MyMessage]()
    
    static internal func clear() {
        MessageList.items.removeAll()
    }
    
    static internal func add(item: MyMessage) -> Int {
        MessageList.items.append(item)
        MessageList.sort()
        
        return MessageList.items.count - 1
    }
    
    static internal func remove(item: MyMessage, remove: Bool) {
        MessageList.items.removeAll { (it) -> Bool in
            
            switch(it.kind) {
            case .systemMessageType1(let msg):
                if item.kind == it.kind {
                    if msg.contains("คิวของคุณคือลำดับที่") {
                        return true
                    }
                }
            case .systemMessageType2(let msg):
                if item.kind == it.kind {
                    if (msg == "กรุณารอสักครู่") {
                        return true
                    } else if (msg == MINTEL_LiveChat.getLanguageString(str: "please_wait")) {
                        return true
                    }
                }
            case .typing:
                if item.kind == it.kind {
                    return true
                }
            default:
                return false
            }
            
            return false
        }
    }
    
    static internal func add(item: MyMessage, remove: Bool) {
        if (remove) {
            MessageList.remove(item: item, remove: remove)
        }
        let _ = MessageList.add(item: item)
    }
    
    static internal func removeTyping() {
        MessageList.items.removeAll { (item) -> Bool in
            switch(item.kind) {
            case .typing:
                return true
            default:
                return false
            }
        }
    }
    
    static internal func setItemAt(index: Int, item: MyMessage) {
        if (MessageList.items.count > index) {
            MessageList.items[index] = item
        }
    }
    
    static internal func at(index: Int) -> MyMessage? {
        if (MessageList.items.count > index) {
            return MessageList.items[index]
        }
        return nil
    }
    
    static internal func count() -> Int {
        return MessageList.items.count
    }
    
    static internal func disableOnMenu() {
        MessageList.items.forEach { (item) in
            item.disableMenu = true
        }
    }
    
    fileprivate static func sort() {
        MessageList.items.sort { (itemA, itemB) -> Bool in
            
            var A:Int = 0
            var B:Int = 0
            switch itemA.kind {
                case .typing: A = 2
                default : A = 0
            }
            switch itemB.kind {
                case .typing: B = 2
                default : B = 0
            }
            
            return B > A
        }
    }
    
    static internal func getMessageForAgent() -> String {
        let ignoreMessage = ["Connecting", "agent", "Your place", "TrueMoney Care สวัสดีค่ะ"]
        
        var allMsg = ""
        
        MessageList.items.forEach { (item) in
            var shouldIgnore = false
            var txtToSend = ""
            switch item.kind {
            case .file(_, _, let txt):
                txtToSend = txt
                for i in 0...ignoreMessage.count - 1 {
                    if (txt.starts(with: ignoreMessage[i])) {
                        shouldIgnore = true
                        break
                    }
                }
                break
            case .image(_, let txt):
                txtToSend = txt
                for i in 0...ignoreMessage.count - 1 {
                    if (txt.starts(with: ignoreMessage[i])) {
                        shouldIgnore = true
                        break
                    }
                }
                break
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
                        name = MINTEL_LiveChat.configuration?.firstname ?? "Customer"
                    } else {
                        name = "Visitor"
                    }
                    
                    allMsg = String(format: "%@\n%@: %@", allMsg, name, txtToSend)
                }
            }
        }
        
        return allMsg
    }
}
