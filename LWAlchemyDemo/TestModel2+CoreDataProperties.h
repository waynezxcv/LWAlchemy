//
//  TestModel2+CoreDataProperties.h
//  LWAlchemyDemo
//
//  Created by 刘微 on 16/3/22.
//  Copyright © 2016年 Warm+. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "TestModel2.h"

NS_ASSUME_NONNULL_BEGIN

@interface TestModel2 (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *sign;
@property (nullable, nonatomic, retain) NSNumber *age;
@property (nullable, nonatomic, retain) id website;

@end

NS_ASSUME_NONNULL_END
