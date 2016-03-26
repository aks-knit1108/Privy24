//
//  DBManager.m
//  SYACHT
//
//  Created by Amit Kumar Shukla on 20/08/14.
//  Copyright (c) 2014 Amit Kumar Shukla. All rights reserved.
//

#import "DBManager.h"

@implementation DBManager

static DBManager *_sharedManager;

+ (DBManager*)sharedManager {
    if (_sharedManager == nil) {
        _sharedManager = [[DBManager alloc] initWithDatabaseFilename:kDATABSE_BUNDLE_NAME];
    }
    return _sharedManager;
}

-(instancetype)initWithDatabaseFilename:(NSString *)dbFilename{
    self = [super init];
    if (self) {
        
        // Copy the database file into the documents directory if necessary.
        [self copyDatabaseIntoDocumentsDirectory];
        
        // get path of document directory
        NSString *sqLiteDb = [kDOCUMENT_FOLDER_PATH stringByAppendingPathComponent:dbFilename];
        
        if (sqlite3_open([sqLiteDb UTF8String], &_database) != SQLITE_OK) {
            NSLog(@"Failed to open database!");
        }
    }
    return self;
}

-(void)copyDatabaseIntoDocumentsDirectory{
    
    // Check if the database file exists in the documents directory.
    NSString *destinationPath = [kDOCUMENT_FOLDER_PATH stringByAppendingPathComponent:kDATABSE_BUNDLE_NAME];
    if (![[NSFileManager defaultManager] fileExistsAtPath:destinationPath]) {
        // The database file does not exist in the documents directory, so copy it from the main bundle now.
        NSString *sourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kDATABSE_BUNDLE_NAME];
        NSError *error;
        [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:destinationPath error:&error];
        
        // Check if any error occurred during copying and display it.
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
}

-(NSInteger)getCountTable:(NSString*)strQuery
{
    sqlite3_stmt *statement = NULL;
    int returnValue = 0;
    long lastInserRowId = 0;
    
    const char *sqlStatement = [strQuery cStringUsingEncoding:NSUTF8StringEncoding];
    returnValue = sqlite3_prepare_v2(_database, sqlStatement, strlen(sqlStatement), &statement, NULL);
    
    
    if(returnValue == SQLITE_OK){
        returnValue = sqlite3_step(statement);
        
        if(returnValue == SQLITE_ROW) {
            lastInserRowId = sqlite3_column_int(statement, 0);
        }
    }
    sqlite3_finalize(statement);
    statement = nil;
    return lastInserRowId;
}

- (BOOL)executeQuery:(NSString *)query
{
    //NSLog(@"Query = %@",query);
    
	int status = sqlite3_exec(_database, [query cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL, NULL);
	if (status == SQLITE_OK)
    {
        //NSLog(@"Query execution succeeded...!!");
        return YES;
	}
	else
    {
        //NSLog(@"Query execution failed...!!");
        return NO;
	}
}

-(sqlite3*)getDBInstance
{
    return _database;
}



- (void)dealloc {
    sqlite3_close(_database);
}

@end
