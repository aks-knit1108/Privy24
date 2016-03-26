//
//  PrivyContacts.m
//  Privy24
//
//  Created by Amit on 10/6/15.
//  Copyright (c) 2015 BrightZone. All rights reserved.
//

#import "PrivyContacts.h"
#import "constants.h"
#import "ContactCustomCell.h"
#import "MessageController.h"
#import "ChatController.h"
#import "ContactDetailVC.h"

@implementation PrivyContacts

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    if (self.isFromNewChat) {
        [AppHelper addRightBarButtonToNavBar:self withText:@"Cancel" action:@selector(onCancelTouched:)];
        self.title = @"New Chat";
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    
    self.usersArray = [[NSMutableArray alloc]initWithArray:[Person fetchAllUsers]];
    [self.tableView reloadData];
}


#pragma mark-
#pragma mark- UITableView delegates..
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return [self.searchResult count];
    }
    else
    {
        return [self.usersArray count];
    }
    
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Person *person = [self getPersonForTableView:tableView andIndexPath:indexPath];
    
    static NSString *cellIdentifier = @"ContactCustomCellIdentifier";
    ContactCustomCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    cell.userName.text = person.localName;
    cell.userImage.layer.cornerRadius = 17.0f;
    cell.userImage.layer.masksToBounds = YES;
    
    if (self.isFromNewChat) {
        cell.accessoryView = UITableViewCellAccessoryNone;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kImageUrl,person.image]];
    [cell.userImage sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"no-img.png"]];
    
    return cell;
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
    Person *person = [self getPersonForTableView:tableView andIndexPath:indexPath];
    
    //Open chat screen
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Chat" bundle: nil];
    MessageController *vc = [storyboard instantiateViewControllerWithIdentifier:@"sid_messagecontroller"];
    vc.opponentUser = person;
    vc.chat = [Chat fetchChatForOpponent:person];
    
    NSArray *viewControllers = kAPP_DELEGATE.tabBarController.viewControllers;
    kAPP_DELEGATE.tabBarController.selectedIndex = 2;
    UINavigationController *navController = viewControllers[2];
    [navController pushViewController:vc animated:YES];
    
    if (self.isFromNewChat) {
        [self dismissViewControllerAnimated:YES completion:^{
            //
        }];
    }
    
}

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Chat" bundle: nil];
    ContactDetailVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"sid_contactDetailVC"];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UISearchDisplayDelegate Methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}


- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    [self.searchResult removeAllObjects];
    
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF.firstName contains[c] %@",searchText];
    
    self.searchResult = [NSMutableArray arrayWithArray: [self.usersArray filteredArrayUsingPredicate:resultPredicate]];
}

- (Person *)getPersonForTableView:(UITableView *)tblView andIndexPath:(NSIndexPath *)indexPath {
    
    if (tblView == self.searchDisplayController.searchResultsTableView)
    {
        return [self.searchResult objectAtIndex:indexPath.row];
    }
    else
    {
        return [self.usersArray objectAtIndex:indexPath.row];
    }
}

#pragma mark-
#pragma mark- All actions here..
- (IBAction)onCancelTouched:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
}






@end
