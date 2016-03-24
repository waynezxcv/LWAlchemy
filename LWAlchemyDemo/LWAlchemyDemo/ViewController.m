//
//  ViewController.m
//  LWAlchemyDemo
//
//  Created by 刘微 on 16/3/17.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "ViewController.h"
#import "StatusModel.h"
#import "LWAlchemy.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self nsObjectModel];
}


- (void)nsmanagedContextObjectModel {
    NSMutableArray* tmp = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < 10000; i ++) {
        NSDictionary* dict = @{@"liked":@NO,
                               @"statusId":@123456,
                               @"percent":@"3.1415926",
                               @"text" : @"使用LWAlchemy",
                               @"website":@"www.google.com",
                               @"likedCount":@9999,
                               @"imgs":@[@"1111",@"2222",@"3333"],
                               @"profileDict":@{@"key":@"value"},
                               @"timeStamp":@1458628616,
                               @"idContent":@"this is void* ",
                               @"c_user" : @{
                                       @"c_name" : @"Waynezxcv",
                                       @"c_sign" : @"这是我的签名",
                                       @"age":@(22),
                                       @"website":@"http://www.waynezxcv.me",
                                       @"test":@{@"content":@"第三级映射。。。"}
                                       },
                               @"retweetedStatus" : @{
                                       @"text" : @"LWAlchemy ORM",
                                       @"user" : @{
                                               @"name" : @"Wayne",
                                               @"sign" : @"just do it!",
                                               @"age": @(18),
                                               @"website":@"www.apple.com"
                                               }
                                       }
                               };
        [tmp addObject:dict];
    }
    
    
    
    
}


- (void)nsObjectModel {
    NSMutableArray* tmp = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < 10000; i ++) {
        NSDictionary* dict = @{@"liked":@NO,
                               @"statusId":@123456,
                               @"percent":@"3.1415926",
                               @"text" : @"使用LWAlchemy",
                               @"website":@"www.google.com",
                               @"likedCount":@9999,
                               @"imgs":@[@"1111",@"2222",@"3333"],
                               @"profileDict":@{@"key":@"value"},
                               @"timeStamp":@1458628616,
                               @"idContent":@"this is void* ",
                               @"c_user" : @{
                                       @"c_name" : @"Waynezxcv",
                                       @"c_sign" : @"这是我的签名",
                                       @"age":@(22),
                                       @"website":@"http://www.waynezxcv.me",
                                       @"test":@{@"content":@"第三级映射。。。"}
                                       },
                               @"retweetedStatus" : @{
                                       @"text" : @"LWAlchemy ORM",
                                       @"user" : @{
                                               @"name" : @"Wayne",
                                               @"sign" : @"just do it!",
                                               @"age": @(18),
                                               @"website":@"www.apple.com"
                                               }
                                       }
                               };
        [tmp addObject:dict];
    }
    /**
     *  LWAlchemy Test Duration
     */
    NSDate* startTime = [NSDate date];
    for (NSDictionary* dict in tmp) {
        // 将字典转为Status模型
        StatusModel* status = [StatusModel objectModelWithJSON:dict];
    }
    NSLog(@"时间消耗: %f", -[startTime timeIntervalSinceNow]);
}

@end
