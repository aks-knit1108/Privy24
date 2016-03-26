//
//  SettingVC.m
//  Privy24
//
//  Created by Amit on 8/31/15.
//  Copyright (c) 2015 BrightZone. All rights reserved.
//

#import "SettingVC.h"
#import "AboutViewController.h"
#import "MyProfileViewController.h"
#import "JKLLockScreenViewController.h"
#import "ContactCustomCell.h"

@interface SettingVC ()<UIActionSheetDelegate,JKLLockScreenViewControllerDataSource, JKLLockScreenViewControllerDelegate>

@end

@implementation SettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:kAPP_COLOR forKey:NSForegroundColorAttributeName]];
//    [self.navigationController.navigationBar setTranslucent:YES];
    
    self.data = [NSMutableArray new];
    
    NSArray *array0 = [NSArray arrayWithObjects:@"Profile", nil];
    NSArray *array1 = [NSArray arrayWithObjects:@"About and Help",@"Tell a Friend", nil];
    NSArray *array2 = [NSArray arrayWithObjects:@"Account",@"Chats",@"Notifications",@"Passcode Lock", nil];
    [self.data addObject:array0];
    [self.data addObject:array1];
    [self.data addObject:array2];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark-
#pragma mark- UITableView delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.data.count;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [(NSArray *)[self.data objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        ContactCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userProfileCell"];
        
        Person *person = [SocketLisner sharedLisner].user;
        
        NSString *fullName = [NSString stringWithFormat:@"%@ %@", person.firstName, person.lastName];
        
        cell.userName.text = fullName;
        cell.statusLabel.text = @"Hey ! I am using Privy24";
        cell.userImage.layer.cornerRadius = 30.0f;
        cell.userImage.layer.masksToBounds = YES;
        
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kImageUrl,person.image]];
        [cell.userImage sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"user.png"]];
        
        return cell;
        
    } else {
    
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingCustomCellIdentifier"];
        cell.textLabel.text = [[self.data objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        return 80.0f;
    }
    
    return 44.0f;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.section) {
            
        case 0:{
            
            switch (indexPath.row) {
                    
                case 0:
                {
//                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Settings" bundle: nil];
//                    MyProfileViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"sid_myprofilecontroller"];
//                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                    
                    
                default:
                    break;
            }
        }
            
            break;
            
        case 1:{
        
            switch (indexPath.row) {
                case 0:
                {
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Settings" bundle: nil];
                    AboutViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"sid_aboutviewcontroller"];
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                    
                case 1:
                {
                    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:nil
                                                                            delegate:self
                                                                   cancelButtonTitle:@"Cancel"
                                                              destructiveButtonTitle:nil
                                                                   otherButtonTitles:@"Mail", @"Message",@"Twitter",@"Facebook", nil];
                    popupQuery.actionSheetStyle = UIActionSheetStyleDefault;
                    [popupQuery showInView:self.view];
                }
                    break;
                    
                default:
                    break;
            }
        }
            
            break;
            
        case 2:{
        
            switch (indexPath.row) {
                    
                case 0: {
                
                }
                    break;
                    
                case 1: {
                    
                }
                    break;
                    
                case 2: {
                    
                }
                    break;
                    
                case 3: {
                   
                    if ([[NSUserDefaults standardUserDefaults] objectForKey:kMOBILE_PASS_CODE]) {
                        
                        UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:nil
                                                                                delegate:self
                                                                       cancelButtonTitle:@"Cancel"
                                                                  destructiveButtonTitle:nil
                                                                       otherButtonTitles:@"Turn Passcode Off", @"Change Passcode", nil];
                        popupQuery.actionSheetStyle = UIActionSheetStyleDefault;
                        [popupQuery showInView:self.view];
                        
                    }
                    
                    else {
                    
                        UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:nil
                                                                                delegate:self
                                                                       cancelButtonTitle:@"Cancel"
                                                                  destructiveButtonTitle:nil
                                                                       otherButtonTitles:@"Turn Passcode On", nil];
                        popupQuery.actionSheetStyle = UIActionSheetStyleDefault;
                        [popupQuery showInView:self.view];
                    }
                }
                    break;
                    
                    
                default:
                    break;
            }
        }
            
            break;
            
        default:
            break;
    }
}


#pragma mark-
#pragma mark- UIActionSheet delegate method
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    

    self.passcode_mode = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kTURN_PASSCODE_OFF]) {
        
        JKLLockScreenViewController * viewController = [[JKLLockScreenViewController alloc] initWithNibName:NSStringFromClass([JKLLockScreenViewController class]) bundle:nil];
        [viewController setLockScreenMode:LockScreenModeOff];
        [viewController setDelegate:self];
        [viewController setDataSource:self];
        [self presentViewController:viewController animated:YES completion:NULL];
        
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kTURN_PASSCODE_ON]) {
        
        JKLLockScreenViewController * viewController = [[JKLLockScreenViewController alloc] initWithNibName:NSStringFromClass([JKLLockScreenViewController class]) bundle:nil];
        [viewController setLockScreenMode:LockScreenModeNew];
        [viewController setDelegate:self];
        [viewController setDataSource:self];
        [self presentViewController:viewController animated:YES completion:NULL];
        
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kTURN_PASSCODE_CHANGE]) {
        
        JKLLockScreenViewController * viewController = [[JKLLockScreenViewController alloc] initWithNibName:NSStringFromClass([JKLLockScreenViewController class]) bundle:nil];
        [viewController setLockScreenMode:LockScreenModeChange];
        [viewController setDelegate:self];
        [viewController setDataSource:self];
        [self presentViewController:viewController animated:YES completion:NULL];
    }
}

#pragma mark -
#pragma mark YMDLockScreenViewControllerDelegate
- (void)unlockWasCancelledLockScreenViewController:(JKLLockScreenViewController *)lockScreenViewController {
    
    NSLog(@"LockScreenViewController dismiss because of cancel");
}

- (void)unlockWasSuccessfulLockScreenViewController:(JKLLockScreenViewController *)lockScreenViewController pincode:(NSString *)pincode {
    
    
    if (lockScreenViewController.lockScreenMode == LockScreenModeOff) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kMOBILE_PASS_CODE];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else if (lockScreenViewController.lockScreenMode == LockScreenModeChange) {
        [[NSUserDefaults standardUserDefaults] setObject:pincode forKey:kMOBILE_PASS_CODE];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else if (lockScreenViewController.lockScreenMode == LockScreenModeNew) {
        [[NSUserDefaults standardUserDefaults] setObject:pincode forKey:kMOBILE_PASS_CODE];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark -
#pragma mark YMDLockScreenViewControllerDataSource
- (BOOL)lockScreenViewController:(JKLLockScreenViewController *)lockScreenViewController pincode:(NSString *)pincode {
    
    NSString *enteredPincode = [[NSUserDefaults standardUserDefaults] objectForKey:kMOBILE_PASS_CODE];
    return [enteredPincode isEqualToString:pincode];
    
}

- (BOOL)allowTouchIDLockScreenViewController:(JKLLockScreenViewController *)lockScreenViewController {
    
    return YES;
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
