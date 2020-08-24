//
//  ViewController.swift
//  SSChat
//
//  Created by Autthapon Sukajaroen on 13/08/2020
//  Copyright © 2020 Autthapon Sukjaroen. All rights reserved.
//

import UIKit
import ServiceCore
import ServiceChat

@objc protocol InputTextViewDelegate: class {
    @objc optional func inputTextViewGotFocus(_ textView: UITextView)
    func didPressSendButton(_ text: String, _ sender: UIButton, _ textView: UITextView)
    @objc optional func didPressFirstLeftButton(_ sender: UIButton, _ textView: UITextView)
    @objc optional func didPressSecondLeftButton(_ sender: UIButton, _ textView: UITextView)
    @objc optional func didPressThirdLeftButton(_ sender: UIButton, _ textView: UITextView)
    @objc optional func didPressFourthLeftButton(_ sender: UIButton, _ textView: UITextView)
}

class InputTextView: UIView {
    
    weak var delegate: InputTextViewDelegate?
    
    static let textViewHeight: CGFloat = 34
    
    static let buttonItemHeight: CGFloat = 44
    
    var textViewHeightConstraint: NSLayoutConstraint!
    
    var leftStackViewWidthConstraint: NSLayoutConstraint!
    
    var rightStackViewWidthConstraint: NSLayoutConstraint!
    
    var textView: UITextView = {
        let v = UITextView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var firstLeftButton = UIButton()
    var secondLeftButton = UIButton()
    var thridLeftButton = UIButton()
    var fourthLeftButton = UIButton()
    
    var firstRightButton = UIButton()
    var secondRightButton = UIButton()
    
    var leftStackView: UIStackView = {
        let v = UIStackView()
        v.axis = NSLayoutConstraint.Axis.horizontal
        v.spacing = 0
        v.distribution = .fillEqually
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var rightStackView: UIStackView = {
        let v = UIStackView()
        v.axis = NSLayoutConstraint.Axis.horizontal
        v.spacing = 0
        v.distribution = .fillEqually
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let padding: CGFloat = 8
        let buttonPadding: CGFloat = 3
        backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
        self.addSubview(textView)
        textView.MyEdges([.bottom, .top], to: self, offset: .init(top: padding, left: padding, bottom: -padding, right: -padding))
        textViewHeightConstraint = textView.heightAnchor.constraint(equalToConstant: InputTextView.textViewHeight)
        textViewHeightConstraint.isActive = true
        textView.delegate = self
        textView.isScrollEnabled = false
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        textView.layer.cornerRadius = InputTextView.textViewHeight/2
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 0.5
        
        self.addSubview(leftStackView)
        leftStackView.MyEdges([.left, .bottom], to: self, offset: .init(top: buttonPadding, left: buttonPadding, bottom: -buttonPadding, right: -buttonPadding))
        leftStackView.trailingAnchor.constraint(equalTo: textView.leadingAnchor, constant: -buttonPadding).isActive = true
        leftStackViewWidthConstraint = leftStackView.widthAnchor.constraint(equalToConstant: 0)
        leftStackViewWidthConstraint.isActive = true
        leftStackView.heightAnchor.constraint(equalToConstant: InputTextView.buttonItemHeight).isActive = true
        setupLeftBarItems()
        
        self.addSubview(rightStackView)
        rightStackView.MyEdges([.right, .bottom], to: self, offset: .init(top: buttonPadding, left: buttonPadding, bottom: -buttonPadding, right: -buttonPadding))
        rightStackView.leadingAnchor.constraint(equalTo: textView.trailingAnchor, constant: buttonPadding).isActive = true
        rightStackViewWidthConstraint = rightStackView.widthAnchor.constraint(equalToConstant: 0)
        rightStackViewWidthConstraint.isActive = true
        rightStackView.heightAnchor.constraint(equalToConstant: InputTextView.buttonItemHeight).isActive = true
        self.setupTwoRightButtons()
        
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0, y: 0, width: 10000, height: 0.5)
        topBorder.backgroundColor = UIColor.lightGray.cgColor
        
        self.layer.addSublayer(topBorder)
        self.clipsToBounds = true
        self.setupSaleForceEvent()
    }
    
    
    
    
    internal func hideLeftMenu() {
        self.setupLeftBarItems()
    }
    
    fileprivate func setupLeftBarItems() {
        firstLeftButton.setImage(UIImage(named: "expand", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil), for: .normal)
        firstLeftButton.addTarget(self, action: #selector(firstLeftButtonTapped(_:)), for: .touchUpInside)
        firstLeftButton.tag = 100
        leftStackView.addArrangedSubview(firstLeftButton)
        
        self.leftStackView.removeArrangedSubview(self.secondLeftButton)
        self.leftStackView.removeArrangedSubview(self.thridLeftButton)
        self.leftStackView.removeArrangedSubview(self.fourthLeftButton)
        self.secondLeftButton.removeFromSuperview()
        self.thridLeftButton.removeFromSuperview()
        self.fourthLeftButton.removeFromSuperview()
        self.setLeftStackViewWidth(36)
        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        }
    }
    
    fileprivate func setupTwoRightButtons() {
        secondRightButton.setImage(UIImage(named: "send", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil), for: .normal)
        secondRightButton.addTarget(self, action: #selector(secondRightButtonTapped(_:)), for: .touchUpInside)
        secondRightButton.tag = 121 // 120 for mic, 121 for send
        rightStackView.addArrangedSubview(secondRightButton)
        self.setRightStackViewWidth(InputTextView.buttonItemHeight)
        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        }
    }
    
    fileprivate func showMoreLeftButton() {
        
        firstLeftButton.setImage(UIImage(named: "close", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil), for: .normal)
        firstLeftButton.tag = 105
        
        secondLeftButton.setImage(UIImage(named: "camera", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil), for: .normal)
        secondLeftButton.addTarget(self, action: #selector(secondButtonLeftTapped(_:)), for: .touchUpInside)
        secondLeftButton.tag = 101
        leftStackView.addArrangedSubview(secondLeftButton)
        
        thridLeftButton.setImage(UIImage(named: "image", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil), for: .normal)
        thridLeftButton.addTarget(self, action: #selector(thirdButtonLeftTapped(_:)), for: .touchUpInside)
        thridLeftButton.tag = 102
        leftStackView.addArrangedSubview(thridLeftButton)
        
        fourthLeftButton.setImage(UIImage(named: "file", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil), for: .normal)
        fourthLeftButton.addTarget(self, action: #selector(fourthButtonLeftTapped(_:)), for: .touchUpInside)
        fourthLeftButton.tag = 104
        leftStackView.addArrangedSubview(fourthLeftButton)
        
        
        self.setLeftStackViewWidth(48 * 3)
        UIView.animate(withDuration: 0.1) {
            self.layoutIfNeeded()
        }
    }
    
    //    fileprivate func showSendButton() {
    //        self.rightStackView.removeArrangedSubview(firstRightButton)
    //        firstRightButton.removeFromSuperview()
    //        secondRightButton.setImage(UIImage(named: "send"), for: .normal)
    //        secondRightButton.tag = 121
    //        self.setRightStackViewWidth(InputTextView.buttonItemHeight)
    //        UIView.animate(withDuration: 0.2) {
    //            self.layoutIfNeeded()
    //        }
    //    }
    
    //    fileprivate func showCameraAndMicButton() {
    //        firstRightButton.setImage(UIImage(named: "camera"), for: .normal)
    //        rightStackView.insertArrangedSubview(firstRightButton, at: 0)
    //        secondRightButton.setImage(UIImage(named: "mic"), for: .normal)
    //        secondRightButton.tag = 120
    //        self.setRightStackViewWidth(InputTextView.buttonItemHeight * 2)
    //        UIView.animate(withDuration: 0.2) {
    //            self.layoutIfNeeded()
    //        }
    //    }
    
    func setLeftStackViewWidth(_ width: CGFloat) {
        leftStackViewWidthConstraint.constant = width
    }
    
    func setRightStackViewWidth(_ width: CGFloat) {
        rightStackViewWidthConstraint.constant = width
    }
    
    @objc func firstLeftButtonTapped(_ sender: UIButton) {
        if (self.leftStackViewWidthConstraint.constant == 36) {
            self.showMoreLeftButton()
        } else {
            self.setupLeftBarItems()
        }
        delegate?.didPressFirstLeftButton?(sender, textView)
    }
    
    @objc func secondButtonLeftTapped(_ sender: UIButton) {
        delegate?.didPressSecondLeftButton?(sender, textView)
    }
    
    @objc func thirdButtonLeftTapped(_ sender: UIButton) {
        delegate?.didPressThirdLeftButton?(sender, textView)
    }
    
    @objc func fourthButtonLeftTapped(_ sender: UIButton) {
        delegate?.didPressFourthLeftButton?(sender, textView)
    }
    
    @objc func secondRightButtonTapped(_ sender: UIButton) {
        delegate?.didPressSendButton(textView.text, sender, textView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}

extension InputTextView: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        delegate?.inputTextViewGotFocus?(textView)
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let startHeight = textView.frame.size.height
        var calcHeight = textView.sizeThatFits(textView.frame.size).height
        if startHeight != calcHeight {
            calcHeight = calcHeight < InputTextView.textViewHeight ? InputTextView.textViewHeight : calcHeight
            self.textViewHeightConstraint.constant = calcHeight
        }
        
        if textView.text.isEmpty {
            NotificationCenter.default.post(name: Notification.Name(MINTELNotifId.userIsNotTyping),
                                            object: nil,
                                            userInfo:nil)
        } else {
            NotificationCenter.default.post(name: Notification.Name(MINTELNotifId.userIsTyping),
                                            object: nil,
                                            userInfo:nil)
        }
    }
    
}


extension InputTextView {
    internal func setupSaleForceEvent() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(MINTEL_reallyEndChat(_:)),
                                               name: Notification.Name(MINTELNotifId.reallyExitChat),
                                               object: nil)
    }
    
    internal func MINTEL_enable() {
        DispatchQueue.main.async {
            self.hideLeftMenu()
            self.leftStackView.isUserInteractionEnabled = true
            self.rightStackView.isUserInteractionEnabled = true
            self.textView.isUserInteractionEnabled = true
            self.textView.isEditable = true
        }
    }
    
    @objc func MINTEL_reallyEndChat(_ notification: Notification) {
        
        DispatchQueue.main.async {
            self.textView.resignFirstResponder()
            self.hideLeftMenu()
            self.leftStackView.isUserInteractionEnabled = false
            self.rightStackView.isUserInteractionEnabled = false
            self.textView.isUserInteractionEnabled = false
            self.textView.isEditable = false
        }
    }
}
