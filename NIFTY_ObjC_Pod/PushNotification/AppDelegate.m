//
//  AppDelegate.m
//  PushNotification
//
//  Created by KentarOu on 2016/01/30.
//  Copyright © 2016年 KentarOu. All rights reserved.
//

#import "AppDelegate.h"
#import <NCMB/NCMB.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    #warning アプリケーションキーとクライアントキーを設定
    [NCMB setApplicationKey:@"アプリケーションキー" clientKey:@"クライアントキー"];
    
    // データストアにオブジェクトを保存するサンプル
    
    NCMBQuery *query = [NCMBQuery queryWithClassName:@"TestClass"];
    [query whereKey:@"message" equalTo:@"test"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error == nil) {
            if ([objects count] > 0) {
                NSLog(@"[FIND] %@", [[objects objectAtIndex:0] objectForKey:@"message"]);
            } else {
                NSError *saveError = nil;
                NCMBObject *obj = [NCMBObject objectWithClassName:@"TestClass"];
                [obj setObject:@"Hello, NCMB!" forKey:@"message"];
                [obj save:&saveError];
                if (saveError == nil) {
                    NSLog(@"[SAVE] Done");
                } else {
                    NSLog(@"[SAVE-ERROR] %@", saveError);
                }
            }
        } else {
            NSLog(@"[ERROR] %@", error);
        }
    }];
    
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1){
        
        //iOS8以上での、DeviceToken要求方法
        
        //通知のタイプを設定したsettingを用意
        UIUserNotificationType type = UIUserNotificationTypeAlert |
        UIUserNotificationTypeBadge |
        UIUserNotificationTypeSound;
        UIUserNotificationSettings *setting;
        setting = [UIUserNotificationSettings settingsForTypes:type
                                                    categories:nil];
        
        //通知のタイプを設定
        [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
        
        //DevoceTokenを要求
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        
        //iOS8未満での、DeviceToken要求方法
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeAlert |
          UIRemoteNotificationTypeBadge |
          UIRemoteNotificationTypeSound)];
    }
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    //端末情報を扱うNCMBInstallationのインスタンスを作成
    NCMBInstallation *installation = [NCMBInstallation currentInstallation];
    
    //Device Tokenを設定
    [installation setDeviceTokenFromData:deviceToken];
    
    //端末情報をデータストアに登録
    [installation saveInBackgroundWithBlock:^(NSError *error) {
        if(!error){
            //端末情報の登録が成功した場合の処理
        } else {
            //端末情報の登録が失敗した場合の処理
        }
    }];
}


// deviceTokenの重複で端末情報の登録に失敗した場合に上書き処理を行う
- (void)updateExistInstallation:(NCMBInstallation*) currentInstallation {
    NCMBQuery *installationQuery = [NCMBInstallation query];
    [installationQuery whereKey:@"deviceToken" equalTo:currentInstallation.deviceToken];
    
    NSError *searchErr = nil;
    NCMBInstallation *searchDevice = [installationQuery getFirstObject:&searchErr];
    
    if (!searchErr){
        //上書き保存する
        currentInstallation.objectId = searchDevice.objectId;
        [currentInstallation saveInBackgroundWithBlock:^(NSError *error) {
            if (!error){
                //端末情報更新に成功したときの処理
            } else {
                //端末情報更新に失敗したときの処理
            }
        }];
    } else {
        //端末情報の検索に失敗した場合の処理
    }
}

@end
