//
//  ChatController.h
//  Whatsapp
//
//  Created by Rafael Castro on 6/16/15.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Chat.h"
#import "constants.h"
#import "PhotoPickerVC.h"
//
// This class control chat exchange message itself
// It creates the bubble UIazz
//

@class MessageCell;

@interface MessageController : UIViewController<UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate, PhotoPickerDelegate>
@property (strong, nonatomic) Chat *chat;
@property (strong, nonatomic) NSMutableArray *messageArray;
@property (strong,nonatomic) Person *opponentUser;
@property (strong,nonatomic) Person *user;

@end
