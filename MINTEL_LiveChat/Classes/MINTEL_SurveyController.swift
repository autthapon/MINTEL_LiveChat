//
//  MINTEL_SurveyController.swift
//  MINTEL_LiveChat
//
//  Created by Autthapon Sukjaroen on 11/9/2563 BE.
//

import Foundation
import WebKit

class MINTEL_SurveyController : UIViewController, WKUIDelegate {
    
    var webView:WKWebView!
    var url:URL? = nil
    
    var btnClose:UIBarButtonItem!
    var btnCollapse:UIBarButtonItem!
    
    override func loadView() {
        let config = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: config)
        webView.uiDelegate = self
        view = webView
    }
    
    @objc func collapseChat() {
        MINTEL_LiveChat.unreadMessage = 0
        
        NotificationCenter.default.post(name: Notification.Name(MINTELNotifId.updateUnreadMessageCount),
        object: nil,
        userInfo:nil)
        
        MINTEL_LiveChat.instance.isHidden = false
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func closeChat() {
        MINTEL_LiveChat.instance.closeButtonHandle()
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            MINTEL_LiveChat.instance.isHidden = true
        }
        super.viewDidAppear(animated)
    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        DispatchQueue.main.async {
//            MINTEL_LiveChat.instance.isHidden = false
//        }
//        
//        super.viewDidDisappear(animated)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnCollapse = UIBarButtonItem(image: UIImage(named: "compress", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil), style: .plain, target: self, action: #selector(collapseChat))
        self.btnCollapse.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = self.btnCollapse
        
        self.btnClose = UIBarButtonItem(image: UIImage(named: "close", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil), style: .plain, target: self, action: #selector(closeChat))
        self.btnClose.tintColor = UIColor.black
        
        self.navigationItem.rightBarButtonItem = self.btnClose
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "true_bar_title", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil))
        
        let request = URLRequest(url: self.url!)
        webView.load(request)
    }
}
