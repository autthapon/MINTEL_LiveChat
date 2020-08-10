/*
 MIT License
 
 Copyright (c) 2017-2019 MessageKit
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import Foundation
import MessageKit
import QuartzCore



open class MyCustomCell: UICollectionViewCell {
    
    var tapGuesture:MyTapGesture?
    open func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView, tapGuesture : MyTapGesture) {
        
        let custom = message as! MockMessage

        self.tapGuesture = tapGuesture
        switch custom.kind {
        case .custom(let items) :
            
            let item = items as! [String: Any]
            let type = item["type"] as! Int
            if (type == 2) {
                
                self.contentView.layer.cornerRadius = 0
                self.contentView.layer.masksToBounds = true
                self.contentView.layer.borderColor = UIColor.white.cgColor
                self.contentView.layer.borderWidth = 0
                self.contentView.subviews.forEach({ $0.removeFromSuperview() })
                
                let line = UIView(frame: CGRect(x: 5, y: self.contentView.center.y, width: self.contentView.frame.size.width - 10, height: 1))
                line.backgroundColor = UIColor.black
                self.contentView.addSubview(line)

                let msg = item["msg"] as! String
                let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 30))
                lbl.text = String(format: "   %@   ", msg)
                lbl.textAlignment = .center
                lbl.font = UIFont.systemFont(ofSize: 12)
                lbl.backgroundColor = UIColor.white
                lbl.layer.masksToBounds = true
                lbl.layer.borderWidth = 0
                lbl.tag = 10000
                lbl.padding = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
                self.contentView.addSubview(lbl)
             
            } else if (type == 1) {
                let menuItems = item["menuItem"] as! [[String: Any]]
                var yIndex = 0
                
                let defaultLabel = UILabel()
                if let title = custom.title {
                    if (title.count > 0) {
                        let height = title.MyHeight(withConstrainedWidth: 300, font: defaultLabel.font)
                        var setHeight = max(height, CGFloat(menuHeight))
                        if Int(setHeight) > Int(menuHeight) {
                            setHeight = setHeight + 25
                        }
                        
                        let lbl = UILabel(frame: CGRect(x: 0, y: yIndex, width: 300, height: Int(setHeight)))
                        lbl.text = title
                        lbl.textAlignment = .center
                        lbl.backgroundColor = UIColor(MyHexString: "#EBEBEB")
                        lbl.layer.masksToBounds = true
                        lbl.layer.borderWidth = 0.5
                        lbl.numberOfLines = 10
                        lbl.textColor = UIColor(MyHexString: "#090909")
                        lbl.layer.borderColor = UIColor(MyHexString: "#EBEBEB").cgColor
                        lbl.tag = 9999
                        lbl.padding = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
                        self.contentView.addSubview(lbl)
                        yIndex = yIndex + Int(setHeight)
                    }
                }
                
                for i in 0..<menuItems.count {
                    let item = menuItems[i]
                    let actions = item["action"] as! [String:Any]
                    let labelText = actions["label"] as? String ?? ""
                    
                    let height = labelText.MyHeight(withConstrainedWidth: 300, font: defaultLabel.font)
                    var setHeight = max(height, CGFloat(menuHeight))
                    if Int(setHeight) > Int(menuHeight) {
                        setHeight = setHeight + 5
                    }
                    
                    let lbl = UILabel(frame: CGRect(x: 0, y: yIndex, width: 300, height: Int(setHeight)))
                    lbl.text = labelText
                    lbl.textAlignment = .center
                    lbl.backgroundColor = UIColor.white
                    lbl.layer.masksToBounds = true
                    lbl.layer.borderWidth = 0.5
                    lbl.numberOfLines = 10
                    lbl.textColor = UIColor(MyHexString: "#FF8300")
                    lbl.layer.borderColor = UIColor(MyHexString: "#EBEBEB").cgColor
                    lbl.tag = 10000 + i
                    self.contentView.addSubview(lbl)
                    yIndex = yIndex + Int(setHeight)
                }
                
                self.contentView.layer.cornerRadius = 20
                self.contentView.layer.masksToBounds = true
                self.contentView.layer.borderColor = UIColor(MyHexString: "#EBEBEB").cgColor
                self.contentView.layer.borderWidth = 1
                
                if let gesture = self.tapGuesture {
                    self.contentView.addGestureRecognizer(gesture)
                }
            }
        default:
            break
        }
    }
}



open class CustomMessagesFlowLayout: MessagesCollectionViewFlowLayout {

    open lazy var customMessageSizeCalculator = CustomMessageSizeCalculator(layout: self)
    var menuHeight = 0
    
    open override func cellSizeCalculatorForItem(at indexPath: IndexPath) -> CellSizeCalculator {
        if isSectionReservedForTypingIndicator(indexPath.section) {
            return typingIndicatorSizeCalculator
        }
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        if case .custom = message.kind {
            return customMessageSizeCalculator
        }
        return super.cellSizeCalculatorForItem(at: indexPath)
    }
    
    open override func messageSizeCalculators() -> [MessageSizeCalculator] {
        var superCalculators = super.messageSizeCalculators()
        // Append any of your custom `MessageSizeCalculator` if you wish for the convenience
        // functions to work such as `setMessageIncoming...` or `setMessageOutgoing...`
        superCalculators.append(customMessageSizeCalculator)
        return superCalculators
    }
}

open class CustomMessageSizeCalculator: MessageSizeCalculator {
    
    public override init(layout: MessagesCollectionViewFlowLayout? = nil) {
        super.init()
        self.layout = layout
    }
    
    open override func sizeForItem(at indexPath: IndexPath) -> CGSize {
        guard let layout = layout else { return .zero }
        let messagesCollectionView = layout as! MessagesCollectionViewFlowLayout
        let message = messagesCollectionView.messagesDataSource.messageForItem(at: indexPath, in: layout.collectionView as! MessagesCollectionView) as! MockMessage
        if case .custom(let items) = message.kind {
            let item = items as! [String: Any]
            let type = item["type"] as! Int
            if (type == 2) {
                return CGSize(width: layout.collectionView?.frame.size.width ?? 0, height: 30)
            } else if (type == 1) {
                let menuItems = item["menuItem"] as! [[String: Any]]
                
                var setMenuHeight = 0
                let defaultLabel = UILabel()
                
                if let title = message.title {
                    if (title.count > 0) {
                        let height = title.MyHeight(withConstrainedWidth: 300, font: defaultLabel.font)
                        var setHeight = max(height, CGFloat(menuHeight))
                        if Int(setHeight) > Int(menuHeight) {
                            setHeight = setHeight + 25
                        }
                        
                        setMenuHeight = setMenuHeight + Int(setHeight)
                    }
                }
                
                for i in 0..<menuItems.count {
                    let item = menuItems[i]
                    let actions = item["action"] as! [String:Any]
                    let labelText = actions["label"] as? String ?? ""
                    
                    let height = labelText.MyHeight(withConstrainedWidth: 300, font: defaultLabel.font)
                    var setHeight = max(height, CGFloat(menuHeight))
                    if Int(setHeight) > Int(menuHeight) {
                        setHeight = setHeight + 5
                    }
                    
                    setMenuHeight = setMenuHeight + Int(setHeight)
                }
                
                return CGSize(width: CGFloat(300), height: CGFloat(setMenuHeight))
            }
        }
        
        return CGSize.zero
    }
  
}
