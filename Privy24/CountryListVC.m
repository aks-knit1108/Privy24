//
//  CountryListVC.m
//  Privy24
//
//  Created by Amit on 8/29/15.
//  Copyright (c) 2015 BrightZone. All rights reserved.
//

#import "CountryListVC.h"
#import "ViewController.h"
#import "CountryCell.h"

@implementation CountryListVC

- (void)viewDidLoad {
    [super viewDidLoad];
        
    // Do any additional setup after loading the view, typically from a nib.
    self.countryArray = [[NSMutableArray alloc] initWithArray:[AppHelper getAllCountries]];
    self.searchArray = [NSMutableArray new];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-
#pragma mark- UITableView delegate methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return self.searchArray.count;
    }
    else
    {
        return self.countryArray.count;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CountryCell *cell = [self.tblView dequeueReusableCellWithIdentifier:@"CountryCell"];
    NSArray *array = [self getCountryForTableView:tableView andIndexPath:indexPath];
    cell.name.text = [array objectAtIndex:2];
    NSString *code = [NSString stringWithFormat:@"%@",[array objectAtIndex:0]];
    cell.code.text = [NSString stringWithFormat:@"+%@",code];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSArray *array = [self getCountryForTableView:tableView andIndexPath:indexPath];
    self.parentController.code = [NSString stringWithFormat:@"%@",[array objectAtIndex:0]];
    self.parentController.country = [array objectAtIndex:2];
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark - UISearchDisplayDelegate Methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}


- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    // remove all data that belongs to previous search
    [self.searchArray removeAllObjects];
    
    
    if([searchText isEqualToString:@""]||searchText==nil){
        [self.tblView reloadData];
        return;
    }
    
    for(NSArray *array in self.countryArray)
    {
        NSString *country = [array objectAtIndex:2];
        NSRange r = [country rangeOfString:searchText];
        if(r.location != NSNotFound)
        {
            if(r.location== 0)//that is we are checking only the start of the names.
            {
                [self.searchArray addObject:array];
            }
        }
        
    }
    
    [self.tblView reloadData];
}

- (NSArray *)getCountryForTableView:(UITableView *)tblView andIndexPath:(NSIndexPath *)indexPath {
    
    if (tblView == self.searchDisplayController.searchResultsTableView)
    {
        return [self.searchArray objectAtIndex:indexPath.row];
    }
    else
    {
        return [self.countryArray objectAtIndex:indexPath.row];
    }
}


- (IBAction)onBackTouched:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}



@end
