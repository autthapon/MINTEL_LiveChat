//
//  MINTEL_Notifications.swift
//  MINTEL_LiveChat
//
//  Created by Autthapon Sukjaroen on 27/8/2563 BE.
//

import Foundation

import Foundation
import UserNotifications

public class MINTEL_Notifications: NSObject, UNUserNotificationCenterDelegate {
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    public func userRequest() {
        
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        notificationCenter.requestAuthorization(options: options) {
            (didAllow, error) in
            if !didAllow {
                print("User has declined notifications")
            }
        }
        
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) {
//            (granted, error) in
//            if granted {
//                print("yes")
//            } else {
//                print("No")
//            }
//        }
//
//        let content = UNMutableNotificationContent()
//        content.title = "Notification Tutorial"
//        content.subtitle = "from ioscreator.com"
//        content.body = " Notification triggered"
//
//        let request = UNNotificationRequest(identifier: "notification.id.01", content: content, trigger: nil)
//        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func scheduleNotification(message: String) {
        
        let content = UNMutableNotificationContent()
//        let userActions = "MINTEL_LiveChat"
        
        content.title = "ทรูมันนี่"
        content.body = message
        content.sound = UNNotificationSound.default
        content.badge = 0
//        content.categoryIdentifier = userActions
        
        let identifier = UUID().uuidString
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
        
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.sound])
    }
    
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                willPresent notification: UNNotification,
//                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//
//        completionHandler([.alert,.sound])
//    }
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                didReceive response: UNNotificationResponse,
//                                withCompletionHandler completionHandler: @escaping () -> Void) {
//
//        if response.notification.request.identifier == "MINTEL_LiveChat Local Notification" {
//            print("Handling notifications with the Local Notification Identifier")
//        }
//
//        switch response.actionIdentifier {
//        case UNNotificationDismissActionIdentifier:
//            print("Dismiss Action")
//        case UNNotificationDefaultActionIdentifier:
//            print("Default")
//        case "Snooze":
//            print("Snooze")
////            scheduleNotification(notificationType: "sdfd")
//        case "Delete":
//            print("Delete")
//        default:
//            print("Unknown action")
//        }
//        completionHandler()
//    }
}


