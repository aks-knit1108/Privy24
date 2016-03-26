//
//  Attachment.h
//  Privy24
//
//  Created by Amit on 11/29/15.
//  Copyright (c) 2015 BrightZone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "constants.h"
#import "DBManager.h"

@interface Attachment : NSObject

@property  AttachmentType type;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *thumbnail;
@property (nonatomic, strong) NSString *size;


- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
