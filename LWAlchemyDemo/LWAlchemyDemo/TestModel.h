//
//  TestModel.h
//  LWAlchemyDemo
//
//  Created by 刘微 on 2017/3/15.
//  Copyright © 2017年 Warm+. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestModel : NSObject<NSCoding,NSCopying>


@property (nonatomic,copy) NSString* name;
@property (nonatomic,assign) NSInteger age;


@end
