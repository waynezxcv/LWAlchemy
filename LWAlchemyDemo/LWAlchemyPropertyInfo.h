//
//  LWAlchemyPropertyInfo.h
//  WarmerApp
//
//  Created by 刘微 on 16/3/14.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, LWType) {
    LWTypeUnkonw,
    LWTypeBasic,
    LWTypeObject,
    LWTypeBlock
};


@interface LWAlchemyPropertyInfo : NSObject

@property (nonatomic,assign) LWType type;
@property (nonatomic,copy) NSString* ivarName;
@property (nonatomic,assign) Class cls;

@end
