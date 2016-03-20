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


+ (id)modelWithJSON:(id)json;


+ (id)modelWithJSON:(id)json JSONKeyPathsByPropertyKey:(NSDictionary *)mapper;


+ (id)coreDataModelWithJSON:(id)json
                    context:(NSManagedObjectContext *)context;


+ (id)coreDataModelWithJSON:(id)json
  JSONKeyPathsByPropertyKey:(NSDictionary *)mapper
                    context:(NSManagedObjectContext *)context;


- (instancetype)modelWithDictionary:(NSDictionary *)dictionary;

- (instancetype)coreDataModelWithDictionary:(NSDictionary *)dictionary;

- (NSString *)description;

@end
