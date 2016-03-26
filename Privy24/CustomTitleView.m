//
//  NetworkView.m
//  Privy24
//
//  Created by Amit on 12/22/15.
//  Copyright (c) 2015 BrightZone. All rights reserved.
//

#import "CustomTitleView.h"

@interface CustomTitleView ()
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *statusLabel;
@property (nonatomic,strong) UIButton *actionButton;

@end

@implementation CustomTitleView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self=[super initWithFrame:frame]) {
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, frame.size.width, 24)];
        [self.titleLabel setTextColor:[UIColor blackColor]];
        [self.titleLabel setFont:[UIFont boldSystemFontOfSize:17.0f]];
        [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.titleLabel setText:@""];
        [self addSubview:self.titleLabel];
        
        self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, frame.size.width, 15)];
        [self.statusLabel setTextColor:[UIColor darkGrayColor]];
        [self.statusLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [self.statusLabel setTextAlignment:NSTextAlignmentCenter];
        [self.statusLabel setText:@""];
        [self addSubview:self.statusLabel];
        
        self.actionButton =  [UIButton buttonWithType:UIButtonTypeSystem];
        [self.actionButton setBackgroundColor:[UIColor clearColor]];
        [self.actionButton addTarget:self action:@selector(actionButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.actionButton setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self addSubview:self.actionButton];
        
        return self;
    }
    
    return nil;
    
    
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

- (void)setStatus:(NSString *)status {
    
    if ([status isEqualToString:@"online"]) {
        [self.statusLabel setFont:[UIFont systemFontOfSize:12.0f]];
    } else {
        [self.statusLabel setFont:[UIFont italicSystemFontOfSize:12.0f]];
    }
    
    CGRect frame = self.titleLabel.frame;
    
    if (frame.origin.y == 10) {
        
        if ([status length]!= 0) {
            
            [self.statusLabel setText:status];
            self.statusLabel.alpha = 0.0f;
            [UIView animateWithDuration:0.5f animations:^{
                self.titleLabel.frame = CGRectMake(0, 2, self.frame.size.width, 24);
                self.statusLabel.alpha = 1.0f;
            } completion:^(BOOL finished) {
                
            }];
        }
        
        else {
            
            self.statusLabel.text = status;
        }
    }
    
    else {
    
        if ([status length]==0) {
            
            [self.statusLabel setText:status];
            self.statusLabel.alpha = 1.0f;
            [UIView animateWithDuration:0.5f animations:^{
                self.titleLabel.frame = CGRectMake(0, 10, self.frame.size.width, 24);
                self.statusLabel.alpha = 0.0f;
            } completion:^(BOOL finished) {

            }];
        }
        
        else {
            self.statusLabel.text = status;
        }

    }
    
}

- (void) actionButtonClicked {
    if ([self.delegate respondsToSelector:@selector(didTapTitleView:)]) {
        [self.delegate didTapTitleView:self];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
