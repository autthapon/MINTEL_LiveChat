//
//  MyTapGuesture.swift
//  MINTEL_LiveChat
//
//  Created by Autthapon Sukjaroen on 13/8/2563 BE.
//

import Foundation

class MyTapGuesture : UITapGestureRecognizer {
    var message: MyMessage?
    var cell : UITableViewCell?
    var menu: [String:Any] = [:]
}
