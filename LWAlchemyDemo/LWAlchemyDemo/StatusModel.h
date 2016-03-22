//
//  StatusModel.h
//  LWAlchemyDemo
//
//  Created by 刘微 on 16/3/20.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserModel.h"
#import <UIKit/UIKit.h>

@interface StatusModel : NSObject

@property (nonatomic,assign,getter=isLiked) BOOL liked;
@property (nonatomic,assign) NSInteger statusId;
@property (nonatomic,assign) CGFloat percent;
@property (nonatomic,copy) NSString* text;
@property (nonatomic,strong) NSURL* website;
@property (nonatomic,strong) NSNumber* likedCount;
@property (nonatomic,strong) NSArray* imgs;
@property (nonatomic,strong) NSDictionary* profileDict;
@property (nonatomic,strong) NSDate* timeStamp;
@property (nonatomic,strong) UserModel* user;
@property (nonatomic,strong) id idContent;

@end
