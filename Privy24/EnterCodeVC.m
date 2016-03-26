//
//  EnterCodeVC.m
//  Privy24
//
//  Created by Amit on 8/29/15.
//  Copyright (c) 2015 BrightZone. All rights reserved.
//

#import "EnterCodeVC.h"
#import "constants.h"
#import "ProfileVC.h"

@interface EnterCodeVC ()
@property (weak, nonatomic) IBOutlet UITextField *verifCodeTextField;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@end

@implementation EnterCodeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        
    self.verifCodeTextField.text = self.verificationCode;
    //self.verifCodeTextField.userInteractionEnabled = NO;
    [self.verifCodeTextField becomeFirstResponder];
    
    self.phoneLabel.text = [NSString stringWithFormat:@"+%@ %@",self.code,self.mobile];

    [AppHelper addRightBarButtonToNavBar:self withText:@"Next" action:@selector(onNextTouched:)];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
        
    
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
- (IBAction)onBackTouched:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onNextTouched:(id)sender {
    
    NSString *url = [kBaseUrl stringByAppendingString:@"/checkCode"];
    
    NSDictionary *param = @{@"code":self.verificationCode,@"mobile":self.mobile};
    
    // Set spinner..
    [AppHelper addActivityToNavBar:self];
    
    [[ConnectionManager sharedManager] getRequest:url parameters:param  success:^(id responseObject) {
        
        [AppHelper addRightBarButtonToNavBar:self withText:@"Next"  action:@selector(onNextTouched:)];
        
        NSError *error = nil;
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                     options:kNilOptions
                                                                       error:&error];
        
        NSLog(@"JSON: %@", jsonResponse);
        
        
        if ([[jsonResponse objectForKey:@"status"] isEqualToString:@"success"]) {
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            Person *user = [[Person alloc] initWithDictionary:[jsonResponse objectForKey:@"data"]];
            ProfileVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"sid_profile"];
            vc.person = user;
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
