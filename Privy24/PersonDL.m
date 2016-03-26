//
//  PersonDL.m
//  Privy24
//
//  Created by Amit on 3/17/16.
//  Copyright (c) 2016 BrightZone. All rights reserved.
//

#import "PersonDL.h"
#import "Person.h"
#import "SocketLisner.h"


@implementation PersonDL

- (Person *) userFromMobile:(NSString *)mobile {

    NSString *strQuery = [NSString stringWithFormat:kQUERY_GET_USER,mobile];
    
    sqlite3_stmt *statement = nil;
    
    Person *object= [[Person alloc] init];
    
    const char *sqlStatement = [strQuery cStringUsingEncoding:NSUTF8StringEncoding];
    if (sqlite3_prepare_v2([kDBMANAGER getDBInstance], sqlStatement, (int)strlen(sqlStatement), &statement, nil) == SQLITE_OK) {
        
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            SAFE_CONVERSION_TEXT_FROM_DB_TO_OBJECT(object.code,sqlite3_column_text(statement, 0));
            SAFE_CONVERSION_TEXT_FROM_DB_TO_OBJECT(object.firstName,sqlite3_column_text(statement, 1));
            SAFE_CONVERSION_TEXT_FROM_DB_TO_OBJECT(object.mobile,sqlite3_column_text(statement, 2));
            SAFE_CONVERSION_TEXT_FROM_DB_TO_OBJECT(object.image,sqlite3_column_text(statement, 3));
            SAFE_CONVERSION_TEXT_FROM_DB_TO_OBJECT(object.lastName,sqlite3_column_text(statement, 4));
            SAFE_CONVERSION_TEXT_FROM_DB_TO_OBJECT(object.localName,sqlite3_column_text(statement, 5));
            
            return object;
            
        }
        sqlite3_finalize(statement);
    }
    
    return object;
    
}

- (NSArray *) fetchAllUsers {

    Person *user = [SocketLisner sharedLisner].user;
    
    NSString *strQuery = [NSString stringWithFormat:kQUERY_GET_ALL_USERS,user.mobile];
    
    NSMutableArray *arrResponse	= [NSMutableArray array];
    sqlite3_stmt *statement = nil;
    
    const char *sqlStatement = [strQuery cStringUsingEncoding:NSUTF8StringEncoding];
    if (sqlite3_prepare_v2([kDBMANAGER getDBInstance], sqlStatement, (int)strlen(sqlStatement), &statement, nil) == SQLITE_OK) {
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            Person *object= [[Person alloc] init];
            SAFE_CONVERSION_TEXT_FROM_DB_TO_OBJECT(object.code,sqlite3_column_text(statement, 0));
            SAFE_CONVERSION_TEXT_FROM_DB_TO_OBJECT(object.firstName,sqlite3_column_text(statement, 1));
            SAFE_CONVERSION_TEXT_FROM_DB_TO_OBJECT(object.mobile,sqlite3_column_text(statement, 2));
            SAFE_CONVERSION_TEXT_FROM_DB_TO_OBJECT(object.image,sqlite3_column_text(statement, 3));
            SAFE_CONVERSION_TEXT_FROM_DB_TO_OBJECT(object.lastName,sqlite3_column_text(statement, 4));
            SAFE_CONVERSION_TEXT_FROM_DB_TO_OBJECT(object.localName,sqlite3_column_text(statement, 5));
            [arrResponse addObject:object];
            
        }
        sqlite3_finalize(statement);
    }
    
    return arrResponse;
}

- (BOOL)saveUser:(Person *)user {

    if (![kDBMANAGER getCountTable:[NSString stringWithFormat:QUERY_COUNT_USERS,user.mobile]]) {
        return [kDBMANAGER executeQuery:[NSString stringWithFormat:kQUERY_INSERT_USER,user.code,user.firstName,user.mobile,user.image,user.lastName,user.localName]];
    } else {
        
        if ([user.localName length] != 0) {
            return [kDBMANAGER executeQuery:[NSString stringWithFormat:kQUERY_UPDATE_USER,user.code,user.firstName,user.image,user.lastName,user.localName,user.mobile]];
        }
    }
    
    return NO;
}

@end
