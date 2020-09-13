//
//  MyMessage.swift
//  MINTEL_LiveChat
//
//  Created by Autthapon Sukjaroen on 13/8/2563 BE.
//

import Foundation

public enum MyMessageKind : Equatable {
    case text(String)
    case file(String, URL)
    case menu(String, [[String:Any]])
    case image(UIImage, String)
    case systemMessageType1(String)
    case systemMessageType2(String)
    case agentJoin(String)
    case typing
}

public func ==(lhs: MyMessageKind, rhs: MyMessageKind) -> Bool {
    switch (lhs, rhs) {
    case (.systemMessageType1(_), .systemMessageType1(_)):
        return true
    case (.systemMessageType2(_), .systemMessageType2(_)):
        return true
    case (.typing, .typing):
        return true
    default: return false
    }
}

class MyMessage {
    
    var messageId: String
    var sentDate: Date
    var kind: MyMessageKind
    var agent:Bool
    var bot:Bool
    var disableMenu:Bool = false
    
    private init(kind: MyMessageKind, agent: Bool, bot:Bool) {
        self.kind = kind
        self.agent = agent
        self.bot = bot
        self.messageId = UUID().uuidString
        self.sentDate = Date()
    }
    
    convenience init(typing: Bool, agent: Bool) {
        self.init(kind: .typing, agent: agent, bot: true)
    }
    
    convenience init(agentJoin: Bool, agentName: String) {
        self.init(kind: .agentJoin(agentName), agent: true, bot: true)
    }
    
    convenience init(text: String, agent: Bool) {
        self.init(kind: .text(text), agent: agent, bot: true)
    }
    
    convenience init(fileName: String, fileURL: URL) {
        self.init(kind: .file(fileName, fileURL), agent: false, bot: false)
    }
    
    convenience init(systemMessageType1: String) {
        self.init(kind: .systemMessageType1(systemMessageType1), agent: false, bot: true)
    }
    
    convenience init(systemMessageType2: String) {
        self.init(kind: .systemMessageType2(systemMessageType2), agent: false, bot: true)
    }
    
    convenience init(text: String, systemMessage: Bool) {
        self.init(kind: .text(text), agent: true, bot: true)
    }
    
    convenience init(text: String, agent: Bool, bot: Bool) {
        self.init(kind: .text(text), agent: agent, bot: bot)
    }
    
    convenience init(text: String, agent: Bool, menu: [[String: Any]]) {
        self.init(kind: .menu(text, menu), agent: agent, bot: true)
    }
    
    convenience init(text: String, agent: Bool, bot: Bool, menu: [[String: Any]]) {
        self.init(kind: .menu(text, menu), agent: agent, bot: bot)
    }
    
    convenience init(image: UIImage, imageUrl:String) {
        self.init(kind: .image(image, imageUrl), agent: false, bot: false)
    }
    
    convenience init(image: UIImage, imageUrl:String, agent: Bool, bot : Bool) {
        self.init(kind: .image(image, imageUrl), agent: agent, bot: bot)
    }
}
