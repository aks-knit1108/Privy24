//
//  InboxVC.m
//  Privy24
//
//  Created by Amit on 8/31/15.
//  Copyright (c) 2015 BrightZone. All rights reserved.
//

#import "ChatController.h"
#import "MessageController.h"
#import "constants.h"
#import "ChatCell.h"
#import "Privy24-Swift.h"
#import "PrivyContacts.h"
#import <iAd/iAd.h>
#import "Reachability.h"
#import "NetworkView.h"
#import "MessageHandler.h"

@interface ChatController ()<ADBannerViewDelegate>
@property (weak, nonatomic) IBOutlet ADBannerView *adBanner;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bannerHeightConstraints;
@end

@implementation ChatController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.chatArray = [[NSMutableArray alloc] init];
    
    /*
     Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the method reachabilityChanged will be called.
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatReceivedNotification:)
                                                 name:kCHAT_NOTIFY_NOTIIFCATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteMessagedNotification:)
                                                 name:kDELETE_MESSAGE_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socketConnected:)
                                                 name:kSOCKET_CONNECTION_CONNECTED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contactReceivedNotification:)
                                                 name:kCONTACT_LOADED_NOTIIFCATION object:nil];
    
        
    
    // Initially hide the ad banner.
    self.adBanner.alpha = 0.0;
    self.bannerHeightConstraints.constant = 50;
    
    BOOL connectionRequired = [kAPP_DELEGATE.reachability connectionRequired];
    
    if (connectionRequired) {
        self.navigationItem.titleView = [[NetworkView alloc] initNetworkView:@"Waiting for Network."];
    } else {
        self.navigationItem.titleView = nil;
        
        if (![[SocketLisner sharedLisner] connectionStatus]) {
            [self socketDisconnected:nil];
        }
    }
    
    // Schedule all message again which were schedlue before app quit
    [[MessageHandler sharedHandler] scheduleMessages];
    

}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.chatArray removeAllObjects];
    [self.chatArray addObjectsFromArray:[Chat fetchAllChats]];
    
    [self reloadChat];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)contactReceivedNotification:(NSNotification *)notif {
    
    [self.chatArray removeAllObjects];
    [self.chatArray addObjectsFromArray:[Chat fetchAllChats]];
    
    [self reloadChat];
}


- (void)chatReceivedNotification:(NSNotification *)notif {
    
    BOOL isExists = NO;
    Chat *chatObject = notif.object;
    for (int index = 0; index<self.chatArray.count; index++) {
        Chat *chat = self.chatArray[index];
        if ([chatObject.chatId isEqualToString:chat.chatId]) {
            isExists = YES;
            [self.chatArray replaceObjectAtIndex:index withObject:chatObject];
            break;
        }
    }
    
    if (!isExists) {
        [self.chatArray addObject:chatObject];
    }
    [self reloadChat];
}

- (void)deleteMessagedNotification:(NSNotification *)notif {
    
    [self reloadChat];
}

- (void)reloadChat {
    
    [self.chatArray sortUsingComparator:^NSComparisonResult(Chat *obj1, Chat *obj2){
        return [obj2.chatDate compare:obj1.chatDate];
    }];
    
    [self.tableView reloadData];
}


#pragma mark-
#pragma mark- UITableView delegates..
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return 0;
    }
    else
    {
        return self.chatArray.count;
    }
    
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ChatCellIdentifier";
    
    ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//    cell.rightUtilityButtons = [self rightButtons];
//    cell.delegate = self;
    
    Chat *chat = self.chatArray[indexPath.row];
    [cell setChat:chat];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Chat" bundle: nil];
    MessageController *vc = [storyboard instantiateViewControllerWithIdentifier:@"sid_messagecontroller"];
    Chat *chat = self.chatArray[indexPath.row];
    Person *person = [chat getOpponentUser];
    vc.opponentUser = person;
    vc.chat = chat;
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
//    [self.searchResult removeAllObjects];
//    
//    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF.firstName contains[c] %@",searchText];
//    
//    self.searchResult = [NSMutableArray arrayWithArray: [self.addressBookContacts filteredArrayUsingPredicate:resultPredicate]];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"DELETE";
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [UIActionSheet showInView:self.view
                    withTitle:@"Are you sure you want to ?"
            cancelButtonTitle:@"Cancel"
       destructiveButtonTitle:@"Delete Chat"
            otherButtonTitles:@[@"Clear Chat"]
                     tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                         NSLog(@"Chose %@", [actionSheet buttonTitleAtIndex:buttonIndex]);
                         
                         switch (buttonIndex) {
                                 
                             case 0: {
                             
                                 Chat *chat = self.chatArray[indexPath.row];
                                 [chat deleteChat];
                                 [self.chatArray removeObjectAtIndex:indexPath.row];
                                 [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                                 
                                 
                             }
                                 break;
                                 
                             case 1: {
                                 
                                 Chat *chat = self.chatArray[indexPath.row];
                                 [Message deleteAllMessagesForChat:chat];
                                 
                                 [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                                 
                                 
                             }
                                 break;
                                 
                                 
                                 
                             default:
                                 break;
                         }
                     }];
    
    
}



- (IBAction)onEditChatTouched:(UIBarButtonItem *)sender {
    
    NSString *title = sender.title;
    if ([title isEqualToString:@"Edit"]) {
        [self.tableView setEditing:YES animated:YES];
        [sender setTitle:@"Done"];
    } else {
        [self.tableView setEditing:NO animated:YES];
        [sender setTitle:@"Edit"];
    }
    
}

- (IBAction)onNewMessageTouched:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Chat" bundle: nil];
    PrivyContacts *vc = [storyboard instantiateViewControllerWithIdentifier:@"sid_PrivyContacts"];
    vc.isFromNewChat = YES;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:navController animated:YES completion:^{
        
    }];
}

-(void)bannerViewWillLoadAd:(ADBannerView *)banner{
    NSLog(@"Ad Banner will load ad.");
}

-(void)bannerViewDidLoadAd:(ADBannerView *)banner{
    NSLog(@"Ad Banner did load ad.");
    
    // Show the ad banner.
    [UIView animateWithDuration:0.5 animations:^{
        self.adBanner.alpha = 1.0;
        self.bannerHeightConstraints.constant = 50;
        
    }];
}

-(BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave{
    NSLog(@"Ad Banner action is about to begin.");
    
    return YES;
}

-(void)bannerViewActionDidFinish:(ADBannerView *)banner{
    NSLog(@"Ad Banner action did finish");
}

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    NSLog(@"Unable to show ads. Error: %@", [error localizedDescription]);
    
    // Hide the ad banner.
    [UIView animateWithDuration:0.5 animations:^{
        self.adBanner.alpha = 0.0;
        self.bannerHeightConstraints.constant = 0;
        
    }];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 0) {
        
        
        
        
    } else if (buttonIndex == 1) {
        
        
    } 
}




/*!
 * Called by Reachability whenever status changes.
 */
- (void) reachabilityChanged:(NSNotification *)note
{
    Reachability* reachability = [note object];
    BOOL connectionRequired = [reachability connectionRequired];
    
    if (connectionRequired) {
        self.navigationItem.titleView = [[NetworkView alloc] initNetworkView:@"Waiting for Network."];
    } else {
        self.navigationItem.titleView = nil;
        
        if (![[SocketLisner sharedLisner] connectionStatus]) {
            [self socketDisconnected:nil];
        } 
    }
}

- (void)socketConnected:(NSNotification *)note {
    self.navigationItem.titleView = nil;
}

- (void)socketDisconnected:(NSNotification *)note {
    self.navigationItem.titleView = [[NetworkView alloc] initNetworkView:@"Connecting.."];
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
