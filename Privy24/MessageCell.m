//
//  MessageCell.m
//  Whatsapp
//
//  Created by Rafael Castro on 7/23/15.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//

#import "MessageCell.h"
#import "constants.h"

#pragma mark-
#pragma mark- MESSAGE CELL IMPLEMENTATION START
@implementation MessageCell


-(CGFloat)height
{
    return _bubbleImage.frame.size.height+10;
}

-(void)updateMessageStatus
{
    [self setStatusIcon];
    
    //Animate Transition
    _statusIcon.alpha = 0;
    [UIView animateWithDuration:.5 animations:^{
        _statusIcon.alpha = 1;
    }];
}

#pragma mark -

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _textView = [[UITextView alloc] init];
        _bubbleImage = [[UIImageView alloc] init];
        _timeLabel = [[UILabel alloc] init];
        _statusIcon = [[UIImageView alloc] init];
        
        self.longPressRecognizer = [[UILongPressGestureRecognizer alloc] init];
        [self.longPressRecognizer addTarget:self action:@selector(menuControllerOpened:)];
        [_bubbleImage setUserInteractionEnabled:true];
        [_bubbleImage addGestureRecognizer:self.longPressRecognizer];

        
        [self.contentView addSubview:_bubbleImage];
        [self.contentView addSubview:_textView];
        [self.contentView addSubview:_timeLabel];
        [self.contentView addSubview:_statusIcon];
    }
    
    return self;
}


-(void)setContentWidth:(CGFloat)contentWidth {
    _contentWidth = contentWidth;
}


-(void)setMessage:(Message *)message
{
    _message = message;
    [self buildCell];
    
    message.heigh = self.height;
}

-(CGFloat)setupWithMessage:(Message *)msg withContentWidth:(CGFloat)width {
    
    _contentWidth = width;
    _message = msg;
    [self buildCell];
    
    msg.heigh = self.height;
    return msg.heigh;
}

-(void)buildCell
{
    [self setTextView];
    [self setTimeLabel];
    [self setBubble];
    [self addStatusIcon];
    [self setStatusIcon];
    
    [self setNeedsLayout];
}

- (void) menuControllerOpened:(UILongPressGestureRecognizer *)gesture {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kMENUCONTROLLER_OPENED_NOTIFICATION object:_longPressRecognizer];
}

#pragma mark - TextView

-(void)setTextView
{
    CGFloat max_witdh = 0.7*self.contentWidth;
    CGRect frame = CGRectMake(0, 0, max_witdh, MAXFLOAT);
    
    _textView.font = [UIFont systemFontOfSize:17.0];
    _textView.backgroundColor = [UIColor clearColor];
    _textView.textColor = [UIColor blackColor];
    _textView.userInteractionEnabled = NO;
    _textView.text = _message.text;
    
    CGSize size = [_textView sizeThatFits:frame.size];
    frame.size = size;
    _textView.frame = frame;
    
    CGFloat textView_x;
    CGFloat textView_y;
    CGFloat textView_w = _textView.frame.size.width;
    CGFloat textView_h = _textView.frame.size.height;
    
    if (_message.sender == MessageSenderMyself)
    {
        textView_x = self.contentWidth - textView_w - 20;
        textView_y = -3;
        textView_x -= [self isSingleLineCase]?65.0:0.0;
    }
    else
    {
        textView_x = 20;
        textView_y = -1;

    }
    
    _textView.frame = CGRectMake(textView_x, textView_y, textView_w, textView_h);
}



#pragma mark - TimeLabel

-(void)setTimeLabel
{
    _timeLabel.frame = CGRectMake(0, 0, 52, 14);
    _timeLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
    _timeLabel.userInteractionEnabled = NO;
    _timeLabel.textColor = [UIColor darkGrayColor];
    _timeLabel.alpha = 0.7;
    _timeLabel.textAlignment = NSTextAlignmentRight;
    
    //Set Text to Label
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.timeStyle = NSDateFormatterShortStyle;
    df.dateStyle = NSDateFormatterNoStyle;
    
    NSTimeZone *outputTimeZone = [NSTimeZone localTimeZone];
    [df setTimeZone:outputTimeZone];
    df.locale = [NSLocale currentLocale];
    df.doesRelativeDateFormatting = YES;
    
    NSDate *date = [AppHelper utcDateFromTimeStamp:_message.date];
    self.timeLabel.text = [df stringFromDate:date];
    
    //Set position
    CGFloat time_x;
    CGFloat time_y = _textView.frame.size.height - 10;
    
    if (_message.sender == MessageSenderMyself)
    {
        time_x = _textView.frame.origin.x + _textView.frame.size.width - _timeLabel.frame.size.width - 20;
    }
    else
    {
        time_x = MAX(_textView.frame.origin.x + _textView.frame.size.width - _timeLabel.frame.size.width,
                     _textView.frame.origin.x);
        
    }
    
    if ([self isSingleLineCase])
    {
        time_x = _textView.frame.origin.x + _textView.frame.size.width - 5;
        time_y -= 10;
    }
    
    _timeLabel.frame = CGRectMake(time_x,
                                  time_y,
                                  _timeLabel.frame.size.width,
                                  _timeLabel.frame.size.height);
    
}
-(BOOL)isSingleLineCase
{
    CGFloat delta_x = _message.sender == MessageSenderMyself?65.0:44.0;
    
    CGFloat textView_height = _textView.frame.size.height;
    CGFloat textView_width = _textView.frame.size.width;
    CGFloat view_width = self.contentWidth;
    
    //Single Line Case
    return (textView_height <= 45 && textView_width + delta_x <= 0.8*view_width)?YES:NO;
}

#pragma mark - Bubble

- (void)setBubble
{
    //Margins to Bubble
    CGFloat marginLeft = 5;
    CGFloat marginRight = 2;
    
    //Bubble positions
    CGFloat bubble_x;
    CGFloat bubble_y = 0;
    CGFloat bubble_width;
    CGFloat bubble_height = MIN(_textView.frame.size.height + 8,
                                _timeLabel.frame.origin.y + _timeLabel.frame.size.height + 6);
    
    if (_message.sender == MessageSenderMyself)
    {
        
        bubble_x = MIN(_textView.frame.origin.x -marginLeft,_timeLabel.frame.origin.x - 2*marginLeft);
        
        _bubbleImage.image = [[UIImage imageNamed:@"Msg_Out"]
                              stretchableImageWithLeftCapWidth:15 topCapHeight:14];
        
        
        bubble_width = self.contentWidth - bubble_x - marginRight;
    }
    else
    {
        bubble_x = marginRight;
        
        _bubbleImage.image = [[UIImage imageNamed:@"Msg_In"]
                              stretchableImageWithLeftCapWidth:21 topCapHeight:14];
        
        bubble_width = MAX(_textView.frame.origin.x + _textView.frame.size.width + marginLeft,
                           _timeLabel.frame.origin.x + _timeLabel.frame.size.width + 2*marginLeft);
    }
    
    _bubbleImage.frame = CGRectMake(bubble_x, bubble_y, bubble_width, bubble_height);
}

#pragma mark - StatusIcon

-(void)addStatusIcon
{
    CGRect time_frame = _timeLabel.frame;
    CGRect status_frame = CGRectMake(0, 0, 15, 14);
    status_frame.origin.x = time_frame.origin.x + time_frame.size.width + 5;
    status_frame.origin.y = time_frame.origin.y;
    _statusIcon.frame = status_frame;
    _statusIcon.contentMode = UIViewContentModeLeft;
}
-(void)setStatusIcon
{
    if (self.message.readStatus == MessageStatusSending)
        _statusIcon.image = [UIImage imageNamed:@"status_sending"];
    else if (self.message.readStatus == MessageStatusSent)
        _statusIcon.image = [UIImage imageNamed:@"status_sent"];
    else if (self.message.readStatus == MessageStatusReceived)
        _statusIcon.image = [UIImage imageNamed:@"status_notified"];
    else if (self.message.readStatus == MessageStatusRead)
        _statusIcon.image = [UIImage imageNamed:@"status_read"];
    else if (self.message.readStatus == MessageStatusFailed)
        _statusIcon.image = nil;
    
    _statusIcon.hidden = _message.sender == MessageSenderSomeone;
}


@end


#pragma mark-
#pragma mark- NOTIFICATION CELL IMPLEMENTATION START
@implementation NotificationCell

-(CGFloat)height
{
        return 30;
}


#pragma mark -

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _notifLabel = [[UILabel alloc] init];
        [self.contentView addSubview:_notifLabel];
    }
    return self;
}

-(void)setContentWidth:(CGFloat)contentWidth {
    _contentWidth = contentWidth;
}

-(void)setMessage:(Message *)message
{
    _message = message;
    [self buildCell];
    
    message.heigh = self.height;
}
-(void)buildCell
{
    [self setNotificationLabel];
    
    [self setNeedsLayout];
}

#pragma mark - TextView


- (void)setNotificationLabel {
    
    _notifLabel.frame = CGRectMake((self.contentWidth-240)/2, 0, 240, 20);
    _notifLabel.textColor = [UIColor whiteColor];
    _notifLabel.font = [UIFont systemFontOfSize:13.0f];
    _notifLabel.alpha = 0.8;
    _notifLabel.text = _message.text;
    _notifLabel.backgroundColor = [UIColor darkGrayColor];
    _notifLabel.layer.cornerRadius = 10.0f;
    _notifLabel.layer.masksToBounds = true;
    _notifLabel.textAlignment = NSTextAlignmentCenter;
}

@end

#pragma mark-
#pragma mark- ATTACHMENT CELL IMPLEMENTATION START
@implementation AttachmentCell

-(CGFloat)height
{
    return _bubbleImage.frame.size.height+10;
}
-(void)updateMessageStatus
{
    [self setStatusIcon];
    
    //Animate Transition
    _statusIcon.alpha = 0;
    [UIView animateWithDuration:.5 animations:^{
        _statusIcon.alpha = 1;
    }];
}

#pragma mark -

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _attachmentImage  = [[UIImageView alloc] init];
        
        _blurrView        = [[UIView alloc] init];
        [_blurrView setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.5f]];
        
        _bubbleImage      = [[UIImageView alloc] init];
        _timeLabel        = [[UILabel alloc] init];
        _statusIcon       = [[UIImageView alloc] init];
        
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
        _activityIndicator.hidesWhenStopped = YES;
        _activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        _activityIndicator.color = [UIColor whiteColor];
        
        self.download_uploadBtn =  [UIButton buttonWithType:UIButtonTypeCustom];
        [self.download_uploadBtn setImage:[UIImage imageNamed:@"upload"] forState:UIControlStateNormal];
        [self.download_uploadBtn addTarget:self action:@selector(uploadDownloadAttachment:) forControlEvents:UIControlEventTouchUpInside];
        
        
        [_attachmentImage setUserInteractionEnabled:true];
        _attachmentImage.clipsToBounds = YES;
        _attachmentImage.contentMode = UIViewContentModeScaleAspectFill;
        
        self.tapRecognizer = [[UITapGestureRecognizer alloc] init];
        [self.tapRecognizer addTarget:self action:@selector(attachmentOpened:)];
        [_attachmentImage setUserInteractionEnabled:true];
        [_attachmentImage addGestureRecognizer:self.tapRecognizer];
        
        
        [self.contentView addSubview:_bubbleImage];
        [self.contentView addSubview:_attachmentImage];
        [self.contentView addSubview:_timeLabel];
        [self.contentView addSubview:_statusIcon];
        [self.contentView addSubview:_blurrView];
        [self.contentView addSubview:_activityIndicator];
        [self.contentView addSubview:_download_uploadBtn];
    }
    return self;
}

- (void) attachmentOpened:(UITapGestureRecognizer *)gesture {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kATTACHMENT_OPENED_NOTIFICATION object:_message];
}

-(void)setContentWidth:(CGFloat)contentWidth {
    _contentWidth = contentWidth;
}
-(void)setMessage:(Message *)message
{
    _message = message;
    [self buildCell];
    
    message.heigh = self.height;
}
-(void)buildCell
{
    [self setAttachment];
    [self setTimeLabel];
    [self setBubble];
    [self addStatusIcon];
    [self setStatusIcon];
    [self addActivityIndicator];
    
    [self setNeedsLayout];
}

#pragma mark - TextView

-(void)setAttachment{
    
    CGFloat max_witdh = 0.6*self.contentWidth;
    CGFloat max_height = max_witdh;
    
    CGFloat x;
    CGFloat y = 5;
    CGFloat w = max_witdh;
    CGFloat h = max_height;
    
    if (_message.sender == MessageSenderMyself)
    {
        x = self.contentWidth - w - 10;
        
    }
    else
    {
        x = 10;
    }
    
    _attachmentImage.layer.cornerRadius = 4.0f;
    _attachmentImage.layer.masksToBounds = true;
    _attachmentImage.frame = CGRectMake(x, y, w-5, h-10);
    
    _blurrView.frame = _attachmentImage.frame;
    _blurrView.layer.cornerRadius = _attachmentImage.layer.cornerRadius;
    
    if (_message.attachmentStatus == AttachmentStatusUploading) {
        
        NSString *pdfFileName = [kDOCUMENT_FOLDER_PATH stringByAppendingPathComponent:[_message getLocalName]];
        UIImage *image=[UIImage imageWithContentsOfFile:pdfFileName];
        _attachmentImage.image = image;
        
        if ([[SocketLisner sharedLisner].imgOperations containsObject:[_message getLocalName]]) {
            [_activityIndicator startAnimating];
            _blurrView.hidden = NO;
            _download_uploadBtn.hidden = YES;
        } else {
            [_activityIndicator stopAnimating];
            _blurrView.hidden = NO;
            _download_uploadBtn.hidden = NO;
        }

    } else if (_message.attachmentStatus == AttachmentStatusDownloading) {
        
        [_activityIndicator startAnimating];
        _blurrView.hidden = NO;
        _download_uploadBtn.hidden = YES;
        
        NSData* data = [NSData dataFromBase64String:_message.attachment.thumbnail];
        UIImage* image = [UIImage imageWithData:data];
        
        [_attachmentImage sd_setImageWithURL:[NSURL URLWithString:_message.attachment.url] placeholderImage:image completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            // Save image to document directory here..
            // This will reduce future downloading of image
            //_message.attachment.image = image;
            _attachmentImage.image = image;
            [_activityIndicator stopAnimating];
            _blurrView.hidden = YES;
            
            NSString *savedImagePath = [kDOCUMENT_FOLDER_PATH stringByAppendingPathComponent:[_message getLocalName]];
            NSData *imageData = UIImagePNGRepresentation(image);
            [imageData writeToFile:savedImagePath atomically:NO];
            
            [_message setAttachmentStatus:AttachmentStatusDownloaded];
            [_message updateStatus];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kATTACHMENT_DOWNLOADED_NOTIFICATION object:_message];
            
        }];
        
    }
    
    else {
    
        [_activityIndicator stopAnimating];
        _blurrView.hidden = YES;
        _download_uploadBtn.hidden = YES;
        
        NSString *pdfFileName = [kDOCUMENT_FOLDER_PATH stringByAppendingPathComponent:[_message getLocalName]];
        UIImage *image=[UIImage imageWithContentsOfFile:pdfFileName];
        _attachmentImage.image = image;
    }
    
    
}

#pragma mark - TimeLabel

-(void)setTimeLabel {
    
    _timeLabel.frame = CGRectMake(0, 0, 52, 14);
    _timeLabel.textColor = [UIColor lightGrayColor];
    _timeLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
    _timeLabel.userInteractionEnabled = NO;
    _timeLabel.alpha = 0.7;
    _timeLabel.textAlignment = NSTextAlignmentRight;
    
    //Set Text to Label
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.timeStyle = NSDateFormatterShortStyle;
    df.dateStyle = NSDateFormatterNoStyle;
    
    NSTimeZone *outputTimeZone = [NSTimeZone localTimeZone];
    [df setTimeZone:outputTimeZone];
    df.locale = [NSLocale currentLocale];
    df.doesRelativeDateFormatting = YES;
    
    self.timeLabel.text = [df stringFromDate:[AppHelper utcDateFromTimeStamp:_message.date]];
    
    //Set position
    CGFloat time_x;
    CGFloat time_y = _attachmentImage.frame.size.height - 10;
    
    if (_message.sender == MessageSenderMyself)
    {
        time_x = _attachmentImage.frame.origin.x + _attachmentImage.frame.size.width - _timeLabel.frame.size.width - 25;
    }
    else
    {
        time_x = MAX(_attachmentImage.frame.origin.x + _attachmentImage.frame.size.width - _timeLabel.frame.size.width-5,
                     _attachmentImage.frame.origin.x);
    }
    
    _timeLabel.frame = CGRectMake(time_x,
                                  time_y,
                                  _timeLabel.frame.size.width,
                                  _timeLabel.frame.size.height);
    
}

#pragma mark - Bubble

- (void)setBubble {
    //Margins to Bubble
    CGFloat marginLeft = 5;
    CGFloat marginRight = 0;
    
    //Bubble positions
    CGFloat bubble_x;
    CGFloat bubble_y = 0;
    CGFloat bubble_width;
    CGFloat bubble_height = _attachmentImage.frame.size.height + 10;
    
    if (_message.sender == MessageSenderMyself)
    {
        
        bubble_x = _attachmentImage.frame.origin.x - marginLeft;
        
        _bubbleImage.image = [[UIImage imageNamed:@"Msg_Out"]
                              stretchableImageWithLeftCapWidth:15 topCapHeight:14];
        
        
        bubble_width = self.contentWidth - bubble_x - marginRight;
    }
    else
    {
        bubble_x = marginRight;
        
        _bubbleImage.image = [[UIImage imageNamed:@"Msg_In"]
                              stretchableImageWithLeftCapWidth:21 topCapHeight:14];
        
        bubble_width = _attachmentImage.frame.origin.x + _attachmentImage.frame.size.width + marginLeft;
    }
    
    _bubbleImage.frame = CGRectMake(bubble_x, bubble_y, bubble_width, bubble_height);
}

- (void) addActivityIndicator {

    self.activityIndicator.frame = CGRectMake(_attachmentImage.frame.origin.x+(_attachmentImage.frame.size.width-40)/2, (_attachmentImage.frame.size.height-40)/2, 40, 40);
    
    [self.download_uploadBtn setFrame:CGRectMake(_attachmentImage.frame.origin.x+(_attachmentImage.frame.size.width-27)/2, (_attachmentImage.frame.size.height-27)/2, 27, 27)];
    
    [self.download_uploadBtn setImage:[UIImage imageNamed:(_message.sender == MessageSenderMyself)?@"upload":@"download"] forState:UIControlStateNormal];
    
    
    
}


#pragma mark - StatusIcon

-(void)addStatusIcon
{
    CGRect time_frame = _timeLabel.frame;
    CGRect status_frame = CGRectMake(0, 0, 15, 14);
    status_frame.origin.x = time_frame.origin.x + time_frame.size.width + 5;
    status_frame.origin.y = time_frame.origin.y;
    _statusIcon.frame = status_frame;
    _statusIcon.contentMode = UIViewContentModeLeft;
}
-(void)setStatusIcon
{
    if (self.message.readStatus == MessageStatusSending)
        _statusIcon.image = [UIImage imageNamed:@"status_sending"];
    else if (self.message.readStatus == MessageStatusSent)
        _statusIcon.image = [UIImage imageNamed:@"status_sent"];
    else if (self.message.readStatus == MessageStatusReceived)
        _statusIcon.image = [UIImage imageNamed:@"status_notified"];
    else if (self.message.readStatus == MessageStatusRead)
        _statusIcon.image = [UIImage imageNamed:@"status_read"];
    else {
        _statusIcon.image = nil;
    }
    
    if (self.message.attachmentStatus == AttachmentStatusUploading)
        _statusIcon.image = nil;
    
    _statusIcon.hidden = _message.sender == MessageSenderSomeone;
    
}

- (void)uploadDownloadAttachment:(UIButton *)sender {
    
    if (_message.sender == MessageSenderMyself)
    {
        _download_uploadBtn.hidden = YES;
        [_activityIndicator startAnimating];
        _blurrView.hidden = NO;
        
        _message.attachmentStatus = AttachmentStatusUploading;
        [_message executeSaveQuery];
        
        NSString *pdfFileName = [kDOCUMENT_FOLDER_PATH stringByAppendingPathComponent:[_message getLocalName]];
        UIImage *image=[UIImage imageWithContentsOfFile:pdfFileName];
        NSData *data = UIImagePNGRepresentation(image);
        
        [[SocketLisner sharedLisner].imgOperations addObject:[_message getLocalName]];
        [[SocketLisner sharedLisner] uplaodImage:_message withImage:data];
        
    }
    else
    {
        _download_uploadBtn.hidden = YES;
        [_activityIndicator startAnimating];
        _blurrView.hidden = NO;
        
        _message.attachmentStatus = AttachmentStatusDownloading;
        [_message executeSaveQuery];
        
        
        
        NSData* data = [NSData dataFromBase64String:_message.attachment.thumbnail];
        UIImage* image = [UIImage imageWithData:data];
        
        [_attachmentImage sd_setImageWithURL:[NSURL URLWithString:_message.attachment.url] placeholderImage:image completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            // Save image to document directory here..
            // This will reduce future downloading of image
            //_message.attachment.image = image;
            _attachmentImage.image = image;
            [_activityIndicator stopAnimating];
            _blurrView.hidden = YES;
            
            NSString *savedImagePath = [kDOCUMENT_FOLDER_PATH stringByAppendingPathComponent:[_message getLocalName]];
            NSData *imageData = UIImagePNGRepresentation(image);
            [imageData writeToFile:savedImagePath atomically:NO];
            
            [_message setAttachmentStatus:AttachmentStatusDownloaded];
            [_message updateStatus];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kATTACHMENT_DOWNLOADED_NOTIFICATION object:_message];
            
        }];
    }
}


@end

