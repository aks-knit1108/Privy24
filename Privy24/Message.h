//
//  Message.h
//  Privy24
//
//  Created by Amit on 10/5/15.
//  Copyright (c) 2015 BrightZone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "constants.h"
#import "DBManager.h"

//
// This class is the message object itself
//

@class Attachment;
@class Chat;
@interface Message : NSObject

@property  MessageSender sender;
@property  MessageStatus readStatus;
@property  MessageMode mode;
@property  MessageType type;
@property  ScheduleStatus messageStatus;
@property  AttachmentStatus attachmentStatus;


@property (assign, nonatomic)  CGFloat heigh;
@property (assign, nonatomic)  NSInteger d_interval;
@property (assign, nonatomic) NSInteger delete_status;

@property (strong, nonatomic) NSString *messageId;
@property (strong, nonatomic) NSString *messageLocalId;
@property (strong, nonatomic) NSString *chatId;
@property (strong, nonatomic) NSString *senderId;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *scheduleDate;
@property (strong, nonatomic) NSString *opponentId;
@property (strong,nonatomic) Attachment *attachment;

// @Convenience methods
- (instancetype)initWithDictionary:(NSDictionary *)dict ;
- (NSString *)getLocalName;

// @Database methods
+ (Message *) fetchMessageForId:(NSString *)msgId;
+ (NSArray *) fetchAllMessageForChat:(Chat *)chat withLimit:(int)limit;
+ (Message *) fetchLastMessageForChat:(Chat *)chat;
+ (NSArray *) fetchReceivedMessagesForChat:(Chat *)chat;
+ (NSArray *) fetchDeliveredMessagesForChat:(Chat *)chat;
+ (void) updateAllMessageReadForChat:(Chat *)chat;
+ (NSArray *) fetchAllScheduledMessage;
+ (NSInteger) fetchUnreadCountForAllChat;
+ (NSInteger) fetchUnreadCountForChat:(Chat *)chat;
+ (void) deleteAllMessagesForChat:(Chat *)chat;
- (void) deleteMessage;
- (void) executeSaveQuery;
- (void) updateStatus;
- (void) schedule;

@end
