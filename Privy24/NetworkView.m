//
//  NetworkView.m
//  Privy24
//
//  Created by Amit on 12/22/15.
//  Copyright (c) 2015 BrightZone. All rights reserved.
//

#import "NetworkView.h"

@implementation NetworkView

- (instancetype)initNetworkView:(NSString *)title {
    
    UILabel *lbl = [[UILabel alloc] init];
    [lbl setText:title];
    CGSize size = [lbl sizeThatFits:CGSizeMake(MAXFLOAT, 30)];
    CGRect frame = CGRectMake(0, 7, (size.width+50), 30);
    
    if (self=[super initWithFrame:frame]) {
        
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [self.activityIndicator startAnimating];
        [self.activityIndicator setTintColor:[UIColor darkGrayColor]];
        [self addSubview:self.activityIndicator];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, frame.size.width, 30)];
        [self.titleLabel setText:title];
        [self.titleLabel setTextColor:[UIColor blackColor]];
        [self addSubview:self.titleLabel];
        
        return self;
    }
    
    return nil;
    
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
