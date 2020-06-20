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

        let config = LiveChatConfiguration.init(withUserName: "Note", withSalesforceLiveAgentPod: liveagentPod, withSalesForceOrdId: ordID, withSalesforceDeployId: deployID, withSalesforceButtonId: buttonID)
        
        appDelegate.chat.startChat(config: config)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

