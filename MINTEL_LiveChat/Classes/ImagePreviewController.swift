//
//  ImagePreviewController.swift
//  MINTEL_LiveChat
//
//  Created by Autthapon Sukjaroen on 4/9/2563 BE.
//

import Foundation
import UIKit
import Alamofire

class ImagePreviewController : UIViewController {
    
    @IBOutlet var scrollView:UIScrollView!
    @IBOutlet var imageView:UIImageView!
    @IBOutlet var btnCloses:UIButton!
    @IBOutlet var btnDownload:UIButton!
    
    var imageUrl:String? = nil
    var image:UIImage? = nil
    
    override func viewDidLoad() {
        self.scrollView.minimumZoomScale = 1
        self.scrollView.maximumZoomScale = 5
        
        let closeImage = UIImage(named: "close_big", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        self.btnCloses.setImage(closeImage, for: .normal)
        
        let downloadImage = UIImage(named: "download", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        self.btnDownload.setImage(downloadImage, for: .normal)
        
        if self.imageUrl != nil && self.imageUrl?.count ?? 0 > 0 {
            self.previewImageFromUrl(txt: self.imageUrl!)
        } else if (self.image != nil) {
            self.previewImageFromImage(img: self.image!)
        }
    }
    
    fileprivate func previewImageFromImage(img: UIImage) {
        self.imageView.image = img
    }
    
    fileprivate func previewImageFromUrl(txt:String) {
        DispatchQueue.main.async {
            
            if txt.hasSuffix("jpg") {
                
                let oldMname = CustomTableViewCell.getQueryStringParameter(url: txt, param: "mname")
                if let oooo = oldMname {
                    let newMname = oldMname?.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
                    let tempUrl = txt.replacingOccurrences(of: oooo, with: newMname!)
                    
                    URLSession.shared.dataTask(with: URL(string: tempUrl)!) { (data, response, error) in
                        if error != nil {
                            DispatchQueue.main.async {
//                                textView.isHidden = false
                            }
                            return
                        }

                        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                            DispatchQueue.main.async {
//                                textView.isHidden = false
                            }
                            return
                        }

                        DispatchQueue.main.async {
                            let imaaa = UIImage(data: data!)
//                            MessageList.setItemAt(index: index, item: MyMessage(image: imaaa!, imageUrl: txt, agent: !MINTEL_LiveChat.chatBotMode, bot: true))
//                            tableView.reloadData()
                            self.imageView.image = imaaa
                        }
                    }.resume()
                }
            } else {
            
                if let url = URL(string: txt) {
                    URLSession.shared.dataTask(with: url) { (data, response, error) in
                        if error != nil {
                            DispatchQueue.main.async {
                                
                            }
                            return
                        }

                        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                            DispatchQueue.main.async {
                            }
                            return
                        }

                        DispatchQueue.main.async {
                            let imaaa = UIImage(data: data!)
                            self.imageView.image = imaaa
                        }
                    }.resume()
                }
            }
        }
    }
    
    
    @objc @IBAction func closePage(_ sender:UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc @IBAction func downloadImage(_ sender:UIButton) {
        guard let image = imageView.image else { return }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "เกิดข้อผิดพลาด", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "ปิด", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "บันทึกข้อมูลเรียบร้อย", message: "ทำการบันทึกรูปภาพเรียบร้อยแล้ว", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "ปิด", style: .default))
            present(ac, animated: true)
        }
    }
}

extension ImagePreviewController : UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
}
