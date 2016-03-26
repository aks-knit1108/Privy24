//
//  ASStretchyTextView.m
//  Privy24
//
//  Created by Amit on 1/2/16.
//  Copyright (c) 2016 BrightZone. All rights reserved.
//

#import "ASStretchyTextView.h"

@interface ASStretchyTextView () {

}

@end



@implementation ASStretchyTextView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer {
    
    self = [super initWithFrame:frame textContainer:textContainer];
    
    if (self) {
        
        self.delegate = self;
        return self;
    }
    
    return nil;
}

- (void)setContentSize:(CGSize)contentSize {
    [self resize];
}

- (CGFloat)maxHeight {return 160;}

- (CGSize)maxSize {return CGSizeMake(CGRectGetWidth(self.bounds), [self maxHeight]);}

- (void) resize {
    
    CGRect bounds = self.bounds;
    bounds.size.height = [self targetHeight];
    self.bounds = bounds;
    [self.stretchyTextViewDelegate stretchyTextViewDidChangeSize:self];
}


- (CGFloat) targetHeight {
    
    CGSize targetSize= [self sizeThatFits:[self maxSize]];
    CGFloat targetHeight = targetSize.height;
    CGFloat maxHeight = [self maxHeight];
    
    return targetHeight < maxHeight ? targetHeight : maxHeight;
    
}

- (void) align {
    
    CGRect caretRect = [self caretRectForPosition:self.selectedTextRange.end];
    
    CGFloat topOfLine = CGRectGetMinY(caretRect);
    CGFloat bottomOfLine = CGRectGetMaxY(caretRect);
    
    CGFloat contentOffsetTop = self.contentOffset.y;
    CGFloat bottomOfVisibleTextArea = contentOffsetTop + CGRectGetHeight(self.bounds);
    
    /*
     If the caretHeight and the inset padding is greater than the total bounds then we are on the first line and aligning will cause bouncing.
     */
    
    CGFloat caretHeightPlusInsets = CGRectGetHeight(caretRect) + self.textContainerInset.top + self.textContainerInset.bottom;
    if (caretHeightPlusInsets < CGRectGetHeight(self.bounds)) {
        
        CGFloat overflow = 0.0;
        
        if (topOfLine < contentOffsetTop + self.textContainerInset.top) {
            overflow = topOfLine - contentOffsetTop - self.textContainerInset.top;
        } else if (bottomOfLine > bottomOfVisibleTextArea - self.textContainerInset.bottom) {
            overflow = (bottomOfLine - bottomOfVisibleTextArea) + self.textContainerInset.bottom;
        }
        CGPoint contentOffset = self.contentOffset;
        contentOffset.y += overflow;
        self.contentOffset = contentOffset;
        
    }
}



- (void) textViewDidChangeSelection:(UITextView *)textView {
    [self align];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    [self.stretchyTextViewDelegate stretchyTextViewDidChangeCharacter:self];
    return YES;
}

@end
