//
//  CDStatusModel+CoreDataProperties.h
//  LWAlchemyDemo
//
//  Created by 刘微 on 16/3/20.
//  Copyright © 2016年 Warm+. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CDStatusModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDStatusModel (CoreDataProperties)

@property (nullable, nonatomic, retain) id test;
@property (nullable, nonatomic, retain) NSString *text;
@property (nullable, nonatomic, retain) CDUserModel *user;
@property (nullable, nonatomic, retain) CDStatusModel *retweetedStatus;

@end

NS_ASSUME_NONNULL_END
