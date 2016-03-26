//
//  ViewController.m
//  Privy24
//
//  Created by Amit on 8/27/15.
//  Copyright (c) 2015 BrightZone. All rights reserved.
//

#import "ViewController.h"
#import "EnterCodeVC.h"
#import "CountryListVC.h"
#import "AppDelegate.h"

@interface ViewController ()


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.code = @"";
    self.country = @"";
    
    NSLocale *countryLocale = [NSLocale currentLocale];
    NSString *countryCode = [countryLocale objectForKey:NSLocaleCountryCode];
    //countryCode = @"IN";
    
    NSString *normalizedCountryId = [countryCode lowercaseString];
    NSMutableArray *countryCodes = [[NSMutableArray alloc] initWithArray:[AppHelper getAllCountries]];
    for (NSArray *array in countryCodes)
    {
        NSString *itemCountryId = [array objectAtIndex:1];
        if ([itemCountryId isEqualToString:normalizedCountryId])
        {
            self.code = [NSString stringWithFormat:@"%@",[array objectAtIndex:0]];
            self.country = [array objectAtIndex:2];
            
        }
    }
    
    
    [self.phoneNumTextField becomeFirstResponder];
    
    [AppHelper addRightBarButtonToNavBar:self withText:@"Next" action:@selector(onNextTouched:)];
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:YES];

    
    if (self.code.length!=0) {
        [self.codeTextField setText:[NSString stringWithFormat:@"+%@",self.code]];
    }
    
    if (self.country.length!=0) {
        [self.countryButton setTitle:self.country forState:UIControlStateNormal];
    }
    
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:YES];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark-
#pragma mark- All actions here..
- (IBAction)onNextTouched:(id)sender {
    
    if (self.code.length==0) {
        [AppHelper showAlert:@"Privy24" withMessage:@"Please select country."];
        return;
    }
    
    if (self.phoneNumTextField.text.length==0) {
        [AppHelper showAlert:@"Privy24" withMessage:@"Please add phone number."];
        return;
    }
    
    if (self.phoneNumTextField.text.length!=0 && self.phoneNumTextField.text.length<10) {
        [AppHelper showAlert:@"Privy24" withMessage:@"Please add valid phone number."];
        return;
    }
    
    NSString *url = [kBaseUrl stringByAppendingString:@"/checkUser"];
    
    NSDictionary *param = @{@"mobile":self.phoneNumTextField.text,@"countryCode":self.code};
    
    // Set spinner..
    [AppHelper addActivityToNavBar:self];
    
    [[ConnectionManager sharedManager] getRequest:url parameters:param  success:^(id responseObject) {
        
        //hide spinner
        [AppHelper addRightBarButtonToNavBar:self withText:@"Next" action:@selector(onNextTouched:)];
        
        NSError *error = nil;
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                     options:kNilOptions
                                                                       error:&error];
        
        NSLog(@"JSON: %@", jsonResponse);
        
        
        if ([[jsonResponse objectForKey:@"status"] isEqualToString:@"success"]) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            EnterCodeVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"sid_entercode"];
            vc.verificationCode = [NSString stringWithFormat:@"%@",[jsonResponse objectForKey:@"code"]];
            vc.mobile = self.phoneNumTextField.text;
            vc.code = self.code;
            
            [self.navigationController pushViewController:vc animated:YES];
            
            
        } else {
        
            [AppHelper showAlert:[jsonResponse objectForKey:@"status"] withMessage:[jsonResponse objectForKey:@"message"]];
        }
        
    } failure:^(NSError *error) {
        //hide spinner
        [AppHelper addRightBarButtonToNavBar:self withText:@"Next" action:@selector(onNextTouched:)];
        //[AppHelper showAlert:@"Error !!" withMessage:error.localizedDescription];
    }];

}

- (IBAction)onCountryTouched:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    CountryListVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"sid_country"];
    vc.parentController = self;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
