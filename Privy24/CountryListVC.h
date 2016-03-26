//
//  CountryListVC.h
//  Privy24
//
//  Created by Amit on 8/29/15.
//  Copyright (c) 2015 BrightZone. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@interface CountryListVC : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchDisplayDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (strong, nonatomic) NSMutableArray *countryArray;
@property (strong, nonatomic) NSMutableArray *searchArray;
@property (strong, nonatomic) ViewController *parentController;
@property BOOL isSearching;

@end
