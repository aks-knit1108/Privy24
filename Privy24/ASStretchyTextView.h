//
//  ASStretchyTextView.h
//  Privy24
//
//  Created by Amit on 1/2/16.
//  Copyright (c) 2016 BrightZone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITextView+Placeholder.h"

@class ASStretchyTextView;

@protocol ASStretchyTextViewDelegate <NSObject>

@required
- (void) stretchyTextViewDidChangeSize:(ASStretchyTextView *)textView;

@optional
- (void) stretchyTextViewDidChangeCharacter:(ASStretchyTextView *)textView;


@end

@interface ASStretchyTextView : UITextView <UITextViewDelegate>
@property (nonatomic, weak) id <ASStretchyTextViewDelegate> stretchyTextViewDelegate;

@end


