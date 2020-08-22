//
//  ViewController.swift
//  SSChat
//
//  Created by Autthapon Sukajaroen on 13/08/2020
//  Copyright © 2020 Autthapon Sukjaroen. All rights reserved.
//

import UIKit
let menuHeight = 40

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
    
    var tapGuesture:MyTapGuesture?
    var menuLabel:[UILabel] = []
    
    //    var avatarView: UIImageView = {
    //        let v = UIImageView()
    //        v.translatesAutoresizingMaskIntoConstraints = false
    //        return v
    //    }()
    //
    //    var bgView: UIView = {
    //        let v = UIView()
    //        v.translatesAutoresizingMaskIntoConstraints = false
    //        return v
    //    }()
    
    //    var topLabel: UILabel = {
    //        let v = UILabel()
    //        v.translatesAutoresizingMaskIntoConstraints = false
    //        return v
    //    }()
    //
    //    var bottomLabel: UILabel = {
    //        let v = UILabel()
    //        v.translatesAutoresizingMaskIntoConstraints = false
    //        return v
    //    }()
    //
    //    var timeLabel: UILabel = {
    //        let v = UILabel()
    //        v.translatesAutoresizingMaskIntoConstraints = false
    //        return v
    //    }()
    
    //    var statusLabel: UILabel = {
    //        let v = UILabel()
    //        v.translatesAutoresizingMaskIntoConstraints = false
    //        return v
    //    }()
    //
    //    var imgView: UIImageView = {
    //        let v = UIImageView()
    //        v.translatesAutoresizingMaskIntoConstraints = false
    //        return v
    //    }()
    
    //    var textView: UITextView = {
    //        let v = UITextView()
    //        v.translatesAutoresizingMaskIntoConstraints = false
    //        return v
    //    }()
    
    //    var showTopLabel = true {
    //        didSet {
    //            textviewTopConstraintToBg.isActive = !showTopLabel
    //            textviewTopConstraintToTopLabel.isActive = showTopLabel
    ////            topLabel.isHidden = !showTopLabel
    //        }
    //    }
    
    let innerSpacing: CGFloat = 4
    
    let secondaryPadding: CGFloat = 8
    
    var textviewTopConstraintToBg: NSLayoutConstraint!
    
    var textviewTopConstraintToTopLabel: NSLayoutConstraint!
    
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
    
    func setupSystemMessage() {
        //        self.avatarView.isHidden = true
        //        self.textView.isHidden = true
        //        self.bgView.isHidden = true
        //        self.bottomLabel.isHidden = true
        //        self.topLabel.isHidden = true
        //        self.timeLabel.isHidden = true
    }
    
    fileprivate static func createSystemMessage(text: String) -> UILabel {
        let lbl = PaddingLabel(withInsets: 0.5, 0.5, 3, 3)
        lbl.font = UIFont.systemFont(ofSize: 12)
        lbl.text = text
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
        self.setupSystemMessage()
        
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
        self.setupSystemMessage()
        
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
    //
    //    func setupReceiversMenuCell() {
    //
    //        self.contentView.addSubview(self.avatarView)
    //        self.avatarView.image = UIImage(named: "chatbot", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil)
    //        self.avatarView.MyEdges([.left, .top], to: self.contentView, offset: UIEdgeInsets(top: padding, left: padding, bottom: -padding, right: -padding))
    //
    //        let offset = UIEdgeInsets(top: padding - 8.0, left: padding + (self.avatarView.image?.size.width ?? 0.0) + 10.0, bottom: -padding, right: -padding)
    //        self.contentView.addSubview(bgView)
    //        bgView.MyEdges([.left, .top, .bottom], to: self.contentView, offset: offset)
    //        bgView.backgroundColor = UIColor.clear
    //
    //        self.bgView.addSubview(topLabel)
    //        topLabel.MyEdges([.left, .top], to: self.bgView, offset: UIEdgeInsets(top: secondaryPadding, left: secondaryPadding, bottom: 0, right: 0))
    //        topLabel.font = UIFont.boldSystemFont(ofSize: 14)
    //        topLabel.textColor = UIColor.red
    //        topLabel.text = "Red"
    //        topLabel.isHidden = true
    //
    ////        imgView.image = UIImage(named: "chatbot", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil)
    ////        self.bgView.addSubview(imgView)
    ////        imgView.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 0).isActive = true
    ////        imgView.topAnchor.constraint(equalTo: bgView.topAnchor, constant: innerSpacing).isActive = true
    ////        imgView.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: innerSpacing).isActive = true
    ////        imgView.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -innerSpacing).isActive = true
    //
    //        self.bgView.addSubview(textView)
    //        textviewTopConstraintToTopLabel = textView.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 0)
    //        textviewTopConstraintToTopLabel.isActive = false
    //        textviewTopConstraintToBg = textView.topAnchor.constraint(equalTo: bgView.topAnchor, constant: innerSpacing)
    //        textviewTopConstraintToBg.isActive = true
    //        textView.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: innerSpacing).isActive = true
    //        textView.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -innerSpacing).isActive = true
    //        topLabel.trailingAnchor.constraint(lessThanOrEqualTo: textView.trailingAnchor, constant: 0).isActive = true
    //        bgView.trailingAnchor.constraint(lessThanOrEqualTo: self.contentView.trailingAnchor, constant: -extraSpacing).isActive = true
    //        textView.isScrollEnabled = false
    //        textView.isEditable = false
    //        textView.isSelectable = true
    //        textView.tintColor = UIColor.white
    //        textView.textColor = UIColor.white
    //        textView.dataDetectorTypes = [.link]
    //        textView.isUserInteractionEnabled = true
    //        textView.font = UIFont.systemFont(ofSize: 16)
    //        textView.text = "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum"
    //        textView.backgroundColor = UIColor.clear
    //
    //        self.bgView.addSubview(bottomLabel)
    //        bottomLabel.MyEdges([.left, .bottom], to: self.bgView, offset: UIEdgeInsets(top: innerSpacing, left: secondaryPadding, bottom: 10, right: 0))
    //        bottomLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -secondaryPadding).isActive = true
    //        bottomLabel.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: -2).isActive = true
    //        bottomLabel.font = UIFont.systemFont(ofSize: 10)
    //        bottomLabel.textColor = UIColor.lightGray
    //        bottomLabel.textAlignment = .right
    //
    //        self.contentView.addSubview(self.timeLabel)
    //        timeLabel.MyEdges([.left, .bottom], to: self.bgView, offset: UIEdgeInsets(top: innerSpacing, left: secondaryPadding, bottom: secondaryPadding, right: 0))
    //        timeLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -secondaryPadding).isActive = true
    //        timeLabel.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 5).isActive = true
    //        timeLabel.text = "HH:mm"
    //    }
    //
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
        self.contentView.addSubview(textView)
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isHidden = false
        textView.text = txt
        textView.backgroundColor = UIColor(MyHexString: "#EBEBEB")
        textView.layer.cornerRadius = 18.0
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView.frame = CGRect(x: avartar.frame.origin.x + avartarWidth + 5, y: 0, width: UIScreen.main.bounds.width - avartar.frame.origin.x - avartarWidth - 10, height: 100)
        textView.dataDetectorTypes = [.link]
        textView.isSelectable = true
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.tintColor = UIColor.black
        textView.textColor = UIColor.black
        textView.sizeToFit()
        textView.frame = CGRect(x: avartar.frame.origin.x + avartarWidth + 5, y: 0, width: textView.contentSize.width, height: textView.contentSize.height)
        
        if let url = URL(string: txt) {
            if UIApplication.shared.canOpenURL(url as URL) {
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
//                                let imgView = UIImageView()
//                                self.contentView.addSubview(imgView)
//                                imgView.frame = CGRect(x: avartar.frame.origin.x + avartarWidth + 5, y: 0, width: 200, height: 200)
//                                imgView.startAnimating()
                                URLSession.shared.dataTask(with: url) { (data, response, error) in
                                    if error != nil {
//                                        print("Failed fetching image:", error)
                                        DispatchQueue.main.async {
                                            textView.isHidden = false
                                        }
                                        return
                                    }

                                    guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
//                                        print("Not a proper HTTPURLResponse or statusCode")
                                        DispatchQueue.main.async {
                                            textView.isHidden = false
                                        }
                                        return
                                    }

                                    DispatchQueue.main.async {
//                                        imgView.stopAnimating()
                                        let imaaa = UIImage(data: data!)
//                                        imgView.image = imaaa
                                        MINTEL_LiveChat.items[index] = MyMessage(image: imaaa!, agent: !MINTEL_LiveChat.chatBotMode, bot: true)
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
        
        let timelbl = UILabel()
        timelbl.font = UIFont.systemFont(ofSize: 12)
        self.contentView.addSubview(timelbl)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let dateString = dateFormatter.string(from: item.sentDate)
        timelbl.backgroundColor = UIColor.clear
        timelbl.text = dateString
        timelbl.frame = CGRect(x: textView.frame.origin.x, y: textView.frame.origin.y + textView.frame.size.height + 5, width: 100, height: 20)
    }
    
    static func calcReceiverCell(_ txt:String, item: MyMessage) -> CGFloat {
        
        let avartar = UIImageView()
        let avartarImage = UIImage(named: "chatbot", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil)
        let avartarWidth = avartarImage?.size.width ?? 0.0
        avartar.image = avartarImage
        avartar.frame = CGRect(x: padding, y: 0, width: avartarWidth, height: avartar.image?.size.height ?? 0)
        
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        
        textView.text = txt
        textView.backgroundColor = UIColor(MyHexString: "#EBEBEB")
        textView.layer.cornerRadius = 18.0
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView.frame = CGRect(x: avartar.frame.origin.x + avartarWidth + 5, y: 0, width: UIScreen.main.bounds.width - avartar.frame.origin.x - avartarWidth - 10, height: 100)
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
    
    func renderSender(txt: String, item :MyMessage) {
        
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
    
    //    func setupReceiversCell() {
    //
    //        self.contentView.addSubview(self.avatarView)
    //        self.avatarView.image = UIImage(named: "chatbot", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil)
    //        self.avatarView.MyEdges([.left, .top], to: self.contentView, offset: UIEdgeInsets(top: padding, left: padding, bottom: -padding, right: -padding))
    //
    //        let offset = UIEdgeInsets(top: padding - 8.0, left: padding + (self.avatarView.image?.size.width ?? 0.0) + 10.0, bottom: -20.0, right: -padding)
    //        self.contentView.addSubview(bgView)
    //        bgView.MyEdges([.left, .top, .bottom], to: self.contentView, offset: offset)
    //        bgView.layer.cornerRadius = 18
    ////        bgView.backgroundColor = UIColor(MyHexString: "#EBEBEB")
    //
    //        self.bgView.addSubview(topLabel)
    //        topLabel.MyEdges([.left, .top], to: self.bgView, offset: UIEdgeInsets(top: secondaryPadding, left: secondaryPadding, bottom: 0, right: 0))
    //        topLabel.font = UIFont.boldSystemFont(ofSize: 14)
    //        topLabel.textColor = UIColor.red
    //        topLabel.text = "Red"
    //        topLabel.isHidden = true
    //
    //        self.bgView.addSubview(textView)
    //        textviewTopConstraintToTopLabel = textView.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 0)
    //        textviewTopConstraintToTopLabel.isActive = false
    //        textviewTopConstraintToBg = textView.topAnchor.constraint(equalTo: bgView.topAnchor, constant: innerSpacing)
    //        textviewTopConstraintToBg.isActive = true
    //        textView.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: innerSpacing).isActive = true
    //        textView.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -innerSpacing).isActive = true
    //        topLabel.trailingAnchor.constraint(lessThanOrEqualTo: textView.trailingAnchor, constant: 0).isActive = true
    //        bgView.trailingAnchor.constraint(lessThanOrEqualTo: self.contentView.trailingAnchor, constant: -extraSpacing).isActive = true
    //        textView.isScrollEnabled = false
    //        textView.isEditable = false
    //        textView.isSelectable = true
    //        textView.tintColor = UIColor.black
    //        textView.textColor = UIColor.black
    //        textView.textContainerInset = UIEdgeInsets(top: secondaryPadding, left: secondaryPadding, bottom: secondaryPadding, right: secondaryPadding)
    //        textView.dataDetectorTypes = [.link]
    //        textView.backgroundColor = UIColor(MyHexString: "#EBEBEB")
    //        textView.font = UIFont.systemFont(ofSize: 16)
    //        textView.layer.cornerRadius = 18
    //        textView.text = "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum"
    ////        textView.backgroundColor = UIColor.clear
    //
    //        self.bgView.addSubview(bottomLabel)
    //        bottomLabel.MyEdges([.left, .bottom], to: self.bgView, offset: UIEdgeInsets(top: innerSpacing, left: secondaryPadding, bottom: -secondaryPadding, right: 0))
    //        bottomLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -secondaryPadding).isActive = true
    //        bottomLabel.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: -5).isActive = true
    //        bottomLabel.font = UIFont.systemFont(ofSize: 10)
    //        bottomLabel.textColor = UIColor.lightGray
    //        bottomLabel.textAlignment = .right
    //
    //        self.contentView.addSubview(self.timeLabel)
    //        timeLabel.MyEdges([.left, .bottom], to: self.bgView, offset: UIEdgeInsets(top: innerSpacing, left: secondaryPadding, bottom: secondaryPadding, right: 0))
    //        timeLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -secondaryPadding).isActive = true
    //        timeLabel.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 2).isActive = true
    //        timeLabel.font = UIFont.systemFont(ofSize: 12)
    //        timeLabel.text = "HH:mm"
    //    }
    
    //    func setupSendersCell() {
    //
    //        let offset = UIEdgeInsets(top: padding, left: padding, bottom: -padding, right: -padding)
    //        self.contentView.addSubview(bgView)
    //        bgView.MyEdges([.right, .top, .bottom], to: self.contentView, offset: offset)
    //
    //        self.bgView.addSubview(textView)
    //        textView.MyEdges([.left, .right, .top], to: self.bgView, offset: .init(top: innerSpacing, left: innerSpacing, bottom: -innerSpacing, right: -innerSpacing))
    //        bgView.leadingAnchor.constraint(greaterThanOrEqualTo: self.contentView.leadingAnchor, constant: extraSpacing).isActive = true
    //        textView.isScrollEnabled = false
    //        textView.isEditable = false
    //        textView.isSelectable = true
    //        textView.isUserInteractionEnabled = true
    //        textView.font = UIFont.systemFont(ofSize: 16)
    //        textView.tintColor = UIColor.white
    //        textView.textColor = UIColor.white
    //        textView.dataDetectorTypes = [.link]
    //        textView.layer.cornerRadius = 18
    //        textView.backgroundColor = UIColor(MyHexString: "#FF8300")
    //        textView.text = "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum"
    //
    //        self.bgView.addSubview(bottomLabel)
    //        bottomLabel.MyEdges([.left, .bottom], to: self.bgView, offset: UIEdgeInsets(top: innerSpacing, left: secondaryPadding, bottom: -secondaryPadding, right: 0))
    //        bottomLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -secondaryPadding).isActive = true
    //        bottomLabel.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: -2).isActive = true
    //        bottomLabel.font = UIFont.systemFont(ofSize: 10)
    //        bottomLabel.textColor = UIColor.white
    //        bottomLabel.textAlignment = .right
    //        bottomLabel.text = ""
    //
    //        self.contentView.addSubview(self.timeLabel)
    //        timeLabel.MyEdges([.right, .bottom], to: self.bgView, offset: UIEdgeInsets(top: innerSpacing, left: 0, bottom: secondaryPadding, right: -secondaryPadding))
    //        timeLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: secondaryPadding).isActive = true
    //        timeLabel.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 2).isActive = true
    //        timeLabel.font = UIFont.systemFont(ofSize: 12)
    //        timeLabel.textAlignment = .right
    //        timeLabel.text = "HH:mm"
    //    }
    
    func setupImageCell() {
        //        self.avatarView.isHidden = true
        //        self.textView.isHidden = true
        //        self.bgView.isHidden = true
        //        self.bottomLabel.isHidden = true
        //        self.topLabel.isHidden = true
    }
    
    func renderImageCell(image:UIImage, time: Date, item: MyMessage) {
        
        self.contentView.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        let img = image.MyResizeImage(targetSize: CGSize(width:200,height: 200))
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
        }
        
        
    }
    
    func renderAgentJoin() {
        self.setupSystemMessage()
        
        let screen = UIScreen.main.bounds
        let imgView = UIImageView(image: UIImage(named: "agent", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil))
        self.contentView.addSubview(imgView)
        var xPosition = (screen.width - imgView.image!.size.width) / 2.0
        imgView.frame = CGRect(x: xPosition, y: 10, width: imgView.image!.size.width, height: imgView.image!.size.height)
        
        let lbl = CustomTableViewCell.createSystemMessage(text: "Agent Joined")
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
        return 200 + 30
    }
    
    func setupMenuCell(_ title:String,_ menus:[[String:Any]], _ item : MyMessage) {
        
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
            bgggView.addSubview(lbl)
            yIndex = yIndex + lbl.frame.size.height
        }
        
        bgggView.frame = CGRect(x: avartar.frame.origin.x + avartarWidth + 5, y: 0, width: UIScreen.main.bounds.width - avartar.frame.origin.x - avartarWidth - 15, height: yIndex)
        
        let timelbl = UILabel()
        timelbl.font = UIFont.systemFont(ofSize: 12)
        self.contentView.addSubview(timelbl)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let dateString = dateFormatter.string(from: item.sentDate)
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
