
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


- (void)simpleJsonToModel {
        NSDictionary* dict = @{@"statusId":@"0755",
            @"text":@"LWAlchemy,a fast and lightweight ORM framework for Cocoa and Cocoa Touch",
            @"website":@"www.apple.com",
            @"imgs":@[@"img1",@"img2",@"img3"],
            @"timeStamp":@"",
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
    StatusModel* status = [StatusModel modelWithJSON:dict];
}


/**
*  自定义映射路径的JSON生成model
*
*/


```

