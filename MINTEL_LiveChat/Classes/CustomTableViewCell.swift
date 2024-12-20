//
//  ViewController.swift
//  SSChat
//
//  Created by Autthapon Sukajaroen on 13/08/2020
//  Copyright © 2020 Autthapon Sukjaroen. All rights reserved.
//

import UIKit
import Alamofire
//import SwiftImageCarousel

let menuHeight = 40

extension CGRect{
    init(_ x:CGFloat,_ y:CGFloat,_ width:CGFloat,_ height:CGFloat) {
        self.init(x:x,y:y,width:width,height:height)
    }

}
extension CGSize{
    init(_ width:CGFloat,_ height:CGFloat) {
        self.init(width:width,height:height)
    }
}
extension CGPoint{
    init(_ x:CGFloat,_ y:CGFloat) {
        self.init(x:x,y:y)
    }
}



func randomString(length: Int) -> String {
    
    let letters : NSString = "abcdefghijklmnopqrst uvwxyzABCDEFGHIJKLMNOPQ RSTUVWXYZ0123456789"
    let len = UInt32(letters.length)
    
    var randomString = ""
    
    for _ in 0 ..< length {
        let rand = arc4random_uniform(len)
        var nextChar = letters.character(at: Int(rand))
        randomString += NSString(characters: &nextChar, length: 1) as String
    }
    
    return randomString
}

let extraSpacing: CGFloat = 10
let padding: CGFloat = 8

class CustomTableViewCell: UITableViewCell {
    
    var bFirstRenderCarousel = true

    var tapGuesture:MyTapGuesture?
    var menuLabel:[UILabel] = []
    
    let innerSpacing: CGFloat = 4
    
    let secondaryPadding: CGFloat = 8
    
    var textviewTopConstraintToBg: NSLayoutConstraint!
    
    var textviewTopConstraintToTopLabel: NSLayoutConstraint!
    
    var viewController:UIViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        if let id = reuseIdentifier {
            if id == CellIds.senderCellId {
                //                self.setupSendersCell()
            } else if id == CellIds.receiverMenuCellid {
                //                self.setupReceiversMenuCell()
            }else {
                //                self.setupReceiversCell()
            }
        }
    }
    
    
    fileprivate static func createSystemMessage(text: String) -> UILabel {
        let lbl = PaddingLabel(withInsets: 0.5, 0.5, 3, 3)
        lbl.font = UIFont.systemFont(ofSize: 12)
        lbl.text = text
        lbl.numberOfLines = 5
        lbl.backgroundColor = UIColor(MyHexString: "#EBEBEB")
        lbl.textColor = UIColor(MyHexString: "#5A5A5A")
        lbl.textAlignment = .center
        lbl.sizeToFit()
        return lbl
    }
    
    fileprivate static func createSystemMessageType2(text: String) -> UILabel {
        let lbl = PaddingLabel(withInsets: 0.5, 0.5, 3, 3)
        lbl.font = UIFont.systemFont(ofSize: 12)
        lbl.text = text
        lbl.backgroundColor = UIColor(MyHexString: "#9C9C9C")
        lbl.textColor = UIColor(MyHexString: "#FFFFFF")
        lbl.textAlignment = .center
        lbl.sizeToFit()
        return lbl
    }
    
    func renderSystemMessage(text: String) {
        
        self.contentView.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
     
        let lbl = CustomTableViewCell.createSystemMessage(text: text)
        let screen = UIScreen.main.bounds
        let xPosition = (screen.width - (lbl.frame.size.width + 25)) / 2.0
        
        lbl.frame = CGRect(x: xPosition, y: 10, width: lbl.frame.size.width + 25, height: lbl.frame.size.height + 10.0)
        lbl.layer.cornerRadius = 10
        lbl.backgroundColor = UIColor(MyHexString: "#EBEBEB")
        lbl.layer.masksToBounds = true
        
        self.contentView.addSubview(lbl)
    }
    
    func renderSystemMessageType2(text: String) {
        
        self.contentView.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        let lbl = CustomTableViewCell.createSystemMessageType2(text: text)
        let screen = UIScreen.main.bounds
        let xPosition = (screen.width - (lbl.frame.size.width + 35)) / 2.0
        
        lbl.frame = CGRect(x: xPosition, y: 10, width: lbl.frame.size.width + 35, height: lbl.frame.size.height + 10)
        lbl.layer.cornerRadius = 12
        lbl.layer.masksToBounds = true
        drawDottedLine(start: CGPoint(x: 0.0, y: (lbl.frame.size.height + 20) / 2.0 ), end: CGPoint(x: UIScreen.main.bounds.size.width, y: (lbl.frame.size.height + 20) / 2.0), view: self.contentView)
        
        self.contentView.addSubview(lbl)
    }
    
    fileprivate func drawDottedLine(start p0: CGPoint, end p1: CGPoint, view: UIView) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.lightGray.cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [7, 3] // 7 is the length of dash, 3 is length of the gap.
        
        let path = CGMutablePath()
        path.addLines(between: [p0, p1])
        shapeLayer.path = path
        view.layer.addSublayer(shapeLayer)
    }
    
    static func calcRowHeightSystemMessage(text: String) -> CGFloat {
        let lbl = createSystemMessage(text: text)
        return lbl.frame.size.height + 25
    }
    
    static func calcRowHeightSystemMessageType2(text: String) -> CGFloat {
        let lbl = createSystemMessage(text: text)
        return lbl.frame.size.height + 25
    }
    
    static func getQueryStringParameter(url: String, param: String) -> String? {
        let tempUrl = url.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed) ?? ""
        guard let temp = URLComponents(string: tempUrl) else { return nil }
        return temp.queryItems?.first(where: { $0.name == param })?.value
    }
    
    func resizeImage(image: UIImage, newHeight: CGFloat) -> UIImage {
        let scale = newHeight / image.size.height
        let newWidth = image.size.width * scale
        UIGraphicsBeginImageContext(CGSize(newWidth, newHeight))
        image.draw(in: CGRect(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
    
    func renderReceiverCell(_ txt:String, item: MyMessage, index: Int, tableView: UITableView) {
        
        self.contentView.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        var imageName:String = ""
        if (item.bot) {
            imageName = "chatbot"
        } else {
            imageName = "agent"
        }
        
        let avartar = UIImageView()
        let avartarImage = UIImage(named: imageName, in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil)
        let avartarWidth = avartarImage?.size.width ?? 0.0
        avartar.image = avartarImage
        self.contentView.addSubview(avartar)
        avartar.frame = CGRect(x: padding, y: 0, width: avartarWidth, height: avartar.image?.size.height ?? 0)
        
        let textView = UITextView()
        textView.tag = 5002
        self.contentView.addSubview(textView)
        
        let extSupports = ["pdf", "doc", "docx", "xls", "xlsx", "ppt", "pptx", "zip", "rar"]
        var txtLower = txt.lowercased()
        var isEndWithSupported = false
        for edd in extSupports {
            isEndWithSupported = txtLower.hasSuffix(edd)
            if (isEndWithSupported) {
                break
            }
        }
        
        if (isEndWithSupported) {
            let mname = CustomTableViewCell.getQueryStringParameter(url: txt, param: "mname")
            if (mname?.count ?? 0 > 0) {
                textView.text = mname
            } else {
                let theFileName = (txt as NSString).lastPathComponent
                textView.text = theFileName
            }
        } else {
//            textView.text = txt
            let textNewLine = txt.replacingOccurrences(of: "\n", with: "<br/>")
            textView.MINTEL_htmlText = textNewLine
        }
        
        let linkAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.blue,
            NSAttributedString.Key.underlineColor: UIColor.blue,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        textView.linkTextAttributes = linkAttributes
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isHidden = false
        textView.backgroundColor = UIColor(MyHexString: "#EBEBEB")
        textView.layer.cornerRadius = 18.0
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView.frame = CGRect(x: avartar.frame.origin.x + avartarWidth + 5, y: 0, width: UIScreen.main.bounds.width - avartar.frame.origin.x - avartarWidth - 10 - 45, height: 200)
        textView.dataDetectorTypes = [.link]
        textView.isSelectable = true
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.tintColor = UIColor.black
        textView.textColor = UIColor.black
        textView.sizeToFit()
        textView.frame = CGRect(x: avartar.frame.origin.x + avartarWidth + 5, y: 0, width: textView.contentSize.width, height: textView.contentSize.height)
        
        let tempUrl = txt.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed) ?? ""
        if let url = URL(string: tempUrl) {
            if UIApplication.shared.canOpenURL(url as URL) {
                
                // Check Extension Is it document file ? (.pdf, .doc, .docx, .xls, .xlsx, .ppt, .pptx, .zip, .rar)
                let extSupports = ["pdf", "doc", "docx", "xls", "xlsx", "ppt", "pptx", "zip", "rar"]
                let txtLower = txt.lowercased()
                var isEndWithSupported = false
                for edd in extSupports {
                    isEndWithSupported = txtLower.hasSuffix(edd)
                    if (isEndWithSupported) {
                        break
                    }
                }
                
                if isEndWithSupported {
                    
                    // Show Icon Download
                    let btnDownload = UIButton()
                    self.contentView.addSubview(btnDownload)
                    var downloadImage = UIImage(named: "download", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil)
                    downloadImage = downloadImage?.MyResizeImage(targetSize: CGSize(width:20,height: 20))
                    btnDownload.setImage(downloadImage, for: .normal)
                    btnDownload.tag = index
                    btnDownload.frame = CGRect(x: textView.frame.origin.x + textView.frame.size.width + CGFloat(5.0), y: textView.frame.origin.y + textView.frame.size.height - CGFloat(35), width: 30, height: 30)
                    btnDownload.addTarget(self, action: #selector(download(_:)), for: .touchUpInside)
                    
                    let mname = CustomTableViewCell.getQueryStringParameter(url: txt, param: "mname")
                    textView.attributedText = NSAttributedString(string: "")
                    if (mname?.count ?? 0 > 0) {
                        textView.text = mname
                    } else {
                        let theFileName = (txt as NSString).lastPathComponent
                        textView.text = theFileName
                    }
                    
                    textView.sizeToFit()
                    textView.frame = CGRect(x: avartar.frame.origin.x + avartarWidth + 5, y: 0, width: textView.contentSize.width, height: textView.contentSize.height)
                    
                } else {
                    
                    if (tempUrl.lowercased().hasSuffix("jpg") || tempUrl.lowercased().hasSuffix("jpeg") || tempUrl.lowercased().hasSuffix("png")) {
                        
                        let oldMname = CustomTableViewCell.getQueryStringParameter(url: txt, param: "mname")
                        //let oldMname = "image"
                        //let oooo = oldMname
                        if let oooo = oldMname {
                            let newMname = oldMname?.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
                            let tempUrl = txt.replacingOccurrences(of: oooo, with: newMname!)
                            
                            // Clear it first
                            DispatchQueue.main.async {
                                MessageList.setItemAt(index: index, item: MyMessage(systemMessageType1: ""))
                                tableView.reloadData()
                            }
                            
                            URLSession.shared.dataTask(with: URL(string: tempUrl)!) { (data, response, error) in
                                if error != nil {
                                    DispatchQueue.main.async {
                                        textView.isHidden = false
                                    }
                                    return
                                }

                                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                                    DispatchQueue.main.async {
                                        textView.isHidden = false
                                    }
                                    return
                                }

                                DispatchQueue.main.async {
                                    let imaaa = UIImage(data: data!)
                                    MessageList.setItemAt(index: index, item: MyMessage(image: imaaa!, imageUrl: txt, agent: !MINTEL_LiveChat.chatBotMode, bot: true))
                                    tableView.reloadData()
                                }
                            }.resume()
                        }
                    } else {
                        let request = URLRequest(url: url)
                        let session = URLSession.shared
                        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                            guard error == nil else {
                                DispatchQueue.main.async {
                                    textView.isHidden = false
                                }
                                return
                            }
                            if let httpResponse = response as? HTTPURLResponse, let contentType = httpResponse.allHeaderFields["Content-Type"] as? String {
                                if contentType.contains("image") {
                                    DispatchQueue.main.async {
                                        textView.isHidden = true
                                        
                                        // Clear it first
                                        DispatchQueue.main.async {
                                            MessageList.setItemAt(index: index, item: MyMessage(systemMessageType1: ""))
                                            tableView.reloadData()
                                        }
                                        
                                        URLSession.shared.dataTask(with: url) { (data, response, error) in
                                            if error != nil {
                                                DispatchQueue.main.async {
                                                    textView.isHidden = false
                                                }
                                                return
                                            }

                                            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                                                DispatchQueue.main.async {
                                                    textView.isHidden = false
                                                }
                                                return
                                            }
                                            // Show again
                                            DispatchQueue.main.async {
                                                let imaaa = UIImage(data: data!)
                                                MessageList.setItemAt(index: index, item: MyMessage(image: imaaa!, imageUrl: txt, agent: !MINTEL_LiveChat.chatBotMode, bot: true))
                                                tableView.reloadData()
                                            }

                                            
                                        }.resume()
                                    }
                                } else {
                                    DispatchQueue.main.async {
                                        textView.isHidden = false
                                    }
                                }
                            } else {
                                DispatchQueue.main.async {
                                    textView.isHidden = false
                                }
                            }
                        })
                        task.resume()
                    }
                }
            } else {
                /*
                txtLower = """
            carousel/[{"imageUrl": "https://www.geeksforgeeks.org/wp-content/uploads/gfg_200X200-1.png", "url": "https://www.google.com"}, {"imageUrl": "https://i.stack.imgur.com/WQna0.png", "url": "https://www.microsoft.com"}]
            """
                 */
                if txtLower.contains("carousel/") {
                    //carousel/[{"imageUrl": "https://www.geeksforgeeks.org/wp-content/uploads/gfg_200X200-1.png", "url": "https://www.google.com"}, {"imageUrl": "https://i.stack.imgur.com/WQna0.png", "url": "https://www.microsoft.com"}]
                    
                    let carStr = txt.replacingOccurrences(of: "carousel/", with: "")
                    var carArr: [[String: String]]
                    //carArr = try! JSONSerialization.jsonObject(with: carStr2, options: .mutableContainers) as! [Carousel]
                    carArr = carStr.toJSON() as! [[String: String]]

                    // Clear it first
                    DispatchQueue.main.async {
                        MessageList.setItemAt(index: index, item: MyMessage(systemMessageType1: ""))
                        tableView.reloadData()
                    }
                    
                    // Show again
                    DispatchQueue.main.async {
                        MessageList.setItemAt(index: index, item: MyMessage(carousel: carArr))
                        tableView.reloadData()
                    }

                } else {
                    DispatchQueue.main.async {
                        textView.isHidden = false
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                textView.isHidden = false
            }
        }
        
        let timelbl = UILabel()
        timelbl.font = UIFont.systemFont(ofSize: 12)
        self.contentView.addSubview(timelbl)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let dateString = dateFormatter.string(from: item.sentDate)
        timelbl.backgroundColor = UIColor.clear
        timelbl.text = dateString
        timelbl.tag = 5003
        timelbl.frame = CGRect(x: textView.frame.origin.x, y: textView.frame.origin.y + textView.frame.size.height + 5, width: 100, height: 20)
    }
    
    static func calcReceiverCell(_ txt:String, item: MyMessage) -> CGFloat {
//        let timelbl = cell.viewWithTag(5003) as! UILabel
//        let textView = cell.viewWithTag(5002) as! UITextView
//        return textView.frame.origin.y + textView.frame.size.height + timelbl.frame.size.height + 5
        
        let avartar = UIImageView()
        let avartarImage = UIImage(named: "chatbot", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil)
        let avartarWidth = avartarImage?.size.width ?? 0.0
        avartar.image = avartarImage
        avartar.frame = CGRect(x: padding, y: 0, width: avartarWidth, height: avartar.image?.size.height ?? 0)

        let textView = UITextView()

        let textNewLine = txt.replacingOccurrences(of: "\n", with: "<br/>")
//        textView.MINTEL_htmlText = textNewLine

        let linkAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.blue,
            NSAttributedString.Key.underlineColor: UIColor.blue,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ]

        let extSupports = ["pdf", "doc", "docx", "xls", "xlsx", "ppt", "pptx", "zip", "rar"]
        let txtLower = txt.lowercased()
        var isEndWithSupported = false
        for edd in extSupports {
            isEndWithSupported = txtLower.hasSuffix(edd)
            if (isEndWithSupported) {
                break
            }
        }

        if (isEndWithSupported) {

            let mname = CustomTableViewCell.getQueryStringParameter(url: txt, param: "mname")
            textView.attributedText = NSAttributedString(string: "")
            if (mname?.count ?? 0 > 0) {
                textView.text = mname
            } else {
                let theFileName = (txt as NSString).lastPathComponent
                textView.text = theFileName
            }
            textView.linkTextAttributes = linkAttributes
            textView.font = UIFont.systemFont(ofSize: 16)
            textView.isHidden = false
            textView.backgroundColor = UIColor(MyHexString: "#EBEBEB")
            textView.layer.cornerRadius = 18.0
            textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            textView.frame = CGRect(x: avartar.frame.origin.x + avartarWidth + 5, y: 0, width: UIScreen.main.bounds.width - avartar.frame.origin.x - avartarWidth - 10 - 45, height: 200)
            textView.dataDetectorTypes = [.link]
            textView.isSelectable = true
            textView.isScrollEnabled = false
            textView.isEditable = false
            textView.tintColor = UIColor.black
            textView.textColor = UIColor.black
            textView.sizeToFit()
            textView.frame = CGRect(x: avartar.frame.origin.x + avartarWidth + 5, y: 0, width: textView.contentSize.width, height: textView.contentSize.height)

            let timelbl = UILabel()
            timelbl.font = UIFont.systemFont(ofSize: 12)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            let dateString = dateFormatter.string(from: item.sentDate)
            timelbl.text = dateString
            timelbl.frame = CGRect(x: textView.frame.origin.x, y: textView.frame.origin.y + textView.frame.size.height + 5, width: 100, height: 20)

            return timelbl.frame.origin.y + timelbl.frame.size.height + 10
        } else {

//            textView.MINTEL_htmlText = textNewLine
            textView.text = txt
            textView.linkTextAttributes = linkAttributes
            textView.font = UIFont.systemFont(ofSize: 16)
            textView.isHidden = false
            textView.backgroundColor = UIColor(MyHexString: "#EBEBEB")
            textView.layer.cornerRadius = 18.0
            textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            textView.frame = CGRect(x: avartar.frame.origin.x + avartarWidth + 5, y: 0, width: UIScreen.main.bounds.width - avartar.frame.origin.x - avartarWidth - 10 - 45, height: 200)
            textView.dataDetectorTypes = [.link]
            textView.isSelectable = true
            textView.isScrollEnabled = false
            textView.isEditable = false
            textView.tintColor = UIColor.black
            textView.textColor = UIColor.black
            textView.sizeToFit()
            textView.frame = CGRect(x: avartar.frame.origin.x + avartarWidth + 5, y: 0, width: textView.contentSize.width, height: textView.contentSize.height)

            let timelbl = UILabel()
            timelbl.font = UIFont.systemFont(ofSize: 12)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            let dateString = dateFormatter.string(from: item.sentDate)
            timelbl.text = dateString
            timelbl.frame = CGRect(x: textView.frame.origin.x, y: textView.frame.origin.y + textView.frame.size.height + 5, width: 100, height: 20)

            return timelbl.frame.origin.y + timelbl.frame.size.height + 10
        }
    }
    
    func renderSender(txt: String, item :MyMessage) {
        
        self.contentView.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        let avartarImage = UIImage(named: "chatbot", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil)
        let avartarWidth = avartarImage?.size.width ?? 0.0
        
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        
        let textNewLine = txt.replacingOccurrences(of: "\n", with: "<br/>")
        let htmlData = NSString(string: textNewLine).data(using: String.Encoding.unicode.rawValue)
        let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
        let attributedString = try! NSMutableAttributedString(data: htmlData!, options: options, documentAttributes: nil)
        attributedString.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor : UIColor.black], range: NSMakeRange(0, attributedString.length))
        textView.attributedText = attributedString
        
        self.contentView.addSubview(textView)
        
        let linkAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.blue,
            NSAttributedString.Key.underlineColor: UIColor.blue,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        textView.linkTextAttributes = linkAttributes
        textView.backgroundColor = UIColor(MyHexString: "#FF8300")
        textView.layer.cornerRadius = 18.0
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView.frame = CGRect(x: UIScreen.main.bounds.width - avartarWidth - padding - 20, y : 0, width: UIScreen.main.bounds.width - avartarWidth - padding - 10, height: 100)
        textView.dataDetectorTypes = [.link]
        textView.isSelectable = true
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.tintColor = UIColor.white
        textView.textColor = UIColor.white
        textView.sizeToFit()
        textView.frame = CGRect(x: UIScreen.main.bounds.width - textView.contentSize.width - padding , y: 0, width: textView.contentSize.width, height: textView.contentSize.height)
        
        let timelbl = UILabel()
        timelbl.font = UIFont.systemFont(ofSize: 12)
        self.contentView.addSubview(timelbl)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let dateString = dateFormatter.string(from: item.sentDate)
        timelbl.backgroundColor = UIColor.clear
        timelbl.text = dateString
        timelbl.textAlignment = .right
        timelbl.frame = CGRect(x: UIScreen.main.bounds.width - 100 - padding, y: textView.frame.origin.y + textView.frame.size.height + 5, width: 100, height: 20)
    }
    
    func renderFileSend(txt: String, item :MyMessage, index:Int) {
        
        self.contentView.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        let avartarImage = UIImage(named: "chatbot", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil)
        let avartarWidth = avartarImage?.size.width ?? 0.0
        
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        
        textView.text = txt
        self.contentView.addSubview(textView)
        textView.backgroundColor = UIColor(MyHexString: "#FF8300")
        textView.layer.cornerRadius = 18.0
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView.frame = CGRect(x: UIScreen.main.bounds.width - avartarWidth - padding - 20, y : 0, width: UIScreen.main.bounds.width - avartarWidth - padding - 10, height: 100)
        textView.dataDetectorTypes = [.link]
        textView.isSelectable = true
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.tintColor = UIColor.white
        textView.textColor = UIColor.white
        textView.sizeToFit()
        textView.frame = CGRect(x: UIScreen.main.bounds.width - textView.contentSize.width - padding , y: 0, width: textView.contentSize.width, height: textView.contentSize.height)
        
        let timelbl = UILabel()
        timelbl.font = UIFont.systemFont(ofSize: 12)
        self.contentView.addSubview(timelbl)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let dateString = dateFormatter.string(from: item.sentDate)
        timelbl.backgroundColor = UIColor.clear
        timelbl.text = dateString
        timelbl.textAlignment = .right
        timelbl.frame = CGRect(x: UIScreen.main.bounds.width - 100 - padding, y: textView.frame.origin.y + textView.frame.size.height + 5, width: 100, height: 20)
        
        let btnDownload = UIButton()
        self.contentView.addSubview(btnDownload)
        var downloadImage = UIImage(named: "download", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil)
        downloadImage = downloadImage?.MyResizeImage(targetSize: CGSize(width:20,height: 20))
        btnDownload.setImage(downloadImage, for: .normal)
        btnDownload.tag = index
        btnDownload.frame = CGRect(x: textView.frame.origin.x - CGFloat(35.0), y: textView.frame.origin.y + textView.frame.size.height - CGFloat(35), width: 30, height: 30)
        btnDownload.addTarget(self, action: #selector(download(_:)), for: .touchUpInside)
    }
    
    static func calcSender(txt: String, item :MyMessage) -> CGFloat {
        
        let avartarImage = UIImage(named: "chatbot", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil)
        let avartarWidth = avartarImage?.size.width ?? 0.0
        
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        
        textView.text = txt
        textView.backgroundColor = UIColor(MyHexString: "#FF8300")
        textView.layer.cornerRadius = 18.0
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView.frame = CGRect(x: UIScreen.main.bounds.width - avartarWidth - padding - 20, y : 0, width: UIScreen.main.bounds.width - avartarWidth - padding - 10, height: 100)
        textView.dataDetectorTypes = [.link]
        textView.isSelectable = true
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.tintColor = UIColor.white
        textView.textColor = UIColor.white
        textView.sizeToFit()
        textView.frame = CGRect(x: UIScreen.main.bounds.width - textView.contentSize.width - padding , y: 0, width: textView.contentSize.width, height: textView.contentSize.height)
        
        let timelbl = UILabel()
        timelbl.font = UIFont.systemFont(ofSize: 12)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let dateString = dateFormatter.string(from: item.sentDate)
        timelbl.backgroundColor = UIColor.clear
        timelbl.text = dateString
        timelbl.textAlignment = .right
        timelbl.frame = CGRect(x: UIScreen.main.bounds.width - 100 - padding, y: textView.frame.origin.y + textView.frame.size.height + 5, width: 100, height: 20)
        
        return timelbl.frame.origin.y + timelbl.frame.size.height
    }
    
    func renderImageCell(image:UIImage, time: Date, item: MyMessage, index: Int) {
        
        self.contentView.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        let img = image.MyResizeImage(targetSize: CGSize(width:270,height: 300))
        let imgView = UIImageView(image: img)
        self.contentView.addSubview(imgView)
        let screen = UIScreen.main.bounds
        
        if (item.bot || item.agent) {
            var imageName:String = ""
            if (item.agent) {
                imageName = "agent"
            } else {
                imageName = "chatbot"
            }
            
            let avartar = UIImageView()
            let avartarImage = UIImage(named: imageName, in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil)
            let avartarWidth = avartarImage?.size.width ?? 0.0
            avartar.image = avartarImage
            self.contentView.addSubview(avartar)
            avartar.frame = CGRect(x: padding, y: 0, width: avartarWidth, height: avartar.image?.size.height ?? 0)
            imgView.frame = CGRect(x: avartar.frame.origin.x + avartarWidth + 5, y: 10, width: img.size.width, height: img.size.height)
            
            let timelbl = UILabel()
            self.contentView.addSubview(timelbl)
            timelbl.frame = CGRect(x: avartar.frame.origin.x + avartarWidth + 5, y: imgView.frame.origin.y + imgView.frame.size.height + 5, width: 50, height: 13)
            timelbl.font = UIFont.systemFont(ofSize: 12)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            let dateString = dateFormatter.string(from: time)
            timelbl.text = dateString
            
            let btnDownload = UIButton()
            self.contentView.addSubview(btnDownload)
            var downloadImage = UIImage(named: "download", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil)
            downloadImage = downloadImage?.MyResizeImage(targetSize: CGSize(width:20,height: 20))
            btnDownload.setImage(downloadImage, for: .normal)
            btnDownload.tag = index
            btnDownload.frame = CGRect(x: imgView.frame.origin.x + imgView.frame.size.width + CGFloat(5.0), y: imgView.frame.origin.y + imgView.frame.size.height - CGFloat(35), width: 30, height: 30)
            btnDownload.addTarget(self, action: #selector(download(_:)), for: .touchUpInside)
            
        } else {
            let xPosition = screen.width - img.size.width - 10.0
            imgView.frame = CGRect(x: xPosition, y: 10, width: img.size.width, height: img.size.height)
            imgView.layer.cornerRadius = 18
            imgView.backgroundColor = UIColor(MyHexString: "#EBEBEB")
            imgView.layer.masksToBounds = true
            imgView.startAnimating()
            
            let timelbl = UILabel()
            self.contentView.addSubview(timelbl)
            timelbl.frame = CGRect(x: UIScreen.main.bounds.size.width - 55, y: img.size.height + 15, width: 50, height: 13)
            timelbl.font = UIFont.systemFont(ofSize: 12)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            let dateString = dateFormatter.string(from: time)
            timelbl.text = dateString
            
            let btnDownload = UIButton()
            self.contentView.addSubview(btnDownload)
            var downloadImage = UIImage(named: "download", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil)
            downloadImage = downloadImage?.MyResizeImage(targetSize: CGSize(width:20,height: 20))
            btnDownload.tag = index
            btnDownload.setImage(downloadImage, for: .normal)
            btnDownload.frame = CGRect(x: imgView.frame.origin.x - CGFloat(35.0), y: imgView.frame.origin.y + imgView.frame.size.height - CGFloat(35), width: 30, height: 30)
            btnDownload.addTarget(self, action: #selector(download(_:)), for: .touchUpInside)
        }
    }
    
    func renderCarouselCell(carousels:[[String: String]], time: Date, item: MyMessage, index: Int) {
        
        self.contentView.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        let storyboard = UIStoryboard (name: "Main", bundle: Bundle(for: SwiftImageCarouselVC.self))
        let vc = storyboard.instantiateInitialViewController() as! SwiftImageCarouselVC
        vc.showModalGalleryOnTap = false
        vc.swipeTimeIntervalSeconds = 10
        vc.swiftImageCarouselVCDelegate = self
        
        for c in carousels {
            debugPrint("carousels loop")
            debugPrint(c["imageUrl"])
            //vc.contentImageURLs.append("https://cdn.britannica.com/70/234870-050-D4D024BB/Orange-colored-cat-yawns-displaying-teeth.jpg")
            //vc.contentImageURLs.append((c["imageUrl"] ?? "") + "&ext=.png")
            vc.contentImageURLs.append(c["imageUrl"] ?? "")
            vc.contentLinkURLs.append(c["url"] ?? "")
        }
       
        /*
        ["https://cdn.britannica.com/70/234870-050-D4D024BB/Orange-colored-cat-yawns-displaying-teeth.jpg", "https://w7.pngwing.com/pngs/444/310/png-transparent-amazon-com-amazon-prime-music-streaming-media-prime-now-payment-miscellaneous-text-logo-thumbnail.png", "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRPniqg7_A0q3bfzWu5hhlksVlxvmSWPVH_8kT-b6ktKg&s"]
*/
        
        
        let xPosition = 10.0
        if (bFirstRenderCarousel == true) {
            vc.view.frame = CGRect(x: xPosition, y: 10, width: self.contentView.frame.width, height: 100)
            bFirstRenderCarousel = false
        }
        else {
            vc.view.frame = CGRect(x: xPosition, y: 10, width: self.contentView.frame.width, height: 300)
        }
        vc.didMove(toParent: self.topViewController())
        
        // Adding it to the container view
        vc.willMove(toParent: self.topViewController())
        self.contentView.addSubview(vc.view)
    }
    
    @objc func download(_ sender:UIButton) {
        let index = sender.tag
        let message = MessageList.at(index: index)
        if (message != nil) {
            switch message!.kind {
            case .text(let url):
                
                let oldMname = CustomTableViewCell.getQueryStringParameter(url: url, param: "mname")
                if let oooo = oldMname {
                    let newMname = oldMname?.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
                    let tempUrl = url.replacingOccurrences(of: oooo, with: newMname!)
                    
                    Downloader.load(url: URL(string: tempUrl)!, mname: oldMname!) { (pathUrl) in
                        DispatchQueue.main.async {
                            let objectsToShare = [pathUrl]
                            let activityVC = UIActivityViewController(activityItems: objectsToShare as [Any], applicationActivities: nil)

                            let currentViewController = self.topViewController()
                            if currentViewController != nil {
                                currentViewController?.present(activityVC, animated: true, completion: nil)
                            }
                        }

                    }
                } else {
                    Downloader.load(url: URL(string: url)!, mname: "") { (pathUrl) in
                        DispatchQueue.main.async {
                            let objectsToShare = [pathUrl]
                            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

                            let currentViewController = self.topViewController()
                            if currentViewController != nil {
                                currentViewController?.present(activityVC, animated: true, completion: nil)
                            }
                        }

                    }
                }
            case .image(let img, _):
                UIImageWriteToSavedPhotosAlbum(img, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            case .file(let fileName, let fileUrl, let fileUploadUrl):
                debugPrint(fileUrl, fileName, fileUploadUrl)
                self.downloadFileAndSave(fileUrl: fileUrl)
            default:
                return
            }
        }
    }
    
    fileprivate func loadFileFromUrl(url: URL, to localUrl: URL, completion: @escaping () -> ()) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = try! URLRequest(url: url, method: .get)

        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Success: \(statusCode)")
                }

                do {
                    try FileManager.default.copyItem(at: tempLocalUrl, to: localUrl)
                    completion()
                } catch (let writeError) {
                    print("error writing file \(localUrl) : \(writeError)")
                }

            } else {
                print("Failure: %@", error?.localizedDescription ?? "");
            }
        }
        task.resume()
    }
    
    fileprivate func topViewController(_ viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = viewController as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = viewController as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = viewController?.presentedViewController {
            return topViewController(presented)
        }
        return viewController
    }

    fileprivate func downloadFileAndSave(fileUrl: URL) {

        //Create directory if not present
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentDirectory = paths.first! as NSString
        let dirPathString = documentDirectory.appendingPathComponent("TrueMoney")
        
        do {
            try FileManager.default.createDirectory(atPath: dirPathString, withIntermediateDirectories: true, attributes:nil)
            print("directory created at \(dirPathString)")
        } catch let error as NSError {
            print("error while creating dir : \(error.localizedDescription)");
        }
        
//        if let audioUrl = URL(string: audioFile) {
            // create your document folder url
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as URL
            let documentsFolderUrl = documentsUrl.appendingPathComponent("TrueMoney")
            // your destination file url
            debugPrint(fileUrl.pathExtension)
            let destinationUrl = documentsFolderUrl.appendingPathComponent(String(format: "%@.%@", UUID().uuidString, fileUrl.pathExtension))
            
            print(destinationUrl)
            // check if it exists before downloading it
            if FileManager().fileExists(atPath: destinationUrl.path) {
                
                DispatchQueue.main.async {
                    let objectsToShare = [destinationUrl]
                    let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

                    let currentViewController = self.topViewController()
                    if currentViewController != nil {
                        currentViewController?.present(activityVC, animated: true, completion: nil)
                    }
                }
            } else {
                //  if the file doesn't exist
                //  just download the data from your url
                DispatchQueue.main.async {
                    
                    if let myAudioDataFromUrl = try? Data(contentsOf: fileUrl){
                        // after downloading your data you need to save it to your destination url
                        if (try? myAudioDataFromUrl.write(to: destinationUrl, options: [.atomic])) != nil {
                            DispatchQueue.main.async {
                                let objectsToShare = [destinationUrl]
                                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

                                let currentViewController = self.topViewController()
                                if currentViewController != nil {
                                    currentViewController?.present(activityVC, animated: true, completion: nil)
                                }
                            }
                        } else {
                            print("error saving file")
                        }
                    }
                }
            }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "เกิดข้อผิดพลาด", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "ปิด", style: .default))
            self.viewController?.present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "บันทึกข้อมูลเรียบร้อย", message: "ทำการบันทึกรูปภาพเรียบร้อยแล้ว", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "ปิด", style: .default))
            self.viewController?.present(ac, animated: true)
        }
    }
    
    func renderTyping(item: MyMessage) {
        
        let indicator = self.contentView.viewWithTag(1000) as? TypingIndicator
        if (indicator != nil) {
            indicator?.stopAnimating()
        }
        
        self.contentView.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        var imageName:String = ""
        if (item.agent) {
            imageName = "agent"
        } else {
            imageName = "chatbot"
        }
        
        let avartar = UIImageView()
        let avartarImage = UIImage(named: imageName, in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil)
        let avartarWidth = avartarImage?.size.width ?? 0.0
        avartar.image = avartarImage
        self.contentView.addSubview(avartar)
        avartar.frame = CGRect(x: padding, y: 0, width: avartarWidth, height: avartar.image?.size.height ?? 0)
        
        let mainView = UIView()
        mainView.backgroundColor = UIColor(MyHexString: "#EEEEEE")
        self.contentView.addSubview(mainView)
        mainView.frame = CGRect(x: avartar.frame.origin.x + avartarWidth + 10, y: 2, width: 65, height: 35)
        mainView.layer.cornerRadius = 17
        mainView.layer.borderWidth = 0
        mainView.layer.masksToBounds = true
        
        let view = TypingIndicator()
        view.tag = 1000
        mainView.addSubview(view)
        view.frame = CGRect(x: 5, y: 8, width: 55, height: 20)
        view.startAnimating()
//        view.layer.cornerRadius = 18.0
//        view.layer.borderWidth = 0.5
//        view.layer.borderColor = UIColor(MyHexString: "#EBEBEB").cgColor
//        view.layer.masksToBounds = true
    }
    
    func renderAgentJoin(_ agentName:String) {
       
        self.contentView.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        let screen = UIScreen.main.bounds
        let imgView = UIImageView(image: UIImage(named: "agent", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil))
        self.contentView.addSubview(imgView)
        var xPosition = (screen.width - imgView.image!.size.width) / 2.0
        imgView.frame = CGRect(x: xPosition, y: 10, width: imgView.image!.size.width, height: imgView.image!.size.height)
        
        let lbl = CustomTableViewCell.createSystemMessage(text: String(format: MINTEL_LiveChat.getLanguageString(str: "chatting_with") + "%@", agentName))
        self.contentView.addSubview(lbl)
        xPosition = (screen.width - (lbl.frame.size.width + 25)) / 2.0
        lbl.frame = CGRect(x: xPosition, y: 10 + imgView.image!.size.height + 2, width: lbl.frame.size.width + 25, height: lbl.frame.size.height + 20)
        lbl.backgroundColor = UIColor(MyHexString: "#FFFFFF")
        lbl.layer.masksToBounds = true
    }
    
    static func calcAgentJoinCellHeight() -> CGFloat {
        return 90
    }
    
    static func calcImageCellHeight(_ image:UIImage) -> CGFloat {
        let img = image.MyResizeImage(targetSize: CGSize(width:200,height: 200))
        debugPrint(img.size.height)
        return img.size.height + 13 + 20 + 100
    }
    
    func setupMenuCell(_ title:String,_ menus:[[String:Any]], _ itemMessage : MyMessage, _ viewController: ViewController) {
        
        self.contentView.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        let avartar = UIImageView()
        let avartarImage = UIImage(named: "chatbot", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil)
        let avartarWidth = avartarImage?.size.width ?? 0.0
        avartar.image = avartarImage
        self.contentView.addSubview(avartar)
        avartar.frame = CGRect(x: padding, y: 0, width: avartarWidth, height: avartar.image?.size.height ?? 0)
        
        let bgggView = UIView()
        self.contentView.addSubview(bgggView)
        bgggView.frame = CGRect(x: avartar.frame.origin.x + avartarWidth + 5, y: 0, width: UIScreen.main.bounds.width - avartar.frame.origin.x - avartarWidth - 15, height: 100)
        bgggView.layer.cornerRadius = 18.0
        bgggView.layer.borderWidth = 0.5
        bgggView.layer.borderColor = UIColor(MyHexString: "#EBEBEB").cgColor
        bgggView.layer.masksToBounds = true
        
        let width = bgggView.frame.size.width
        var height = CGFloat(0.0)
        var yIndex = CGFloat(0.0)
        if (title.count > 0) {
            height = title.MyHeight(withConstrainedWidth: bgggView.frame.size.width - 20, font: UIFont.systemFont(ofSize: 16.0))
            height = max(height, 40.0)
            let lbl = PaddingLabel(withInsets: 8, 8, 18, 18)
            bgggView.addSubview(lbl)
            lbl.frame = CGRect(x: 0, y: yIndex, width: bgggView.frame.size.width, height: height + 16)
            lbl.text = title
            lbl.font = UIFont.systemFont(ofSize: 16.0)
            lbl.textAlignment = .center
            lbl.backgroundColor = UIColor(MyHexString: "#EBEBEB")
            lbl.layer.masksToBounds = true
            lbl.layer.borderWidth = 0.5
            lbl.numberOfLines = 10
            lbl.layer.masksToBounds = true
            lbl.textColor = UIColor(MyHexString: "#090909")
            lbl.layer.borderColor = UIColor(MyHexString: "#EBEBEB").cgColor
            lbl.tag = 9999
            yIndex = yIndex + lbl.frame.size.height
        }
        
        for i in 0..<menus.count {
            let item = menus[i]
            let actions = item["action"] as! [String:Any]
            let labelText = actions["label"] as? String ?? ""
            
            height = labelText.MyHeight(withConstrainedWidth: bgggView.frame.size.width - 20, font: UIFont.systemFont(ofSize: 16.0))
            height = max(40.0, height)
            let lbl = MyButton(type: .custom) // PaddingLabel(withInsets: 8, 8, 18, 18)
            lbl.frame = CGRect(x: 0.0, y: yIndex, width: width, height: height + 16)
            lbl.setTitle(labelText, for: .normal)
            lbl.setBackgroundImage(MyImageColor(color: UIColor(MyHexString: "#22ff8300").withAlphaComponent(0.5)), for: .highlighted)
            lbl.setBackgroundImage(MyImageColor(color: UIColor.white), for: .normal)
            lbl.setBackgroundImage(MyImageColor(color: UIColor(MyHexString: "#66f0f0f0")), for: .selected)
            lbl.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
            lbl.titleLabel?.textAlignment = .center
            lbl.titleLabel?.numberOfLines = 10
            lbl.setTitleColor(UIColor(MyHexString: "#FF8300"), for: .normal)
            lbl.backgroundColor = UIColor.white
            lbl.layer.borderWidth = 0.5
            lbl.layer.borderColor = UIColor(MyHexString: "#EBEBEB").cgColor
            lbl.TMN_Menu = item
            lbl.TMN_Message = itemMessage
            lbl.isSelected = i == itemMessage.selectedIndex
            
            lbl.tag = 10000 + i
            bgggView.addSubview(lbl)
            yIndex = yIndex + lbl.frame.size.height
        }
        
        bgggView.frame = CGRect(x: avartar.frame.origin.x + avartarWidth + 5, y: 0, width: UIScreen.main.bounds.width - avartar.frame.origin.x - avartarWidth - 15, height: yIndex)
        
        let timelbl = UILabel()
        timelbl.font = UIFont.systemFont(ofSize: 12)
        self.contentView.addSubview(timelbl)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let dateString = dateFormatter.string(from: itemMessage.sentDate)
        timelbl.backgroundColor = UIColor.clear
        timelbl.text = dateString
        timelbl.frame = CGRect(x: avartar.frame.origin.x + avartarWidth + 5, y: bgggView.frame.origin.y + bgggView.frame.size.height + 5, width: 100, height: 20)
    }
    
    static func calMenuCellHeight(_ title:String,_ menus:[[String:Any]], _ item : MyMessage) -> CGFloat {
        let avartar = UIImageView()
        let avartarImage = UIImage(named: "chatbot", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil)
        let avartarWidth = avartarImage?.size.width ?? 0.0
        avartar.image = avartarImage
        avartar.frame = CGRect(x: padding, y: 0, width: avartarWidth, height: avartar.image?.size.height ?? 0)
        
        let bgggView = UIView()
        bgggView.frame = CGRect(x: avartar.frame.origin.x + avartarWidth + 5, y: 0, width: UIScreen.main.bounds.width - avartar.frame.origin.x - avartarWidth - 15, height: 100)
        bgggView.layer.cornerRadius = 18.0
        bgggView.layer.borderWidth = 0.5
        bgggView.layer.borderColor = UIColor(MyHexString: "#EBEBEB").cgColor
        bgggView.layer.masksToBounds = true
        
        let width = bgggView.frame.size.width
        var height = CGFloat(0.0)
        var yIndex = CGFloat(0.0)
        if (title.count > 0) {
            height = title.MyHeight(withConstrainedWidth: bgggView.frame.size.width - 20, font: UIFont.systemFont(ofSize: 16.0))
            height = max(height, 40.0)
            let lbl = PaddingLabel(withInsets: 8, 8, 18, 18)
            bgggView.addSubview(lbl)
            lbl.frame = CGRect(x: 0, y: yIndex, width: bgggView.frame.size.width, height: height + 16)
            lbl.text = title
            lbl.font = UIFont.systemFont(ofSize: 16.0)
            lbl.textAlignment = .center
            lbl.backgroundColor = UIColor(MyHexString: "#EBEBEB")
            lbl.layer.masksToBounds = true
            lbl.layer.borderWidth = 0.5
            lbl.numberOfLines = 10
            lbl.layer.masksToBounds = true
            lbl.textColor = UIColor(MyHexString: "#090909")
            lbl.layer.borderColor = UIColor(MyHexString: "#EBEBEB").cgColor
            lbl.tag = 9999
            yIndex = yIndex + lbl.frame.size.height
        }
        
        for i in 0..<menus.count {
            let item = menus[i]
            let actions = item["action"] as! [String:Any]
            let labelText = actions["label"] as? String ?? ""
            
            height = labelText.MyHeight(withConstrainedWidth: bgggView.frame.size.width - 20, font: UIFont.systemFont(ofSize: 16.0))
            height = max(40.0, height)
            let lbl = PaddingLabel(withInsets: 8, 8, 18, 18)
            lbl.frame = CGRect(x: 0.0, y: yIndex, width: width, height: height + 16)
            lbl.text = labelText
            lbl.font = UIFont.systemFont(ofSize: 16.0)
            lbl.textAlignment = .center
            lbl.backgroundColor = UIColor.white
            lbl.layer.borderWidth = 0.5
            lbl.numberOfLines = 10
            lbl.textColor = UIColor(MyHexString: "#FF8300")
            lbl.layer.borderColor = UIColor(MyHexString: "#EBEBEB").cgColor
            lbl.tag = 10000 + i
            lbl.isUserInteractionEnabled = true
            bgggView.addSubview(lbl)
            yIndex = yIndex + lbl.frame.size.height
        }
        
        bgggView.frame = CGRect(x: avartar.frame.origin.x + avartarWidth + 5, y: 0, width: UIScreen.main.bounds.width - avartar.frame.origin.x - avartarWidth - 15, height: yIndex)
        
        let timelbl = UILabel()
        timelbl.font = UIFont.systemFont(ofSize: 12)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let dateString = dateFormatter.string(from: item.sentDate)
        timelbl.backgroundColor = UIColor.clear
        timelbl.text = dateString
        timelbl.frame = CGRect(x: avartar.frame.origin.x + avartarWidth + 5, y: bgggView.frame.origin.y + bgggView.frame.size.height + 5, width: 100, height: 20)
        
        return timelbl.frame.origin.y + timelbl.frame.size.height + 15
    }
//
//    @objc func menuLabelClick(_ sender: UITapGestureRecognizer) {
//        debugPrint("Menu Click")
//    }
    
    //    func setupMenuCell(_ title:String,_ menus:[[String:Any]], _ item : MyMessage) {
    //
    //
    //        self.contentView.addSubview(self.avatarView)
    //        self.avatarView.image = UIImage(named: "chatbot", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil)
    //        self.avatarView.MyEdges([.left, .top], to: self.contentView, offset: UIEdgeInsets(top: padding, left: padding, bottom: -padding, right: -padding))
    //
    //        let offset = UIEdgeInsets(top: padding - 8.0, left: padding + (self.avatarView.image?.size.width ?? 0.0) + 10.0, bottom: -padding, right: -padding)
    //        self.contentView.addSubview(bgView)
    //        bgView.MyEdges([.left, .top, .bottom], to: self.contentView, offset: offset)
    //        bgView.layer.cornerRadius = 18
    //        bgView.backgroundColor = UIColor.clear
    ////        bgView.backgroundColor = UIColor(MyHexString: "#EBEBEB")
    //        bgView.trailingAnchor.constraint(lessThanOrEqualTo: self.contentView.trailingAnchor, constant: -extraSpacing).isActive = true
    //        bgView.layer.borderWidth = 0.5
    //        bgView.layer.borderColor = UIColor(MyHexString: "#EBEBEB").cgColor
    //        bgView.layer.masksToBounds = true
    //
    //        self.textView.isHidden = true
    //        self.topLabel.isHidden = true
    //        self.bottomLabel.isHidden = true
    //        self.timeLabel.isHidden = true
    //
    //        var yIndex = bgView.frame.origin.y
    //        let width = UIScreen.main.bounds.size.width - (8.0 + (self.avatarView.image?.size.width ?? 0.0) + 10.0 + extraSpacing)
    //        var height = CGFloat(0.0)
    //        if (title.count > 0) {
    //            height = title.MyHeight(withConstrainedWidth: width + 36, font: UIFont.systemFont(ofSize: 16.0))
    //            height = max(height, 40.0)
    //            let lbl = PaddingLabel(withInsets: 8, 8, 18, 18)
    //            bgView.addSubview(lbl)
    //            lbl.frame = CGRect(x: 0.0, y: yIndex, width: width, height: height + 16)
    //            lbl.text = title
    //            lbl.font = UIFont.systemFont(ofSize: 16.0)
    //            lbl.textAlignment = .center
    //            lbl.backgroundColor = UIColor(MyHexString: "#EBEBEB")
    //            lbl.layer.masksToBounds = true
    //            lbl.layer.borderWidth = 0.5
    //            lbl.numberOfLines = 10
    //            lbl.layer.masksToBounds = true
    //    //        lbl.layer.cornerRadius = 18
    //            lbl.textColor = UIColor(MyHexString: "#090909")
    //            lbl.layer.borderColor = UIColor(MyHexString: "#EBEBEB").cgColor
    //            lbl.tag = 9999
    //
    //            let path = UIBezierPath(roundedRect: lbl.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 18.0, height: 18.0))
    //            let mask = CAShapeLayer()
    //            mask.path = path.cgPath
    //            lbl.layer.mask = mask
    //
    //            yIndex = yIndex + lbl.frame.size.height
    //        }
    //
    //
    //        for i in 0..<menus.count {
    //            let item = menus[i]
    //            let actions = item["action"] as! [String:Any]
    //            let labelText = actions["label"] as? String ?? ""
    //
    //            height = labelText.MyHeight(withConstrainedWidth: width + 36, font: UIFont.systemFont(ofSize: 16.0))
    //            height = max(40.0, height)
    //            let lbl = PaddingLabel(withInsets: 8, 8, 18, 18)
    //            lbl.frame = CGRect(x: 0.0, y: yIndex, width: width, height: height + 16)
    //            lbl.text = labelText
    //            lbl.font = UIFont.systemFont(ofSize: 16.0)
    //            lbl.textAlignment = .center
    //            lbl.backgroundColor = UIColor.white
    ////            lbl.layer.masksToBounds = false
    //            lbl.layer.borderWidth = 0.5
    //            lbl.numberOfLines = 10
    //            lbl.textColor = UIColor(MyHexString: "#FF8300")
    //            lbl.layer.borderColor = UIColor(MyHexString: "#EBEBEB").cgColor
    //            lbl.tag = 10000 + i
    //            self.menuLabel.append(lbl)
    //            bgView.addSubview(lbl)
    //            yIndex = yIndex + lbl.frame.size.height
    //        }
    //
    //        let dateFormatter = DateFormatter()
    //        dateFormatter.dateFormat = "HH:mm"
    //        let dateString = dateFormatter.string(from: item.sentDate)
    //        let time = UILabel()
    //        self.contentView.addSubview(time)
    //        time.frame = CGRect(x: padding + (self.avatarView.image?.size.width ?? 0.0) + 10.0, y: yIndex + 5, width: width, height: 13)
    //        time.font = UIFont.systemFont(ofSize: 12.0)
    //        time.text = dateString
    //    }
    //
    //    static func calcMenuCellHeight(_ title:String,_ menus:[[String:Any]]) -> CGFloat {
    //        var yIndex = CGFloat(0.0)
    //        let image = UIImage(named: "chatbot", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil)
    //        let width = UIScreen.main.bounds.size.width - (8.0 + (image?.size.width ?? 0.0) + 10.0 + extraSpacing)
    //        var height = CGFloat(0.0)
    //        if (title.count > 0) {
    //            height = title.MyHeight(withConstrainedWidth: width + 36, font: UIFont.systemFont(ofSize: 16.0))
    //            height = max(height, 40.0)
    //            yIndex = yIndex + height + 16
    //        }
    //
    //        for i in 0..<menus.count {
    //            let item = menus[i]
    //            let actions = item["action"] as! [String:Any]
    //            let labelText = actions["label"] as? String ?? ""
    //
    //            height = labelText.MyHeight(withConstrainedWidth: width + 36, font: UIFont.systemFont(ofSize: 16.0))
    //            height = max(40.0, height)
    //            yIndex = yIndex + height + 16
    //        }
    //
    //        yIndex = yIndex + CGFloat(13)
    //
    //        return CGFloat(yIndex + 15)
    //    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}


extension CustomTableViewCell: SwiftImageCarouselVCDelegate {
    func didTapSwiftImageCarouselItemVC(swiftImageCarouselItemController: SwiftImageCarouselItemVC) {
        // The user selected this swiftImageCarouselItemController
        debugPrint(swiftImageCarouselItemController.itemIndex)
        debugPrint(swiftImageCarouselItemController.contentLinkURLs[swiftImageCarouselItemController.itemIndex])
        let urlString = swiftImageCarouselItemController.contentLinkURLs[swiftImageCarouselItemController.itemIndex]
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url)  {
            UIApplication.shared.open(url)
        }
    }
}
