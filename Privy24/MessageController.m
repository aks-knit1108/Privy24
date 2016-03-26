//
//  MessageController.m
//  Whatsapp
//
//  Created by Rafael Castro on 7/23/15.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//

#import "MessageController.h"
#import "MessageCell.h"
#import "Privy24-Swift.h"
#import "FullImageViewer.h"
#import "Reachability.h"
#import "NetworkView.h"
#import "ASChatInput.h"
#import "CustomTitleView.h"
#import "ContactDetailVC.h"
#import <QBImagePickerController/QBImagePickerController.h>
#import "CustomMenu.h"
#import "MessageHandler.h"

@interface MessageController() <UITableViewDataSource,UITableViewDelegate,SBPickerSelectorDelegate,ASChatInputDelegate,CustomTitleViewDelegate,QBImagePickerControllerDelegate>

@property (strong, nonatomic) UIButton *privyBtn;
@property (strong, nonatomic) NSString *mode;

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) ASChatInput *chatInput;
@property (strong, nonatomic) NSLayoutConstraint *bottomChatInputConstraint;
@property (readwrite, nonatomic) BOOL isTyping;
@property (strong,nonatomic) NSTimer *typingTimer;
@property (strong,nonatomic) CustomTitleView *titleView;

@end


@implementation MessageController

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

-(BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action
              withSender:(id)sender
{
    BOOL result = NO;
    if(@selector(copyAction:) == action ||
       @selector(deleteAction:) == action) {
        result = YES;
    }
    return result;
}

// UIMenuController Methods

// Default copy method
- (void)copyAction:(id)sender {
    NSLog(@"Copy");
    
    UIMenuController *targetSender = (UIMenuController *)sender ;
    CustomMenu *menuItem=(CustomMenu *)[targetSender.menuItems firstObject];
    Message *msg = [self.messageArray objectAtIndex:menuItem.indexPath.row];
    
    if (msg.type == MessageTypeText) {
        [UIPasteboard generalPasteboard].string = msg.text;
    }
    
}

// Our custom method
- (void)deleteAction:(id)sender {
    
    NSLog(@"Delete Action");
    UIMenuController *targetSender = (UIMenuController *)sender ;
    CustomMenu *menuItem=(CustomMenu *)[targetSender.menuItems firstObject];
    
    Message *msg = [self.messageArray objectAtIndex:menuItem.indexPath.row];
    [msg deleteMessage];
    [self.messageArray removeObjectAtIndex:menuItem.indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[menuItem.indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
}


-(void)viewDidLoad
{
    [super viewDidLoad];

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] init];
    [tapRecognizer addTarget:self action:@selector(tapGestureMethod:)];
    [self.view addGestureRecognizer:tapRecognizer];
    
    self.isTyping = NO;
    
    self.titleView = [[CustomTitleView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    [self.titleView setDelegate:self];
    [self.navigationItem setTitleView:self.titleView];
    
    
    [self setup];
    [self addListners];
    
    BOOL connectionRequired = [kAPP_DELEGATE.reachability connectionRequired];
    [self enableControls:!connectionRequired];
    
    /* **** <startChat> ****
     * Call start chat if user is starting completely new chat
     * For this check chat id
     * Also Param - isStartChatCalled is used fro avoiding multiple calls of new chat method
     */
    
    [self.titleView setStatus:@""];
    
    
    if ([self.chat.chatId length] == 0) {
        
        [[SocketLisner sharedLisner] startChatWithUser:self.opponentUser];
        
    } else {
    
        [SocketLisner sharedLisner].chatId = self.chat.chatId;
        [self setStatusOfPrivyButton];
        
        
        
        // Load older chat here
        [self.messageArray removeAllObjects];
        [self.messageArray addObjectsFromArray:[Message fetchAllMessageForChat:self.chat withLimit:0]];
        
        [self.tableView reloadData];
        
        
        if(self.messageArray.count > 0) {
            
            // Reload table
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.messageArray count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
        
        // Check satus for sender
        NSArray *unreadMessagesSender = [Message fetchDeliveredMessagesForChat:self.chat];
        [[SocketLisner sharedLisner] checkStatusForMessages:unreadMessagesSender];
        
        // Update message sttaus 2 Read for all messages;
        [Message updateAllMessageReadForChat:self.chat];
        
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[Message fetchUnreadCountForAllChat]];
        
        // Set pending messages
        [self sendPendingMessage];
        
        [[SocketLisner sharedLisner] enterChatWithPrams:@[@{@"chat_id":self.chat.chatId,@"receiver_id":self.opponentUser.mobile}]];
        
    }
}

- (void) setup {
    
    [self setupTableView];
    [self setupChatInput];
    [self setupLayoutConstraints];
    
    self.user = [SocketLisner sharedLisner].user;
    self.messageArray = [NSMutableArray new];
    
    self.chat = (self.chat)?(self.chat):[Chat new];
    
    self.privyBtn =  [UIButton buttonWithType:UIButtonTypeSystem];
    [self.privyBtn setBackgroundColor:[UIColor darkGrayColor]];
    [self.privyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.privyBtn setTitle:@"P" forState:UIControlStateNormal];
    [self.privyBtn addTarget:self action:@selector(startPrivy:) forControlEvents:UIControlEventTouchUpInside];
    [self.privyBtn.layer setCornerRadius:15.0f];
    [self.privyBtn.layer setMasksToBounds:YES];
    [self.privyBtn setFrame:CGRectMake(0, 0, 30, 30)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.privyBtn];
    self.privyBtn.tintColor = [UIColor darkGrayColor];
    
    [self.titleView setTitle:([self.opponentUser.localName length] != 0 )?self.opponentUser.localName:[NSString stringWithFormat:@"+%@ %@",self.opponentUser.countryCode,self.opponentUser.mobile]];

}

- (void) setupTableView {
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.allowsSelection = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.frame = self.view.bounds;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.contentInset = UIEdgeInsetsMake(10,0,0,0);
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    [self.view addSubview:self.tableView];
    
    [self.tableView registerClass:[MessageCell class] forCellReuseIdentifier: @"MessageCell"];
    [self.tableView registerClass:[NotificationCell class] forCellReuseIdentifier: @"NotificationCell"];
    [self.tableView registerClass:[AttachmentCell class] forCellReuseIdentifier: @"AttachmentCell"];
}

- (void) setupChatInput {
    
    self.chatInput = [[ASChatInput alloc] initWithFrame:CGRectZero];
    self.chatInput.delegate = self;
    [self.view addSubview:self.chatInput];
}

- (void) setupLayoutConstraints{
    
    self.chatInput.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self setUpchatInputConstraints];
    [self setUptableViewConstraints];
}

- (void) setUpchatInputConstraints {
    
    self.bottomChatInputConstraint = [NSLayoutConstraint constraintWithItem:self.chatInput attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.bottomLayoutGuide attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
   
    
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.chatInput attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    
    
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.chatInput attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];

    [self.view addConstraints:@[leftConstraint,self.bottomChatInputConstraint,rightConstraint]];
}

- (void) setUptableViewConstraints {
    
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    
    
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    
    
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.chatInput attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    
    
    [self.view addConstraints:@[rightConstraint, leftConstraint, topConstraint, bottomConstraint]];

}


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    
}

- (void) enableControls:(BOOL)enabled {
    self.privyBtn.enabled = enabled;
    [self.chatInput enableControls:enabled];
}


- (void) addListners {

    // Set keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification object:nil];
    
    /*
     Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the method reachabilityChanged will be called.
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socketConnected:)
                                                 name:kSOCKET_CONNECTION_CONNECTED object:nil];
    
    
    // Receive message Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveChat:) name:kRECEIVE_CHAT_NOTIIFCATION object:nil];
    
    // Receive Online user Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveUserStatus:) name:kONLINE_USER_NOTIIFCATION object:nil];
    
    // Receive message Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMessage:) name:kMESSAGE_RECEIVE_NOTIIFCATION object:nil];
    
    // Load messages
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMessageStatus:) name:kMESSAGE_STATUS_NOTIIFCATION object:nil];
    
    // Delete Privy messages
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deletePrivyMessage:) name:kDELETE_MESSAGE_NOTIFICATION object:nil];
    
    // Attachment uploaded messages
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(attachmentUploadedMessage:) name:kATTACHMENT_UPLOADED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(attachmentDownloadedMessage:) name:kATTACHMENT_DOWNLOADED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(attachmentErrorMessage:) name:kATTACHMENT_ERROR_NOTIFICATION object:nil];
    
    // Attachment uploaded messages
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(attachmentOpenedMessage:) name:kATTACHMENT_OPENED_NOTIFICATION object:nil];
    

    // Menu opened Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuControllerOpened:) name:kMENUCONTROLLER_OPENED_NOTIFICATION object:nil];
    
    // Typing Message Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userTypingMessage:) name:kTYPING_MESSAGE_NOTIFICATION object:nil];
}


- (void)receiveUserStatus:(NSNotification *)notif {
    
    Person *user = notif.object;
    if (CONVERT_TO_INTEGER(user.mobile) == CONVERT_TO_INTEGER(self.opponentUser.mobile)) {
        self.opponentUser.online = user.online;
        
        if (self.opponentUser.online) {
            [self.titleView setStatus:@"online"];
        } else {
            [self.titleView setStatus:@""];
        }
    }
    
}

- (void)userTypingMessage:(NSNotification *)notif {
    
    NSDictionary *dict = notif.object;
    
    NSString *chat_id    = EMPTYIFNULL(dict[@"chat_id"]);
    NSString *user_id    = EMPTYIFNULL(dict[@"user_id"]);
    BOOL is_typing       = [EMPTYIFNULL(dict[@"is_typing"]) boolValue];
    
    if ([self.chat.chatId isEqualToString:chat_id] && ![user_id isEqualToString:self.user.mobile]) {
        
        if (is_typing == 1) {
            [self.titleView setStatus:@"typing.."];
        } else {
            
            if (self.opponentUser.online) {
                [self.titleView setStatus:@"online"];
            } else {
                [self.titleView setStatus:@""];
            }
        }
    }
    
}



- (void)receiveChat:(NSNotification *)notif {
    
    NSDictionary *dict = notif.object;
    NSLog(@"receiveChat = %@",dict);
    
    self.chat.chatId               = EMPTYIFNULL(dict[@"chat_id"]);
    self.chat.mode = [[NSString stringWithFormat:@"%@",EMPTYIFNULL(dict[@"mode"])] integerValue];
    self.chat.d_interval = [[NSString stringWithFormat:@"%@",EMPTYIFNULL(dict[@"delete_interval"])] integerValue];
    
    [SocketLisner sharedLisner].chatId = self.chat.chatId;
    
    [self setStatusOfPrivyButton];
    
    [[SocketLisner sharedLisner] enterChatWithPrams:@[@{@"chat_id":self.chat.chatId,@"receiver_id":self.opponentUser.mobile}]];
}


- (void)receiveMessage:(NSNotification *)notif {
    
    Message *message = notif.object;
    
    if (message.sender == MessageSenderSomeone) {
        
        BOOL isAddMessage = YES;
        
        // Update local array with new message status
        if (self.messageArray.count != 0) {
            Message *msg = [self.messageArray lastObject];
            if ([msg.messageId isEqualToString:message.messageId]) {
                isAddMessage = NO;
            }
        }
        
        if (isAddMessage) {
            
            [self.messageArray addObject:message];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.messageArray indexOfObject:message] inSection:0];
            
            [self scrollRowAtIndexPath:indexPath];
            
            self.chat.mode = message.mode;
            self.chat.d_interval = message.d_interval;
            
            [self setStatusOfPrivyButton];
            
        }
        
    }
    
    else {
        
        NSIndexPath *indexPath = [self indexPathForLocalMessage:message];
        
        if (indexPath != nil) {
            
            [self.messageArray replaceObjectAtIndex:indexPath.row withObject:message];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            
            [message schedule];
        }
        
        
        
    }
    
}


- (void)receiveMessageStatus:(NSNotification *)notif {
    
    Message *message = notif.object;
    
    NSIndexPath *indexPath = [self indexPathForMessage:message];
    
    if (indexPath) {
        
        Message *msg = [self.messageArray objectAtIndex:indexPath.row];
        
        if (msg.readStatus != message.readStatus) {
            
            msg.readStatus = message.readStatus;
            [msg updateStatus];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            
        }
        
        [[MessageHandler sharedHandler] addMessage:msg];
    }
}

- (void)deletePrivyMessage:(NSNotification *)notif {
    
    Message *message = notif.object;

    NSIndexPath *indexPath = [self indexPathForMessage:message];
    
    if (indexPath) {
        
        [self.messageArray removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
    }
    
}

- (void)attachmentUploadedMessage:(NSNotification *)notif {
    
    Message *message = notif.object;
    
    if (message.chatId == self.chat.chatId) {
        
        for (NSUInteger index = self.messageArray.count; index>0; index--) {
            
            Message *msg = [self.messageArray objectAtIndex:index-1];
            
            if ([msg.date isEqualToString:message.date]) {
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index-1 inSection:0];
                [self.messageArray replaceObjectAtIndex:indexPath.row withObject:message];
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                
                break;
            }
            
        }
        
        
    }
    
}

- (void)attachmentDownloadedMessage:(NSNotification *)notif {
    
    Message *message = notif.object;
    
    if (message.chatId == self.chat.chatId) {
        
        for (NSUInteger index = self.messageArray.count; index>0; index--) {
            
            Message *msg = [self.messageArray objectAtIndex:index-1];
            
            if ([msg.messageId isEqualToString:message.messageId]) {
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index-1 inSection:0];
                [self.messageArray replaceObjectAtIndex:indexPath.row withObject:message];
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                
                break;
            }
            
        }
        
        
    }
    
}


- (void)attachmentErrorMessage:(NSNotification *)notif {
    
    Message *message = notif.object;
    
    if (message.chatId == self.chat.chatId) {
        
        for (NSUInteger index = self.messageArray.count; index>0; index--) {
            
            Message *msg = [self.messageArray objectAtIndex:index-1];
            
            if ([msg.messageId isEqualToString:message.messageId]) {
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index-1 inSection:0];
                [self.messageArray replaceObjectAtIndex:indexPath.row withObject:message];
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                
                break;
            }
            
        }
        
        
    }
    
}



- (void)attachmentOpenedMessage:(NSNotification *)notif {

    Message *message = notif.object;
    
    NSString *pdfFileName = [kDOCUMENT_FOLDER_PATH stringByAppendingPathComponent:[message getLocalName]];
    UIImage *image=[UIImage imageWithContentsOfFile:pdfFileName];
    
    if (image != nil) {
        
        FullImageViewer *imageViewer = [[FullImageViewer alloc] initWithImage:image];
        [imageViewer presentWithAnimation:YES];
        
        
    } else {
    
        FullImageViewer *imageViewer = [[FullImageViewer alloc] initWithUrl:message.attachment.url];
        [imageViewer presentWithAnimation:YES];
    }
    
}

- (void)menuControllerOpened:(NSNotification *)notif {
    
    UILongPressGestureRecognizer *gesture = notif.object;
    UIImageView *gestureView = (UIImageView *)gesture.view;
    
    
    CGRect targetRectangle = gestureView.frame;
    [[UIMenuController sharedMenuController] setTargetRect:targetRectangle
                                                    inView:gestureView.superview];
    
    CustomMenu *menuItemDelete = [[CustomMenu alloc] initWithTitle:@"Delete"
                                                      action:@selector(deleteAction:)];
    CustomMenu *menuItemCopy = [[CustomMenu alloc] initWithTitle:@"Copy"
                                                      action:@selector(copyAction:)];
    CGPoint point = [gesture locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    menuItemDelete.indexPath = indexPath;
    menuItemCopy.indexPath = indexPath;
    
    [[UIMenuController sharedMenuController]
     setMenuItems:@[menuItemCopy,menuItemDelete]];
    [[UIMenuController sharedMenuController]
     setMenuVisible:YES animated:YES];
}

- (void) removeListners {

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[SocketLisner sharedLisner].socket off:@"receiveTyping"];

}


- (void) setStatusOfPrivyButton {

    switch (self.chat.mode) {
            
        case MessageModeReceiverEnd:
            [self.privyBtn setBackgroundColor:kAPP_COLOR];
            [self.privyBtn setTitle:@"P1" forState:UIControlStateNormal];
            break;
            
        case MessageModeBothEnd:
            [self.privyBtn setBackgroundColor:kAPP_COLOR];
            [self.privyBtn setTitle:@"P2" forState:UIControlStateNormal];
            break;
            
        default:
            [self.privyBtn setBackgroundColor:[UIColor darkGrayColor]];
            [self.privyBtn setTitle:@"P" forState:UIControlStateNormal];
            break;
    }
}

- (void) sendPendingMessage {
    
//    for (Message *msg in self.messageArray) {
//        if (msg.readStatus == MessageStatusSending) {
//            [[SocketLisner sharedLisner] sendMessage:msg toUser:self.opponentUser];
//        } else if (msg.readStatus == MessageStatusUploading) {
//            
//            // Doing something on the main thread
//            dispatch_queue_t myQueue = dispatch_queue_create("_background_queue",NULL);
//            dispatch_async(myQueue, ^{
//                
//                // Perform long running process
//                NSString *pdfFileName = [kDOCUMENT_FOLDER_PATH stringByAppendingPathComponent:[msg getLocalName]];
//                UIImage *image=[UIImage imageWithContentsOfFile:pdfFileName];
//                NSData *imageData = UIImagePNGRepresentation(image);
//                [msg uploadImage:imageData];
//                
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    // Update the UI
//                    
//                });
//            });
//        }
//    }
}

#pragma mark
#pragma mark Keyboard notifications

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    
    NSDictionary *userInfo = [notification userInfo];
    
    NSTimeInterval duration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&duration];
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey]    getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]          getValue:&keyboardFrame];
    
    if (self.view.window != nil) {
        keyboardFrame = [self.view.window convertRect:keyboardFrame toView:self.view] ;
    }
   
    
    self.tableView.scrollEnabled = NO;
    self.tableView.decelerationRate = UIScrollViewDecelerationRateFast;
    [self.view layoutIfNeeded];
    
    CGFloat chatInputOffset = -((CGRectGetHeight(self.view.bounds) - self.bottomLayoutGuide.length) - CGRectGetMinY(keyboardFrame));
    
    if (chatInputOffset > 0 ){
        chatInputOffset = 0;
    }
    self.bottomChatInputConstraint.constant = chatInputOffset;
    
    [UIView animateWithDuration:duration delay:0.0 options:(animationCurve << 16)|UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.view layoutIfNeeded];
        
        if (self.messageArray.count > 0) {
            
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.messageArray count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
        
    } completion:^(BOOL finished) {
        self.tableView.scrollEnabled = true;
        self.tableView.decelerationRate = UIScrollViewDecelerationRateNormal;
    }];
    
}

#pragma mark
#pragma mark CustomTitleView delegate
- (void)didTapTitleView:(CustomTitleView *)sender {

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Chat" bundle: nil];
    ContactDetailVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"sid_contactDetailVC"];
    vc.person = self.opponentUser;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tapGestureMethod:(UITapGestureRecognizer *)gesture {
    
    [self.view endEditing:YES];
}
#pragma mark
#pragma mark ASChatInput delegate
- (void)chatInputDidResize:(ASChatInput *)chatInput {
    
    if (self.messageArray.count > 0) {
        
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.messageArray count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
    
    
}

- (void)chatInputDidChangeCharacter:(ASChatInput *)chatInput {

    if (self.isTyping == NO) {
        
        self.isTyping = YES;
        
        [[SocketLisner sharedLisner] startTypingWithPrams:@[@{@"chat_id":self.chat.chatId,@"is_typing":CONVERT_TO_NUMBER(1),@"user_id":self.user.mobile}]];
        
        
    }
    
    if (self.typingTimer != nil) {
        [self.typingTimer invalidate];
        self.typingTimer = nil;
    }
    
    self.typingTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f
                                                        target: self
                                                      selector:@selector(stopTypings)
                                                      userInfo: nil repeats:NO];
}

- (void)chatInputDidSendAttachment:(ASChatInput *)chatInput {
    
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel"
                                          destructiveButtonTitle:nil otherButtonTitles:@"Take Photo or Video",@"Photo or Video Library",@"Share Location",@"Share Contact", nil];
    [action showInView:self.view];
}

- (void)chatInput:(ASChatInput *)chatInput didSendMessage:(NSString *)msg {
    
    Message *message = [[Message alloc] init];
    message.text = msg;
    message.date =  [AppHelper currentDate];
    message.chatId = self.chat.chatId;
    message.senderId = self.user.mobile;
    message.mode = self.chat.mode;
    message.d_interval = self.chat.d_interval;
    message.type = MessageTypeText;
    message.opponentId = self.opponentUser.mobile;
    
    //Store Message in memory
    [self.messageArray addObject:message];
    
    [message executeSaveQuery];
    
    //Send message to server
    NSLog(@"chat mode = %ld",(long)self.chat.mode);
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messageArray.count-1 inSection:0];
    [self scrollRowAtIndexPath:indexPath];
    [[SocketLisner sharedLisner] sendMessage:message];
    
//    dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
//    dispatch_async(myQueue, ^{
//        
//        // Perform long running process
//        
//        [message executeSaveQuery];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            // Update the UI
//            
//            
//        });
//    });
    
    
}


#pragma mark
#pragma mark - UITableView Delegate & Datasource methods

- (void)scrollRowAtIndexPath:(NSIndexPath *)indexPath {

    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.messageArray count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messageArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Message *message = self.messageArray[indexPath.row];
    
    
    switch (message.type) {
            
        case MessageTypeNotification:{
        
            static NSString *CellIdentifier = @"NotificationCell";;
            NotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell)
            {
                cell = [[NotificationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            [cell setContentWidth:self.view.frame.size.width];
            [cell setMessage:message];
            return cell;
        
        }
            break;
            
        case MessageTypeAttachment:{
            
            static NSString *CellIdentifier = @"AttachmentCell";
            AttachmentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell)
            {
                cell = [[AttachmentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            [cell setContentWidth:self.view.frame.size.width];
            [cell setMessage:message];
            return cell;
        }
            break;
            
        default:{
        
            static NSString *CellIdentifier = @"MessageCell";
            MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell)
            {
                cell = [[MessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            [cell setContentWidth:self.view.frame.size.width];
            [cell setMessage:message];
            return cell;
        }
            break;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Message *message = self.messageArray[indexPath.row];
    return message.heigh;
    
    switch (message.type) {
            
        case MessageTypeNotification:{
            
            return 30;
            
        }
            break;
            
        case MessageTypeAttachment:{
            
            CGFloat max_height = 0.6*self.view.frame.size.width;
            return max_height+10;
        }
            break;
            
        default:{
            
            MessageCell *msgCell = [self.tableView dequeueReusableCellWithIdentifier:@"MessageCell"];
            if (!msgCell) {
                msgCell = [[MessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MessageCell"];
            }
            CGFloat height = [msgCell setupWithMessage:message withContentWidth:self.view.frame.size.width];
            return height;
        }
            break;
    }
    
    
}

- (NSIndexPath *)indexPathForMessage:(Message *)message {
    
    for (NSUInteger index = self.messageArray.count; index>0; index--) {
        
        Message *msg = [self.messageArray objectAtIndex:index-1];
        
        if ([msg.messageId isEqualToString:message.messageId]) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index-1 inSection:0];
            return indexPath;
        }
    }
    
    return nil;
}

- (NSIndexPath *)indexPathForLocalMessage:(Message *)message {
    
    for (NSUInteger index = self.messageArray.count; index>0; index--) {
        
        Message *msg = [self.messageArray objectAtIndex:index-1];
        
        if ([msg.date isEqualToString:message.date]) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index-1 inSection:0];
            return indexPath;
        }
    }
    
    return nil;
}

#pragma mark-
#pragma mark- All actions here..

- (IBAction)onBackTouched:(id)sender {

    [self removeListners];
    [SocketLisner sharedLisner].chatId = @"";
    self.tabBarController.tabBar.hidden = NO;
    [self.navigationController popViewControllerAnimated:YES];
    
    [self stopTypings];
}

- (void)startPrivy:(UIButton *)sender {
        
    [self.view endEditing:YES];
    
    TOActionSheet *actionSheet = [[TOActionSheet alloc] init];
    actionSheet.buttonFont = [UIFont systemFontOfSize:18.0f];
    actionSheet.title = @"Privy";
    actionSheet.destructiveButtonBackgroundColor = kAPP_COLOR;
    
    actionSheet.style = TOActionSheetStyleLight;
    
    [actionSheet addButtonWithTitle:@"Mode1: Auto delete messages at receiver end." tappedBlock:^{
        
        self.mode = @"1";
        
        SBPickerSelector *picker = [SBPickerSelector picker];
        
        picker.pickerData = @[@"15 second",@"30 second",@"45 second",@"1 minute",@"10 minute",@"30 minute",@"1 day",@"1 week"]; //picker content
        picker.pickerType = SBPickerSelectorTypeText;
        picker.delegate = self;
        picker.doneButtonTitle = @"Done";
        picker.cancelButtonTitle = @"Cancel";
        [picker showPickerOver:self];
        
    }];
    
    [actionSheet addButtonWithTitle:@"Mode2: Auto delete messages at both ends." tappedBlock:^{
        
        self.mode = @"2";
        
        SBPickerSelector *picker = [SBPickerSelector picker];
        
        picker.pickerData = @[@"15 second",@"30 second",@"45 second",@"1 minute",@"10 minute",@"30 minute",@"1 day",@"1 week"]; //picker content
        picker.pickerType = SBPickerSelectorTypeText;
        picker.delegate = self;
        picker.doneButtonTitle = @"Done";
        picker.cancelButtonTitle = @"Cancel";
        [picker showPickerOver:self];
    }];
    
    if (self.chat.mode != MessageModeOff) {
    
        [actionSheet addDestructiveButtonWithTitle:@"Mode off" tappedBlock:^{
            
            Message *message = [[Message alloc] init];
            message.text = @"Privy mode disabled.";
            message.date =  [AppHelper currentDate];
            message.chatId = self.chat.chatId;
            message.type = MessageTypeNotification;
            message.senderId = self.user.mobile;
            message.opponentId = self.opponentUser.mobile;
            
            self.chat.mode = 0;
            self.chat.d_interval = 0;
            
            message.mode = 0;
            message.d_interval = 0;
            
            [self.messageArray addObject:message];
            [message executeSaveQuery];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messageArray.count-1 inSection:0];
            [self scrollRowAtIndexPath:indexPath];
            
            [self setStatusOfPrivyButton];
            
            [[SocketLisner sharedLisner] sendMessage:message];
            
        }];
    }
    
    UIButton *button = (UIButton *)sender;
    [actionSheet showFromView:button inView:self.navigationController.view];
    
}

- (void) uploadImage:(UIImage *)actualImage {
    
    UIImage *normalResImage = [actualImage scaleToFillSize:CGSizeMake(400, 400)];
    UIImage *blurrImage = [normalResImage squareAndSmall];
    NSData *data = UIImagePNGRepresentation(blurrImage);
    NSString *base64  = [data base64EncodedString];
    
    Message *message = [[Message alloc] init];
    
    UTF32Char c = 0x1F4F7;
    NSData *utf32Data = [NSData dataWithBytes:&c length:sizeof(c)];
    NSString *camera = [[NSString alloc] initWithData:utf32Data encoding:NSUTF32LittleEndianStringEncoding];
    message.text = [NSString stringWithFormat:@"%@ photo",camera];
    
    message.date =  [AppHelper currentDate];
    message.chatId = self.chat.chatId;
    message.senderId = self.user.mobile;
    message.mode = self.chat.mode;
    message.d_interval = self.chat.d_interval;
    message.readStatus = MessageStatusSending;
    message.attachmentStatus = AttachmentStatusUploading;
    message.type = MessageTypeAttachment;
    message.attachment.type = AttachmentTypeImage;
    message.attachment.size = [NSString stringWithFormat:@"%lu",(unsigned long)[normalResImage calculatedSize]];
    message.attachment.thumbnail = base64;
    message.opponentId = self.opponentUser.mobile;
    
    //Store Message in memory
    [self.messageArray addObject:message];
    
    [message executeSaveQuery];
    
    //Send message to server
    NSLog(@"chat mode = %ld",(long)self.chat.mode);
    
    //NSString *imageName = [NSString stringWithFormat:@"%@_image.png",message.date];
    NSString *savedImagePath = [kDOCUMENT_FOLDER_PATH stringByAppendingPathComponent:[message getLocalName]];
    NSData *imageData = UIImagePNGRepresentation(normalResImage);
    [imageData writeToFile:savedImagePath atomically:NO];
    
    [[SocketLisner sharedLisner].imgOperations addObject:[message getLocalName]];
    
    // Update the UI
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messageArray.count-1 inSection:0];
    [self scrollRowAtIndexPath:indexPath];
    
    [[SocketLisner sharedLisner] uplaodImage:message withImage:imageData];
    
    
//    dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
//    dispatch_async(myQueue, ^{
//        // Perform long running process
//        
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//            // Update the UI
//            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messageArray.count-1 inSection:0];
//            [self scrollRowAtIndexPath:indexPath];
//            
//             [[SocketLisner sharedLisner] uplaodImage:message withImage:imageData];
//            
//        });
//    });
    
}

- (void)openCamera {
    
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.sourceType = UIImagePickerControllerSourceTypeCamera;
    controller.allowsEditing = NO;
    controller.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera];
    controller.delegate = self;
    [self presentViewController: controller animated: YES completion: nil];
}

- (void)openPhotoLibrary {
    
    QBImagePickerController *imagePickerController = [QBImagePickerController new];
    imagePickerController.delegate = self;
    imagePickerController.allowsMultipleSelection = YES;
    imagePickerController.maximumNumberOfSelection = 5;
    imagePickerController.showsNumberOfSelectedAssets = YES;
    imagePickerController.mediaType = QBImagePickerMediaTypeImage;
    
    [self presentViewController:imagePickerController animated:YES completion:NULL];
}

- (void)openVideoLibrary {
    
    QBImagePickerController *imagePickerController = [QBImagePickerController new];
    imagePickerController.delegate = self;
    imagePickerController.allowsMultipleSelection = YES;
    imagePickerController.maximumNumberOfSelection = 5;
    imagePickerController.showsNumberOfSelectedAssets = YES;
    imagePickerController.mediaType = QBImagePickerMediaTypeVideo;
    
    [self presentViewController:imagePickerController animated:YES completion:NULL];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 0) {
    
        if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
        {
            if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    // Will get here on both iOS 7 & 8 even though camera permissions weren't required
                    // until iOS 8. So for iOS 7 permission will always be granted.
                    if (granted) {
                        // Permission has been granted. Use dispatch_async for any UI updating
                        // code because this block may be executed in a thread.
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self openCamera];
                        });
                    } else {
                        // Permission has been denied.
                    }
                }];
            } else {
                // We are on iOS <= 6. Just do what we need to do.
                [self openCamera];
            }
            
            
        }
        
        else {
            
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                                  message:@"No Camera"
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles: nil];
            
            [myAlertView show];
            
            [myAlertView show];
        }
        
    } else if (buttonIndex == 1) {
        [self openPhotoLibrary];
        
    }
}

#pragma mark-
#pragma mark - UIImagePickerController  delegates

#pragma mark-
#pragma mark- Get image from imagePicker
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *normalImage          = [info valueForKey: UIImagePickerControllerOriginalImage];
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (normalImage) {
            [self uploadImage:normalImage];
        }
    }];
    
}

#pragma mark-
#pragma mark- dismiss imagePicker
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self.tableView reloadData];
    }];
}


#pragma mark - QBImagePickerControllerDelegate

- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets
{
    NSLog(@"Selected assets:");
    NSLog(@"%@", assets);
    
    __block int i = 0;
    
    for (PHAsset *asset in assets) {
        
        // Do something with the asset
        PHImageRequestOptions * imageRequestOptions = [[PHImageRequestOptions alloc] init];
        imageRequestOptions.synchronous = YES;
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:imageRequestOptions resultHandler:^(UIImage *result, NSDictionary *info) {
            
            NSLog(@"info = %@.",info);
            [self performSelector:@selector(uploadImage:) withObject:result afterDelay:i*1.2f ];
            i++;
        }];
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{
    NSLog(@"Canceled.");
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark-
#pragma mark- SBPickerSelector delegate
//if your piker is a traditional selection
-(void) pickerSelector:(SBPickerSelector *)selector selectedValue:(NSString *)value index:(NSInteger)idx {
    
    NSInteger interval = 0;
    NSString *text = [NSString stringWithFormat:@"Mode%@ started for ",self.mode];
    
    switch (idx) {
            
            // 15 second
        case 0: {
            interval = 15;
            text = [text stringByAppendingString:@"15 seconds"];
        }
            
            break;
            
            // 30 second
        case 1: {
            interval = 30;
            text = [text stringByAppendingString:@"30 seconds"];
        }
            
            break;
            
            // 45 second
        case 2: {
            interval = 45;
            text = [text stringByAppendingString:@"45 seconds"];
        }
            
            break;
            
            // 1 min
        case 3: {
            interval = 60;
            text = [text stringByAppendingString:@"1 minute"];
        }
            
            break;
            // 10 min
        case 4: {
            interval = 600;
            text = [text stringByAppendingString:@"10 minute"];
        }
            
            break;
            
            // 30 min
        case 5: {
            interval = 1800;
            text = [text stringByAppendingString:@"30 minute"];
        }
            
            break;
            
            
            // 1 day
        case 6: {
            interval = 86400;
            text = [text stringByAppendingString:@"1 day"];
        }
            
            break;
            
            // 1 week
        case 7: {
            interval = 604800;
            text = [text stringByAppendingString:@"1 week"];
        }
            
            break;
            
        default:
            break;
    }
    
    Message *message = [[Message alloc] init];
    message.text = text;
    message.date =  [AppHelper currentDate];
    message.chatId = self.chat.chatId;
    message.type = MessageTypeNotification;
    message.senderId = self.user.mobile;
    
    self.chat.mode = [self.mode integerValue];
    self.chat.d_interval = interval;
    
    message.mode = self.chat.mode;
    message.d_interval = self.chat.d_interval;
    message.opponentId = self.opponentUser.mobile;
    
    [self.messageArray addObject:message];
    [message executeSaveQuery];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messageArray.count-1 inSection:0];
    
    [self scrollRowAtIndexPath:indexPath];
    
    [self setStatusOfPrivyButton];
    
    [[SocketLisner sharedLisner] sendMessage:message];
    

}

//when picker value is changing
-(void) pickerSelector:(SBPickerSelector *)selector intermediatelySelectedValue:(id)value atIndex:(NSInteger)idx {
    
}
//if the user cancel the picker
-(void) pickerSelector:(SBPickerSelector *)selector cancelPicker:(BOOL)cancel {
    
}



- (void) stopTypings {
    
    if (self.typingTimer != nil) {
        [self.typingTimer invalidate];
        self.typingTimer = nil;
    }
    
    self.isTyping = NO;
    
    [[SocketLisner sharedLisner] startTypingWithPrams:@[@{@"chat_id":self.chat.chatId,@"is_typing":CONVERT_TO_NUMBER(0),@"user_id":self.user.mobile}]];
    
}


/*!
 * Called by Reachability whenever status changes.
 */
- (void) reachabilityChanged:(NSNotification *)note
{
    Reachability* reachability = [note object];
    BOOL connectionRequired = [reachability connectionRequired];
    [self enableControls:!connectionRequired];
    
//    if (connectionRequired) {
//        self.navigationItem.titleView = [[NetworkView alloc] initNetworkView:@"Waiting for Network."];
//    } else {
//        
//        if (![[SocketLisner sharedLisner] connectionStatus]) {
//            [self socketDisconnected:nil];
//        } else {
//        
//            self.navigationItem.titleView = nil;
//            [self sendPendingMessage:nil];
//        }
//    }
}

- (void)socketConnected:(NSNotification *)note {
    
    //self.navigationItem.titleView = nil;
    [self enableControls:YES];
}

- (void)socketDisconnected:(NSNotification *)note {
    //self.navigationItem.titleView = [[NetworkView alloc] initNetworkView:@"Connecting.."];
    [self enableControls:NO];
}







@end
