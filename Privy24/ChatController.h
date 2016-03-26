//
//  InboxVC.h
//  Privy24
//
//  Created by Amit on 8/31/15.
//  Copyright (c) 2015 BrightZone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchDisplayDelegate>

@property (nonatomic,strong) NSMutableArray *chatArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
