//
//  ChatDL.h
//  Privy24
//
//  Created by Amit on 3/18/16.
//  Copyright (c) 2016 BrightZone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBManager.h"

// CREATE TABLE "tblChat" ("chat_id" VARCHAR UNIQUE , "chat_status" INTEGER, "chat_type" INTEGER, "date" VARCHAR, "interval" INTEGER, "mode" INTEGER, "participants_id" VARCHAR)

#define QUERY_COUNT_CHATS                   @"SELECT COUNT() FROM tblChat WHERE chat_id = '%@'"
#define kQUERY_GET_ALL_CHATS                @"SELECT * FROM tblChat ORDER BY date ASC"
#define kQUERY_GET_CHAT                     @"SELECT * FROM tblChat WHERE chat_id = '%@'"
#define kQUERY_GET_CHAT_FOR_OPPONENT        @"SELECT * FROM tblChat WHERE participants_id = '%@'"

#define kQUERY_INSERT_CHAT                  @"INSERT INTO tblChat (chat_id,chat_status,chat_type,date,interval,mode,participants_id) VALUES ('%@','%d','%d','%@','%d','%d','%@')"
#define kQUERY_UPDATE_CHAT                  @"UPDATE tblChat SET chat_status = '%d',chat_type = '%d',date = '%@',interval = '%d',mode = '%d',participants_id = '%@' WHERE chat_id = '%@'"

#define kQUERY_DELETE_CHAT        @"DELETE FROM tblChat WHERE chat_id = '%@'"


@class Chat;
@class Person;

@interface ChatDL : DBManager

- (NSArray *) fetchAllChats;
- (Chat *) fetchChatWithQuery:(NSString *)strQuery;
- (BOOL) saveChat:(Chat *)chat;
- (BOOL) deleteChat:(Chat *)chat;

@end
