//
//  ViewController.h
//  Privy24
//
//  Created by Amit on 8/27/15.
//  Copyright (c) 2015 BrightZone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "constants.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h> 
#import <CoreTelephony/CTCarrier.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *countryButton;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumTextField;
@property (strong, nonatomic) NSString *code;
@property (strong, nonatomic) NSString *country;

@end

