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
        
        let liveagentPod:String         = "d.la2-c2-hnd.salesforceliveagent.com";
        let ordID:String                = "00D2x000005sq7f";
        let deployID:String             = "5722x000000TffP";
        let buttonID:String             = "5732x000000TgxT";
        let webhookUrl:String           = "https://asia-east2-acm-clt-chatbots.cloudfunctions.net/"
        let uploadUrl:String            = "https://us-central1-test-tmn-bot.cloudfunctions.net"
        let xApiKey:String              = "381b0ac187994f82bdc05c09d1034afa"
        let surveyChatbotUrl:String       = "https://www.google.co.th?uid=sessionId"
        let surveryFormUrl:String       = "https://truemoney--c.ap12.visual.force.com/apex/MINTEL_ExternalChatSurvey?uid=sessionId"
        let announcementUrl:String       = "https://us-central1-test-tmn-bot.cloudfunctions.net/announcementmulti?uid=sessionId"
        // https://asia-east2-acm-clt-chatbots.cloudfunctions.net/onNewSessionMobile

        let firstname = "Note"
        let lastname = "Note"
        let phone = "0818888888"
        let email = "a@a.com"
        let tmnId = "11241313"
        let saleforceFirst = false
        
        let config = LiveChatConfiguration(withUserName: "Note", withSalesforceLiveAgentPod: liveagentPod, withSalesForceOrdId: ordID, withSalesforceDeployId: deployID, withSalesforceButtonId: buttonID, withWebHookBaseUrl: webhookUrl, withXApiKey: xApiKey, withUploadBaseUrl: uploadUrl, withSurveyChatbotUrl: surveyChatbotUrl, withSurveyFormUrl: surveryFormUrl, withAnnouncementUrl: announcementUrl, withFirstName: firstname, withLastName: lastname, withEmail: email, withPhone: phone, withTmnId: tmnId, withSalesforceFirst: saleforceFirst)
        
        appDelegate.chat.startChat(config: config)
    }
    
    @objc @IBAction func stopChat() {
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        appDelegate.chat.stopChat()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

