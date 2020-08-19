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
    
    var avatarView: UIImageView = {
        let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var bgView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var topLabel: UILabel = {
        let v = UILabel()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var bottomLabel: UILabel = {
        let v = UILabel()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var statusLabel: UILabel = {
        let v = UILabel()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var textView: UITextView = {
        let v = UITextView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var showTopLabel = true {
        didSet {
            textviewTopConstraintToBg.isActive = !showTopLabel
            textviewTopConstraintToTopLabel.isActive = showTopLabel
            topLabel.isHidden = !showTopLabel
        }
    }
    
    
    
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
                self.setupSendersCell()
            } else if id == CellIds.receiverMenuCellid {
                self.setupReceiversMenuCell()
            }else {
                self.setupReceiversCell()
            }
        }
    }
    
    func setupSystemMessage() {
        self.avatarView.isHidden = true
        self.textView.isHidden = true
        self.bgView.isHidden = true
        self.bottomLabel.isHidden = true
        self.topLabel.isHidden = true
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
    
    func setupReceiversMenuCell() {
        self.contentView.addSubview(self.avatarView)
        self.avatarView.image = UIImage(named: "chatbot", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil)
        self.avatarView.MyEdges([.left, .top], to: self.contentView, offset: UIEdgeInsets(top: padding, left: padding, bottom: -padding, right: -padding))
        
        let offset = UIEdgeInsets(top: padding - 8.0, left: padding + (self.avatarView.image?.size.width ?? 0.0) + 10.0, bottom: -padding, right: -padding)
        self.contentView.addSubview(bgView)
        bgView.MyEdges([.left, .top, .bottom], to: self.contentView, offset: offset)
        bgView.backgroundColor = UIColor.clear
        
        self.bgView.addSubview(topLabel)
        topLabel.MyEdges([.left, .top], to: self.bgView, offset: UIEdgeInsets(top: secondaryPadding, left: secondaryPadding, bottom: 0, right: 0))
        topLabel.font = UIFont.boldSystemFont(ofSize: 14)
        topLabel.textColor = UIColor.red
        topLabel.text = "Red"
        topLabel.isHidden = true
        
        self.bgView.addSubview(textView)
        textviewTopConstraintToTopLabel = textView.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 0)
        textviewTopConstraintToTopLabel.isActive = false
        textviewTopConstraintToBg = textView.topAnchor.constraint(equalTo: bgView.topAnchor, constant: innerSpacing)
        textviewTopConstraintToBg.isActive = true
        textView.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: innerSpacing).isActive = true
        textView.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -innerSpacing).isActive = true
        topLabel.trailingAnchor.constraint(lessThanOrEqualTo: textView.trailingAnchor, constant: 0).isActive = true
        bgView.trailingAnchor.constraint(lessThanOrEqualTo: self.contentView.trailingAnchor, constant: -extraSpacing).isActive = true
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.isSelectable = true
        textView.tintColor = UIColor.white
        textView.textColor = UIColor.white
        textView.dataDetectorTypes = [.link]
//        textView.isUserInteractionEnabled = false
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.text = "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum"
        textView.backgroundColor = UIColor.clear
        
        self.bgView.addSubview(bottomLabel)
        bottomLabel.MyEdges([.left, .bottom], to: self.bgView, offset: UIEdgeInsets(top: innerSpacing, left: secondaryPadding, bottom: -secondaryPadding, right: 0))
        bottomLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -secondaryPadding).isActive = true
        bottomLabel.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: -2).isActive = true
        bottomLabel.font = UIFont.systemFont(ofSize: 10)
        bottomLabel.textColor = UIColor.lightGray
        bottomLabel.textAlignment = .right
    }
    
    func setupSendersCell() {
        let offset = UIEdgeInsets(top: padding, left: padding, bottom: -padding, right: -padding)
        self.contentView.addSubview(bgView)
        bgView.MyEdges([.right, .top, .bottom], to: self.contentView, offset: offset)
        bgView.layer.cornerRadius = 18
        bgView.backgroundColor = UIColor(MyHexString: "#FF8300")
        
        self.bgView.addSubview(textView)
        textView.MyEdges([.left, .right, .top], to: self.bgView, offset: .init(top: innerSpacing, left: innerSpacing, bottom: -innerSpacing, right: -innerSpacing))
        bgView.leadingAnchor.constraint(greaterThanOrEqualTo: self.contentView.leadingAnchor, constant: extraSpacing).isActive = true
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.isSelectable = true
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.tintColor = UIColor.white
        textView.textColor = UIColor.white
        textView.text = "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum"
        textView.dataDetectorTypes = [.link]
        textView.backgroundColor = UIColor.clear
        
        self.bgView.addSubview(bottomLabel)
        bottomLabel.MyEdges([.left, .bottom], to: self.bgView, offset: UIEdgeInsets(top: innerSpacing, left: secondaryPadding, bottom: -secondaryPadding, right: 0))
        bottomLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -secondaryPadding).isActive = true
        bottomLabel.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: -2).isActive = true
        bottomLabel.font = UIFont.systemFont(ofSize: 10)
        bottomLabel.textColor = UIColor.white
        bottomLabel.textAlignment = .right
    }
    
    func setupImageCell() {
        self.avatarView.isHidden = true
        self.textView.isHidden = true
        self.bgView.isHidden = true
        self.bottomLabel.isHidden = true
        self.topLabel.isHidden = true
    }
    
    func renderImageCell(image:UIImage) {
        self.setupImageCell()
        
        let img = image.MyResizeImage(targetSize: CGSize(width:200,height: 200))
        let imgView = UIImageView(image: img)
        let screen = UIScreen.main.bounds
        let xPosition = screen.width - img.size.width - 10.0
        imgView.frame = CGRect(x: xPosition, y: 10, width: img.size.width, height: img.size.height)
        imgView.layer.cornerRadius = 18
        imgView.backgroundColor = UIColor(MyHexString: "#EBEBEB")
        imgView.layer.masksToBounds = true
        imgView.startAnimating()
        
        self.contentView.addSubview(imgView)
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
        return 80
    }
    
    static func calcImageCellHeight(_ image:UIImage) -> CGFloat {
        return 200 + 15
    }
    
    func setupReceiversCell() {
        
        self.contentView.addSubview(self.avatarView)
        self.avatarView.image = UIImage(named: "chatbot", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil)
        self.avatarView.MyEdges([.left, .top], to: self.contentView, offset: UIEdgeInsets(top: padding, left: padding, bottom: -padding, right: -padding))
        
        let offset = UIEdgeInsets(top: padding - 8.0, left: padding + (self.avatarView.image?.size.width ?? 0.0) + 10.0, bottom: -padding, right: -padding)
        self.contentView.addSubview(bgView)
        bgView.MyEdges([.left, .top, .bottom], to: self.contentView, offset: offset)
        bgView.layer.cornerRadius = 18
        bgView.backgroundColor = UIColor(MyHexString: "#EBEBEB")
        
        self.bgView.addSubview(topLabel)
        topLabel.MyEdges([.left, .top], to: self.bgView, offset: UIEdgeInsets(top: secondaryPadding, left: secondaryPadding, bottom: 0, right: 0))
        topLabel.font = UIFont.boldSystemFont(ofSize: 14)
        topLabel.textColor = UIColor.red
        topLabel.text = "Red"
        topLabel.isHidden = true
        
        self.bgView.addSubview(textView)
        textviewTopConstraintToTopLabel = textView.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 0)
        textviewTopConstraintToTopLabel.isActive = false
        textviewTopConstraintToBg = textView.topAnchor.constraint(equalTo: bgView.topAnchor, constant: innerSpacing)
        textviewTopConstraintToBg.isActive = true
        textView.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: innerSpacing).isActive = true
        textView.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -innerSpacing).isActive = true
        topLabel.trailingAnchor.constraint(lessThanOrEqualTo: textView.trailingAnchor, constant: 0).isActive = true
        bgView.trailingAnchor.constraint(lessThanOrEqualTo: self.contentView.trailingAnchor, constant: -extraSpacing).isActive = true
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.isSelectable = true
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.text = "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum"
        textView.backgroundColor = UIColor.clear
        
        self.bgView.addSubview(bottomLabel)
        bottomLabel.MyEdges([.left, .bottom], to: self.bgView, offset: UIEdgeInsets(top: innerSpacing, left: secondaryPadding, bottom: -secondaryPadding, right: 0))
        bottomLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -secondaryPadding).isActive = true
        bottomLabel.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: -2).isActive = true
        bottomLabel.font = UIFont.systemFont(ofSize: 10)
        bottomLabel.textColor = UIColor.lightGray
        bottomLabel.textAlignment = .right
    }
    
    func setupMenuCell(_ title:String,_ menus:[[String:Any]]) {
        
        self.contentView.addSubview(self.avatarView)
        self.avatarView.image = UIImage(named: "chatbot", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil)
        self.avatarView.MyEdges([.left, .top], to: self.contentView, offset: UIEdgeInsets(top: padding, left: padding, bottom: -padding, right: -padding))
        
        let offset = UIEdgeInsets(top: padding - 8.0, left: padding + (self.avatarView.image?.size.width ?? 0.0) + 10.0, bottom: -padding, right: -padding)
        self.contentView.addSubview(bgView)
        bgView.MyEdges([.left, .top, .bottom], to: self.contentView, offset: offset)
        bgView.layer.cornerRadius = 18
        bgView.backgroundColor = UIColor(MyHexString: "#EBEBEB")
        bgView.trailingAnchor.constraint(lessThanOrEqualTo: self.contentView.trailingAnchor, constant: -extraSpacing).isActive = true
        bgView.layer.borderWidth = 0.5
        bgView.layer.borderColor = UIColor(MyHexString: "#EBEBEB").cgColor
        bgView.layer.masksToBounds = true
        
        self.textView.isHidden = true
        self.topLabel.isHidden = true
        self.bottomLabel.isHidden = true
        
        var yIndex = bgView.frame.origin.y
        let width = UIScreen.main.bounds.size.width - (8.0 + (self.avatarView.image?.size.width ?? 0.0) + 10.0 + extraSpacing) 
        var height = title.MyHeight(withConstrainedWidth: width + 36, font: UIFont.systemFont(ofSize: 16.0))
        height = max(height, 40.0)
        let lbl = PaddingLabel(withInsets: 8, 8, 18, 18)
        bgView.addSubview(lbl)
        lbl.frame = CGRect(x: 0.0, y: yIndex, width: width, height: height + 16)
        lbl.text = title
        lbl.font = UIFont.systemFont(ofSize: 16.0)
        lbl.textAlignment = .center
        lbl.backgroundColor = UIColor(MyHexString: "#EBEBEB")
        lbl.layer.masksToBounds = true
        lbl.layer.borderWidth = 0.5
        lbl.numberOfLines = 10
        lbl.layer.masksToBounds = true
//        lbl.layer.cornerRadius = 18
        lbl.textColor = UIColor(MyHexString: "#090909")
        lbl.layer.borderColor = UIColor(MyHexString: "#EBEBEB").cgColor
        lbl.tag = 9999
        yIndex = yIndex + lbl.frame.size.height

        for i in 0..<menus.count {
            let item = menus[i]
            let actions = item["action"] as! [String:Any]
            let labelText = actions["label"] as? String ?? ""

            height = labelText.MyHeight(withConstrainedWidth: width + 36, font: UIFont.systemFont(ofSize: 16.0))
            height = max(40.0, height)
            let lbl = PaddingLabel(withInsets: 8, 8, 18, 18)
            lbl.frame = CGRect(x: 0.0, y: yIndex, width: width, height: height + 16)
            lbl.text = labelText
            lbl.font = UIFont.systemFont(ofSize: 16.0)
            lbl.textAlignment = .center
            lbl.backgroundColor = UIColor.white
            lbl.layer.masksToBounds = true
            lbl.layer.borderWidth = 0.5
            lbl.numberOfLines = 10
            lbl.textColor = UIColor(MyHexString: "#FF8300")
            lbl.layer.borderColor = UIColor(MyHexString: "#EBEBEB").cgColor
            lbl.tag = 10000 + i
            self.menuLabel.append(lbl)
            bgView.addSubview(lbl)
            yIndex = yIndex + lbl.frame.size.height
        }
    }
    
    static func calcMenuCellHeight(_ title:String,_ menus:[[String:Any]]) -> CGFloat {
        var yIndex = CGFloat(0.0)
        let image = UIImage(named: "chatbot", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil)
        let width = UIScreen.main.bounds.size.width - (8.0 + (image?.size.width ?? 0.0) + 10.0 + extraSpacing)
        var height = title.MyHeight(withConstrainedWidth: width + 36, font: UIFont.systemFont(ofSize: 16.0))
        height = max(height, 40.0)
        yIndex = yIndex + height + 16

        for i in 0..<menus.count {
            let item = menus[i]
            let actions = item["action"] as! [String:Any]
            let labelText = actions["label"] as? String ?? ""

            height = labelText.MyHeight(withConstrainedWidth: width + 36, font: UIFont.systemFont(ofSize: 16.0))
            height = max(40.0, height)
            yIndex = yIndex + height + 16
        }
        
        return CGFloat(yIndex + 15)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
