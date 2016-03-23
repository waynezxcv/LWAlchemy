//
//  The MIT License (MIT)
//  Copyright (c) 2016 Wayne Liu <liuweiself@126.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//　　The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//
//
//
//  Copyright © 2016年 Wayne Liu. All rights reserved.
//  https://github.com/waynezxcv/LWAlchemy
//  See LICENSE for this sample’s licensing information
//



#import <UIKit/UIKit.h>


@class NSPersistentStoreCoordinator;
@class NSManagedObjectContext;
@class NSManagedObjectModel;
@class NSManagedObjectID;
@class NSManagedObject;
@class NSFetchRequest;

typedef void(^Completion)(void);
typedef void(^FetchResults)(NSArray* results, NSError *error);
typedef void(^ExistingObject)(NSManagedObject* existedObject);


@interface LWAlchemyCoreDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectModel* managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator* persistentStoreCoordinator;

@property (readonly, strong, nonatomic) NSManagedObjectContext* managedObjectContext;//主线程Context，用户增，改，删（在内存中操作）。
@property (readonly, strong, nonatomic) NSManagedObjectContext* parentContext;//用来写入数据到SQLite的Context，在一个后台线程中操作。


+ (LWAlchemyCoreDataManager *)sharedManager;

/**
 *  增
 *
 */
- (id)insertNSManagedObjectWithObjectClass:(Class)objectClass JSON:(id)json;


/**
 *  增加一条数据，并指定UniqueAttributesName，若存在则重复插入，改为更新数据(每增加一条会新开一个线程)
 *
 */
- (void)insertNSManagedObjectWithObjectClass:(Class)objectClass
                                        JSON:(id)json
                         uiqueAttributesName:(NSString *)uniqueAttributesName
                                  completion:(Completion)completeBlock;



/**
 *  批量增加数据，并指定UniqueAttributesName，若存在则重复插入，改为更新数据（总共新开一个线程）
 *
 */
- (void)insertNSManagedObjectWithObjectClass:(Class)objectClass
                                  JSONsArray:(NSArray *)JSONsArray
                         uiqueAttributesName:(NSString *)uniqueAttributesName
                                  completion:(Completion)completeBlock;

/**
 *  查
 */
- (void)fetchNSManagedObjectWithObjectClass:(Class)objectClass
                                  predicate:(NSPredicate *)predicate
                             sortDescriptor:(NSArray<NSSortDescriptor *> *)sortDescriptors
                                fetchOffset:(NSInteger)offset
                                 fetchLimit:(NSInteger)limit
                                fetchReults:(FetchResults)resultsBlock;
/**
 *  删
 */
- (void)deleteNSManagedObjectWithObjectWithObjectIdsArray:(NSArray<NSManagedObjectID *> *)objectIDs;


/**
 *  改
 *
 */
- (void)updateNSManagedObjectWithObjectID:(NSManagedObjectID *)objectID JSON:(id)json;


/**
 *  提交修改
 *
 */
- (void)saveContext:(Completion)completionBlock;

@end
