//
//  ViewController.m
//  LWAlchemyDemo
//
//  Created by 刘微 on 16/3/17.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "ViewController.h"
#import "LWAlchemy.h"
#import "StatusModel.h"



@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDictionary *dict = @{@"text" : @"是啊，今天天气确实不错！",
                           @"user" : @{
                                   @"name" : @"Jack",
                                   @"sign" : @"这是我的签名"
                                   },
                           @"retweetedStatus" : @{
                                   @"text" : @"今天天气真不错！",
                                   @"user" : @{
                                           @"name" : @"Rose",
                                           @"sign" : @"just do it!"
                                           }
                                   }
                           };

    StatusModel* status = [StatusModel modelWithJSON:dict];
//    NSLog(@"%@",status.text);
//    NSLog(@"user:%@...%@",status.user.name,status.user.sign);
//    NSLog(@"retweetStatus:%@",status.retweetedStatus.text);
//    NSLog(@"retweetUser:%@..%@",status.retweetedStatus.user.name,status.retweetedStatus.user.sign);
}


@end
