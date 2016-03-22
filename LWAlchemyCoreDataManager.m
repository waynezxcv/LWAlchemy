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


#import "LWAlchemyCoreDataManager.h"
#import <CoreData/CoreData.h>
#import "NSObject+LWAlchemy.h"
#import "AppDelegate.h"

@interface LWAlchemyCoreDataManager ()

@property (strong,nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong,nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong,nonatomic) NSManagedObjectContext* managedObjectContext;
@property (strong,nonatomic) NSManagedObjectContext* parentContext;
@property (strong,nonatomic) NSManagedObjectContext* importContext;
@property (nonatomic,copy) NSString* executableFile;

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
        [self setupNotifications];

    }
    return self;
}

#pragma mark - CURD

- (id)insertNSManagerObjectWithObjectClass:(Class)objectClass JSON:(id)json {
    __block NSObject* model;
    __weak typeof(self) weakSelf = self;
    [self.importContext performBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        model = [objectClass nsManagedObjectModelWithDictionary:json context:strongSelf.importContext];
    }];
    return model;
}

- (NSArray *)fetchNSManagerObjectWithObjectClass:(Class)objectClass
                                  sortDescriptor:(NSArray<NSSortDescriptor *> *)sortDescriptors
                                       predicate:(NSPredicate *) predicate {
    __block NSArray* results;
    __weak typeof(self) weakSelf = self;
    [self.managedObjectContext performBlockAndWait:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription* entity = [NSEntityDescription entityForName:NSStringFromClass(objectClass)
                                                  inManagedObjectContext:strongSelf.managedObjectContext];
        [fetchRequest setEntity:entity];
        if (sortDescriptors) {
            [fetchRequest setSortDescriptors:sortDescriptors];
        }
        if (predicate) {
            [fetchRequest setPredicate:predicate];
        }
        NSError* requestError = nil;
        results = [strongSelf.managedObjectContext executeFetchRequest:fetchRequest error:&requestError];
    }];
    return results;
}

- (void)saveContext:(NSManagedObjectContext *)context {
    if (!context) {
        return;
    }
    [context performBlockAndWait:^{
        NSError *error = nil;
        if ([context hasChanges] && ![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }];
}

- (void)backgroundSaveContext {
    [self saveContext:self.importContext];
    __weak typeof(self) weakSelf = self;
    [self.managedObjectContext performBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSError *error = nil;
        if ([strongSelf.managedObjectContext hasChanges] && ![strongSelf.managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        [strongSelf.parentContext performBlock:^{
            NSManagedObjectContext* managedObjectContext = strongSelf.parentContext;
            if (managedObjectContext != nil) {
                NSError *error = nil;
                if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    abort();
                }
            }
        }];
    }];
}


#pragma mark - Getter

- (NSString *)executableFile {
    if (!_executableFile) {
        _executableFile = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleExecutableKey];
    }
    return _executableFile;
}


- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:self.executableFile withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}


- (NSURL *)applicationDocumentsDirectory {

    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSString* sql = [NSString stringWithFormat:@"%@.sqlite",self.executableFile];
    NSURL* storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:sql];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)importContext {
    if (!_importContext) {
        _importContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_importContext performBlockAndWait:^{
            [_importContext setParentContext:self.managedObjectContext];
            [_importContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
            [_importContext setUndoManager:nil];
        }];
    }
    return _importContext;
}

- (NSManagedObjectContext *)managedObjectContext {
    if (!_managedObjectContext) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext performBlockAndWait:^{
            [_managedObjectContext setParentContext:self.parentContext];
            [_managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
            [_managedObjectContext setUndoManager:nil];
        }];
    }
    return _managedObjectContext;
}

- (NSManagedObjectContext *)parentContext {
    if (!_parentContext) {
        _parentContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_parentContext performBlockAndWait:^{
            [_parentContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
            [_parentContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        }];
    }
    return _parentContext;
}

- (void)setupNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(backgroundSaveContext)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(backgroundSaveContext)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillTerminateNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
}

@end
