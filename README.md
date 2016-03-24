
[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/waynezxcv/LWAlchemy/blob/master/LICENSE)&nbsp;



# LWAlchemy V1.0
LWAlchemy 快速、高性能的iOS ORM框架。<br>


## 特性
* 支持JSON直接生成NSObject、NSManagedObject模型，且速度极快。
* 支持自动和自定义的映射路径。
* 支持CoreData并发，在不阻塞主线程的情况下，进行数据库CURD。
* 支持CoreData设置Unique约束。
* 轻量级，代码入侵少。

## 使用方法

### API Quickstart
* **Class**

|Class | Function|
|--------|---------|
|LWAlchemyManager|提供CoreData增查改删API，自动处理CoreData并发|
|LWAlchemyPropertyInfo|对NSObject属性的抽象类|
|NSObject+LWAlchemy|提供模型映射API|
|LWAlchemyValueTransformer|继承NSValueTransformer提供更方便使用的API|




* **Example**
例如试下如图布局

## 简单的模型映射

```objc
NSDictionary* dict = @{@"liked":@NO,
@"statusId":@123456,
@"percent":@"3.1415926",
@"text" : @"使用LWAlchemy",
@"website":@"www.google.com",
@"likedCount":@9999,
@"imgs":@[@"1111",@"2222",@"3333"],
@"profileDict":@{@"key":@"value"},
@"timeStamp":@1458628616,
@"idContent":@"this is void* ",
@"c_user" : @{
@"c_name" : @"Waynezxcv",
@"c_sign" : @"这是我的签名",
@"age":@(22),
@"website":@"http://www.waynezxcv.me",
@"test":@{@"content":@"第三级映射。。。"}
},
@"retweetedStatus" : @{
@"text" : @"LWAlchemy ORM",
@"user" : @{
@"name" : @"Wayne",
@"sign" : @"just do it!",
@"age": @(18),
@"website":@"www.apple.com"
}
}
};
StatusModel* status = [StatusModel objectModelWithJSON:dict];

```

