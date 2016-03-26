//
//  constants.h
//  Privy24
//
//  Created by Amit on 8/27/15.
//  Copyright (c) 2015 BrightZone. All rights reserved.
//

#ifndef Privy24_constants_h
#define Privy24_constants_h


typedef NS_ENUM(NSInteger, MessageStatus)
{
    MessageStatusSending,
    MessageStatusSent,
    MessageStatusReceived,
    MessageStatusRead,
    MessageStatusFailed,
    
};

typedef NS_ENUM(NSInteger, AttachmentStatus)
{
    AttachmentStatusNone,
    AttachmentStatusError,
    AttachmentStatusUploading,
    AttachmentStatusUploaded,
    AttachmentStatusDownloading,
    AttachmentStatusDownloaded,
    
    
};

typedef NS_ENUM(NSInteger, MessageSender)
{
    MessageSenderMyself,
    MessageSenderSomeone
};

typedef NS_ENUM(NSInteger, MessageType)
{
    MessageTypeText,
    MessageTypeAttachment,
    MessageTypeNotification
};

typedef NS_ENUM(NSInteger, AttachmentType)
{
    AttachmentTypeImage,
};

typedef NS_ENUM(NSInteger, MessageMode)
{
    MessageModeOff,
    MessageModeReceiverEnd,
    MessageModeBothEnd,
};

typedef NS_ENUM(NSInteger, ScheduleStatus)
{
    NonScheduled,
    Scheduled,
    
};


#import "AppHelper.h"
#import "AppDelegate.h"
#import "SocketLisner.h"
#import "ContactManager.h"
#import "ConnectionManager.h"
#import "RSKImageCropViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImageView+WebCache.h"
#import "SBPickerSelector.h"
#import "TOActionSheet.h"
#import "UIImage+Extends.h"
#import "NSData+Base64.h"
#import "Person.h"
#import "Message.h"
#import "Attachment.h"
#import "GMDCircleLoader.h"
#import "PXAlertView+Customization.h"
#import "LLARingSpinnerView.h"
#import "UIActionSheet+Blocks.h"

// SERVER URL
#define kBaseUrl @"http://54.148.12.178:3000"
#define kImageUrl @"http://54.148.12.178:3000/getimages/"

#define kUSER_MOBILE_NUMBER @"LoggedInUserNumber"
#define kPUSH_TOKEN @"PushToken"

// NSNOTIFICATION KEYS
#define kCHAT_NOTIFY_NOTIIFCATION @"NotifyChat"
#define kRECEIVE_CHAT_NOTIIFCATION @"ReceiveChat"
#define kONLINE_USER_NOTIIFCATION @"OnlineUser"
#define kMESSAGE_RECEIVE_NOTIIFCATION @"ReceiveMessage"
#define kMESSAGE_STATUS_NOTIIFCATION @"MessageStatus"
#define kBORADCAST_CHAT_NOTIIFCATION @"BroadCastChat"
#define kDELETE_MESSAGE_NOTIFICATION @"DeletePrivyMessage"
#define kATTACHMENT_UPLOADED_NOTIFICATION @"AttachmentUploaded"
#define kATTACHMENT_ERROR_NOTIFICATION @"AttachmentUploadedDownloadError"
#define kATTACHMENT_DOWNLOADED_NOTIFICATION @"AttachmentDownloaded"
#define kATTACHMENT_OPENED_NOTIFICATION @"AttachmentOpened"
#define kMENUCONTROLLER_OPENED_NOTIFICATION @"MenuControllerOpened"
#define kNETWORK_DOWN_NOTIFICATION @"NetworkDown"
#define kNETWORK_UP_NOTIFICATION @"NetworkUp"
#define kTYPING_MESSAGE_NOTIFICATION @"TypingMessage"

// CHECK IOS VERSION
#ifdef __IPHONE_7_0
# define STATUS_STYLE UIStatusBarStyleLightContent
#else
# define STATUS_STYLE UIStatusBarStyleBlackTranslucent
#endif


// CUSTOMIZE NSLOG
#ifdef DEBUG
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define DLog(...)
#endif

#define SINGLETON_FOR_CLASS(classname)\
+ (id) shared##classname {\
static dispatch_once_t pred = 0;\
__strong static id _sharedObject = nil;\
dispatch_once(&pred, ^{\
_sharedObject = [[self alloc] init];\
});\
return _sharedObject;\
}


// PASSCODE KEY
#define kMOBILE_PASS_CODE @"Privy Passcode"
#define kTURN_PASSCODE_OFF @"Turn Passcode Off"
#define kTURN_PASSCODE_ON @"Turn Passcode On"
#define kTURN_PASSCODE_CHANGE @"Change Passcode"

// DEVICE VERSION
#define kDEVICE_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

// DEFINE ALL STRING CONSTANTS HERE
#define kDOCUMENT_FOLDER_PATH [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
#define kAPP_DELEGATE ((AppDelegate *)[[UIApplication sharedApplication] delegate])


// HANDLE NULL VALUES
#define EMPTYIFNULL(obj) ((obj == [NSNull null]) ? @"" : ((obj == nil) ? @"" : obj))

// OBJECT CONVERSION
#define CONVERT_TO_NUMBER(obj) ([NSNumber numberWithInteger:obj])
#define CONVERT_TO_INTEGER(obj) ([obj integerValue])

//RGB color macro
#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

//RGB color macro with alpha
#define UIColorFromRGBWithAlpha(rgbValue,a) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

#define kAPP_COLOR [UIColor colorWithRed:91/255.0f green:44/255.0f blue:135/255.0f alpha:1.0f]

// COMPARE TWO COORDINATES
#define CLCOORDINATES_EQUAL( coord1, coord2 ) (coord1.latitude == coord2.latitude && coord1.longitude == coord2.longitude)

#define TIME_STAMP [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000]

#endif
