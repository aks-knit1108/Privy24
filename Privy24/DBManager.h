//
//  DBManager.h
//  SYACHT
//
//  Created by Amit Kumar Shukla on 20/08/14.
//  Copyright (c) 2014 Amit Kumar Shukla. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

#define SAFE_CONVERSION_TEXT_FROM_DB_TO_OBJECT(_objectVal, _dbVal) { char *chars = (char *)_dbVal; if (chars == NULL) {_objectVal = nil;} else {_objectVal = [[NSString stringWithUTF8String:chars] stringByReplacingOccurrencesOfString:@"__||??||__" withString:@"'"];}}
#define SAFE_INSERT(xx) xx.length?[xx stringByReplacingOccurrencesOfString:@"'" withString:@"__||??||__"]:@""

#define kDBMANAGER [DBManager sharedManager]

#define kDATABSE_BUNDLE_NAME @"privydb.sqlite3"

#define kDOCUMENT_FOLDER_PATH [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]


@interface DBManager : NSObject {

    sqlite3 *_database;
}

+ (DBManager*)sharedManager;
- (sqlite3*)getDBInstance;
- (NSInteger)getCountTable:(NSString*)strQuery;
- (BOOL)executeQuery:(NSString *)query;


@end
