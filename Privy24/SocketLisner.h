//
//  SocketLisner.h
//  Privy24
//
//  Created by Amit on 10/16/15.
//  Copyright (c) 2015 BrightZone. All rights reserved.
//

#import <Foundation/Foundation.h>

// URL
#define kSOCKET_URL @"http://54.148.12.178:3000"

// Socket
#define kCONNECT_SOCKET @"connect"
#define kCONNECT_USER @"connectUser"
#define kSOCKET_CONNECTION_CONNECTED @"SocketConnected"
#define kSOCKET_CONNECTION_DISCONNECTED @"SocketDisConnected"
#define kSTART_PRIVY_MODE @"startPrivyMode"
#define kSEND_MESSAGE @"sendMessage"
#define kDELETE_PRIVY_MESSAGE @"deletePrivyMsg"
#define kONLINE_USERS @"onlineUsers"

// Chat
#define kSHOW_ALL_CHAT @"showAllChats"
#define kNOTIFY_CHAT @"notifyChat"
#define kSTART_NEW_CHAT @"newChat"
#define kRECEIVE_CHAT @"receiveChat"
#define kDELETE_CHAT @"deleteChat"
#define kCLEAR_CHAT @"clearChat"
#define kENTER_CHAT @"enterChat"
#define kSTART_TYPING @"sendTyping"
#define kRECEIVE_TYPING @"receiveTyping"

// Message
#define kNOTIFY_MESSAGE @"notifyMessage"
#define kGET_MESSAGE_STATUS @"getMessageStatus"
#define kSET_MESSAGE_STATUS @"setMessageStatus"
#define kCHECK_MESSAGE_STATUS @"checkMessageStatus"
#define kRECEIVE_MESSAGE_STATUS @"receiveMessageStatus"

@class SocketIOClient;
@class Person;
@class Message;
@class Chat;

@interface SocketLisner : NSObject

+ (instancetype)sharedLisner;
- (void)connect;
- (void)disconnect;
- (void)reconnect;
- (BOOL)connectionStatus;
- (void)sendMessage:(Message *)message;
- (void)startChatWithUser:(Person *)opponent;
- (void)deleteMessage:(Message *)message;
- (void)readMessage:(Message *)message;
- (void)checkStatusForMessages:(NSArray *)msgArray;
- (void)deleteChat:(Chat*)chat;
- (void)clearChat:(Chat*)chat;
- (void)fetchScheduledMessages;
- (void)scheduleMessage:(Message *)msg;
- (void)removesMessage:(Message *)msg;
- (void)startTypingWithPrams:(NSArray *)params;
- (void)enterChatWithPrams:(NSArray *)params;

- (void)uplaodImage:(Message *)msg withImage:(NSData *)data;

@property (nonatomic,strong) SocketIOClient *socket;
@property (nonatomic,strong) Person *user;
@property (nonatomic,strong) NSString *chatId;
@property (nonatomic,strong) NSMutableArray *imgOperations;

@end
