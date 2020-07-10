//
//  ViewController.swift
//  Chat
//
//  Created by autthapon@gmail.com on 06/14/2020.
//  Copyright (c) 2020 autthapon@gmail.com. All rights reserved.
//

import UIKit
import MINTEL_LiveChat

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
        let webhookUrl:String           = "https://asia-east2-tmn-chatbot-integration.cloudfunctions.net"
        let uploadUrl:String            = "https://us-central1-test-tmn-bot.cloudfunctions.net"
        let xApiKey:String              = "381b0ac187994f82bdc05c09d1034afa"

//        let config = LiveChatConfiguration.init(withUserName: "Note", withSalesforceLiveAgentPod: liveagentPod, withSalesForceOrdId: ordID, withSalesforceDeployId: deployID, withSalesforceButtonId: buttonID)
        
        let config = LiveChatConfiguration(withUserName: "Note", withSalesforceLiveAgentPod: liveagentPod, withSalesForceOrdId: ordID, withSalesforceDeployId: deployID, withSalesforceButtonId: buttonID, withWebHookBaseUrl: webhookUrl, withXApiKey: xApiKey, withUploadBaseUrl: uploadUrl)
        
        appDelegate.chat.startChat(config: config)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

