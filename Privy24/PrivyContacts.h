//
//  PrivyContacts.h
//  Privy24
//
//  Created by Amit on 10/6/15.
//  Copyright (c) 2015 BrightZone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PrivyContacts : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray *searchResult;
@property (nonatomic, strong) NSMutableArray *usersArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property BOOL isFromNewChat;

@end
