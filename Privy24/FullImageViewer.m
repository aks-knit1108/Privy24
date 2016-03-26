//
//  FullImageViewer.m
//  MarketPlace
//
//  Created by Amit on 2/8/15.
//  Copyright (c) 2015 Smart Data Inc. All rights reserved.
//

#import "FullImageViewer.h"
#import "constants.h"

@interface FullImageViewer()
@property (nonatomic,strong) UIImageView *imageView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end
@implementation FullImageViewer

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithUrl:(NSString *)url {
    
    CGRect frame = [[UIApplication sharedApplication] keyWindow].bounds;
    
    if (self==[super initWithFrame:frame]) {
        
        [self setBackgroundColor:[UIColor blackColor]];
        self.imageView = [[UIImageView alloc] initWithFrame:frame];
        [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:self.imageView];
        
        _activityIndicator = [[UIActivityIndicatorView alloc] init];
        _activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        _activityIndicator.center = self.center;
        _activityIndicator.hidesWhenStopped = true;
        
        
        [self addSubview:_activityIndicator];
        
        UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [doneButton setTitle:@"Done" forState:UIControlStateNormal];
        [doneButton addTarget:self action:@selector(removeWithAnimation:) forControlEvents:UIControlEventTouchUpInside];
        doneButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        doneButton.layer.borderWidth = 1;
        doneButton.layer.cornerRadius = 4;
        doneButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [doneButton setFrame:CGRectMake(frame.size.width-80, 30, 70, 30)];
        doneButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:doneButton];
        
        [_activityIndicator startAnimating];
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            self.imageView.image = image;
            [_activityIndicator stopAnimating];
        }];

        return self;
    }
    
    return nil;
    
}

- (instancetype)initWithImage:(UIImage *)image {
    
    CGRect frame = [[UIApplication sharedApplication] keyWindow].bounds;
    
    if (self==[super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor blackColor]];
        self.imageView = [[UIImageView alloc] initWithFrame:frame];
        [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.imageView setImage:image];
        [self addSubview:self.imageView];
        
        UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [doneButton setTitle:@"DONE" forState:UIControlStateNormal];
        [doneButton addTarget:self action:@selector(removeWithAnimation:) forControlEvents:UIControlEventTouchUpInside];
        doneButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        doneButton.layer.borderWidth = 1;
        doneButton.layer.cornerRadius = 4;
        doneButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [doneButton setFrame:CGRectMake(frame.size.width-80, 30, 70, 30)];
        doneButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:doneButton];
        
        return self;
    }
    
    return nil;
    
}

- (void)presentWithAnimation:(BOOL)isAnim {
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [window addSubview:self];

}

- (void)removeWithAnimation:(UIButton *)button {
    
    [self removeFromSuperview];
    
}


@end
