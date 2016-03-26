//
//  MessageHandler.m
//  
//
//  Created by Apple on 25/03/16.
//
//

#import "MessageHandler.h"
#import "Message.h"
#import "MessageDL.h"

@implementation MessageHandler

+(instancetype)sharedHandler
{
    static MessageHandler *sharedHandler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedHandler = [[self alloc] init];
    });
    return sharedHandler;
}
-(id)init
{
    self = [super init];
    
    if (self)
    {
        
    }
    return self;
}

- (void)scheduleMessages {
    
    NSArray *msgArray = [Message fetchAllScheduledMessage];
    for (Message *msg in msgArray) {
        [self addMessage:msg];
    }
}
- (void)addMessage:(Message *)msg {
    
    BOOL isSchedule = NO;
    
    if (msg.messageStatus == Scheduled) {
        
        isSchedule = YES;
        
        NSDate *scheduledDate = [AppHelper utcDateFromTimeStamp:msg.scheduleDate];
        NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:scheduledDate];
        int diff = msg.d_interval - interval;
        msg.d_interval = 0;
        if (diff > 0) {
            msg.d_interval = diff;
        }
        
        
    }
    
    else {
        
        if (msg.readStatus == MessageStatusRead && msg.type != MessageTypeNotification) {
            
            if (msg.mode == MessageModeBothEnd) {
                
                isSchedule = YES;
                msg.scheduleDate = [AppHelper utcStringFromDate:[NSDate date]];
                msg.messageStatus = Scheduled;
                
            } else if (msg.mode == MessageModeReceiverEnd && msg.sender == MessageSenderSomeone) {
                
                isSchedule = YES;
                msg.scheduleDate = [AppHelper utcStringFromDate:[NSDate date]];
                msg.messageStatus = Scheduled;
            }
        }
    }
    
    if (isSchedule) {
        
        [msg schedule];
        
        [NSTimer scheduledTimerWithTimeInterval:msg.d_interval target:self selector:@selector(deleteMessage:) userInfo:msg repeats:NO];
    }
    
}

- (void)deleteMessage:(NSTimer*)dt {
    
    Message *msg = (Message *)dt.userInfo;
    [msg deleteMessage];
    [[NSNotificationCenter defaultCenter] postNotificationName:kDELETE_MESSAGE_NOTIFICATION object:msg];
}


@end
