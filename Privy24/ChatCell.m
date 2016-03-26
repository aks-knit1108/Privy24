//
//  ChatListCell.m
//  Whatsapp
//
//  Created by Rafael Castro on 7/24/15.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//

#import "ChatCell.h"
#import "constants.h"

@interface ChatCell()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *picture;
@property (weak, nonatomic) IBOutlet UILabel *notificationLabel;
@end



@implementation ChatCell

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    self.picture.layer.cornerRadius = self.picture.frame.size.width/2;
    self.picture.layer.masksToBounds = YES;
    self.notificationLabel.layer.cornerRadius = self.notificationLabel.frame.size.width/2;
    self.notificationLabel.layer.masksToBounds = YES;
    self.notificationLabel.backgroundColor = kAPP_COLOR;
    self.notificationLabel.textColor = [UIColor whiteColor];
    self.nameLabel.text = @"";
    self.messageLabel.text = @"";
    self.timeLabel.text = @"";
}
-(void)setChat:(Chat *)chat
{
    _chat = chat;
    Person *opponnetUser = [_chat getOpponentUser];
    
    if ([opponnetUser.localName length] != 0 ) {
        
        self.nameLabel.text = opponnetUser.localName;
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kImageUrl,opponnetUser.image]];
        [self.picture sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"no-img.png"]];
    } else {
    
        self.nameLabel.text = [NSString stringWithFormat:@"+%@ %@",opponnetUser.countryCode,opponnetUser.mobile];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kImageUrl,opponnetUser.image]];
        [self.picture sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"no-img.png"]];
    }
    
    Message *msg = [Message fetchLastMessageForChat:_chat];
    
    if (msg.type == MessageTypeAttachment) {
        
        UTF32Char c = 0x1F4F7;
        NSData *utf32Data = [NSData dataWithBytes:&c length:sizeof(c)];
        NSString *camera = [[NSString alloc] initWithData:utf32Data encoding:NSUTF32LittleEndianStringEncoding];
        self.messageLabel.text = [NSString stringWithFormat:@"%@ photo",camera];
        
    } else {
        
        self.messageLabel.text = msg.text;
    }
    
    
    
    if (self.chat.mode != MessageModeOff) {
        self.nameLabel.textColor = kAPP_COLOR;
    } else {
        self.nameLabel.textColor = [UIColor blackColor];
    }
    NSDate *date = [AppHelper utcDateFromTimeStamp:chat.chatDate];
    
    NSInteger unreadCount = [Message fetchUnreadCountForChat:chat];
    [self updateTimeLabelWithDate:date];
    [self updateUnreadMessagesIcon:unreadCount];
}
-(void)updateTimeLabelWithDate:(NSDate *)date
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.timeStyle = NSDateFormatterShortStyle;
    df.dateStyle = NSDateFormatterNoStyle;
    df.doesRelativeDateFormatting = NO;
    self.timeLabel.text = [df stringFromDate:date];
    self.timeLabel.textColor = [UIColor lightGrayColor];
}
-(void)updateUnreadMessagesIcon:(NSInteger)numberOfUnreadMessages
{
    self.notificationLabel.hidden = numberOfUnreadMessages == 0;
    self.notificationLabel.text = [NSString stringWithFormat:@"%ld", (long)numberOfUnreadMessages];
    self.timeLabel.textColor = (numberOfUnreadMessages == 0)?[UIColor lightGrayColor]:kAPP_COLOR;
    
}

@end
