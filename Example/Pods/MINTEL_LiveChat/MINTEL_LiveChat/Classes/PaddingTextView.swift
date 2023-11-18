//
//  PaddingTextView.swift
//  MINTEL_LiveChat
//
//  Created by Autthapon Sukjaroen on 21/8/2563 BE.
//

import UIKit

class UITextViewPadding : UITextView {
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
  }
}
