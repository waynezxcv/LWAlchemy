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

/**
 *  NSObject
 *
 */
+ (id)modelWithJSON:(id)json;
+ (id)coreDataModelWithJSON:(id)json context:(NSManagedObjectContext *)context;


/**
 *  NSManagedObject
 *
 */
- (instancetype)modelWithDictionary:(NSDictionary *)dictionary;
- (instancetype)coreDataModelWithDictionary:(NSDictionary *)dictionary context:(NSManagedObjectContext *)contxt;




@end
