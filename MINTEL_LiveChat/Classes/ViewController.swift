//
//  ViewController.swift
//  SSChat
//
//  Created by Autthapon Sukajaroen on 13/08/2020
//  Copyright © 2020 Autthapon Sukjaroen. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import AVFoundation


internal class CellIds {
    
    static let senderCellId = "senderCellId"
    static let receiverCellId = "receiverCellId"
    static let receiverMenuCellid = "receiverMenuCellid"
    static let systemMessageCellId = "systemMessageCellId"
    static let systemMessageType2CellId = "systemMessageType2CellId"
    static let imageMessageCellId = "imageCellId"
    static let agentJoinCellId = "agentJoinCellId"
}

internal class SalesForceNotifId {
    static let didUpdatePosition = "saleForceDidUpdatePosition"
    static let agentJoined = "saleForceAgentJoin"
    static let didReceiveMessage = "saleForceDidReceiveMessage"
    static let agentLeftConference = "saleForceAgentLeftConference"
    static let didEnd = "saleForceDidEnd"
}

class ViewController: UIViewController {
    
    // Saleforce
    var queuePosition : Int = 99999
    
    var imagePanel:Bool = false
    
    var bottomHeight: CGFloat {
        let window = UIApplication.shared.keyWindow
        
        if #available(iOS 11.0, *) {
            return window?.safeAreaInsets.bottom ?? 0.0
        } else {
            return bottomLayoutGuide.length
        }
    }
    
    let imagePanelHeight:CGFloat = 245.0
    var items = [MyMessage]()
    var imagePicker: UIImagePickerController!
    var fetchResult: PHFetchResult<PHAsset>!
    var assetCollection: PHAssetCollection!

    fileprivate let imageManager = PHCachingImageManager()
    fileprivate var thumbnailSize: CGSize!
    fileprivate var previousPreheatRect = CGRect.zero
    
    var tableView: UITableView = {
        let v = UITableView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var inputTextView: InputTextView = {
        let v = InputTextView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var imagePanelView: UICollectionView = {
        
        let flowLayout = UICollectionViewFlowLayout()
        let size = ceil(UIScreen.main.bounds.size.width / 3.0) - 2
        flowLayout.itemSize = CGSize(width: size, height: size)
        flowLayout.estimatedItemSize = CGSize(width: size, height: size)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 1
        flowLayout.sectionInset = UIEdgeInsets(top: 2, left: 1, bottom: 1, right: 1)
        let v = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var inputTextViewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "TMN Chatbot"
        self.view.backgroundColor = UIColor.white
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        self.setupViews()
        
        resetCachedAssets()
        PHPhotoLibrary.shared().register(self)
        
        if fetchResult == nil {
            let allPhotosOptions = PHFetchOptions()
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
        }
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let date24 = dateFormatter.string(from: date)
        
        self.items.append(MyMessage(systemMessageType1: String(format: "Chat Initiated %@", date24)))
        self.tableView.reloadData()
        self.tableView.scrollToBottom()
        self.getAnnouncementMessage()
        self.setupSaleForcesNotification()
        
        self.switchToAgentMode()
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let scale = UIScreen.main.scale
        let cellSize = (imagePanelView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCachedAssets()
    }
    
    func setupViews() {
        self.view.addSubview(tableView)
        tableView.MyEdges([.left, .right, .top], to: self.view, offset: .zero)
        tableView.backgroundColor = UIColor(MyHexString: "#FFFFFF")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CellIds.receiverCellId)
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CellIds.senderCellId)
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CellIds.receiverMenuCellid)
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CellIds.systemMessageCellId)
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CellIds.systemMessageType2CellId)
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CellIds.imageMessageCellId)
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CellIds.agentJoinCellId)
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tableViewTapped(recognizer:))))
        
        self.view.addSubview(inputTextView)
        inputTextView.MyEdges([.left, .right], to: self.view, offset: .zero)
        if #available(iOS 11.0, *) {
            inputTextViewBottomConstraint = inputTextView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        } else {
            // TODO
        }
        inputTextViewBottomConstraint.isActive = true
        inputTextView.topAnchor.constraint(equalTo: tableView.bottomAnchor).isActive = true
        inputTextView.delegate = self
        
        self.view.addSubview(imagePanelView)
        imagePanelView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        imagePanelView.backgroundColor = UIColor(MyHexString: "#EBEBEB")
        imagePanelView.delegate = self
        imagePanelView.dataSource = self
        imagePanelView.register(GridViewCell.self, forCellWithReuseIdentifier: String(describing: GridViewCell.self))
    }
    
    @objc func keyboardWillShow(notification:NSNotification){
        let userInfo = notification.userInfo!
        if var keyboardFrame  = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, let keyboardAnimationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval {
            keyboardFrame = self.view.convert(keyboardFrame, from: nil)
            let oldOffset = self.tableView.contentOffset
            self.inputTextViewBottomConstraint.constant = -keyboardFrame.height + bottomHeight
            UIView.animate(withDuration: keyboardAnimationDuration) {
                self.view.layoutIfNeeded()
                self.tableView.setContentOffset(CGPoint(x: oldOffset.x, y: oldOffset.y + keyboardFrame.height - self.bottomHeight), animated: false)
            }
        }
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        let userInfo = notification.userInfo!
        if var keyboardFrame  = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, let keyboardAnimationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval, let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt {
            keyboardFrame = self.view.convert(keyboardFrame, from: nil)
            self.inputTextViewBottomConstraint.constant = 0
            let oldOffset = self.tableView.contentOffset
            UIView.animate(withDuration: keyboardAnimationDuration, delay: 0, options: UIView.AnimationOptions(rawValue: curve), animations: {
                self.view.layoutIfNeeded()
                self.tableView.setContentOffset(CGPoint(x: oldOffset.x, y: oldOffset.y - keyboardFrame.height + self.bottomHeight), animated: false)
            }, completion: nil)
        }
    }
    
    @objc func tableViewTapped(recognizer: UITapGestureRecognizer) {
        if (imagePanel) {
            self.hideImagePanel()
        }
        self.inputTextView.textView.resignFirstResponder()
    }
}

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.items[indexPath.section]
        let agent = item.agent
        
        var cellIdentifierId:String
        switch item.kind {
        case .systemMessageType1( _):
            cellIdentifierId = CellIds.systemMessageCellId
        case .systemMessageType2( _):
            cellIdentifierId = CellIds.systemMessageType2CellId
        case .text( _):
            cellIdentifierId = agent ? CellIds.receiverCellId : CellIds.senderCellId
        case .menu( _, _):
            cellIdentifierId = CellIds.receiverMenuCellid
        case .image( _):
            cellIdentifierId = CellIds.imageMessageCellId
        case .agentJoin:
            cellIdentifierId = CellIds.agentJoinCellId
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifierId, for: indexPath) as? CustomTableViewCell {
            cell.selectionStyle = .none
           
            switch item.kind {
            case .systemMessageType1(let txt):
                cell.renderSystemMessage(text: txt)
            case .systemMessageType2(let txt):
                cell.renderSystemMessageType2(text: txt)
            case .text(let txt):
                cell.textView.text = txt
            case .menu(let title, let menus):
                cell.setupMenuCell(title, menus)
                let gesture = cell.tapGuesture ?? MyTapGuesture(target: self, action: #selector(didTap(_:)))
                gesture.message = item
                cell.addGestureRecognizer(gesture)
            case .image(let img):
                cell.renderImageCell(image: img)
            case .agentJoin:
                cell.renderAgentJoin()
            }
            return cell
        }
        return UITableViewCell()
    }
    
    @objc func didTap(_ sender: MyTapGuesture? = nil) {
        print("Tab")
        let message = sender?.message
        switch message?.kind {
        case .text( _):
            return
        case .menu(let title, let menus):
            if sender?.state == .ended {
                let touchLocation: CGPoint = (sender?.location(in: sender?.view))!
                findMenuOnTap(menus: menus, title: title, yPosition: touchLocation.y)
            }
            
        default:
            return
        }
    }
    
    fileprivate func findMenuOnTap(menus:[[String: Any]], title:String, yPosition:CGFloat) {
        print("yPosition", yPosition)
        
        let defaultLabel = UILabel()
        defaultLabel.font = UIFont.systemFont(ofSize: 16.0)
        let height = title.MyHeight(withConstrainedWidth: 300.0, font: defaultLabel.font)
        var headerHeight = max(height, CGFloat(menuHeight))
        if Int(headerHeight) > Int(menuHeight) {
            headerHeight = headerHeight + 20
        }
        
        print("header height", headerHeight)
        
        var yIndex = CGFloat(0.0)
        
        var targetAction:[String:Any]? = nil
        for i in 0..<menus.count {
            let item = menus[i]
            let actions = item["action"] as! [String:Any]
            let labelText = actions["label"] as? String ?? ""
            
            let height = labelText.MyHeight(withConstrainedWidth: 300.0, font: defaultLabel.font)
            var setHeight = max(height, CGFloat(menuHeight))
            setHeight = setHeight + 20
            
            print("yIndex" , yIndex)
            if (yPosition >= (yIndex + headerHeight)) {
                targetAction = actions
            }
            
            yIndex = yIndex + setHeight
        }
        
        if (targetAction != nil) {
            let text = targetAction?["text"] as? String ?? ""
            if (text.count > 0) {
                self.items.append(MyMessage(text: text, agent: false))
                self.tableView.reloadData()
                self.tableView.scrollToBottom()
                self.sendPost(text: text)
            }
        }
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let item = self.items[indexPath.section]

        switch item.kind {
        case .systemMessageType1(let txt):
            return CustomTableViewCell.calcRowHeightSystemMessage(text: txt)
        case .systemMessageType2(let txt):
            return CustomTableViewCell.calcRowHeightSystemMessageType2(text: txt)
        case .text( _):
            return UITableView.automaticDimension
        case .menu(let title, let menus):
            return CustomTableViewCell.calcMenuCellHeight(title, menus) - 7.0
        case .image(let image):
            return CustomTableViewCell.calcImageCellHeight(image)
        case .agentJoin:
            return CustomTableViewCell.calcAgentJoinCellHeight()
        }
    }
}

extension UITableView {

    func scrollToBottom(){

        DispatchQueue.main.async {
            let indexPath = IndexPath(
                row: self.numberOfRows(inSection:  self.numberOfSections-1) - 1,
                section: self.numberOfSections - 1)
            if self.hasRowAtIndexPath(indexPath: indexPath) {
                self.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }

    func scrollToTop() {

        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: 0)
            if self.hasRowAtIndexPath(indexPath: indexPath) {
                self.scrollToRow(at: indexPath, at: .top, animated: false)
           }
        }
    }

    func hasRowAtIndexPath(indexPath: IndexPath) -> Bool {
        return indexPath.section < self.numberOfSections && indexPath.row < self.numberOfRows(inSection: indexPath.section)
    }
}

extension ViewController: InputTextViewDelegate {
    
    func inputTextViewGotFocus(_ textView: UITextView) {
        self.hideImagePanel()
    }
    
    func didPressSendButton(_ text: String, _ sender: UIButton, _ textView: UITextView) {
        print(text)
        if (text.trimmingCharacters(in: .whitespacesAndNewlines).count > 0) {
            self.items.append(MyMessage(text: text, agent: false))
            self.tableView.reloadData()
            self.tableView.scrollToBottom()
            textView.text = ""
            
            if (MINTEL_LiveChat.chatBotMode) {
                self.sendPost(text: text)
            } else {
                self.sendMessageToSaleForce(text: text)
            }
        }
    }
    
    func didPressFirstLeftButton(_ sender: UIButton, _ textView: UITextView) {
        if (imagePanel) {
            sender.setImage(UIImage(named: "image", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil), for: .normal)
            inputTextView.hideLeftMenu()
            textView.becomeFirstResponder()
            self.hideImagePanel()
        }
    }
    
    func didPressSecondLeftButton(_ sender: UIButton, _ textView: UITextView) {
         guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            checkCameraAccess()
            return
        }
        selectImageFrom(.camera)
    }
    
    func checkCameraAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied:
            print("Denied, request permission from settings")
            presentCameraSettings()
        case .restricted:
            print("Restricted, device owner must approve")
        case .authorized:
            print("Authorized, proceed")
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { success in
                if success {
                    print("Permission granted, proceed")
                } else {
                    print("Permission denied")
                }
            }
        }
    }

    func presentCameraSettings() {
        let alertController = UIAlertController(title: "Error",
                                      message: "Camera access is denied",
                                      preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        alertController.addAction(UIAlertAction(title: "Settings", style: .cancel) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                    // Handle
                })
            }
        })

        present(alertController, animated: true)
    }
    
    func presentPhotoSetting() {
        let alertController = UIAlertController(title: "Error",
                                      message: "Photo Library access is denied",
                                      preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        alertController.addAction(UIAlertAction(title: "Settings", style: .cancel) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                    // Handle
                })
            }
        })

        present(alertController, animated: true)
    }
    
    func didPressThirdLeftButton(_ sender: UIButton, _ textView: UITextView) {
        if (imagePanel) {
            sender.setImage(UIImage(named: "image", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil), for: .normal)
            self.hideImagePanel()
        } else {
            sender.setImage(UIImage(named: "image_active", in: Bundle(for: MINTEL_LiveChat.self), compatibleWith: nil), for: .normal)
            self.showImagePanel()
        }
    }
    
    func didPressFourthLeftButton(_ sender: UIButton, _ textView: UITextView) {
        
        self.hideImagePanel()
        
        let importMenu = UIDocumentPickerViewController(documentTypes: ["com.apple.iwork.pages.pages", "com.apple.iwork.numbers.numbers", "com.apple.iwork.keynote.key","public.image", "com.apple.application", "public.item", "public.content", "public.audiovisual-content", "public.movie", "public.audiovisual-content", "public.video", "public.audio", "public.text", "public.data", "public.zip-archive", "com.pkware.zip-archive", "public.composite-content"], in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        importMenu.modalPresentationStyle = .fullScreen
        self.present(importMenu, animated: true, completion: nil)

        
//        if FileManager.default.fileExists(atPath: url.path){
//
//            let filename = (url.absoluteString as NSString).lastPathComponent
//            self.insertMessage(MockMessage(text: filename, user: ChatViewController.user, messageId: UUID().uuidString, date: Date()))
//
//            do {
//                // Get the saved data
//                let savedData = try Data(contentsOf: url)
//                // Convert the data back into a string
//                self.upload(imageData: nil, imageName: nil, fileData: savedData, fileName: filename, parameters: ["session_id": MINTEL_LiveChat.userId])
//            } catch {
//             // Catch any errors
//             print("Unable to read the file")
//            }
//        }

    }
    
    func showImagePanel() {
        self.inputTextView.textView.resignFirstResponder()
        self.imagePanel = true
        let keyboardFrame = CGSize(width: 0, height: imagePanelHeight)
        self.inputTextViewBottomConstraint.constant = -180.0
        let oldOffset = self.tableView.contentOffset
        self.imagePanelView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height - imagePanelHeight, width: UIScreen.main.bounds.size.width, height: 180.0)
        self.view.layoutIfNeeded()
        self.tableView.setContentOffset(CGPoint(x: oldOffset.x, y: oldOffset.y + keyboardFrame.height - self.bottomHeight), animated: false)
    }
    
    func hideImagePanel() {
        self.imagePanel = false
        self.inputTextView.hideLeftMenu()
        let keyboardFrame = CGSize(width: 0.0, height: 0.0)
        self.inputTextViewBottomConstraint.constant = 0
        let oldOffset = self.tableView.contentOffset
        self.imagePanelView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: 180.0)
        self.view.layoutIfNeeded()
        self.tableView.setContentOffset(CGPoint(x: oldOffset.x, y: oldOffset.y - keyboardFrame.height + self.bottomHeight), animated: false)
        self.inputTextView.becomeFirstResponder()
    }
}

extension ViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    enum ImageSource {
        case photoLibrary
        case camera
    }
    
    func selectImageFrom(_ source: ImageSource){
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        switch source {
        case .camera:
            imagePicker.sourceType = .camera
        case .photoLibrary:
            imagePicker.sourceType = .photoLibrary
        }
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        imagePicker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }
//        imageTake.image = selectedImage
    }
}


extension ViewController : UIDocumentMenuDelegate, UIDocumentPickerDelegate {
    func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
    }
    
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        self.documentPicker(url: url)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if urls.count > 0 {
            self.documentPicker(url: urls[0])
        }
    }
    
    private func documentPicker(url: URL) {
        debugPrint(url)
        
        if FileManager.default.fileExists(atPath: url.path){
            
            let filename = (url.absoluteString as NSString).lastPathComponent
            self.items.append(MyMessage(text: filename, agent: false))
            self.tableView.reloadData()
            self.tableView.scrollToBottom()
            do {
                // Get the saved data
                let savedData = try Data(contentsOf: url)
                // Convert the data back into a string
                self.upload(imageData: nil, imageName: nil, fileData: savedData, fileName: filename, parameters: ["session_id": "1"])
            } catch {
             // Catch any errors
             print("Unable to read the file")
            }
        }
    }
}

// Agent Mode


extension ViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = fetchResult.object(at: indexPath.item)
        
        // Dequeue a GridViewCell.
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: GridViewCell.self), for: indexPath) as? GridViewCell
           else { fatalError("unexpected cell in collection view") }

        // Add a badge to the cell if the PHAsset represents a Live Photo.
        if asset.mediaSubtypes.contains(.photoLive) {
           cell.livePhotoBadgeImage = PHLivePhotoView.livePhotoBadgeImage(options: .overContent)
        }
        
        // Request an image for the asset from the PHCachingImageManager.
        cell.representedAssetIdentifier = asset.localIdentifier
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
           // The cell may have been recycled by the time this handler gets called;
           // set the cell's thumbnail image only if it's still showing the same asset.
           if cell.representedAssetIdentifier == asset.localIdentifier {
               cell.thumbnailImage = image
           }
        })

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = fetchResult.object(at: indexPath.item)
        print("Did Image")
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil) { (image, info) in
            let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
            if isDegraded {
               return
            }
            
            if (image != nil) {
                
                let fileName = "file.jpeg"
                let data = image!.jpegData(compressionQuality: 1.0)
                self.items.append(MyMessage(image: image!))
                self.tableView.reloadData()
                self.tableView.scrollToBottom()
                self.upload(imageData: data, imageName: fileName, fileData: nil, fileName: nil, parameters: ["session_id": "1"])
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCachedAssets()
    }
    
    fileprivate func resetCachedAssets() {
       imageManager.stopCachingImagesForAllAssets()
       previousPreheatRect = .zero
    }
    
    fileprivate func updateCachedAssets() {
       // Update only if the view is visible.
       guard isViewLoaded && view.window != nil else { return }

       // The preheat window is twice the height of the visible rect.
        let visibleRect = CGRect(origin: imagePanelView.contentOffset, size: imagePanelView.bounds.size)
       let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)

       // Update only if the visible area is significantly different from the last preheated area.
       let delta = abs(preheatRect.midY - previousPreheatRect.midY)
       guard delta > view.bounds.height / 3 else { return }

       // Compute the assets to start caching and to stop caching.
       let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
       let addedAssets = addedRects
        .flatMap { rect in self.imagePanelView.indexPathsForElements(in: rect) }
           .map { indexPath in fetchResult.object(at: indexPath.item) }
       let removedAssets = removedRects
        .flatMap { rect in self.imagePanelView.indexPathsForElements(in: rect) }
           .map { indexPath in fetchResult.object(at: indexPath.item) }

       // Update the assets the PHCachingImageManager is caching.
       imageManager.startCachingImages(for: addedAssets,
           targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
       imageManager.stopCachingImages(for: removedAssets,
           targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)

       // Store the preheat rect to compare against in the future.
       previousPreheatRect = preheatRect
    }

    fileprivate func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
       if old.intersects(new) {
           var added = [CGRect]()
           if new.maxY > old.maxY {
               added += [CGRect(x: new.origin.x, y: old.maxY,
                                   width: new.width, height: new.maxY - old.maxY)]
           }
           if old.minY > new.minY {
               added += [CGRect(x: new.origin.x, y: new.minY,
                                   width: new.width, height: old.minY - new.minY)]
           }
           var removed = [CGRect]()
           if new.maxY < old.maxY {
               removed += [CGRect(x: new.origin.x, y: new.maxY,
                                     width: new.width, height: old.maxY - new.maxY)]
           }
           if old.minY < new.minY {
               removed += [CGRect(x: new.origin.x, y: old.minY,
                                     width: new.width, height: new.minY - old.minY)]
           }
           return (added, removed)
       } else {
           return ([new], [old])
       }
    }
    
}

private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}

extension ViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
 
        guard let changes = changeInstance.changeDetails(for: fetchResult)
            else { return }
 
        // Change notifications may be made on a background queue. Re-dispatch to the
        // main queue before acting on the change as we'll be updating the UI.
        DispatchQueue.main.sync {
            // Hang on to the new fetch result.
            fetchResult = changes.fetchResultAfterChanges
            if changes.hasIncrementalChanges {
                // If we have incremental diffs, animate them in the collection view.
                self.imagePanelView.performBatchUpdates({
                    // For indexes to make sense, updates must be in this order:
                    // delete, insert, reload, move
                    if let removed = changes.removedIndexes, removed.count > 0 {
                        self.imagePanelView.deleteItems(at: removed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    if let inserted = changes.insertedIndexes, inserted.count > 0 {
                        self.imagePanelView.insertItems(at: inserted.map({ IndexPath(item: $0, section: 0) }))
                    }
                    if let changed = changes.changedIndexes, changed.count > 0 {
                        self.imagePanelView.reloadItems(at: changed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    changes.enumerateMoves { fromIndex, toIndex in
                        self.imagePanelView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                to: IndexPath(item: toIndex, section: 0))
                    }
                })
            } else {
                // Reload the collection view if incremental diffs are not available.
                self.imagePanelView.reloadData()
            }
            resetCachedAssets()
        }
    }
}
