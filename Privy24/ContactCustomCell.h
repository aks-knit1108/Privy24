//
//  UserListingCustomCell.h
//  MarketPlace
//
//  Created by Amit Kumar Shukla on 14/01/15.
//  Copyright (c) 2015 Smart Data Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactCustomCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *inviteButton;




@end
