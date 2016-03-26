//
//  ProfileVC.h
//  Privy24
//
//  Created by Amit on 8/30/15.
//  Copyright (c) 2015 BrightZone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "constants.h"

@interface ProfileVC : UIViewController<UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,RSKImageCropViewControllerDelegate,RSKImageCropViewControllerDataSource,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UITextField *fnameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lnameTextField;
@property (weak, nonatomic) IBOutlet UILabel *privacyLabel;
@property (strong,nonatomic) Person *person;
@property (strong,nonatomic) UIImage *image;


@end
