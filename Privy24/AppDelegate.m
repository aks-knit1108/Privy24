//
//  AppDelegate.m
//  Privy24
//
//  Created by Amit on 8/27/15.
//  Copyright (c) 2015 BrightZone. All rights reserved.
//

#import "AppDelegate.h"
#import "DBManager.h"
#import "constants.h"
#import "SocketLisner.h"
#import "Reachability.h"
#import "Chat.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
   
    [[UITableView appearance] setTintColor:kAPP_COLOR];
    [[UINavigationBar appearance] setTintColor:kAPP_COLOR];
    [[UITabBar appearance] setTintColor:kAPP_COLOR];
    
    //Change the host name here to change the server you want to monitor.
    NSString *remoteHostName = @"www.apple.com";
    
    
    self.reachability = [Reachability reachabilityWithHostName:remoteHostName];
    [self.reachability startNotifier];

    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kPUSH_TOKEN]) {
        self.pushToken = [[NSUserDefaults standardUserDefaults] objectForKey:kPUSH_TOKEN];
    } else {
        self.pushToken = @"";
    }
    
    // Let the device know we want to receive push notifications
    // Register for Push Notitications, if running on iOS 8
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
    
    // Check user registartion status
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kUSER_MOBILE_NUMBER]) {
       
        NSString *mobile = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:kUSER_MOBILE_NUMBER]];
        
        Person *person = [Person fetchUserForId:mobile];
        
        // If user is alerady registed then open chat screen
        [self openChatScreenWithUser:person andSelectedTab:2];
    }
    
    
    //Remote notification info
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    NSDictionary *remoteNotifiInfo = [launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
    
    //Accept push notification when app is not open
//    if (remoteNotifiInfo) {
//        [self handleRemoteNotifications:remoteNotifiInfo];
//    }
    
    
    [[UIApplication sharedApplication]
     setMinimumBackgroundFetchInterval:
     UIApplicationBackgroundFetchIntervalMinimum];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    //[[SocketLisner sharedLisner] disconnect];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [self openLock:LockScreenModeNormal];    
    [[SocketLisner sharedLisner] reconnect];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    
}


- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    // Prepare the Device Token for Registration (remove spaces and < >)
    NSString *devToken = [[[[deviceToken description]
                            stringByReplacingOccurrencesOfString:@"<"withString:@""]
                           stringByReplacingOccurrencesOfString:@">" withString:@""]
                          stringByReplacingOccurrencesOfString: @" " withString: @""];
    NSLog(@"My token is: %@", devToken);
    
    self.pushToken = devToken;
    [[NSUserDefaults standardUserDefaults] setObject:devToken forKey:kPUSH_TOKEN];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {

    [self handleRemoteNotifications:userInfo];
    
    //Success
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {

    [self handleRemoteNotifications:userInfo];
}

#pragma mark - Remote notifications handling

-(void)handleRemoteNotifications:(NSDictionary *)userInfo {
    // do your stuff
    
    
}

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    completionHandler(UIBackgroundFetchResultNewData);
    
}

-(void) beginBackgroundUploadTask
{
    if(self.bgTaskIdentifier != UIBackgroundTaskInvalid)
    {
        [self endBackgroundUploadTask];
    }
    
    self.bgTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        
        [self endBackgroundUploadTask];
        
    }];
}

-(void) endBackgroundUploadTask
{
    [[UIApplication sharedApplication] endBackgroundTask:self.bgTaskIdentifier ];
    self. bgTaskIdentifier = UIBackgroundTaskInvalid;
}

#pragma mark - Helper methods

- (void)openChatScreenWithUser:(Person *)person andSelectedTab:(NSInteger)index {

    // Connect socket firtst time..
    [[SocketLisner sharedLisner] setUser:person];
    [[SocketLisner sharedLisner] connect];
    
    NSString *url = [kBaseUrl stringByAppendingString:@"/saveToken"];
    NSDictionary *param = @{@"mobile":person.mobile,@"token":self.pushToken,@"type":@"ios"};
    
    // Post device token here..
    [[ConnectionManager sharedManager] postRequest:url parameters:param  success:^(id responseObject) {
        
        NSError *error = nil;
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                     options:kNilOptions
                                                                       error:&error];
        
        NSLog(@"JSON: %@", jsonResponse);
        
        
    } failure:^(NSError *error) {
        
    }];
    
    
    // Save user mobile number locally for future use
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kUSER_MOBILE_NUMBER]) {
        [[NSUserDefaults standardUserDefaults] setObject:person.mobile forKey:kUSER_MOBILE_NUMBER];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    // Set Chat storyboard
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Chat" bundle: nil];
    UITabBarController *tabBarController = [storyboard instantiateViewControllerWithIdentifier:@"sid_tabBarController"];
    tabBarController.selectedIndex = index;
    [self.window setRootViewController:tabBarController];
    self.tabBarController = tabBarController;
    
    [[ContactManager sharedManager] fetchContacts];
}


#pragma mark -
#pragma mark YMDLockScreenViewControllerDelegate
- (void)unlockWasCancelledLockScreenViewController:(JKLLockScreenViewController *)lockScreenViewController {
    
    NSLog(@"LockScreenViewController dismiss because of cancel");
}

- (void)unlockWasSuccessfulLockScreenViewController:(JKLLockScreenViewController *)lockScreenViewController pincode:(NSString *)pincode {
    
}

#pragma mark -
#pragma mark YMDLockScreenViewControllerDataSource
- (BOOL)lockScreenViewController:(JKLLockScreenViewController *)lockScreenViewController pincode:(NSString *)pincode {
    
    NSString *pin = [[NSUserDefaults standardUserDefaults] objectForKey:kMOBILE_PASS_CODE];
    return [pin isEqualToString:pincode];
    
}

- (BOOL)allowTouchIDLockScreenViewController:(JKLLockScreenViewController *)lockScreenViewController {
    
    return YES;
}


- (void)openLock:(LockScreenMode)mode {
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kMOBILE_PASS_CODE]) {
        
        JKLLockScreenViewController * viewController = [[JKLLockScreenViewController alloc] initWithNibName:NSStringFromClass([JKLLockScreenViewController class]) bundle:nil];
        [viewController setLockScreenMode:mode];
        [viewController setDelegate:self];
        [viewController setDataSource:self];
        
        UIViewController *controller = [self.window visibleViewController];
        if (![controller isKindOfClass:[JKLLockScreenViewController class]]) {
            [controller presentViewController:viewController animated:mode!=LockScreenModeNormal completion:NULL];
        }

    }
    
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

@end
