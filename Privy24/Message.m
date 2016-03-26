//
//  Message.m
//  Privy24
//
//  Created by Amit on 10/5/15.
//  Copyright (c) 2015 BrightZone. All rights reserved.
//

#import "Message.h"
#import "Chat.h"
#import "Person.h"
#import "MessageDL.h"
#import "MessageHandler.h"

@implementation Message

-(id)init
{
    self = [super init];
    if (self)
    {
        self.sender = MessageSenderMyself;
        self.readStatus = MessageStatusSending;
        self.attachmentStatus = AttachmentStatusNone;
        self.text = @"";
        self.heigh = 44;
        self.date = [AppHelper currentDate];
        self.scheduleDate = [AppHelper currentDate];
        self.messageStatus = NonScheduled;
        self.messageId = @"";
        self.messageLocalId = @"";
        self.senderId = @"";
        self.opponentId = @"";
        self.attachment = [Attachment new];
        //self.fromUser = [Person new];
        
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    
    self = [super init];
    if (self) {
        
        self.text = EMPTYIFNULL(dict[@"message"]);
        self.heigh = 44;
        self.scheduleDate = [AppHelper utcStringFromDate:[NSDate date]];
        self.date =  [AppHelper utcStringFromDate:[NSDate date]];
        self.messageStatus = NonScheduled;
        self.attachmentStatus = AttachmentStatusNone;
        self.messageId = EMPTYIFNULL(dict[@"message_id"]);
        self.messageLocalId = EMPTYIFNULL(dict[@"message_local_id"]);
        self.senderId = [NSString stringWithFormat:@"%@",EMPTYIFNULL(dict[@"sender_id"])];
        self.chatId = [NSString stringWithFormat:@"%@",EMPTYIFNULL(dict[@"chat_id"])];
        self.mode = [[NSString stringWithFormat:@"%@",EMPTYIFNULL(dict[@"mode"])] integerValue];
        self.d_interval = [[NSString stringWithFormat:@"%@",EMPTYIFNULL(dict[@"delete_interval"])] integerValue];
        self.type  = [[NSString stringWithFormat:@"%@",EMPTYIFNULL(dict[@"type"])] integerValue];
        self.readStatus = [EMPTYIFNULL(dict[@"read_status"]) integerValue];
        
        NSDictionary *attachment = dict[@"attachment"];
        if (attachment != nil && [attachment isKindOfClass:[NSDictionary class]]) {
            self.attachment = [[Attachment alloc] initWithDictionary:dict[@"attachment"]];
        } else {
            self.attachment = [Attachment new];
        }
        
        NSArray *participants  = [dict objectForKey:@"participants_id"];
        NSUInteger user_id = [[SocketLisner sharedLisner].user.mobile integerValue];
        
        for (NSString *number in participants) {
            if ([number integerValue] != user_id) {
                self.opponentId = [NSString stringWithFormat:@"%@",number];
                break;
            }
        }
        
        NSUInteger sender_id = [self.senderId integerValue];
        
        if (sender_id == user_id) {
            self.sender = MessageSenderMyself;
            if (self.messageLocalId.length != 0) {
                self.date = self.messageLocalId;
            } 
            
        } else {
            self.sender = MessageSenderSomeone;
            self.attachmentStatus = AttachmentStatusDownloading;
            
        }
        
        NSDictionary *fromUser = dict[@"from_user"];
        if (fromUser != nil && [fromUser isKindOfClass:[NSDictionary class]]) {
            Person *user = [[Person alloc] initWithDictionary:fromUser];
            [user executeSaveQuery];
        }
    }
    return self;
}

- (NSString *)getLocalName {
    
    NSString *imageName = [NSString stringWithFormat:@"%@_%@_image.png",self.chatId,self.date];
    return imageName;
}


+ (Message *) fetchMessageForId:(NSString *)msgId {
   
    MessageDL *repo = [MessageDL new];
    NSString *strQuery = [NSString stringWithFormat:kQUERY_GET_MESSAGE,msgId];
    return [repo fetchMessageWithQuery:strQuery];
    
}

+ (Message *) fetchLastMessageForChat:(Chat *)chat{

    MessageDL *repo = [MessageDL new];
    NSString *strQuery = [NSString stringWithFormat:@"SELECT * FROM tblMessage WHERE chat_id = '%@' ORDER BY date DESC LIMIT 1 ",chat.chatId];
    Message *msg = [repo fetchMessageWithQuery:strQuery];
    
    return msg;
}

+ (NSArray *) fetchAllMessageForChat:(Chat *)chat withLimit:(int)limit {
    
    MessageDL *repo = [MessageDL new];
    NSString *strQuery = [NSString stringWithFormat:kQUERY_GET_ALL_MESSAGE,chat.chatId];
    NSArray *results = [repo fetchAllMessageWithQuery:strQuery];
    NSMutableArray *msgArray = [NSMutableArray new];
    for (Message *msg in results) {
        
        [msg setOpponentId:chat.opponnetId];
        [msgArray addObject:msg];
        
    }
    
    return msgArray;
}

+ (NSArray *) fetchAllScheduledMessage {
    
    MessageDL *repo = [MessageDL new];
    NSString *strQuery = [NSString stringWithFormat:@"SELECT * FROM tblMessage WHERE message_status = %ld",(long)Scheduled];
    NSArray *results = [repo fetchAllMessageWithQuery:strQuery];
    
    return results;
    
}

+ (NSArray *) fetchSendingMessageForChat:(Chat *)chat {

    MessageDL *repo = [MessageDL new];
    NSString *strQuery = [NSString stringWithFormat:@"SELECT * FROM tblMessage WHERE chat_id = '%@' AND (read_status = %ld)",chat.chatId,(long)MessageStatusSending];
    NSArray *results = [repo fetchAllMessageWithQuery:strQuery];
    
    return results;
}

+ (NSArray *) fetchReceivedMessagesForChat:(Chat *)chat {

    MessageDL *repo = [MessageDL new];
    NSString *strQuery = [NSString stringWithFormat:@"SELECT * FROM tblMessage WHERE chat_id = '%@' AND sender_id <> %@ AND read_status <> %ld",chat.chatId,[SocketLisner sharedLisner].user.mobile,(long)MessageStatusRead];
    NSArray *results = [repo fetchAllMessageWithQuery:strQuery];
    
    return results;
}

+ (NSArray *) fetchDeliveredMessagesForChat:(Chat *)chat {

    MessageDL *repo = [MessageDL new];
    NSString *strQuery = [NSString stringWithFormat:@"SELECT * FROM tblMessage WHERE chat_id = '%@' AND sender_id = %@ AND (read_status = %ld OR read_status = %ld) AND msg_type <> %ld",chat.chatId,[SocketLisner sharedLisner].user.mobile,(long)MessageStatusSent,(long)MessageStatusReceived,(long)MessageTypeNotification];
    NSArray *results = [repo fetchAllMessageWithQuery:strQuery];
    
    return results;
}


+ (NSInteger) fetchUnreadCountForAllChat {

    MessageDL *repo = [MessageDL new];
    NSString *strQuery = [NSString stringWithFormat:@"SELECT COUNT(*) FROM tblMessage WHERE sender_id <> %@ AND read_status <> %ld",[SocketLisner sharedLisner].user.mobile,(long)MessageStatusRead];
    return [repo getUnreadCount:strQuery];
    
}

+ (NSInteger) fetchUnreadCountForChat:(Chat *)chat {
   
    MessageDL *repo = [MessageDL new];
    NSString *strQuery = [NSString stringWithFormat:@"SELECT COUNT(*) FROM tblMessage WHERE chat_id = '%@' AND sender_id <> %@ AND read_status <> %ld",chat.chatId,[SocketLisner sharedLisner].user.mobile,(long)MessageStatusRead];
    return [repo getUnreadCount:strQuery];
}

+ (void)updateAllMessageReadForChat:(Chat *)chat {

    MessageDL *repo = [MessageDL new];
    NSString *strQuery = [NSString stringWithFormat:@"SELECT * FROM tblMessage WHERE chat_id = '%@' AND sender_id <> %@ AND read_status <> %ld",chat.chatId,[SocketLisner sharedLisner].user.mobile,(long)MessageStatusRead];
    NSArray *results = [repo fetchAllMessageWithQuery:strQuery];
    
    for (Message *message in results) {
        
        message.readStatus = MessageStatusRead;
        if ([repo updateMessageReadStatus:message]) {
            [[SocketLisner sharedLisner] readMessage:message];
            [[MessageHandler sharedHandler] addMessage:message];
        }
        
    }
}


- (void) executeSaveQuery {
    
    MessageDL *repo = [MessageDL new];
    [repo saveMessage:self];
    
}

- (void) updateStatus {
    
    MessageDL *repo = [MessageDL new];
    [repo updateMessageStatus:self];
}


+ (void) deleteAllMessagesForChat:(Chat *)chat {
    
    MessageDL *repo = [MessageDL new];
    NSString *strQuery = [NSString stringWithFormat:@"DELETE FROM tblMessage WHERE chat_id = '%@'",chat.chatId];
    [repo deleteMessageWithQuery:strQuery];
}

- (void) deleteMessage {
    
    MessageDL *repo = [MessageDL new];
    NSString *strQuery = [NSString stringWithFormat:@"DELETE FROM tblMessage WHERE %@ = '%@' AND chat_id = '%@'",(self.sender == MessageSenderSomeone)?@"message_id":@"date",(self.sender == MessageSenderSomeone)?self.messageId:self.date,self.chatId];
    [repo deleteMessageWithQuery:strQuery];
}

- (void) schedule {
    
    MessageDL *repo = [MessageDL new];
    [repo updateScheduleStatus:self];
}

@end
