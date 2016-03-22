//
//  TestModel2.m
//  LWAlchemyDemo
//
//  Created by 刘微 on 16/3/22.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "TestModel2.h"
#import "LWAlchemyValueTransformer.h"

@implementation TestModel2

// Insert code here to add functionality to your managed object subclass


//ValueTransformer

+ (void)initialize {

    LWAlchemyValueTransformer* transformer = [LWAlchemyValueTransformer transformerUsingForwardBlock:^NSURL*(id value, BOOL *success, NSError *__autoreleasing *error) {
        return [NSURL URLWithString:[NSString stringWithFormat:@"%@",value]];
    }];
    [NSValueTransformer setValueTransformer:transformer forName:@"URLTrans"];
}


@end
