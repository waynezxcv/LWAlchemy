//
//  UserModel.h
//  LWAlchemyDemo
//
//  Created by 刘微 on 16/3/17.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TestModel.h"

@interface UserModel : NSObject

@property (nonatomic,copy) NSString* name;
@property (nonatomic,copy) NSString* sign;
@property (nonatomic,assign) NSInteger age;
@property (nonatomic,strong) NSURL* website;
@property (nonatomic,strong) TestModel* test;

@end
