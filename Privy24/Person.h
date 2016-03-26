//
//  Person.h
//  Privy24
//
//  Created by Amit on 9/9/15.
//  Copyright (c) 2015 BrightZone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBManager.h"

@interface Person : NSObject

@property (nonatomic, strong) NSString *mobile;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *countryCode;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *localName;
@property (nonatomic, strong) NSString *image;
@property (nonatomic, readwrite) BOOL online;

// @Convenience methods
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (BOOL)isNotAlphaNumeric;
+ (NSString *)getValidNumber:(NSString *)phoneNumber;

// @Database methods
+ (Person *) fetchUserForId:(NSString *)mobile;
+ (NSArray *) fetchAllUsers;
- (void) executeSaveQuery;


@end
