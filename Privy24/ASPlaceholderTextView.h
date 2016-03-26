//
//  ASPlaceholderTextView.h
//  Privy24
//
//  Created by Amit on 1/5/16.
//  Copyright (c) 2016 BrightZone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASPlaceholderTextView : UITextView

@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;

-(void)textChanged:(NSNotification*)notification;

@end
