//
//  ViewController.swift
//  Chat
//
//  Created by autthapon@gmail.com on 06/14/2020.
//  Copyright (c) 2020 autthapon@gmail.com. All rights reserved.
//

import UIKit
import MINTEL_LiveChat
import ServiceCore
import ServiceChat

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    @objc @IBAction func startChat(sender: UIButton) {
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        /*
        let liveagentPod:String         = "d.la2-c2-ukb.salesforceliveagent.com";
        let ordID:String                = "00D2w000006wosb";
        let deployID:String             = "5722w0000009B6e";
        let buttonID:String             = "5732w0000009E15";
 */
        
        // Prod
        let liveagentPod:String         = "d.la2-c2-ukb.salesforceliveagent.com";
        let ordID:String                = "00D7F000007CmSP";
        let deployID:String             = "5727F000000LmFo";
        let buttonID:String             = "5732t000000Gmas"; // main
        //let buttonID:String             = "5737F000000Pq0m"; // foreigner
        //let buttonID:String             = "5732t000000k9bN"; // direct chat 3
        
        
//        let webhookUrl:String           = "https://asia-east2-tmn-chatbot-integration.cloudfunctions.net"
        //let webhookUrl:String           = "https://asia-east2-acm-clt-chatbots.cloudfunctions.net" // prod
        let webhookUrl:String           = "https://asia-east2-acm-clt-chatbots-stg.cloudfunctions.net" // dev
        let uploadUrl:String            = "https://asia-east2-acm-clt-chatbots.cloudfunctions.net"
        let xApiKey:String              = "381b0ac187994f82bdc05c09d1034afa" // dev
        let surveryFormUrl:String       = "https://truemoney.secure.force.com/staffsurvey?uid=sessionId"
        let chatBotSurveyUrl:String     = "https://truemoney.secure.force.com/botsurvey?uid=sessionId"
        //let announcementUrl:String       = "https://asia-east2-acm-clt-chatbots.cloudfunctions.net/announcementmulti?uid=sessionId"
        //let announcementUrl:String       = "https://us-central1-test-tmn-bot.cloudfunctions.net/announcementmulti?uid=sessionId"
        // https://asia-east2-acm-clt-chatbots.cloudfunctions.net/onNewSessionMobile
        let announcementUrl:String       = "https://asia-east2-acm-clt-chatbots.cloudfunctions.net/announcementmulti?uid=sessionId"
        //let announcementUrl:String       =

        let firstname = "Note"
        let lastname = "Note"
        let phone = "0879108889"
        let email = ""
        let tmnId = "tmn.10012386317"
        let disableBotMode = false
        let startupIntent = "00_home";
        
        let config = LiveChatConfiguration(withUserName: "Note", withSalesforceLiveAgentPod: liveagentPod, withSalesForceOrdId: ordID, withSalesforceDeployId: deployID, withSalesforceButtonId: buttonID, withWebHookBaseUrl: webhookUrl, withXApiKey: xApiKey, withUploadBaseUrl: uploadUrl, withSurveyChatbotUrl: chatBotSurveyUrl, withSurveyFormUrl: surveryFormUrl, withAnnouncementUrl: announcementUrl, withFirstName: firstname, withLastName: lastname, withEmail: email, withPhone: phone, withTmnId: tmnId, withDisableBotMode: disableBotMode, withLanguage: "en", withStartupIntent: startupIntent)
        
        appDelegate.chat.startChat(config: config)
        
        print("App Version : ", appDelegate.chat.getSDKVersion())
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { // Change `2.0` to the desired number of seconds.
//            appDelegate.chat.hideChat()
//        }
    }
    
    @objc @IBAction func startChatAnotherPhone(sender: UIButton) {
            let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
            
            let liveagentPod:String         = "d.la2-c2-ukb.salesforceliveagent.com";
            let ordID:String                = "00D2w000006wosb";
            let deployID:String             = "5722w0000009B6e";
            let buttonID:String             = "5732t000000Gmas"; // main
            //let buttonID:String             = "5732w0000009E15";
            //let webhookUrl:String           = "https://asia-east2-acm-clt-chatbots.cloudfunctions.net"
            let webhookUrl:String           = "https://asia-east2-acm-clt-chatbots-stg.cloudfunctions.net" // dev
            let uploadUrl:String            = "https://asia-east2-acm-clt-chatbots.cloudfunctions.net"
            let xApiKey:String              = "381b0ac187994f82bdc05c09d1034afa"
            let surveryFormUrl:String       = "https://truemoney.secure.force.com/staffsurvey?uid=sessionId"
            let chatBotSurveyUrl:String     = "https://truemoney.secure.force.com/botsurvey?uid=sessionId"
            //let announcementUrl:String       = "https://us-central1-test-tmn-bot.cloudfunctions.net/announcementmulti?uid=sessionId"
            let announcementUrl:String       = "https://asia-east2-acm-clt-chatbots.cloudfunctions.net/announcementmulti?uid=sessionId"
            // https://asia-east2-acm-clt-chatbots.cloudfunctions.net/onNewSessionMobile

            let firstname = "Note"
            let lastname = "Note"
            let phone = "0818888889"
            let email = "a@a.com"
            let tmnId = "11241313"
            let disableBotMode = false
            
            let config = LiveChatConfiguration(withUserName: "Note", withSalesforceLiveAgentPod: liveagentPod, withSalesForceOrdId: ordID, withSalesforceDeployId: deployID, withSalesforceButtonId: buttonID, withWebHookBaseUrl: webhookUrl, withXApiKey: xApiKey, withUploadBaseUrl: uploadUrl, withSurveyChatbotUrl: chatBotSurveyUrl, withSurveyFormUrl: surveryFormUrl, withAnnouncementUrl: announcementUrl, withFirstName: firstname, withLastName: lastname, withEmail: email, withPhone: phone, withTmnId: tmnId, withDisableBotMode: disableBotMode)
            
            appDelegate.chat.startChat(config: config)
            
            print("App Version : ", appDelegate.chat.getSDKVersion())
            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { // Change `2.0` to the desired number of seconds.
//                appDelegate.chat.hideChat()
//            }
        }
    
    @objc @IBAction func stopChat() {
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        //appDelegate.chat.stopChat()
        appDelegate.chat.hideChat()
    }
    
    @objc @IBAction func checkSession() {
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        debugPrint("Session : ", appDelegate.chat.isSessionActive())
        
        appDelegate.chat.unhideChat()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

