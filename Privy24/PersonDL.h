//
//  PersonDL.h
//  Privy24
//
//  Created by Amit on 3/17/16.
//  Copyright (c) 2016 BrightZone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBManager.h"

// CREATE TABLE "tblPerson" ("code" VARCHAR,"firstName" VARCHAR,"mobile" VARCHAR DEFAULT (null) ,"image" VARCHAR,"lastName" VARCHAR,"localName" VARCHAR,"online" BOOL PRIMARY KEY  NOT NULL )

#define QUERY_COUNT_USERS                   @"SELECT COUNT() FROM tblPerson WHERE mobile = %@"
#define kQUERY_GET_ALL_USERS                @"SELECT * FROM tblPerson WHERE mobile <> %@ AND localName <> ''"
#define kQUERY_GET_USER                     @"SELECT * FROM tblPerson WHERE mobile = %@"
#define kQUERY_INSERT_USER                  @"INSERT INTO tblPerson (code,firstName,mobile,image,lastName,localName) VALUES ('%@','%@','%@','%@','%@','%@')"
#define kQUERY_UPDATE_USER                  @"UPDATE tblPerson SET code = '%@',firstName = '%@',image = '%@',lastName = '%@',localName = '%@' WHERE mobile = %@"



@class Person;

@interface PersonDL : DBManager
- (Person *) userFromMobile:(NSString *)mobile;
- (NSArray *) fetchAllUsers;
- (BOOL)saveUser:(Person *)user;

@end
