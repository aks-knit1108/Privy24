//
//  RBImageCollectionCell.m
//  RBImagePicker
//
//  Created by Roshan Balaji on 1/29/14.
//  Copyright (c) 2014 Uniq Labs. All rights reserved.
//

#import "ASImageCollectionCell.h"

@implementation ASImageCollectionCell

-(void)setImageAsset:(ALAsset *)imageAsset{
    
    _imageAsset = imageAsset;
    self.assetImage.image = [UIImage imageWithCGImage:[_imageAsset thumbnail]];
    
}


@end
