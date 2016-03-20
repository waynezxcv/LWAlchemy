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
#import "AppDelegate.h"
#import "CDUserModel.h"
#import "CDStatusModel.h"

@interface ViewController ()
@property (nonatomic,weak) AppDelegate* appDelegate;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.appDelegate = [UIApplication sharedApplication].delegate;

    NSDictionary* dict = @{@"text" : @"是啊，今天天气确实不错！",
                           @"user" : @{
                                   @"name" : @"Jack",
                                   @"sign" : @"这是我的签名",
                                   @"age":@(22),
                                   @"website":@"http://www.waynezxcv.me",
                                   @"test":@"testString"
                                   },
                           @"retweetedStatus" : @{
                                   @"text" : @"今天天气真不错！",
                                   @"user" : @{
                                           @"name" : @"Rose",
                                           @"sign" : @"just do it!",
                                           @"age": @(18),
                                           @"website":@"http://www.baidu.com"
                                           }
                                   }
                           };

    // NSObject自动映射
    NSLog(@"=======================NSObject=================================");
    StatusModel* status = [StatusModel modelWithJSON:dict];
    NSLog(@"%@",[status lwAlchemyDescription]);
    NSLog(@"%@",status.text);
    NSLog(@"user:%@...%@...%ld...%@",status.user.name,status.user.sign,status.user.age,status.user.website);
    NSLog(@"retweetStatus:%@",status.retweetedStatus.text);
    NSLog(@"retweetUser:%@..%@..%ld...%@",status.retweetedStatus.user.name,status.retweetedStatus.user.sign,status.retweetedStatus.user.age,status.retweetedStatus.user.website.absoluteString);

    //NSManagedObject
    NSLog(@"=======================NSManagedObject=================================");
    CDStatusModel* cdStatus = [CDStatusModel coreDataModelWithJSON:dict context:self.appDelegate.managedObjectContext];
    NSLog(@"%@",[cdStatus lwAlchemyDescription]);
    NSLog(@"%@",cdStatus.text);
    NSLog(@"user:%@...%@...%@...%@",cdStatus.user.name,cdStatus.user.sign,cdStatus.user.age,cdStatus.user.website);
    NSLog(@"retweetStatus:%@",cdStatus.retweetedStatus.text);
    NSLog(@"retweetUser:%@..%@..%@...%@",cdStatus.retweetedStatus.user.name,cdStatus.retweetedStatus.user.sign,cdStatus.retweetedStatus.user.age,cdStatus.retweetedStatus.user.website);


}


@end
