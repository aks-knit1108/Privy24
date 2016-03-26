//
//  AppHelper.h
//  Privy24
//
//  Created by Amit on 8/27/15.
//  Copyright (c) 2015 BrightZone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AppHelper : NSObject
+ (void) showAlert:(NSString *)title withMessage:(NSString *)msg;
+ (UIColor *) colorFromHexColor: (NSString *) hexColor;
+ (NSMutableArray *)getAllCountries;

//Navigation helpers
+(void) addActivityToNavBar: (UIViewController *) viewController;
+(void) addRightBarButtonToNavBar: (UIViewController *) viewController withText:(NSString *)theText action:(SEL)theActionToPerform;

+ (long int)utcTimeStamp:(NSDate *)date; //full seconds since
+ (NSString *)utcStringFromDate:(NSDate *)date;
+ (NSDate *)utcDateFromTimeStamp:(NSString *)input;
+ (NSDate *)localDateFromUtcDate:(NSDate *)someDateInUTC;
+ (NSString *)currentDate;
+ (NSString *)addInterval:(NSTimeInterval)interval withDate:(NSDate *)date;

@end
