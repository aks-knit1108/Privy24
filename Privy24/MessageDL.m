//
//  MessageDL.m
//  Privy24
//
//  Created by Amit on 3/18/16.
//  Copyright (c) 2016 BrightZone. All rights reserved.
//

#import "MessageDL.h"
#import "Message.h"

@implementation MessageDL

- (NSArray *) fetchAllMessageWithQuery:(NSString *)strQuery {
    
    NSMutableArray *arrResponse	= [NSMutableArray array];
    sqlite3_stmt *statement = nil;
    
    const char *sqlStatement = [strQuery cStringUsingEncoding:NSUTF8StringEncoding];
    if (sqlite3_prepare_v2([kDBMANAGER getDBInstance], sqlStatement, (int)strlen(sqlStatement), &statement, nil) == SQLITE_OK) {
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            Message *object= [Message new];
            
            SAFE_CONVERSION_TEXT_FROM_DB_TO_OBJECT(object.attachment.size,sqlite3_column_text(statement, 0));
            object.attachmentStatus = sqlite3_column_int(statement, 1);
            object.attachment.type = sqlite3_column_int(statement, 2);
            SAFE_CONVERSION_TEXT_FROM_DB_TO_OBJECT(object.attachment.thumbnail,sqlite3_column_text(statement, 3));
            SAFE_CONVERSION_TEXT_FROM_DB_TO_OBJECT(object.chatId,sqlite3_column_text(statement, 4));
            SAFE_CONVERSION_TEXT_FROM_DB_TO_OBJECT(object.date,sqlite3_column_text(statement, 5));
            SAFE_CONVERSION_TEXT_FROM_DB_TO_OBJECT(object.attachment.url,sqlite3_column_text(statement, 6));
            
            object.d_interval = sqlite3_column_int(statement, 7);
            SAFE_CONVERSION_TEXT_FROM_DB_TO_OBJECT(object.text,sqlite3_column_text(statement, 8));
            SAFE_CONVERSION_TEXT_FROM_DB_TO_OBJECT(object.messageId,sqlite3_column_text(statement, 9));
            object.messageStatus = sqlite3_column_int(statement, 10);
            object.mode = sqlite3_column_int(statement, 11);
            object.type = sqlite3_column_int(statement, 12);
            object.readStatus = sqlite3_column_int(statement, 13);
            
            SAFE_CONVERSION_TEXT_FROM_DB_TO_OBJECT(object.scheduleDate,sqlite3_column_text(statement, 14));
            SAFE_CONVERSION_TEXT_FROM_DB_TO_OBJECT(object.senderId,sqlite3_column_text(statement, 15));
            
            
            NSUInteger user_id = [[SocketLisner sharedLisner].user.mobile integerValue];
            
            if ([object.senderId integerValue] == user_id) {
                object.sender = MessageSenderMyself;
                
                
            } else {
                object.sender = MessageSenderSomeone;
                
            }
            
            [arrResponse addObject:object];
            
        }
        sqlite3_finalize(statement);
    }
    
    return arrResponse;
    

}

- (Message *) fetchMessageWithQuery:(NSString *)strQuery {
    
    sqlite3_stmt *statement = nil;
    
    Message *object= [Message new];
    
    const char *sqlStatement = [strQuery cStringUsingEncoding:NSUTF8StringEncoding];
    if (sqlite3_prepare_v2([kDBMANAGER getDBInstance], sqlStatement, (int)strlen(sqlStatement), &statement, nil) == SQLITE_OK) {
        
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            SAFE_CONVERSION_TEXT_FROM_DB_TO_OBJECT(object.attachment.size,sqlite3_column_text(statement, 0));
            object.attachmentStatus = sqlite3_column_int(statement, 1);
            object.attachment.type = sqlite3_column_int(statement, 2);
            SAFE_CONVERSION_TEXT_FROM_DB_TO_OBJECT(object.attachment.thumbnail,sqlite3_column_text(statement, 3));
            SAFE_CONVERSION_TEXT_FROM_DB_TO_OBJECT(object.chatId,sqlite3_column_text(statement, 4));
            SAFE_CONVERSION_TEXT_FROM_DB_TO_OBJECT(object.date,sqlite3_column_text(statement, 5));
            SAFE_CONVERSION_TEXT_FROM_DB_TO_OBJECT(object.attachment.url,sqlite3_column_text(statement, 6));
            
            object.d_interval = sqlite3_column_int(statement, 7);
            SAFE_CONVERSION_TEXT_FROM_DB_TO_OBJECT(object.text,sqlite3_column_text(statement, 8));
            SAFE_CONVERSION_TEXT_FROM_DB_TO_OBJECT(object.messageId,sqlite3_column_text(statement, 9));
            object.messageStatus = sqlite3_column_int(statement, 10);
            object.mode = sqlite3_column_int(statement, 11);
            object.type = sqlite3_column_int(statement, 12);
            object.readStatus = sqlite3_column_int(statement, 13);
            
            SAFE_CONVERSION_TEXT_FROM_DB_TO_OBJECT(object.scheduleDate,sqlite3_column_text(statement, 14));
            SAFE_CONVERSION_TEXT_FROM_DB_TO_OBJECT(object.senderId,sqlite3_column_text(statement, 15));
            
            return object;
            
        }
        sqlite3_finalize(statement);
    }
    
    return object;
}

- (NSInteger) getUnreadCount:(NSString *)query {
    return [kDBMANAGER getCountTable:query];
}
- (BOOL)saveMessage:(Message *)msg {
    
    NSString *strQuery = [NSString stringWithFormat:QUERY_COUNT_MESSAGE,(msg.sender == MessageSenderSomeone)?@"message_id":@"date",(msg.sender == MessageSenderSomeone)?msg.messageId:msg.date,msg.chatId];
    
    if (![kDBMANAGER getCountTable:[NSString stringWithFormat:@"%@",strQuery]]) {
        
        return [kDBMANAGER executeQuery:[NSString stringWithFormat:kQUERY_INSERT_MESSAGE,msg.attachment.size,(int)msg.attachmentStatus,(int)msg.attachment.type,msg.attachment.thumbnail,msg.chatId,msg.date,msg.attachment.url,(int)msg.d_interval,msg.text,msg.messageId,(int)msg.messageStatus,(int)msg.mode,(int)msg.type,(int)msg.readStatus,msg.scheduleDate,msg.senderId]];
    } else {
        
        return [kDBMANAGER executeQuery:[NSString stringWithFormat:kQUERY_UPDATE_RECEIVED_MESSAGE,msg.attachment.size,(int)msg.attachmentStatus,(int)msg.attachment.type,msg.attachment.thumbnail,msg.chatId,msg.date,msg.attachment.url,(int)msg.d_interval,msg.text,msg.messageId,(int)msg.messageStatus,(int)msg.mode,(int)msg.type,(int)msg.readStatus,msg.scheduleDate,msg.senderId,(msg.sender == MessageSenderSomeone)?@"message_id":@"date",(msg.sender == MessageSenderSomeone)?msg.messageId:msg.date,msg.chatId]];
    }

}

- (BOOL)updateMessageStatus:(Message *)msg {
    
    return [kDBMANAGER executeQuery:[NSString stringWithFormat:kQUERY_UPDATE_MESSAGE_STATUS,(int)msg.attachmentStatus,(int)msg.readStatus,msg.messageId,msg.chatId]];
}

- (BOOL)updateMessageReadStatus:(Message *)msg {
    
    return [kDBMANAGER executeQuery:[NSString stringWithFormat:kQUERY_UPDATE_READ_STATUS,(int)msg.readStatus,msg.messageId]];
}

- (BOOL)updateScheduleStatus:(Message *)msg {
    
    return [kDBMANAGER executeQuery:[NSString stringWithFormat:kQUERY_SHCEDULE_STATUS,(int)msg.messageStatus,msg.scheduleDate,msg.messageId]];
}

- (BOOL) deleteMessageWithQuery:(NSString *)strQuery {
    return [kDBMANAGER executeQuery:strQuery];
}

@end
