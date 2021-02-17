//
//  ChatBoxConfiguration.swift
//  Chat
//
//  Created by Autthapon Sukjaroen on 17/6/2563 BE.
//

import Foundation
import ServiceCore
import ServiceChat

public class LiveChatConfiguration {
    
    internal var webHookBaseUrl:String!
    internal var uploadBaseUrl:String!
    internal var xApikey:String!
    internal var userName:String!
    internal var disableBotMode:Bool = false
    internal var salesforceLiveAgentPod:String!
    internal var salesforceOrdID:String!
    internal var salesforceDeployID:String!
    internal var salesforceButtonID:String!
    internal var surveyChatbotUrl:String?
    internal var surveyFormUrl:String?
    internal var announcementUrl:String?
    internal var firstname:String!
    internal var lastname:String!
    internal var email:String!
    internal var phone:String!
    internal var tmnId:String!
    internal var language:String!
    
    public init(withUserName userName:String, withSalesforceLiveAgentPod salesforceLiveAgentPod:String, withSalesForceOrdId salesforceOrdId:String, withSalesforceDeployId salesforceDeployId:String, withSalesforceButtonId salesforceButtonId:String, withWebHookBaseUrl webhookBaseUrl:String, withXApiKey xapiKey:String, withUploadBaseUrl uploadBaseUrl:String, withSurveyChatbotUrl surveyChatbotUrl:String?, withSurveyFormUrl surveyFormUrl:String?, withAnnouncementUrl announcementUrl:String, withFirstName firstname:String, withLastName lastname:String, withEmail email:String, withPhone phone:String, withTmnId tmnId:String, withDisableBotMode disableBotMode:Bool = false,
                withLanguage language:String = "th") {
        self.userName = userName
        self.salesforceLiveAgentPod = salesforceLiveAgentPod
        self.salesforceOrdID = salesforceOrdId
        self.salesforceButtonID = salesforceButtonId
        self.salesforceDeployID = salesforceDeployId
        self.webHookBaseUrl = webhookBaseUrl
        self.xApikey = xapiKey
        self.uploadBaseUrl = uploadBaseUrl
        self.surveyChatbotUrl = surveyChatbotUrl
        self.surveyFormUrl = surveyFormUrl
        self.announcementUrl = announcementUrl
        self.firstname = firstname
        self.lastname = lastname
        self.phone = phone
        self.email = email
        self.tmnId = tmnId
        self.disableBotMode = disableBotMode
        self.language = language
    }
}
