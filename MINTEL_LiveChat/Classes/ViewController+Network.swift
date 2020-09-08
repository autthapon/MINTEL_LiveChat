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
    
    internal func upload(imageData: Data?, imageName:String?, fileData: Data?, fileName:String?, parameters: [String : Any]) {
        
        MINTEL_LiveChat.chatUserTypedIn = true
        
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
            
            MINTEL_LiveChat.checkTime()
            
            
            switch result{
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    print("Succesfully uploaded")
                    self.uploadDataFiles = self.uploadDataFiles - 1;
                    if let err = response.error{
                        debugPrint(err)
                        return
                    }
                    
                    if let json = response.value {
                        debugPrint(json)
                        let dict = json as! [String: Any]
                        let url = dict["url"] as? String ?? ""
                        if url.count > 0 {
                            self.uploadDataText.append(url)
//                            if (MINTEL_LiveChat.chatBotMode) {
//
////                                MINTEL_LiveChat.sendPost(text: url, menu:false)
//                            } else {
//                                self.sendMessageToSaleForce(text: url)
//                            }
                        }
                    }
                    
                    
                    if (self.uploadDataFiles == 0) {
                        let text = self.uploadDataText.joined(separator: "\n")
                        if (MINTEL_LiveChat.chatBotMode) {
                            MINTEL_LiveChat.sendPost(text: text, menu:false)
                        } else {
                            self.sendMessageToSaleForce(text: text)
                        }
                    }
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                
                if (self.uploadDataFiles == 0) {
                    let text = self.uploadDataText.joined(separator: "\n")
                    if (MINTEL_LiveChat.chatBotMode) {
                        MINTEL_LiveChat.sendPost(text: text, menu:false)
                    } else {
                        self.sendMessageToSaleForce(text: text)
                    }
                }
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
