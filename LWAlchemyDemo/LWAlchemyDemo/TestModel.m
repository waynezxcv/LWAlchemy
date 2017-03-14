//
//  TestModel.m
//  LWAlchemyDemo
//
//  Created by 刘微 on 2017/3/15.
//  Copyright © 2017年 Warm+. All rights reserved.
//

#import "TestModel.h"
#import "NSObject+Archive.h"
#import "NSOject+Copying.h"




@implementation TestModel

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self lw_encodeWithCoder:aCoder];
}


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        [self lw_decodeWithCoder:aDecoder];
    }
    return self;
}


- (id)copyWithZone:(NSZone *)zone {
    return [self lw_copy];
}


@end
