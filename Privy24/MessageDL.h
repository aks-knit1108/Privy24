//
//  MessageDL.h
//  Privy24
//
//  Created by Amit on 3/18/16.
//  Copyright (c) 2016 BrightZone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBManager.h"

//CREATE TABLE "tblMessage" ("attach_size" VARCHAR, "attach_status" INTEGER, "attach_type" INTEGER, "base64" VARCHAR, "chat_id" VARCHAR, "date" VARCHAR, "img_url" VARCHAR, "interval" VARCHAR, "message" VARCHAR, "message_id" VARCHAR UNIQUE , "message_status" INTEGER, "mode" INTEGER, "msg_type" INTEGER, "read_status" INTEGER, "shcedule_date" VARCHAR, "sender_id" VARCHAR)

#define QUERY_COUNT_MESSAGE                        @"SELECT COUNT() FROM tblMessage WHERE %@ = '%@' AND chat_id = '%@'"
#define kQUERY_GET_MESSAGE                         @"SELECT * FROM tblMessage WHERE message_id = '%@'"
#define kQUERY_GET_ALL_MESSAGE                     @"SELECT * FROM tblMessage WHERE chat_id = '%@' ORDER BY date ASC"

#define kQUERY_INSERT_MESSAGE                      @"INSERT INTO tblMessage (attach_size,attach_status,attach_type,base64,chat_id,date,img_url,interval,message,message_id,message_status,mode,msg_type,read_status,shcedule_date,sender_id) VALUES ('%@','%d','%d','%@','%@','%@','%@','%d','%@','%@','%d','%d','%d','%d','%@','%@')"
#define kQUERY_UPDATE_SENT_MESSAGE                 @"UPDATE tblMessage SET attach_size = '%@',attach_status = '%d',attach_type = '%d',base64 = '%@',chat_id = '%@',date = '%@',img_url = '%@',interval = '%d',message = '%@',message_id = '%@',message_status = '%d',mode = '%d',msg_type = '%d',read_status = '%d',shcedule_date = '%@',sender_id = '%@' date = '%@' AND chat_id = '%@'"

#define kQUERY_UPDATE_RECEIVED_MESSAGE                 @"UPDATE tblMessage SET attach_size = '%@',attach_status = '%d',attach_type = '%d',base64 = '%@',chat_id = '%@',date = '%@',img_url = '%@',interval = '%d',message = '%@',message_id = '%@',message_status = '%d',mode = '%d',msg_type = '%d',read_status = '%d',shcedule_date = '%@',sender_id = '%@' WHERE %@ = '%@' AND chat_id = '%@'"

#define kQUERY_UPDATE_MESSAGE_STATUS                 @"UPDATE tblMessage SET attach_status = '%d',read_status = '%d' WHERE message_id = '%@' AND chat_id = '%@'"

#define kQUERY_UPDATE_READ_STATUS                 @"UPDATE tblMessage SET read_status = '%d' WHERE message_id = '%@' "

#define kQUERY_SHCEDULE_STATUS                 @"UPDATE tblMessage SET message_status = '%d', shcedule_date = '%@' WHERE message_id = '%@'"

@class Message;
@class Person;
@class Chat;

@interface MessageDL : DBManager

- (NSInteger) getUnreadCount:(NSString *)query;
- (NSArray *) fetchAllMessageWithQuery:(NSString *)strQuery;
- (Message *) fetchMessageWithQuery:(NSString *)strQuery;
- (BOOL)saveMessage:(Message *)msg;
- (BOOL)updateMessageStatus:(Message *)msg;
- (BOOL)updateMessageReadStatus:(Message *)msg;
- (BOOL)updateScheduleStatus:(Message *)msg;
- (BOOL) deleteMessageWithQuery:(NSString *)strQuery;

@end
