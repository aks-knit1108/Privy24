//
//  ContactManager.h
//  Privy24
//
//  Created by Amit on 2/24/16.
//  Copyright (c) 2016 BrightZone. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kCONTACT_LOADED_NOTIIFCATION @"AddressBookContactLoaded"

@interface ContactManager : NSObject
@property (nonatomic, strong) NSMutableArray *addressBookContacts;

// shared instnace
+ (ContactManager*)sharedManager;
- (void)loadAddressBook;
- (void)fetchContacts;
- (void)getPrivyContacts;

@end
