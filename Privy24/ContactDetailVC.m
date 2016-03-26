//
//  InviteUserVC.m
//  Privy24
//
//  Created by Amit on 9/12/15.
//  Copyright (c) 2015 BrightZone. All rights reserved.
//

#import "ContactDetailVC.h"
#import "ContactCustomCell.h"


@implementation ContactDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.tabBarController.tabBar.hidden = YES;
    self.title = @"Contact Info";
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    self.tabBarController.tabBar.hidden = NO;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark-
#pragma mark- All actions here..
- (IBAction)onBackTouched:(id)sender {
    self.tabBarController.tabBar.hidden = NO;
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark-
#pragma mark- UITableView delegate methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the n7mber of rows in the section.
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            ContactCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"nameCellIdentifier"];
            cell.userImage.layer.cornerRadius = 30.0f;
            cell.userImage.layer.masksToBounds = YES;
            
            if ([self.person.localName length] != 0 ) {
                
                cell.userName.text = self.person.localName;
                
            } else {
                
                cell.userName.text = [NSString stringWithFormat:@"+%@ %@",self.person.countryCode,self.person.mobile];
            }
            
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kImageUrl,self.person.image]];
            [cell.userImage sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"user.png"]];
            return cell;
        }
            break;
            
        case 1:
        {
            ContactCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mobileCellIdentifier"];
            cell.titleLabel.text = @"mobile";
            cell.statusLabel.text = [NSString stringWithFormat:@"+%@ %@",self.person.countryCode,self.person.mobile];
            return cell;
        }
            break;
            
        case 2:
        {
            ContactCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mobileCellIdentifier"];
            cell.titleLabel.text = @"status";
            cell.statusLabel.text = @"Hey!! I am using privy24.";
            return cell;
        }
            break;
            
        case 3:
        {
            ContactCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"blockCellIdentifier"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.titleLabel.text = @"View All Media";
            return cell;
        }
            break;
            
        case 4:
        {
            ContactCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"blockCellIdentifier"];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.titleLabel.text = @"Clear Chat";
            return cell;
        }
            break;
            
        case 5:
        {
            ContactCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"blockCellIdentifier"];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.titleLabel.text = @"Delete Chat";
            return cell;
        }
            break;
            
        default:
        {
            ContactCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"blockCellIdentifier"];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.titleLabel.text = @"Block User";
            return cell;
        }
            break;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    switch (indexPath.row) {
        case 0:
            return 90;
            break;
            
        default:
            return 50;
            break;
    }
}


@end
