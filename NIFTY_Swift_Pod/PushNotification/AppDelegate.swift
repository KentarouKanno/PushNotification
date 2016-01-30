//
//  AppDelegate.swift
//  PushNotification
//
//  Created by KentarOu on 2016/01/30.
//  Copyright © 2016年 KentarOu. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        NCMB.setApplicationKey("APPLICATION_KEY", clientKey: "CLIENT_KEY")
        
        if #available(iOS 8.0, *) {
            // iOS8.0以上
            let settings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories:nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
            
        } else {
            
            // iOS7以下
            let types:UIRemoteNotificationType = [.Badge, .Alert, .Sound]
            UIApplication.sharedApplication().registerForRemoteNotificationTypes(types)
        }
        
        // アプリ起動時のプッシュ通知受信
        if let remoteNotification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary {
            print("Remote Notification \(remoteNotification)")
        }
        
        return true
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = NCMBInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackgroundWithBlock { (error) -> Void in
            // Error!処理
        }
    }
    
    
    // Receive RemoteNotification
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print("User Info \(userInfo)")
        switch application.applicationState {
        case .Inactive:
            // アプリがバックグラウンドにいる状態で、Push通知から起動したとき
            break
        case .Active:
            // アプリ起動中にPush通知を受信
            break
        default:
            break
        }
    }
}

