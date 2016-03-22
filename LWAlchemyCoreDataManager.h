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

@class NSManagedObjectContext;
@class NSManagedObjectModel;
@class NSPersistentStoreCoordinator;
@class NSManagedObjectID;
@class NSManagedObject;

typedef void(^Completion)(void);

@interface LWAlchemyCoreDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectModel* managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator* persistentStoreCoordinator;

@property (readonly, strong, nonatomic) NSManagedObjectContext* managedObjectContext;//主线程Context
@property (readonly, strong, nonatomic) NSManagedObjectContext* parentContext;//用来保存到persistentStoreCoordinator的Context
@property (readonly, strong, nonatomic) NSManagedObjectContext* importContext;//插入数据的Context




+ (LWAlchemyCoreDataManager *)sharedManager;

/**
 *  增
 *
 */
- (id)insertNSManagedObjectWithObjectClass:(Class)objectClass JSON:(id)json;

/**
 *  查
 *
 */
- (NSArray *)fetchNSManagedObjectWithObjectClass:(Class)objectClass
                                  sortDescriptor:(NSArray<NSSortDescriptor *> *)sortDescriptor
                                       predicate:(NSPredicate *) predicate;

/**
 *  删
 */

- (BOOL)deleteNSManagedObjectWithObjectWithObjectIdsArray:(NSArray<NSManagedObjectID *> *)objectIDs;

/**
 *  改
 *
 */
- (NSManagedObject *)updateNSManagedObjectWithObjectID:(NSManagedObjectID *)objectID JSON:(id)json;

/**
 *  保存NSManagedObjectContext中的内容到SQLite
 */
- (void)commitContextCompletion:(Completion)completeBlock;

@end
