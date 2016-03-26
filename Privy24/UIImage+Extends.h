//
//  UIImage+Extends.h
//  MarketPlace
//
//  Created by Amit on 9/8/15.
//  Copyright (c) 2015 Smart Data Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extends)

- (UIImage *)scaleToFillSize:(CGSize)size;
- (UIImage*)resizedImageToSize:(CGSize)dstSize;
- (UIImage*)resizedImageToFitInSize:(CGSize)boundingSize scaleIfSmaller:(BOOL)scale;
- (UIImage *)squareAndSmall;
- (NSUInteger)calculatedSize;

@end
