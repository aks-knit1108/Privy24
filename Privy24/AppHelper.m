//
//  AppHelper.m
//  Privy24
//
//  Created by Amit on 8/27/15.
//  Copyright (c) 2015 BrightZone. All rights reserved.
//

#import "AppHelper.h"
#import "constants.h"

@implementation AppHelper

+ (void) showAlert:(NSString *)title withMessage:(NSString *)msg {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

+ (UIColor *) colorFromHexColor: (NSString *) hexString {
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#" withString: @""] uppercaseString];
    CGFloat alpha, red, blue, green;
    alpha = 1.0f;
    red   = [self colorComponentFrom: colorString start: 0 length: 2];
    green = [self colorComponentFrom: colorString start: 2 length: 2];
    blue  = [self colorComponentFrom: colorString start: 4 length: 2];
    return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
}


+ (CGFloat) colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length {
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}


+ (NSMutableArray *)getAllCountries {

    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"PhoneCountries" ofType:@"txt"];
    NSData *stringData = [NSData dataWithContentsOfFile:filePath];
    NSString *data = nil;
    if (stringData != nil)
        data = [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
    
    if (data == nil)
        return nil;
    
    NSString *delimiter = @";";
    NSString *endOfLine = @"\n";
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    int currentLocation = 0;
    
    while (true)
    {
        NSRange codeRange = [data rangeOfString:delimiter options:0 range:NSMakeRange(currentLocation, data.length - currentLocation)];
        if (codeRange.location == NSNotFound)
            break;
        
        int countryCode = [[data substringWithRange:NSMakeRange(currentLocation, codeRange.location - currentLocation)] intValue];
        
        NSRange idRange = [data rangeOfString:delimiter options:0 range:NSMakeRange(codeRange.location + 1, data.length - (codeRange.location + 1))];
        if (idRange.location == NSNotFound)
            break;
        
        NSString *countryId = [[data substringWithRange:NSMakeRange(codeRange.location + 1, idRange.location - (codeRange.location + 1))] lowercaseString];
        
        NSRange nameRange = [data rangeOfString:endOfLine options:0 range:NSMakeRange(idRange.location + 1, data.length - (idRange.location + 1))];
        if (nameRange.location == NSNotFound)
            nameRange = NSMakeRange(data.length, INT_MAX);
        
        NSString *countryName = [data substringWithRange:NSMakeRange(idRange.location + 1, nameRange.location - (idRange.location + 1))];
        if ([countryName hasSuffix:@"\r"])
            countryName = [countryName substringToIndex:countryName.length - 1];
        
        [array addObject:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:countryCode], countryId, countryName, nil]];
        //TGLog(@"%d, %@, %@", countryCode, countryId, countryName);
        
        currentLocation = nameRange.location + nameRange.length;
        if (nameRange.length > 1)
            break;
    }
    
    return array;
}

#pragma mark -
#pragma mark  Navigation Utilites

// Add activity indicator on rightnavbar
+(void) addActivityToNavBar: (UIViewController *) viewController {

    // Set spinner..
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    activityIndicator.color = kAPP_COLOR;
    UIBarButtonItem * barButton =
    [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    [[viewController navigationItem] setRightBarButtonItem:barButton];
    [activityIndicator startAnimating];
}


+(void) addRightBarButtonToNavBar: (UIViewController *) viewController withText:(NSString *)theText action:(SEL)theActionToPerform{
    
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:theText style:UIBarButtonItemStylePlain target:viewController action:theActionToPerform];
    rightBarButtonItem.tintColor = kAPP_COLOR;
    viewController.navigationItem.rightBarButtonItem = rightBarButtonItem;
}


+(long int)utcTimeStamp:(NSDate *)date {
    return lround(floor([date timeIntervalSince1970]*1000));
}

+ (NSString *)utcStringFromDate:(NSDate *)date {
    
    double milliseconds = [self utcTimeStamp:date];
    //NSLog(@"milliseconds = %f",milliseconds);
    NSString *intervalString = [NSString stringWithFormat:@"%ld", (NSInteger)milliseconds];
    
    return intervalString;
}


+ (NSDate *)utcDateFromTimeStamp:(NSString *)input {
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:([input doubleValue] / 1000)];
    
    return date;
    
}

+ (NSDate *)localDateFromUtcDate:(NSDate *)someDateInUTC {
    
    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate: someDateInUTC];
    return [NSDate dateWithTimeInterval: seconds sinceDate: someDateInUTC];
    
}

+ (NSString *)currentDate {
    
    double milliseconds = [self utcTimeStamp:[NSDate date]];
    NSString *intervalString = [NSString stringWithFormat:@"%ld", (NSInteger)milliseconds];
    
    return intervalString;
}

+ (NSString *)addInterval:(NSTimeInterval)interval withDate:(NSDate *)date {
    
    NSDate *newDate = [date dateByAddingTimeInterval:interval];
    double milliseconds = [self utcTimeStamp:newDate];
    NSString *intervalString = [NSString stringWithFormat:@"%ld", (NSInteger)milliseconds];
    
    return intervalString;
}



@end
