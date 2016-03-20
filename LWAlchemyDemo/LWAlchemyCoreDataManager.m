//
//  The MIT License (MIT)
//  Copyright (c) 2016 Wayne Liu <liuweself@126.com>
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


#import "LWAlchemyCoreDataManager.h"
#import <CoreData/CoreData.h>
#import "NSObject+LWAlchemy.h"

@interface LWAlchemyCoreDataManager ()


@property (strong,nonatomic) NSManagedObjectContext* context;
@property (strong,nonatomic) NSManagedObjectContext* parentContext;
@property (strong,nonatomic) NSManagedObjectContext* importContext;
@property (strong,nonatomic) NSManagedObjectContext* sourceContext;

@property (strong,nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong,nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSPersistentStoreCoordinator* sourcePersistentStoreCoordinator;


@end


@implementation LWAlchemyCoreDataManager

+ (LWAlchemyCoreDataManager *)sharedManager {
    static dispatch_once_t onceToken;
    static LWAlchemyCoreDataManager* sharedManager;
    dispatch_once(&onceToken, ^{
        sharedManager = [[LWAlchemyCoreDataManager alloc] init];
    });
    return sharedManager;
}

- (id)init {
    self = [super init];
    if (self) {
        _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
        
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_managedObjectModel];
        _parentContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        
        [_parentContext performBlockAndWait:^{
            [_parentContext setPersistentStoreCoordinator:_persistentStoreCoordinator];
            [_parentContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        }];
        
        _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_context setParentContext:_parentContext];
        [_context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        
        
        _importContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_importContext performBlockAndWait:^{
            [_importContext setParentContext:_context];
            [_importContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
            [_importContext setUndoManager:nil];
        }];
        
        _sourceContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_sourceContext performBlockAndWait:^{
            [_sourceContext setParentContext:_context];
            [_sourceContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
            [_sourceContext setUndoManager:nil];
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(backgroundSaveContext)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(backgroundSaveContext)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
    return self;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillTerminateNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
}


- (void)saveContext {
    NSManagedObjectContext* managedObjectContext = self.context;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)backgroundSaveContext {
    NSLog(@"background SAVE");
    [self saveContext];
    [_parentContext performBlock:^{
        NSManagedObjectContext* managedObjectContext = _parentContext;
        if (managedObjectContext != nil) {
            NSError *error = nil;
            if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
    }];
}

#pragma mark - CURD

- (id)insertNSManagerObjectWithObjectClass:(Class)objectClass JSON:(id)json {
    NSObject* model = [objectClass coreDataModelWithJSON:json context:self.importContext];
    return model;
}

- (NSArray *)fetchNSManagerObjectWithObjectClass:(Class)objectClass
                                  sortDescriptor:(NSArray<NSSortDescriptor *> *)sortDescriptors
                                       predicate:(NSPredicate *) predicate {
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* entity = [NSEntityDescription entityForName:NSStringFromClass(objectClass)
                                              inManagedObjectContext:self.importContext];
    [fetchRequest setEntity:entity];
    if (sortDescriptors) {
        [fetchRequest setSortDescriptors:sortDescriptors];
    }
    if (predicate) {
        [fetchRequest setPredicate:predicate];
    }
    NSError* requestError = nil;
    NSArray* results = [self.importContext executeFetchRequest:fetchRequest error:&requestError];
    return results;
}


@end
