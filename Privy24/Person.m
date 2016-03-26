//
//  Person.m
//  Privy24
//
//  Created by Amit on 9/9/15.
//  Copyright (c) 2015 BrightZone. All rights reserved.
//

#import "Person.h"
#import "constants.h"
#import "PersonDL.h"

@implementation Person

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        self.mobile         = @"";
        self.countryCode    = @"";
        self.code           = @"";
        self.firstName      = @"";
        self.lastName       = @"";
        self.localName      = @"";
        self.image          = @"";
        self.online         = NO;
                
        return self;
    }
    
    return nil;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    
    self = [super init];
    if (self) {
        
        self.mobile         = [NSString stringWithFormat:@"%@",EMPTYIFNULL(dict[@"mobile"])];
        self.code           = [NSString stringWithFormat:@"%@",EMPTYIFNULL(dict[@"code"])];
        self.countryCode    = [NSString stringWithFormat:@"%@",EMPTYIFNULL(dict[@"countryCode"])];
        self.firstName      = [NSString stringWithFormat:@"%@",EMPTYIFNULL(dict[@"fname"])];
        self.lastName       = [NSString stringWithFormat:@"%@",EMPTYIFNULL(dict[@"lname"])];
        self.localName      = @"";
        self.image          = [NSString stringWithFormat:@"%@",EMPTYIFNULL(dict[@"image"])];
        self.online         = NO;
        
        return self;
    }
    
    return nil;
}

- (NSComparisonResult)compare:(Person *)personObject {
    return [self.firstName compare:personObject.firstName];
}
- (BOOL)isNotAlphaNumeric
{
    NSLog(@"%@",self.firstName);
    
    NSString *firstLtr = [self.firstName substringToIndex:1];
    
    NSRange match = [firstLtr rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet] options:0 range:NSMakeRange(0, firstLtr.length)];
    if (match.location != NSNotFound) {
        // someString has a letter in it
        return YES;
    }
    
    return NO;
    
}

+ (NSString *)getValidNumber:(NSString *)phoneNumber {
    
    NSMutableString *result = [NSMutableString stringWithCapacity:phoneNumber.length];
    
    NSScanner *scanner = [NSScanner scannerWithString:phoneNumber];
    NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    
    while ([scanner isAtEnd] == NO)
    {
        NSString *buffer;
        if ([scanner scanCharactersFromSet:numbers intoString:&buffer])
        {
            [result appendString:buffer];
        }
        else
        {
            [scanner setScanLocation:([scanner scanLocation] + 1)];
        }
    }
    
    NSLog(@"%@", result);
    
    if (result.length>10) {
        
        NSString *substring = [result substringWithRange:NSMakeRange(result.length-10, 10)];
        return substring;
    }
    
    return result;
}

+ (Person *) fetchUserForId:(NSString *)mobile {
    
    PersonDL *repo = [PersonDL new];
    return [repo userFromMobile:mobile];
}

+ (NSArray *) fetchAllUsers {
    
    PersonDL *repo = [PersonDL new];
    return [repo fetchAllUsers];
}

- (void) executeSaveQuery {

    PersonDL *repo = [PersonDL new];
    [repo saveUser:self];
    
}


@end
