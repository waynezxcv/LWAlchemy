//
//  StatusModel.h
//  LWAlchemyDemo
//
//  Created by 刘微 on 16/3/20.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserModel.h"

@interface StatusModel : NSObject

@property (nonatomic,strong) id test;
@property (nonatomic,copy) NSString* text;
@property (nonatomic,strong) UserModel* user;
@property (nonatomic,strong) StatusModel* retweetedStatus;

@end
