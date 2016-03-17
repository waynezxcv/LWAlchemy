//
//  NSObject+Model.h
//  LWAlchemyDemo
//
//  Created by 刘微 on 16/1/20.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>



@interface NSObject(LWAlchemy)

@property (nonatomic,copy) NSDictionary* mapper;

/**
 *  普通模型
 */
+ (id)modelWithJSON:(id)json JSONKeyPathsByPropertyKey:(NSDictionary *)mapper;

/**
 *  CoreData模型
 *
 */
+ (id)coreDataModelWithJSON:(id)json
  JSONKeyPathsByPropertyKey:(NSDictionary *)mapper
                    context:(NSManagedObjectContext *)context;
@end
