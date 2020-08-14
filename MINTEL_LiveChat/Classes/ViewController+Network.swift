//
//  ViewController+Network.swift
//  MINTEL_LiveChat
//
//  Created by Autthapon Sukjaroen on 13/8/2563 BE.
//

import Foundation
import Alamofire

fileprivate let urlUpload = "https://asia-east2-tmn-chatbot-integration.cloudfunctions.net/uploadFile"

extension ViewController {
    
    internal func getAnnouncementMessage() {
        let params: Parameters = [:]
         let url = (MINTEL_LiveChat.configuration?.announcementUrl ?? "").replacingOccurrences(of: "sessionId", with: MINTEL_LiveChat.userId)
         let header:HTTPHeaders = [
             "x-api-key": MINTEL_LiveChat.configuration?.xApikey ?? "" // "381b0ac187994f82bdc05c09d1034afa"
         ]
        
         Alamofire
             .request(url, method: .post, parameters: params, encoding: JSONEncoding.init(), headers: header)
             .responseJSON { (response) in
                 switch response.result {
                 case .success(_):
                     if let json = response.value {
                         debugPrint(json)
                         let dict = json as! [String: Any]
                         let desc = dict["Description__c"] as? String ?? ""
                         
                         if desc.count > 0 {
                             DispatchQueue.global(qos: .userInitiated).async {
                     
                                self.items.append(MyMessage(text: desc, agent: true))
                                 DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                    self.tableView.scrollToBottom()
                                    
                                    self.sendPost(text: "สวัสดี")
                                 }
                             }
                         }
                         
                     }
                     break
                 case .failure( _):
                     break
                 }
         }
    }
    
    internal func sendPost(text: String) {
            
            let params : Parameters = ["session_id": MINTEL_LiveChat.userId,"text": text]
            let url = String(format: "%@/webhook", MINTEL_LiveChat.configuration?.webHookBaseUrl ?? "")
            let header:HTTPHeaders = [
                "x-api-key": MINTEL_LiveChat.configuration?.xApikey ?? "" // "381b0ac187994f82bdc05c09d1034afa"
            ]
           
            Alamofire
                .request(url, method: .post, parameters: params, encoding: JSONEncoding.init(), headers: header)
                .responseJSON { (response) in
                    switch response.result {
                        case .success(_):
                            if let json = response.value {
                                debugPrint(json)
                                let dict = json as! [String: Any]
                                let error = dict["error"] as? [String: Any] ?? nil
                                if (error == nil) {
                                    let intent = dict["intent"] as? String ?? ""
                                    if (intent == "08_wait_for_call") {
                                        self.switchToAgentMode()
                                    }
                                    
                                    let messages = dict["messages"] as! [[String: Any]]
                                    messages.forEach { body in
                                        let type = body["type"] as? String ?? ""
                                        let quickReplyTitle = body["text"] as? String ?? ""
                                        let quickReply = body["quickReply"] as? [String: Any] ?? nil
                                        if (type == "text") {
                                            if (quickReply != nil) {
                                                let items = quickReply!["items"] as? [[String:Any]] ?? []
//                                                let theMessage = ["type": 1, "menuItem" : items] as [String : Any]
                                                self.items.append(MyMessage(text: quickReplyTitle, agent: true, menu: items))
//                                                self.insertMessage(MockMessage(custom: theMessage, title: quickReplyTitle,  user: ChatViewController.callCenterUser, messageId: UUID().uuidString, date: Date()))
                                            } else {
                                                self.items.append(MyMessage(text: quickReplyTitle, agent: true))
                                                
                                            }
                                            
                                            self.tableView.reloadData()
                                            self.tableView.scrollToBottom()
                                        }
                                    }
                                }
                            }
                            break
                        case .failure(let error):
                            print(error)
                            break
                    }
            }
        }
    
    internal func upload(imageData: Data?, imageName:String?, fileData: Data?, fileName:String?, parameters: [String : Any]) {
        
        let url = String(format: "%@/uploadFile", MINTEL_LiveChat.configuration?.uploadBaseUrl ?? "") // "https://us-central1-test-tmn-bot.cloudfunctions.net/uploadFile"
        
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data"
        ]
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            
            if let data = fileData {
                let pathExtention = URL(string: fileName!)!.pathExtension
                multipartFormData.append(data, withName: "file", fileName: fileName ?? "", mimeType: pathExtention)
            }
            
            if let data = imageData{
                multipartFormData.append(data, withName: "file", fileName: imageName ?? "", mimeType: self.mimeType(for: data))
            }
            
        }, usingThreshold: UInt64.init(), to: url, method: .post, headers: headers) { (result) in
            switch result{
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    print("Succesfully uploaded")
                    if let err = response.error{
                        debugPrint(err)
                        return
                    }
                    
                    if let json = response.value {
                        debugPrint(json)
                        let dict = json as! [String: Any]
                        let url = dict["url"] as? String ?? ""
                        if url.count > 0 {
                            self.sendPost(text: url)
                        }
                    }
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
            }
        }
    }
    
    private func mimeType(for data: Data) -> String {

        var b: UInt8 = 0
        data.copyBytes(to: &b, count: 1)

        switch b {
        case 0xFF:
            return "image/jpeg"
        case 0x89:
            return "image/png"
        case 0x47:
            return "image/gif"
        case 0x4D, 0x49:
            return "image/tiff"
        case 0x25:
            return "application/pdf"
        case 0xD0:
            return "application/vnd"
        case 0x46:
            return "text/plain"
        default:
            return "application/octet-stream"
        }
    }
}
