//
//  ASChatInput.h
//  Privy24
//
//  Created by Amit on 1/2/16.
//  Copyright (c) 2016 BrightZone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASStretchyTextView.h"

@class ASChatInput;

@protocol ASChatInputDelegate <NSObject>

@required
- (void)chatInputDidResize:(ASChatInput *)chatInput;
- (void)chatInput:(ASChatInput *)chatInput didSendMessage:(NSString *)message;
- (void)chatInputDidSendAttachment:(ASChatInput *)chatInput;

@optional
- (void)chatInputDidChangeCharacter:(ASChatInput *)chatInput;

@end

@interface ASChatInput : UIView <ASStretchyTextViewDelegate>
@property (nonatomic, weak) id <ASChatInputDelegate> delegate;
- (void)enableControls:(BOOL)enable;
@end
