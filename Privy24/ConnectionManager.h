
//
//  ConnectionManager.h
//  MarketPlace
//
//  Created by Amit Kumar Shukla on 26/12/14.
//  Copyright (c) 2014 Smart Data Inc. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//typedef void (^success)(id responseObject);
//typedef void (^failure)(NSError *error);

@interface ConnectionManager : NSObject<NSURLConnectionDelegate> {

    dispatch_queue_t backgroundQueue; // dispaatch queue
}

// shared instnace
+ (ConnectionManager*)sharedManager;

// post request
- (void)postRequest:(NSString *)url parameters:(NSDictionary *)param success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
- (void)getRequest:(NSString *)url parameters:(NSDictionary *)param success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
- (void)uploadAttachmentRequest:(NSString *)url attachmentName:(NSString *)fileName attachmentData:(NSData *)data success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;


// background services
- (void)postBackgroundRequest:(NSString *)url parameters:(NSDictionary *)param;




@end
