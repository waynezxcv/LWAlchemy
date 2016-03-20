//
//  ViewController.m
//  LWAlchemyDemo
//
//  Created by 刘微 on 16/3/17.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "StatusModel.h"
#import "CDUserModel.h"
#import "CDStatusModel.h"
#import "LWAlchemy.h"



@interface ViewController ()
@property (nonatomic,weak) AppDelegate* appDelegate;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.appDelegate = [UIApplication sharedApplication].delegate;
    NSDictionary* dict = @{@"text" : @"我们一起来使用LWAlechemy~",
                           @"user" : @{
                                   @"name":@"Waynezxcv",
                                   @"sign":@"这是我的签名",
                                   @"age":@(22),
                                   @"website":@"http://www.waynezxcv.me",
                                   @"test":@"testString"
                                   },
                           @"retweetedStatus" : @{
                                   @"text" : @"hahaha...我们一起来使用LWAlechemy~",
                                   @"user" : @{
                                           @"name" : @"Wayne",
                                           @"sign" : @"just do it!",
                                           @"age": @(18),
                                           @"website":@"http://www.baidu.com"
                                           }
                                   }
                           };
    LWAlchemyCoreDataManager* manager = [LWAlchemyCoreDataManager sharedManager];
    [manager insertNSManagerObjectWithObjectClass:[CDStatusModel class] JSON:dict];
    NSArray* results = [manager fetchNSManagerObjectWithObjectClass:[CDStatusModel class] sortDescriptor:nil predicate:nil];
    NSLog(@"%ld",results.count);
    for (CDStatusModel* cdStatus in results) {
        NSLog(@"=======================NSManagedObject=================================");
        NSLog(@"%@",cdStatus.text);
        NSLog(@"user:%@...%@...%@...%@",cdStatus.user.name,cdStatus.user.sign,cdStatus.user.age,cdStatus.user.website);
        NSLog(@"retweetStatus:%@",cdStatus.retweetedStatus.text);
        NSLog(@"retweetUser:%@..%@..%@...%@",cdStatus.retweetedStatus.user.name,cdStatus.retweetedStatus.user.sign,cdStatus.retweetedStatus.user.age,cdStatus.retweetedStatus.user.website);
    }
}


/**
 *  测试时间消耗
 */
- (void)timeCostTest {
    NSMutableArray* tmp = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < 1000; i ++) {
        NSDictionary* dict = @{@"text" : @"我们一起来使用LWAlechemy~",
                               @"user" : @{
                                       @"name" : @"Waynezxcv",
                                       @"sign" : @"这是我的签名",
                                       @"age":@(22),
                                       @"website":@"http://www.waynezxcv.me",
                                       @"test":@"testString"
                                       },
                               @"retweetedStatus" : @{
                                       @"text" : @"hahaha...我们一起来使用LWAlechemy~",
                                       @"user" : @{
                                               @"name" : @"Wayne",
                                               @"sign" : @"just do it!",
                                               @"age": @(18),
                                               @"website":@"http://www.baidu.com"
                                               }
                                       }
                               };
        [tmp addObject:dict];
    }
    
    /**
     *  Test Duration
     */
    NSDate* startTime = [NSDate date];
    NSMutableArray* results = [[NSMutableArray alloc] init];
    for (NSDictionary* dict in tmp) {
        // 将字典转为Status模型
        StatusModel* status = [StatusModel modelWithJSON:dict];
        [results addObject:status];
    }
    NSLog(@"花费时间为: %f", -[startTime timeIntervalSinceNow]);
}


@end
