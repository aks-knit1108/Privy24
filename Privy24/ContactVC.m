//
//  ContactVC.m
//  Privy24
//
//  Created by Amit on 8/31/15.
//  Copyright (c) 2015 BrightZone. All rights reserved.
//

#import "ContactVC.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "MessageController.h"
#import "ContactCustomCell.h"
#import "ContactManager.h"

@interface ContactVC ()<ABNewPersonViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *animalIndexTitles;
@property (nonatomic, strong) NSMutableDictionary *alphabeticalDict;
@property (nonatomic, strong) NSMutableArray *searchResult;
@property (nonatomic, strong) NSMutableArray *addressBookContacts;

@end

@implementation ContactVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.addressBookContacts = [[NSMutableArray alloc] init];
    self.alphabeticalDict = [[NSMutableDictionary alloc] init];
    self.searchResult = [[NSMutableArray alloc] init];
        
    self.animalIndexTitles = @[@"#",@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contactReceivedNotification:)
                                                 name:kCONTACT_LOADED_NOTIIFCATION object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    
    if (self.addressBookContacts.count == 0) {
        
        [self.addressBookContacts removeAllObjects];
        [self.addressBookContacts addObjectsFromArray:[ContactManager sharedManager].addressBookContacts];
        [self sortContacts];
    }
    
}



- (void)contactReceivedNotification:(NSNotification *)notif {
    
    [self.addressBookContacts removeAllObjects];
    NSArray *contacts = (NSArray *)notif.object;
    [self.addressBookContacts addObjectsFromArray:contacts];
    [self sortContacts];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-
#pragma mark- ABNewPersonViewController delegates..
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person {
    
    [self dismissViewControllerAnimated:YES completion:^{
        [[ContactManager sharedManager] loadAddressBook];
    }];
}

- (void)sortContacts {
    
    BOOL found;
    
    [self.alphabeticalDict removeAllObjects];
    
    // Loop through the books and create our keys
    for (Person *person in self.addressBookContacts)
    {
        NSString *c;
        
        if (person.firstName.length == 0 && person.lastName.length == 0) {
            c = @"#";
        }
        
        else {
            
            if ([person isNotAlphaNumeric]){
                c = [[person.firstName substringToIndex:1] capitalizedString];
            } else {
                c= @"#";
            }
        }
        
        found = NO;
        
        for (NSString *str in [self.alphabeticalDict allKeys]){
            
            if ([str isEqualToString:c]){
                found = YES;
            }
        }
        
        if (!found){
            [self.alphabeticalDict setValue:[[NSMutableArray alloc] init] forKey:c];
        }
    }
    
    // Loop again and sort the books into their respective keys
    for (Person *person in self.addressBookContacts)
    {
        NSString *c;
        
        
        if (person.firstName.length == 0 && person.lastName.length == 0) {
            c = @"#";
        }
        else {
            
            if ([person isNotAlphaNumeric])
            {
                c = [[person.firstName substringToIndex:1] capitalizedString];
            }
            else
            {
                c= @"#";
            }
        }
        [[self.alphabeticalDict objectForKey:c] addObject:person];
    }
    
    [self.tableView reloadData];
    
}

#pragma mark-
#pragma mark- UITableView delegates..
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return 1;
    }
    else
    {
        return [[self.alphabeticalDict allKeys] count];
        
    }
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return [self.searchResult count];
    }
    else
    {
        return [[self.alphabeticalDict valueForKey:[[[self.alphabeticalDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section]] count];
    }
    
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView){
        return @"";
    } else {
        return [[[self.alphabeticalDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section];
    }
    
    
    
    
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    } else {
        return self.animalIndexTitles;
    }
    
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Person *person = [self getPersonForTableView:tableView andIndexPath:indexPath];
    
    static NSString *cellIdentifier = @"ContactCellIdentifier";
    ContactCustomCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    
    if (person.firstName.length == 0 && person.lastName.length == 0) {
        
        // Create the attributes
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:person.mobile];
        cell.userName.attributedText = attrString;
        cell.statusLabel.text = @"";
        
    } else {
        
        NSString *fullName = [NSString stringWithFormat:@"%@ %@", person.firstName, person.lastName];
        
        // Create the attributes
        float fontSize = cell.userName.font.pointSize;
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:fullName];
        [attrString beginEditing];
        [attrString addAttribute:NSFontAttributeName
                           value:[UIFont systemFontOfSize:fontSize]
                           range:NSMakeRange(0, fullName.length)];
        [attrString addAttribute:NSFontAttributeName
                           value:[UIFont boldSystemFontOfSize:fontSize]
                           range:NSMakeRange(0, person.firstName.length)];
        [attrString endEditing];
        
        
        cell.userName.attributedText = attrString;
        cell.statusLabel.text = person.mobile;
    }
    
    [cell.inviteButton addTarget:self action:@selector(inviteButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        [cell.inviteButton setAccessibilityIdentifier:@"seaarch"];
    }
    else
    {
        [cell.inviteButton setAccessibilityIdentifier:@""];
    }
    
    
    
    
    return cell;
    
    
}

- (void)inviteButtonTapped:(UIButton *)sender
{
    NSString *identifier = sender.accessibilityIdentifier;
    
    if (identifier.length == 0) {
        
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
        Person *person = [[self.alphabeticalDict valueForKey:[[[self.alphabeticalDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        
        [self sendSMS:person];
        
    } else {
        
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.searchDisplayController.searchResultsTableView];
        NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForRowAtPoint:buttonPosition];
        Person *person = [self.searchResult objectAtIndex:indexPath.row];;
        [self sendSMS:person];
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    

    
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
    
    self.searchResult = [NSMutableArray arrayWithArray: [self.addressBookContacts filteredArrayUsingPredicate:resultPredicate]];
}

- (Person *)getPersonForTableView:(UITableView *)tblView andIndexPath:(NSIndexPath *)indexPath {
    
    if (tblView == self.searchDisplayController.searchResultsTableView)
    {
        return [self.searchResult objectAtIndex:indexPath.row];
    }
    else
    {
        return [[self.alphabeticalDict valueForKey:[[[self.alphabeticalDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    }
}


#pragma mark - SMS sending method

- (void)sendSMS:(Person *)p
{
    if ([MFMessageComposeViewController canSendText])
    {
        MFMessageComposeViewController *messageCompose = [[MFMessageComposeViewController alloc] init];
        NSMutableArray *receipients = [NSMutableArray new];
        [receipients addObject:p.mobile];
        messageCompose.recipients = receipients;
        messageCompose.body = @"Hey, let's switch to Privy24: ";
        messageCompose.messageComposeDelegate = self;
        [self presentViewController:messageCompose animated:YES completion:nil];
    }
    else [AppHelper showAlert:@"" withMessage:@"SMS cannot be sent from this device."];
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result

{
    if (result == MessageComposeResultSent)
    {
        [AppHelper showAlert:@"" withMessage:@"SMS sent successfully."];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark-
#pragma mark- All actions here..
- (IBAction)onAddContactTouched:(id)sender {
    
    ABNewPersonViewController *newPersonViewController = [[ABNewPersonViewController alloc] init];
    [newPersonViewController setNewPersonViewDelegate:self];
    // Wrap in a nav controller and display
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:newPersonViewController];
    [self presentViewController:navController animated:YES completion:^{
        //
    }];
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
