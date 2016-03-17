//
//  NSObject+Model.h
//  LWAlchemyDemo
//
//  Created by 刘微 on 16/1/20.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject(LWAlchemy)

@property (nonatomic,copy) NSDictionary* mapper;

+ (id)modelWithJSON:(id)json JSONKeyPathsByPropertyKey:(NSDictionary *)mapper;

@end
