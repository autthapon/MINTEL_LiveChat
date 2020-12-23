# MINTEL_LiveChat

[![CI Status](https://img.shields.io/travis/autthapon@gmail.com/MINTEL_LiveChat.svg?style=flat)](https://travis-ci.org/autthapon@gmail.com/MINTEL_LiveChat)
[![Version](https://img.shields.io/cocoapods/v/MINTEL_LiveChat.svg?style=flat)](https://cocoapods.org/pods/MINTEL_LiveChat)
[![License](https://img.shields.io/cocoapods/l/MINTEL_LiveChat.svg?style=flat)](https://cocoapods.org/pods/MINTEL_LiveChat)
[![Platform](https://img.shields.io/cocoapods/p/MINTEL_LiveChat.svg?style=flat)](https://cocoapods.org/pods/MINTEL_LiveChat)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

MINTEL_LiveChat is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'MINTEL_LiveChat'
```

## Author

autthapon@gmail.com, autthapon@gmail.com

## License

MINTEL_LiveChat is available under the MIT license. See the LICENSE file for more info.


## How To Use
1. I suggest you to new instance of MINTEL_LiveChat in Appdelegate to make sure that it has only one instance at a time. 
2. When you want to startChat please call. startChat(config) method 
3. config : 
```ruby
    internal var webHookBaseUrl:String!  --> ChatBot Url 
    internal var uploadBaseUrl:String!  --> Upload Url
    internal var xApikey:String!  --> Chatbot API Key
    internal var userName:String! --> User's name 
    internal var salesforceLiveAgentPod:String!  --> sale force live agent pod config
    internal var salesforceOrdID:String! --> sale force ord id config
    internal var salesforceDeployID:String! --> sale force deploy id 
    internal var salesforceButtonID:String! --> sale force button id 
    internal var surveyChatbotUrl:String? --> survey chat bot url (optional)
    internal var surveyFormUrl:String? --> survey form url (optional)
    internal var announcementUrl:String? --> chatbot announcement url 
    internal var firstname:String! --> firstname of saleforce chat entity 
    internal var lastname:String!  --> lastname of saleforce chat entity 
    internal var email:String!  --> email of saleforce chat entity 
    internal var phone:String!  --> phone of saleforce chat entity 
    internal var tmnId:String!  --> tmnid of saleforce chat entity 
    internal var salesforceFirst:Bool = false --> if you want go to saleforce immediately (default is chatbot)
```

4. you can stop the Chat , please call stopChat() 
5. you can hide the Chat , please call hideChat() (chat log is not cleared)
6. you can check SessionActive by call isSessionActive() 
7. please call applicationDidEnterBackground() in AppDelgate applicationDidEnterBackground function
8. please call applicationWillEnterForeground() in AppDelegate applicationWillEnterForeground function
9. please call userNotificationCenter( willPresent) in UNUserNotificationCenterDelegate.userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)


