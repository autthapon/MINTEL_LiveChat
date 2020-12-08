//
//  Downloader.swift
//  MINTEL_LiveChat
//
//  Created by Autthapon Sukjaroen on 6/12/2563 BE.
//

import Foundation
import Alamofire

class Downloader {
    class func load(url: URL, mname:String, completion: @escaping (_ url: URL?) -> ()) {
        
        var destination: DownloadRequest.DownloadFileDestination? = nil
        if (mname.count > 0) {
            destination = { _, _ in
                var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                documentsURL.appendPathComponent(mname)
                return (documentsURL, [.removePreviousFile])
            }
        } else {
            destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        }

        debugPrint("Load URL : " , url)
        Alamofire.download(
            url,
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: nil,
            to: destination).downloadProgress(closure: { (progress) in
                //progress closure
            }).response(completionHandler: { (DefaultDownloadResponse) in
                //here you able to access the DefaultDownloadResponse
                //result closure
//                debugPrint("Error : " , DefaultDownloadResponse.error)
//                debugPrint("Download To : " , DefaultDownloadResponse.destinationURL)
                completion(DefaultDownloadResponse.destinationURL)
            })
        
//        let sessionConfig = URLSessionConfiguration.default
//        let session = URLSession(configuration: sessionConfig)
//        let request = try! URLRequest(url: url, method: .get)
//
//        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
//            if let tempLocalUrl = tempLocalUrl, error == nil {
//                // Success
//                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
//                    print("Success: \(statusCode)")
//                }
//
//                do {
//                    try FileManager.default.removeItem(at: toUrl)
//                } catch(let removeError) {
//                    print("error remove file \(toUrl) : \(removeError)")
//                }
//
//                do {
//
//                    try FileManager.default.copyItem(at: tempLocalUrl, to: toUrl)
//                    completion()
//                } catch (let writeError) {
//                    print("error writing file \(toUrl) : \(writeError)")
//                }
//
//            } else {
//                print("Failure: %@", error?.localizedDescription);
//            }
//        }
//        task.resume()
    }
}
