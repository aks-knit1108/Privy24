//
//  MessageHandler.h
//  
//
//  Created by Apple on 25/03/16.
//
//

#import <Foundation/Foundation.h>


@class Message;

@interface MessageHandler : NSObject
+ (instancetype)sharedHandler;
- (void)addMessage:(Message *)msg;
- (void)scheduleMessages;

@end
