//
//  AppDelegate.h
//  Privy24
//
//  Created by Amit on 8/27/15.
//  Copyright (c) 2015 BrightZone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JKLLockScreenViewController.h"
#import "UIWindow+PazLabs.h"


//openssl pkcs12 -in apns-dev-cert.p12 -out apns-dev-cert.pem -nodes -clcerts

@class SocketIOClient;
@class Person;
@class DBManager;
@class Reachability;

@interface AppDelegate : UIResponder <UIApplicationDelegate,JKLLockScreenViewControllerDataSource,JKLLockScreenViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (strong, nonatomic) NSString *pushToken;
@property (nonatomic) Reachability *reachability;
@property  UIBackgroundTaskIdentifier bgTaskIdentifier;

- (void)openChatScreenWithUser:(Person *)person andSelectedTab:(NSInteger)index;

@end

