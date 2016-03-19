//
//  ViewController.m
//  LWAlchemyDemo
//
//  Created by 刘微 on 16/3/17.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "ViewController.h"
#import "UserModel.h"
#import "LWAlchemy.h"
#import "TestModel.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDictionary* dict = @{
                           @"c_name":@"waynezxcv",
                           @"c_age":@18,
                           @"c_birth":@1458227969,
                           @"c_phone":@"18682189243",
                           @"c_email":@"liuweiself@126.com",
                           @"c_website":@"http://www.waynezxcv.me",
                           };
    NSDictionary* mapper = @{@"name":@"c_name",
                             @"email":@"c_email"};
    
    AppDelegate* delegate = [UIApplication sharedApplication].delegate;
    
    TestModel* model1 = [TestModel coreDataModelWithJSON:dict JSONKeyPathsByPropertyKey:mapper context:delegate.managedObjectContext];
    TestModel* model2 = [TestModel coreDataModelWithJSON:dict JSONKeyPathsByPropertyKey:mapper context:delegate.managedObjectContext];
    TestModel* model3 = [TestModel coreDataModelWithJSON:dict JSONKeyPathsByPropertyKey:mapper context:delegate.managedObjectContext];
    
}


@end
