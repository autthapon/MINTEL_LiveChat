//
//  ChatBoxConfiguration.swift
//  Chat
//
//  Created by Autthapon Sukjaroen on 17/6/2563 BE.
//

import Foundation

public class LiveChatConfiguration {
    
    internal var userName:String!
    internal var salesforceLiveAgentPod:String!
    internal var salesforceOrdID:String!
    internal var salesforceDeployID:String!
    internal var salesforceButtonID:String!
    
    public init(withUserName userName:String, withSalesforceLiveAgentPod salesforceLiveAgentPod:String, withSalesForceOrdId salesforceOrdId:String, withSalesforceDeployId salesforceDeployId:String, withSalesforceButtonId salesforceButtonId:String) {
        self.userName = userName
        self.salesforceLiveAgentPod = salesforceLiveAgentPod
        self.salesforceOrdID = salesforceOrdId
        self.salesforceButtonID = salesforceButtonId
        self.salesforceDeployID = salesforceDeployId
    }
}