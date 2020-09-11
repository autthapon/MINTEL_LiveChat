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
    
    override func loadView() {
        let config = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: config)
        webView.uiDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let request = URLRequest(url: self.url!)
        webView.load(request)
    }
}
