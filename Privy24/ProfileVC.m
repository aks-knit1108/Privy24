//
//  ProfileVC.m
//  Privy24
//
//  Created by Amit on 8/30/15.
//  Copyright (c) 2015 BrightZone. All rights reserved.
//

#import "ProfileVC.h"
#import "constants.h"

@interface ProfileVC ()

@end

@implementation ProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        
    self.userImage.layer.cornerRadius = 80.0f / 2;
    self.userImage.userInteractionEnabled = YES;
    self.userImage.clipsToBounds = YES;
    
    UITapGestureRecognizer *recogNizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recog:)];
    recogNizer.numberOfTapsRequired = 1;
    [self.userImage addGestureRecognizer:recogNizer];
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc]
                                       initWithString: self.privacyLabel.text];
    
    [text addAttribute:NSForegroundColorAttributeName
                 value:kAPP_COLOR
                 range:[self.privacyLabel.text rangeOfString:@"Terms of Services"]];
    [text addAttribute:NSForegroundColorAttributeName
                 value:kAPP_COLOR
                 range:[self.privacyLabel.text rangeOfString:@"Privacy Policy"]];
    
    [self.privacyLabel setAttributedText: text];
    
    [AppHelper addRightBarButtonToNavBar:self withText:@"Finish" action:@selector(onFinishTouched:)];
    
    self.fnameTextField.text = self.person.firstName;
    self.lnameTextField.text = self.person.lastName;
    
    if (self.person.image.length != 0) {
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kImageUrl,self.person.image]];
        self.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
        [self.userImage sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"no-img.png"]];
    }

}

- (void)viewWillAppear:(BOOL)animated {
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark-
#pragma mark- UIActionSheet delegate method
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Take Photo"]) {
        
        if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
        {
            if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    // Will get here on both iOS 7 & 8 even though camera permissions weren't required
                    // until iOS 8. So for iOS 7 permission will always be granted.
                    if (granted) {
                        // Permission has been granted. Use dispatch_async for any UI updating
                        // code because this block may be executed in a thread.
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self openCamera];
                        });
                    } else {
                        // Permission has been denied.
                    }
                }];
            } else {
                // We are on iOS <= 6. Just do what we need to do.
                [self openCamera];
            }
            
            
        } else {
            
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                                  message:@"No Camera"
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles: nil];
            
            [myAlertView show];
            
            [myAlertView show];
        }
        
    }
    
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Choose Existing"]) {
        
        if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary])
        {
            [self openPhotoLibrary];
        }
    }
}

- (void)openCamera {
    
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.sourceType = UIImagePickerControllerSourceTypeCamera;
    controller.allowsEditing = NO;
    controller.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera];
    controller.delegate = self;
    [self presentViewController: controller animated: YES completion: nil];
}

- (void)openPhotoLibrary {
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.allowsEditing = NO;
    imagePickerController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypePhotoLibrary];
    imagePickerController.delegate = self;
    [self presentViewController: imagePickerController animated: YES completion: nil];
}


#pragma mark-
#pragma mark - UIImagePickerController  delegates

#pragma mark-
#pragma mark- Get image from imagePicker
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image          = [info valueForKey: UIImagePickerControllerOriginalImage];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        RSKImageCropViewController *imageCropVC = [[RSKImageCropViewController alloc] initWithImage:image cropMode:RSKImageCropModeCircle];
        imageCropVC.delegate = self;
        [self presentViewController:imageCropVC animated:NO completion:nil];
    }];
    
    
}

#pragma mark-
#pragma mark- dismiss imagePicker
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - RSKImageCropViewControllerDelegate

- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"image cancelled..");
    }];
}

- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage
{
    NSLog(@"croppedImage = %@",NSStringFromCGSize(croppedImage.size));
    UIImage *scaledImage = [croppedImage resizedImageToFitInSize:CGSizeMake(200, 200) scaleIfSmaller:YES];
    NSLog(@"scaledImage = %@",NSStringFromCGSize(scaledImage.size));
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self.userImage setImage:scaledImage];
        self.image = scaledImage;
    }];
}


#pragma mark- UITextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return true;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    if (textField==self.fnameTextField) {
        [self.lnameTextField becomeFirstResponder];
        
    } else {
        
        [textField resignFirstResponder];
    }
    
    return TRUE;
}


#pragma mark-
#pragma mark- All actions here..

#pragma mark-
#pragma mark- open UIActionSheet for profile pic
- (void)recog:(UITapGestureRecognizer *)sender {
    
    [self.view endEditing:YES];
    
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:nil
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:@"Take Photo", @"Choose Existing", nil];
    popupQuery.actionSheetStyle = UIActionSheetStyleDefault;
    [popupQuery showInView:self.view];
}


- (IBAction)onBackTouched:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onFinishTouched:(id)sender {
    
    [self.view endEditing:YES];
    
    if (self.fnameTextField.text.length==0) {
        [AppHelper showAlert:@"Privy24" withMessage:@"Please enter name."];
        return;
    }
    
    NSString *url = [kBaseUrl stringByAppendingString:@"/saveUserDetails"];
    NSString *img = @"";
    if (self.image != nil) {
        NSData *data = UIImagePNGRepresentation(self.image);
        img = [data base64EncodedString];
        if (!img) {
            img = @"";
        }
        
    }

    NSDictionary *param = @{@"fname":self.fnameTextField.text,@"lname":self.lnameTextField.text,@"image":img,@"mobile":self.person.mobile,@"countryCode":self.person.countryCode};
    
    // Set spinner..
    [AppHelper addActivityToNavBar:self];
    
    [[ConnectionManager sharedManager] postRequest:url parameters:param  success:^(id responseObject) {
        
        // hide spinner
        [AppHelper addRightBarButtonToNavBar:self withText:@"Finsih" action:@selector(onFinishTouched:)];
        
        NSError *error = nil;
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                     options:kNilOptions
                                                                       error:&error];
        
        NSLog(@"JSON: %@", jsonResponse);
        
        
        if ([[jsonResponse objectForKey:@"status"] isEqualToString:@"success"]) {
            
            Person *user = [[Person alloc] initWithDictionary:[jsonResponse objectForKey:@"data"]];
            self.person = user;
            [self.person executeSaveQuery];
            [kAPP_DELEGATE openChatScreenWithUser:self.person andSelectedTab:0];
        }
        
        else {
        
            [AppHelper showAlert:[jsonResponse objectForKey:@"status"] withMessage:[jsonResponse objectForKey:@"message"]];
        }
        
    } failure:^(NSError *error) {
        // hide spinner
        [AppHelper addRightBarButtonToNavBar:self withText:@"Finish" action:@selector(onFinishTouched:)];
        //[AppHelper showAlert:@"Error !!" withMessage:error.localizedDescription];
    }];

    
    
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
