//
//  MessageCell.h
//  Whatsapp
//
//  Created by Rafael Castro on 7/23/15.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"
#import "BaseMessageCell.h"

//
// This class build bubble message cells
// for Income or Outgoing messages
//
@interface MessageCell : BaseMessageCell

@property (strong, nonatomic) Message *message;

@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UIImageView *bubbleImage;
@property (strong, nonatomic) UIImageView *statusIcon;
@property (strong, nonatomic) UILongPressGestureRecognizer *longPressRecognizer;

-(CGFloat)height;
@property (readwrite, nonatomic) CGFloat contentWidth;

-(void)updateMessageStatus;
-(CGFloat)setupWithMessage:(Message *)msg withContentWidth:(CGFloat)width;


@end

@interface NotificationCell : BaseMessageCell

@property (strong, nonatomic) Message *message;

@property (strong, nonatomic) UILabel *notifLabel;

-(CGFloat)height;
@property (readwrite, nonatomic) CGFloat contentWidth;

@end

@interface AttachmentCell : BaseMessageCell

@property (strong, nonatomic) Message *message;

@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UIImageView *attachmentImage;
@property (strong, nonatomic) UIButton *download_uploadBtn;
@property (strong, nonatomic) UIView *blurrView;
@property (strong, nonatomic) UIImageView *bubbleImage;
@property (strong, nonatomic) UIImageView *statusIcon;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;

-(CGFloat)height;
@property (readwrite, nonatomic) CGFloat contentWidth;

-(void)updateMessageStatus;

@end
