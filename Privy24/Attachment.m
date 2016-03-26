//
//  Attachment.m
//  Privy24
//
//  Created by Amit on 11/29/15.
//  Copyright (c) 2015 BrightZone. All rights reserved.
//

#import "Attachment.h"

@implementation Attachment

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        self.url            = @"";
        self.type           = 0;
        self.size           = @"";
        self.thumbnail      = @"";
        return self;
    }
    
    return nil;
}


- (instancetype)initWithDictionary:(NSDictionary *)dict {
    
    self = [super init];
    if (self) {
        
        self.url            = EMPTYIFNULL(dict[@"url"]);;
        self.type           = AttachmentTypeImage;
        self.size           = EMPTYIFNULL(dict[@"size"]);
        self.thumbnail      = EMPTYIFNULL(dict[@"thumbnail"]);
        
        return self;
    }
    
    return nil;
}


@end
