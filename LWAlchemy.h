//
//  NSObject+Model.h
//  LWAlchemyDemo
//
//  Created by 刘微 on 16/1/20.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LWAlchemy:NSObject

- (id)initWithJSON:(id)JSON JSONKeyPathsByPropertyKey:(NSDictionary *)mapDict;

@end
