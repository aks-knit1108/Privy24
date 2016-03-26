//
//  NetworkView.h
//  Privy24
//
//  Created by Amit on 12/22/15.
//  Copyright (c) 2015 BrightZone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NetworkView : UIView
@property (nonatomic,strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic,strong) UILabel *titleLabel;

- (instancetype)initNetworkView:(NSString *)title;

@end
