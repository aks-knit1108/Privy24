//
//  ASChatInput.m
//  Privy24
//
//  Created by Amit on 1/2/16.
//  Copyright (c) 2016 BrightZone. All rights reserved.
//

#import "ASChatInput.h"


@interface ASChatInput ()

@property (nonatomic,strong) UIButton *sendButton;
@property (nonatomic,strong) UIButton *attachButton;
@property (nonatomic,strong) ASStretchyTextView *textView ;
@property (nonatomic,strong) UIToolbar *blurredBackgroundView;
@property (nonatomic,strong) NSLayoutConstraint *heightConstraint;
@property (nonatomic,readwrite) UIEdgeInsets textViewInsets;


@end

@implementation ASChatInput

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (instancetype) initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    if (self) {
        
        self.textViewInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        
        [self setup];
        [self stylize];
        
        return self;
    }
    
    return nil;
}


- (void) setup {
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self setupSendButton];
    [self setupSendButtonConstraints];
    [self setupAttachmentButton];
    [self setupAttachButtonConstraints];
    [self setupTextView];
    [self setupTextViewConstraints];
    [self setupBlurredBackgroundView];
    [self setupBlurredBackgroundViewConstraints];
}

- (void) setupSendButton {
    
    self.sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [self.sendButton addTarget:self action:@selector(sendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.sendButton.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    self.sendButton.bounds = CGRectMake(0, 0, 40, 1);
    [self.sendButton setTitleColor:[UIColor colorWithRed:91/255.0f green:44/255.0f blue:135/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [self addSubview:self.sendButton];
}

- (void) setupSendButtonConstraints {
    
    self.sendButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.sendButton removeConstraints:self.sendButton.constraints];
    
    // TODO: Fix so that button height doesn't change on first newLine
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.sendButton attribute:NSLayoutAttributeRight multiplier:1.0 constant:self.textViewInsets.right];
    
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.sendButton attribute:NSLayoutAttributeBottom multiplier:1.0 constant:self.textViewInsets.bottom];
    
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self.sendButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:40.0f];
    
    NSLayoutConstraint *sendButtonHeightConstraint = [NSLayoutConstraint constraintWithItem:self.sendButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:30];
    
    [self addConstraints:@[sendButtonHeightConstraint, widthConstraint, rightConstraint, bottomConstraint]];
}

- (void) setupAttachmentButton {
    
    self.attachButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.attachButton setImage:[UIImage imageNamed:@"arrow-circle"] forState:UIControlStateNormal];
    [self.attachButton addTarget:self action:@selector(attachButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.attachButton.bounds = CGRectMake(0, 0, 40, 1);
    
    [self addSubview:self.attachButton];
}

- (void) setupAttachButtonConstraints {
    
    self.attachButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.attachButton removeConstraints:self.sendButton.constraints];
    
    // TODO: Fix so that button height doesn't change on first newLine
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.attachButton attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-self.textViewInsets.left];
    
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.attachButton attribute:NSLayoutAttributeBottom multiplier:1.0 constant:self.textViewInsets.bottom];
    
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self.attachButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:30.0f];
    
    NSLayoutConstraint *attachmentButtonHeightConstraint = [NSLayoutConstraint constraintWithItem:self.attachButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:30];
    
    [self addConstraints:@[attachmentButtonHeightConstraint, widthConstraint, leftConstraint, bottomConstraint]];
}


- (void) setupTextView {
    
    self.textView = [[ASStretchyTextView alloc] initWithFrame:CGRectZero textContainer:nil];
    
    self.textView.bounds = UIEdgeInsetsInsetRect(self.bounds, self.textViewInsets);
    self.textView.stretchyTextViewDelegate = self;
    self.textView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    self.textView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.textView.layer.shouldRasterize = true;
    self.textView.layer.cornerRadius = 5.0;
    self.textView.layer.borderWidth = 1.0;
    self.textView.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:0.2].CGColor;
    self.textView.placeholder = @"Type message here";
    self.textView.placeholderColor = [UIColor lightGrayColor];
    [self addSubview:self.textView];
}


- (void) setupTextViewConstraints {
    
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.textView attribute:NSLayoutAttributeTop multiplier:1.0 constant:-self.textViewInsets.top];
    
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.attachButton attribute:NSLayoutAttributeRight multiplier:1.0 constant:self.textViewInsets.left];
    
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.textView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:self.textViewInsets.bottom];
    
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.sendButton attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-self.textViewInsets.right];
    
    self.heightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:40];
    
    [self addConstraints:@[topConstraint, leftConstraint, bottomConstraint, rightConstraint, self.heightConstraint]];
}

- (void) setupBlurredBackgroundView {
    
    self.blurredBackgroundView = [[UIToolbar alloc] init];
    [self addSubview:self.blurredBackgroundView];
    [self sendSubviewToBack:self.blurredBackgroundView];
}

- (void) setupBlurredBackgroundViewConstraints {
    
    self.blurredBackgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.blurredBackgroundView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.blurredBackgroundView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.blurredBackgroundView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.blurredBackgroundView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    
    [self addConstraints:@[topConstraint, leftConstraint, bottomConstraint, rightConstraint]];
    
}

// MARK: Styling

- (void) stylize {
    
    self.textView.backgroundColor = [UIColor whiteColor];
    self.sendButton.tintColor = [UIColor colorWithRed:0.0 green:120/255.0 blue:255/255.0 alpha:1.0];
    self.textView.tintColor = [UIColor colorWithRed:0.0 green:120/255.0 blue:255/255.0 alpha:1.0];
    self.textView.font = [UIFont systemFontOfSize:17.0f];
    self.textView.textColor = [UIColor darkTextColor];
    self.blurredBackgroundView.hidden = NO;
    self.backgroundColor = [UIColor whiteColor];
    
}

// MARK: StretchyTextViewDelegate
- (void) stretchyTextViewDidChangeSize:(ASStretchyTextView *)textView {
    
    CGFloat textViewHeight = CGRectGetHeight(textView.bounds);
    CGFloat targetConstant = textViewHeight + self.textViewInsets.top + self.textViewInsets.bottom;
    self.heightConstraint.constant = targetConstant;
    [self.delegate chatInputDidResize:self];
}

- (void) stretchyTextViewDidChangeCharacter:(ASStretchyTextView *)textView {
    [self.delegate chatInputDidChangeCharacter:self];
}


- (void) sendButtonPressed:(UIButton *)sender {
    
    if (self.textView.text.length > 0) {
        [self.delegate chatInput:self didSendMessage:self.textView.text];
        self.textView.text = @"";
    }
}

- (void) attachButtonPressed:(UIButton *)sender {
    
    [self.delegate chatInputDidSendAttachment:self];
}

- (void)enableControls:(BOOL)enable {
    
    self.sendButton.enabled = enable;
    self.sendButton.alpha = enable?1.0:0.5;
    self.attachButton.enabled = enable;
}

@end
