//
//  TestModel1+CoreDataProperties.h
//  LWAlchemyDemo
//
//  Created by 刘微 on 16/3/22.
//  Copyright © 2016年 Warm+. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "TestModel1.h"

NS_ASSUME_NONNULL_BEGIN

@interface TestModel1 (CoreDataProperties)

@property (nullable, nonatomic, retain) NSURL* url;
@property (nullable, nonatomic, retain) NSString *text;
@property (nullable, nonatomic, retain) NSDate *timeStampe;
@property (nullable, nonatomic, retain) TestModel2 *user;

@end

NS_ASSUME_NONNULL_END
