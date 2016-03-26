//
//  RBImageCollectionCell.h
//  RBImagePicker
//
//  Created by Roshan Balaji on 1/29/14.
//  Copyright (c) 2014 Uniq Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
@interface ASImageCollectionCell : UICollectionViewCell

@property (nonatomic, strong) ALAsset *imageAsset;
@property (weak, nonatomic) IBOutlet UIImageView *assetImage;
@property (weak, nonatomic) IBOutlet UIView *alphaView;
@property (weak, nonatomic) IBOutlet UIImageView *checkImage;

@end
