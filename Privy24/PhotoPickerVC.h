//
//  PhotoPickerVC.h
//  Privy24
//
//  Created by Amit on 3/2/16.
//  Copyright (c) 2016 BrightZone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ASImageCollectionCell.h"

@class PhotoPickerVC;

@protocol PhotoPickerDelegate <NSObject>

@required
-(void)imagePickerController:(PhotoPickerVC *)imagePicker didFinishPickingImagesWithURL:(NSArray *)imageURLS;

@optional
-(void)imagePickerControllerDidCancel:(PhotoPickerVC *)imagePicker;

@end

@interface PhotoPickerVC : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate>
@property(nonatomic, strong) NSMutableDictionary *selected_images;
@property(nonatomic, strong) NSMutableArray *selected_images_index;
@property(nonatomic, strong) NSArray *assets;
@property(nonatomic, weak) id<PhotoPickerDelegate, UINavigationControllerDelegate>delegate;

@end
