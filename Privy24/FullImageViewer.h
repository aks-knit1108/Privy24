//
//  FullImageViewer.h
//  MarketPlace
//
//  Created by Amit on 2/8/15.
//  Copyright (c) 2015 Smart Data Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FullImageViewer : UIView

- (instancetype)initWithUrl:(NSString *)url;
- (instancetype)initWithImage:(UIImage *)image;
- (void)presentWithAnimation:(BOOL)isAnim;

@end
