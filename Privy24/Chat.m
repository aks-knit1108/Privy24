//
//  Chat.m
//  Whatsapp
//
//  Created by Rafael Castro on 7/24/15.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//

#import "Chat.h"
#import "constants.h"
#import "Message.h"
#import "Person.h"
#import "ChatDL.h"

@implementation Chat

-(id)init
{
    self = [super init];
    
    if (self)
    {
        self.chatId = @"";
        self.opponnetId = @"";
        self.mode = 0;
        self.d_interval = 0;
        self.chat_type = 0;
        self.chatDate = [AppHelper currentDate];
        return self;
    }
    return self;
}


- (instancetype)initWithDictionary:(NSDictionary *)dict {
    
    self = [super init];
    
    if (self) {
        
        self.chatId       = EMPTYIFNULL(dict[@"chat_id"]);
        self.chat_type    = [EMPTYIFNULL(dict[@"type"]) integerValue];
        self.mode = [[NSString stringWithFormat:@"%@",EMPTYIFNULL(dict[@"mode"])] integerValue];
        self.d_interval = [[NSString stringWithFormat:@"%@",EMPTYIFNULL(dict[@"delete_interval"])] integerValue];
        Message *msg = [[Message alloc] initWithDictionary:dict[@"message"]];
        msg.chatId = self.chatId;
        self.chatDate = msg.date;
        self.opponnetId = msg.opponentId;
        self.message = msg;
        
        return self;
    }
    
    return nil;
}

- (Person *)getOpponentUser {
    
    return [Person fetchUserForId:self.opponnetId];
}



+ (Chat *) fetchChatForOpponent:(Person *)opponent {
  
    ChatDL *repo = [ChatDL new];
    NSString *strQuery = [NSString stringWithFormat:kQUERY_GET_CHAT_FOR_OPPONENT,opponent.mobile];
    return [repo fetchChatWithQuery:strQuery];
    
}

+ (NSArray *) fetchAllChats {
    
    ChatDL *repo = [ChatDL new];
    NSArray *chats = [repo fetchAllChats];
    NSArray *sortedArray = [chats sortedArrayUsingComparator: ^(Chat *chat1, Chat *chat2) {
        return [chat1.chatDate compare:chat2.chatDate];
    }];
    return sortedArray;
    
}

+ (Chat *) fetchChatForId:(NSString *)chatId {
    
    ChatDL *repo = [ChatDL new];
    NSString *strQuery = [NSString stringWithFormat:kQUERY_GET_CHAT,chatId];
    return [repo fetchChatWithQuery:strQuery];

}

- (void) executeSaveQuery {
    
    ChatDL *repo = [ChatDL new];
    [repo saveChat:self];
    
        
}


- (void) deleteChat {
    ChatDL *repo = [ChatDL new];
    
    // Delte chat
    if ([repo deleteChat:self]) {
        
        // Delete all message for chat
        [Message deleteAllMessagesForChat:self];
    }
    
}


@end
