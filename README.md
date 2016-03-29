
[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/waynezxcv/LWAlchemy/blob/master/LICENSE)&nbsp;



# LWAlchemy V1.0
LWAlchemy 快速、高性能的iOS ORM框架。<br>


## 特性
* 支持JSON直接生成NSObject、NSManagedObject模型，且速度极快。
* 支持自动和自定义的映射路径。
* 支持CoreData并发，在不阻塞主线程的情况下，进行数据库CURD。
* 支持CoreData设置Unique约束。
* 轻量级，代码入侵少。


### API Quickstart
* **Class**

|Class | Function|
|--------|---------|
|LWAlchemyManager|提供CoreData增查改删API，自动处理CoreData并发|
|LWAlchemyPropertyInfo|对NSObject属性的抽象类|
|NSObject+LWAlchemy|提供模型映射API|
|LWAlchemyValueTransformer|继承NSValueTransformer提供更方便使用的API|


## 使用方法

* **模型映射**

```objc

/**
*  简单的由JSON生成model
*
*/
        //Json
        NSDictionary* dict = @{@"statusId":@"0755",
            @"text":@"LWAlchemy,a fast and lightweight ORM framework for Cocoa and Cocoa Touch",
            @"website":@"www.apple.com",
            @"imgs":@[@"img1",@"img2",@"img3"],
            @"timeStamp":@"1459242514",
            @"user":@{
            @"name":@"Waynezxcv",
            @"sign":@"this is wayne's sign",
            @"age":@18,
            @"avatar":@"https://avatars0.githubusercontent.com/u/8408918?v=3&s=460",
            @"detail":@{
            @"detailDescription":@"this is Wayne's detail description."
            }
        }

        //生成Model
        StatusModel* status = [StatusModel modelWithJSON:dict];
}


/**
*  自定义映射路径的JSON生成model
*
*/
        //Json
        NSDictionary* dict = @{@"statusId":@"0755",
            @"text":@"LWAlchemy,a fast and lightweight ORM framework for Cocoa and Cocoa Touch",
            @"website":@"www.apple.com",
            @"imgs":@[@"img1",@"img2",@"img3"],
            @"timeStamp":@"1459242514",
            @"user":@{
            @"name":@"Waynezxcv",
            @"sign":@"this is wayne's sign",
            @"age":@18,
            @"avatar":@"https://avatars0.githubusercontent.com/u/8408918?v=3&s=460",
            @"detail":@{
            @"detailDescription":@"this is Wayne's detail description."
            }
        }
    };

        //生成Model
        StatusModel* status = [StatusModel modelWithJSON:dict];

    //在对应的Model下实现以下方法
    @implementation StatusModel
    //自定义映射
    + (NSDictionary *)mapper {
        return @{@"statusId":@"c_statusId",
                @"text":@"c_text",
                @"website":@"c_website",
                @"imgs":@"c_imgs",
                @"timeStamp":@"c_timeStamp",
                @"user":@"c_user"
            };
    }


/**
*  多级映射
*
*/

    NSDictionary* dict = @{@"statusId":@"0755",
        @"text":@"LWAlchemy,a fast and lightweight ORM framework for Cocoa and Cocoa Touch",
        @"website":@"www.apple.com",
        @"imgs":@[@"img1",@"img2",@"img3"],
        @"timeStamp":@"1459242514",
        @"user":@{
        @"name":@"Waynezxcv",
        @"sign":@"this is wayne's sign",
        @"age":@18,
        @"avatar":@"https://avatars0.githubusercontent.com/u/8408918?v=3&s=460",
        @"detail":@{
        @"detailDescription":@"this is Wayne's detail description."
        }
    }
};

在对应的Model下实现以下方法

+ (NSDictionary *)mapper {
    return @{@"name":@"user.name"
    };
}

```

* **CoreData的CURD**

```objc

//插入entity并设置unique 当unique对应的值已经存在时，不再重复插入，而是更新数据
- (void)coredataUniqBatchInsert {
    self.refreshCount ++;//刷新的次数
    NSMutableArray* fakeData = [[NSMutableArray alloc] init];
    NSInteger index = 0;
    for (NSInteger i = 0; i < 500; i ++) {
        NSString* text =  [NSString stringWithFormat:@"这是ID为%ld的数据第%ld次更新",index + i,self.refreshCount];//更新的内容。
        NSDictionary* dict = @{@"statusId":@(index + i),
        @"text":text,
        @"c_user" : @{@"c_name" :[NSString stringWithFormat:@"这是ID为%ld 的第二级Model",index + i],
        @"test":@{@"content":@"第三级映射。。。"}}
        };
        [fakeData addObject:dict];
    }
    __weak typeof(self) wself = self;
    LWAlchemyManager* manager = [LWAlchemyManager sharedManager];
    [manager insertEntitysWithClass:[StatusEntity class]
    JSONsArray:fakeData
    uiqueAttributesName:@"statusId"
    save:YES
    completion:^{
    //查询
        NSSortDescriptor* sort = [NSSortDescriptor sortDescriptorWithKey:@"statusId" ascending:YES];
        [manager fetchNSManagedObjectWithObjectClass:[StatusEntity class]
        predicate:nil
        sortDescriptor:@[sort]
        fetchOffset:0
        fetchLimit:0
        fetchReults:^(NSArray *results, NSError *error) {
        __strong typeof(wself) swself = wself;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [swself.dataSource removeAllObjects];
        for (StatusEntity* entity in results) {
        [swself.dataSource addObject:entity];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [swself.tableView reloadData];
                });
            });
        }];
    }];
}


```

更多用法请看头文件。

