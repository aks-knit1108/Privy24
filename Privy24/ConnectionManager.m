//
//  ConnectionManager.h
//  MarketPlace
//
//  Created by Amit Kumar Shukla on 26/12/14.
//  Copyright (c) 2014 Smart Data Inc. All rights reserved.


#import "ConnectionManager.h"

static NSString *boundary = @"----------V2ymHFg03ehbqgZCaKO6jy";
static ConnectionManager *_sharedManager;

@implementation ConnectionManager

+ (ConnectionManager*)sharedManager {

    if (_sharedManager == nil) {
        _sharedManager = [[ConnectionManager alloc] init];
    }
    
    return _sharedManager;
}

- (id)init {
    
    self = [super init];
    if (self) {
         
        return self;
    }
    return nil;
}


#pragma mark- Main requests
- (void)postRequest:(NSString *)url parameters:(NSDictionary *)param success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure {

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:&error];
        
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                               NSLog(@"response = %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                               if (!error) {
                                   success(data);;
                               } else {
                                   failure(error);
                               }
                           }];
    
   
}

- (void)getRequest:(NSString *)url parameters:(NSDictionary *)param success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure{

    NSMutableArray *params = [NSMutableArray new];
    NSArray *array = [param allKeys];
    
    for (NSString *key in array) {
        [params  addObject:[NSString stringWithFormat:@"%@=%@",key,[param valueForKey:key]]];
    }
    
    NSString *fullUrl = [NSString stringWithFormat:@"%@?%@",url,[params componentsJoinedByString:@"&"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:fullUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    // Asynchronously Api is hit here
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                               NSLog(@"response = %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                               
                               if (!error) {
                                   success(data);;
                               } else {
                                   failure(error);
                               }
                           }];
}

#pragma mark-
#pragma mark- Background services
- (void)postBackgroundRequest:(NSString *)url parameters:(NSDictionary *)param {
    
    backgroundQueue= dispatch_queue_create("connectionManager.backgroundqueue", NULL);
    
    dispatch_async(backgroundQueue, ^(void){
        /// function name which you want to call in background
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:&error];
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"%@", jsonString);
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:jsonData];
        
        // Asynchronously Api is hit here
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                   
                                   if (error!=nil) {
                                       // Call api again here..
                                       [self postBackgroundRequest:url parameters:param];
                                   } else {
                                       NSLog(@"response = %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                   }
                               }];
    });
}

- (void)uploadAttachmentRequest:(NSString *)url attachmentName:(NSString *)fileName attachmentData:(NSData *)data success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure {
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=file; filename=\"%@\"\r\n",fileName]] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               NSLog(@"response = %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                               
                               if (!error) {
                                   success(data);;
                               } else {
                                   failure(error);
                               }
                               
                           }];
    
}



@end
