//
//  ChatDL.m
//  Privy24
//
//  Created by Amit on 3/18/16.
//  Copyright (c) 2016 BrightZone. All rights reserved.
//

#import "ChatDL.h"
#import "Chat.h"
#import "Person.h"

@implementation ChatDL

- (NSArray *) fetchAllChats {
    
    NSString *strQuery = [NSString stringWithFormat:kQUERY_GET_ALL_CHATS];
    
    NSMutableArray *arrResponse	= [NSMutableArray array];
    sqlite3_stmt *statement = nil;
    
    const char *sqlStatement = [strQuery cStringUsingEncoding:NSUTF8StringEncoding];
    if (sqlite3_prepare_v2([kDBMANAGER getDBInstance], sqlStatement, (int)strlen(sqlStatement), &statement, nil) == SQLITE_OK) {
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            Chat *object= [Chat new];
            
            SAFE_CONVERSION_TEXT_FROM_DB_TO_OBJECT(object.chatId,sqlite3_column_text(statement, 0));
            object.chat_type = sqlite3_column_int(statement, 2);
            SAFE_CONVERSION_TEXT_FROM_DB_TO_OBJECT(object.chatDate,sqlite3_column_text(statement, 3));
            object.d_interval = sqlite3_column_int(statement, 4);
            object.mode = sqlite3_column_int(statement, 5);
            SAFE_CONVERSION_TEXT_FROM_DB_TO_OBJECT(object.opponnetId,sqlite3_column_text(statement, 6));
            [arrResponse addObject:object];
            
        }
        sqlite3_finalize(statement);
    }
    
    return arrResponse;

    
}

- (Chat *) fetchChatWithQuery:(NSString *)strQuery {
    
   // NSLog(@"strQuery %@",strQuery);
    
    sqlite3_stmt *statement = nil;
    
    Chat *object= [Chat new];
    
    const char *sqlStatement = [strQuery cStringUsingEncoding:NSUTF8StringEncoding];
    if (sqlite3_prepare_v2([kDBMANAGER getDBInstance], sqlStatement, (int)strlen(sqlStatement), &statement, nil) == SQLITE_OK) {
        
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            SAFE_CONVERSION_TEXT_FROM_DB_TO_OBJECT(object.chatId,sqlite3_column_text(statement, 0));
            object.chat_type = sqlite3_column_int(statement, 2);
            SAFE_CONVERSION_TEXT_FROM_DB_TO_OBJECT(object.chatDate,sqlite3_column_text(statement, 3));
            object.d_interval = sqlite3_column_int(statement, 4);
            object.mode = sqlite3_column_int(statement, 5);
            SAFE_CONVERSION_TEXT_FROM_DB_TO_OBJECT(object.opponnetId,sqlite3_column_text(statement, 6));
            
            return object;
            
        }
        sqlite3_finalize(statement);
    }
    
    return object;
}

- (BOOL)saveChat:(Chat *)chat {

    if (![kDBMANAGER getCountTable:[NSString stringWithFormat:QUERY_COUNT_CHATS,chat.chatId]]) {
        return [kDBMANAGER executeQuery:[NSString stringWithFormat:kQUERY_INSERT_CHAT,chat.chatId,0,(int)chat.chat_type,chat.chatDate,(int)chat.d_interval,(int)chat.mode,chat.opponnetId]];
    } else {
        
        return [kDBMANAGER executeQuery:[NSString stringWithFormat:kQUERY_UPDATE_CHAT,0,(int)chat.chat_type,chat.chatDate,(int)chat.d_interval,(int)chat.mode,chat.opponnetId,chat.chatId]];
        
    }
}

- (BOOL) deleteChat:(Chat *)chat {
    return [kDBMANAGER executeQuery:[NSString stringWithFormat:kQUERY_DELETE_CHAT,chat.chatId]];
}

@end
