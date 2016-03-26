//
//  SocketLisner.m
//  Privy24
//
//  Created by Amit on 10/16/15.
//  Copyright (c) 2015 BrightZone. All rights reserved.
//

#import "SocketLisner.h"
#import "Privy24-Swift.h"
#import "Person.h"
#import "Chat.h"
#import "Message.h"
#import "MessageHandler.h"

static NSString *boundary = @"----------V2ymHFg03ehbqgZCaKO6jy";

@implementation SocketLisner

+(instancetype)sharedLisner
{
    static SocketLisner *sharedLisner = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLisner = [[self alloc] init];
    });
    return sharedLisner;
}
-(id)init
{
    self = [super init];
    
    if (self)
    {
        self.socket = [[SocketIOClient alloc] initWithSocketURL:kSOCKET_URL options:nil];
        self.chatId = @"";
        self.imgOperations = [NSMutableArray new];
        [self addSocketListners];
    }
    return self;
}

- (void)connect {
    [self.socket connect];
}

- (void)disconnect {
    [self.socket disconnectWithFast:YES];
}

- (void)reconnect {
    if (!self.socket.reconnecting) {
        [self.socket reconnect];
    }
}

- (BOOL)connectionStatus {
    return self.socket.connected;
}


#pragma mark
#pragma mark Callback methods
- (void)addSocketListners {

    // CallBack for getting connected status
    [self.socket on:kCONNECT_SOCKET callback: ^(NSArray* data, void (^ack)(NSArray*)) {
        
        NSLog(@"connect called");
        [self.socket emit:kCONNECT_USER withItems:@[@{@"id":self.user.mobile}]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kSOCKET_CONNECTION_CONNECTED object:nil];
    }];
    
    // CallBack for getting chat id
    [self.socket on:kRECEIVE_CHAT callback: ^(NSArray* data, void (^ack)(NSArray*)) {
        
        if (data.count!=0) {
            
            if (data.count!=0) {
                NSDictionary *dict = [data objectAtIndex:0];
                [[NSNotificationCenter defaultCenter] postNotificationName:kRECEIVE_CHAT_NOTIIFCATION object:dict];
            }
        }
    }];
    
    // CallBack for getting all chat
    [self.socket on:kSHOW_ALL_CHAT callback: ^(NSArray* data, void (^ack)(NSArray*)) {
        
        if (data.count!=0) {
            
            NSDictionary *chatDictionary = [data objectAtIndex:0];
            
            NSArray *participants = [chatDictionary valueForKey:@"participants"];
            for (NSDictionary *participant in participants) {
                Person *user = [[Person alloc] initWithDictionary:participant];
                [user executeSaveQuery];
            }
            
            NSArray *chats = [chatDictionary valueForKey:@"chat"];
            
            for (NSDictionary *dict in chats) {
                
                Chat *chatObject = [[Chat alloc] initWithDictionary:dict];
                [self receiveChat:chatObject];
            }
            
        }
        
        
    }];
    
    // CallBack for getting latest chat
    [self.socket on:kNOTIFY_CHAT callback: ^(NSArray* data, void (^ack)(NSArray*)) {
        
        if (data.count!=0) {
            
            NSDictionary *dict = [data objectAtIndex:0];
            Chat *chatObject = [[Chat alloc] initWithDictionary:dict];
            [self receiveChat:chatObject];

        }
    }];
    
    // CallBack for notifying message
    [self.socket on:kNOTIFY_MESSAGE callback: ^(NSArray* data, void (^ack)(NSArray*)) {
        
        if (data.count!=0) {
            
            NSDictionary *messageDict = [data objectAtIndex:0];
            Message *message = [[Message alloc] initWithDictionary:messageDict];
            [self receiveMessage:message];
        }
        
    }];
    
    // CallBack for receiving message status
    [self.socket on:kGET_MESSAGE_STATUS callback: ^(NSArray* data, void (^ack)(NSArray*)) {
        
        if (data.count!=0) {
            
            NSDictionary *dict = [data objectAtIndex:0];
            
            [self receiveMessageStatus:dict];
        }
        
    }];
    
    // CallBack for receiving all message status
    [self.socket on:kRECEIVE_MESSAGE_STATUS callback: ^(NSArray* data, void (^ack)(NSArray*)) {
        
        if (data.count!=0) {
            
            NSArray *array = [data objectAtIndex:0];
            
            for (NSDictionary *dict in array) {
                [self receiveMessageStatus:dict];
            }
        }
        
    }];
    
    // CallBack for receiving typing status
    [self.socket on:kRECEIVE_TYPING callback: ^(NSArray* data, void (^ack)(NSArray*)) {
        
        NSDictionary *dict = [data objectAtIndex:0];
        [[NSNotificationCenter defaultCenter] postNotificationName:kTYPING_MESSAGE_NOTIFICATION object:dict];
    }];
    
    // CallBack for getting latest chat
    [self.socket on:kONLINE_USERS callback: ^(NSArray* data, void (^ack)(NSArray*)) {
        
        if (data.count!=0) {
            
            NSArray *array = [data objectAtIndex:0];
            
            if ([array isKindOfClass:[NSDictionary class]]) {
                
                NSDictionary *dict = (NSDictionary *)array;
                
                Person *user = [Person new];
                
                NSString *user_id    = EMPTYIFNULL(dict[@"user_id"]);
                BOOL status        = [EMPTYIFNULL(dict[@"status"]) boolValue];
                user.mobile = user_id;
                user.online = status;
                
                //[user updateOnlineStatus];
                
                if (![self.chatId isEqualToString:@""]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kONLINE_USER_NOTIIFCATION object:user];
                }
            }
            
            else if([array isKindOfClass:[NSArray class]]) {
            
                for (NSDictionary *dict in array) {
                    
                    Person *user = [Person new];
                    
                    NSString *user_id    = EMPTYIFNULL(dict[@"user_id"]);
                    NSInteger status        = [EMPTYIFNULL(dict[@"status"]) boolValue];
                    user.mobile = user_id;
                    user.online = status;
                    
                    //[user updateOnlineStatus];
                    
                    if (![self.chatId isEqualToString:@""]) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:kONLINE_USER_NOTIIFCATION object:user];
                    }
                    
                    
                }

            }
            
                
        }
    }];

}

#pragma mark
#pragma mark Socket methods
- (void)sendMessage:(Message *)message {

    switch (message.type) {
            
        case MessageTypeNotification:
            
        {
            NSArray *param = @[@{@"chat_id":message.chatId,@"message":message.text,@"type":CONVERT_TO_NUMBER(message.type),@"mode":CONVERT_TO_NUMBER(message.mode),@"delete_interval":CONVERT_TO_NUMBER(message.d_interval),@"message_local_id":message.date}];
            
            NSLog(@"privy message params = %@",param);
            
            [self.socket emit:kSTART_PRIVY_MODE withItems:param];
        }
            break;
            
            
        default:
        {
            
            NSArray *params = @[@{@"chat_id":message.chatId,@"message":message.text,@"type":CONVERT_TO_NUMBER(message.type),@"mode":CONVERT_TO_NUMBER(message.mode),@"delete_interval":CONVERT_TO_NUMBER(message.d_interval),@"message_local_id":message.date,@"attachment": @{@"url": message.attachment.url,@"type":CONVERT_TO_NUMBER(message.attachment.type),@"size" :message.attachment.size,@"thumbnail" :message.attachment.thumbnail}}];
            
            NSLog(@"send message params = %@",params);
            
            
            [self.socket emit:kSEND_MESSAGE withItems:params];
        }
            break;
    }
   
}

- (void)startChatWithUser:(Person *)opponent {
    
    [self.socket emit:kSTART_NEW_CHAT withItems:@[@{@"receiver_id":opponent.mobile}]];
}

- (void) startTypingWithPrams:(NSArray *)params {
    [self.socket emit:kSTART_TYPING withItems:params];
}

- (void) enterChatWithPrams:(NSArray *)params {
    [self.socket emit:kENTER_CHAT withItems:params];
}

- (void)deleteMessage:(Message *)message {
    
    [self.socket emit:kDELETE_PRIVY_MESSAGE withItems:@[@{@"chat_id":message.chatId,@"message_id":message.messageId,@"mode":[NSString stringWithFormat:@"%li",(long)message.mode]}]];
}


- (void)readMessage:(Message *)message {
    [self.socket emit:kSET_MESSAGE_STATUS withItems:@[@{@"message_id":message.messageId,@"status":CONVERT_TO_NUMBER(message.readStatus)}]];
}

- (void)checkStatusForMessages:(NSArray *)msgArray {
    
    NSMutableArray *idArray = [NSMutableArray new];
    
    for (Message *message in msgArray) {
        [idArray addObject:message.messageId];
        
    }
    
    [self.socket emit:kCHECK_MESSAGE_STATUS withItems:@[idArray]];
}


- (void)deleteChat:(Chat*)chat {

    [self.socket emit:kDELETE_CHAT withItems:@[@{@"chat_id":chat.chatId}]];
}

- (void)clearChat:(Chat*)chat {
    
    [self.socket emit:kCLEAR_CHAT withItems:@[@{@"chat_id":chat.chatId}]];
}

#pragma mark
#pragma mark Helper methods
- (void)receiveMessageStatus:(NSDictionary *)dict {
    
    NSString *message_id    = EMPTYIFNULL(dict[@"message_id"]);
    NSInteger status        = [EMPTYIFNULL(dict[@"read_status"]) integerValue];
    
    Message *message = [Message new];
    message.messageId = message_id;
    message.readStatus = status;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kMESSAGE_STATUS_NOTIIFCATION object:message];
}

- (void)receiveChat:(Chat *)chat {
    
    [chat executeSaveQuery];
    
    Message *message = chat.message;
    
    [self performMessage:message withChat:chat];
    
}


- (void)receiveMessage:(Message *)message {
    
    Chat *chat = [Chat fetchChatForId:message.chatId];
    chat.chatDate = message.date;
    [chat executeSaveQuery];
    
    [self performMessage:message withChat:chat];
}

- (void)performMessage:(Message *)message withChat:(Chat *)chat {
    
    if ([chat.chatId isEqualToString:[SocketLisner sharedLisner].chatId]) {
        
        if (message.sender == MessageSenderSomeone) {
            
            [message setReadStatus:MessageStatusRead];
            
            [message executeSaveQuery];

            [self readMessage:message];
            
            [[MessageHandler sharedHandler] addMessage:message];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kMESSAGE_RECEIVE_NOTIIFCATION object:message];
        } else {
            
            [message executeSaveQuery];
            [[NSNotificationCenter defaultCenter] postNotificationName:kMESSAGE_RECEIVE_NOTIIFCATION object:message];
        }
        
    }
    
    else {
        
        [message setReadStatus:MessageStatusReceived];
        [message executeSaveQuery];
        [self readMessage:message];
        [[NSNotificationCenter defaultCenter] postNotificationName:kCHAT_NOTIFY_NOTIIFCATION object:chat];
    }
}



#pragma mark
#pragma mark Image uploading methods
- (void)uplaodImage:(Message *)msg withImage:(NSData *)data {
    
    NSString *url = [kBaseUrl stringByAppendingString:@"/attachment"];
    
    [[ConnectionManager sharedManager] uploadAttachmentRequest:url attachmentName:[msg getLocalName] attachmentData:data success:^(id responseObject) {
        
        NSError *error = nil;
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                     options:kNilOptions
                                                                       error:&error];
        NSString *url = [jsonResponse objectForKey:@"fileurl"];
        msg.attachment.url = url;
        msg.attachmentStatus = AttachmentStatusUploaded;
        [msg executeSaveQuery];
        
        [self sendMessage:msg];
        [[NSNotificationCenter defaultCenter] postNotificationName:kATTACHMENT_UPLOADED_NOTIFICATION object:msg];
        
    } failure:^(NSError *error) {
        msg.attachmentStatus = AttachmentStatusError;
        [msg executeSaveQuery];
        [[NSNotificationCenter defaultCenter] postNotificationName:kATTACHMENT_ERROR_NOTIFICATION object:msg];
    }];
}



@end
