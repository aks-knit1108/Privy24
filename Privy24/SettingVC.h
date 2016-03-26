//
//  SettingVC.h
//  Privy24
//
//  Created by Amit on 8/31/15.
//  Copyright (c) 2015 BrightZone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "constants.h"

@interface SettingVC : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *data;
@property (strong, nonatomic) NSString *passcode_mode;

@end
