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
    
    var imageUrl:String? = nil
    var image:UIImage? = nil
    
    override func viewDidLoad() {
        self.scrollView.minimumZoomScale = 1
        self.scrollView.maximumZoomScale = 5
        
        let closeImage = UIImage(named: "close_big", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        self.btnCloses.setImage(closeImage, for: .normal)
        
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
    
    
    @objc @IBAction func closePage(_ sender:UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ImagePreviewController : UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
}
