//
//  InviteUserVC.h
//  Privy24
//
//  Created by Amit on 9/12/15.
//  Copyright (c) 2015 BrightZone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "constants.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import "constants.h"

@interface ContactDetailVC : UIViewController<UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate,UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *inameLabel;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) Person *person;

@end
