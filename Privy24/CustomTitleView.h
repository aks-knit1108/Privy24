//
//  NetworkView.h
//  Privy24
//
//  Created by Amit on 12/22/15.
//  Copyright (c) 2015 BrightZone. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomTitleViewDelegate <NSObject>

@optional
- (void)didTapTitleView:(id)sender;

@end

@interface CustomTitleView : UIView
@property (nonatomic, weak) id <CustomTitleViewDelegate> delegate;
- (void)setStatus:(NSString *)sttaus;
- (void)setTitle:(NSString *)title;

@end
