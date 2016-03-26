//
//  ContactManager.m
//  Privy24
//
//  Created by Amit on 2/24/16.
//  Copyright (c) 2016 BrightZone. All rights reserved.
//

#import "ContactManager.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "Person.h"
#import "ConnectionManager.h"
#import "constants.h"

static ContactManager *_sharedManager;

@implementation ContactManager

+ (ContactManager*)sharedManager {
    
    if (_sharedManager == nil) {
        _sharedManager = [[ContactManager alloc] init];
    }
    
    return _sharedManager;
}

- (id)init {
    
    self = [super init];
    if (self) {
        self.addressBookContacts = [NSMutableArray new];
        [self fetchContacts];
        return self;
    }
    return nil;
}

- (void)fetchContacts {

    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, nil);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)
                                             {
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     if (granted) [self loadAddressBook];
                                                 });
                                             });
}

- (void)loadAddressBook
{
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    
    if (addressBook != nil) {
        
        [self.addressBookContacts removeAllObjects];
        
        NSLog(@"Succesful.");
        
        NSArray *allContacts = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
        
        NSUInteger i = 0; for (i = 0; i < [allContacts count]; i++)
        {
            ABRecordRef contactPerson = (__bridge ABRecordRef)allContacts[i];
            
            NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(contactPerson,
                                                                                  kABPersonFirstNameProperty);
            NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
            
            //phone
            ABMultiValueRef phones = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
            
            for (NSUInteger j = 0; j < ABMultiValueGetCount(phones); j++) {
                NSString *number = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phones, j);
                Person *person = [[Person alloc] init];
                
                if (firstName) {
                    person.firstName = firstName;
                    
                    if (lastName) {
                        person.lastName = lastName;
                    }
                } else {
                    
                    if (lastName) {
                        person.firstName = lastName;
                    }
                }
                
                
                
                NSString *fullName = [NSString stringWithFormat:@"%@ %@", person.firstName, person.lastName];
                person.localName = fullName;
                person.mobile = number;
                
                [self.addressBookContacts addObject:person];
            }
            
        }
        
        CFRelease(addressBook);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kCONTACT_LOADED_NOTIIFCATION object:self.addressBookContacts];
        
        [self getPrivyContacts];
        
        
    }
    
    else {
        NSLog(@"Error reading Address Book");
    }
    
    
}

- (void) getPrivyContacts {
    
    if (self.addressBookContacts.count==0) {
        return;
    }
    
    NSMutableArray *contacts = [NSMutableArray new];
    
    
    for (Person *person in self.addressBookContacts) {
        
        NSString *phoneNumber = person.mobile;
        NSString *result = [Person getValidNumber:phoneNumber];
        
        [contacts addObject:result];
    }
        
    NSString *url = [kBaseUrl stringByAppendingString:@"/getUserContact"];
    NSDictionary *param = @{@"mobilenumbers":contacts};
    
    [[ConnectionManager sharedManager] postRequest:url parameters:param  success:^(id responseObject) {
        
        NSError *error = nil;
        NSArray *jsonResponse = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                options:kNilOptions
                                                                  error:&error];
        
        for (NSDictionary *dict in jsonResponse) {
            
            Person *person = [[Person alloc] initWithDictionary:dict];
            [self.addressBookContacts enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(Person *p, NSUInteger index, BOOL *stop) {
                
                NSString *phoneNumber = p.mobile;
                NSString *result = [Person getValidNumber:phoneNumber];
                if ([result isEqualToString:person.mobile]) {
                    person.localName = p.localName;
                    [person executeSaveQuery];
                    [self.addressBookContacts removeObject:p];
                    
                }
            }];
        }
        
    } failure:^(NSError *error) {
        
        [AppHelper showAlert:@"Error !!" withMessage:error.localizedDescription];
    }];
    
    
    
}



@end
