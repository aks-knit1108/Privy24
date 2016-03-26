//
//  Chat.h
//  Whatsapp
//
//  Created by Rafael Castro on 7/24/15.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DBManager.h"
#import "constants.h"

//
// This class is responsable to store information
// displayed in ChatController
//

@class Message;
@class Person;
@interface Chat : NSObject

@property (assign, nonatomic) NSInteger d_interval;
@property (assign, nonatomic) NSInteger mode;
@property (assign, nonatomic) NSInteger chat_type;
@property (strong, nonatomic) NSString *chatId;
@property (strong, nonatomic) NSString *opponnetId;
@property (strong, nonatomic) NSString *chatDate;
@property (strong, nonatomic) Message *message;

- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (Person *)getOpponentUser;

+ (NSArray *) fetchAllChats;
+ (Chat *) fetchChatForId:(NSString *)chatId;
+ (Chat *) fetchChatForOpponent:(Person *)opponent;

- (void) executeSaveQuery;
- (void) deleteChat;

@end
