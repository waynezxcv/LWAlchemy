//
//  LWAlchemyPropertyInfo.h
//  WarmerApp
//
//  Created by 刘微 on 16/3/14.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

typedef NS_ENUM(NSUInteger, LWType) {
    LWTypeUnkonw        = 0,//未知类型
    LWTypeVoid          = 1,//void类型
    LWTypeBool          = 2,//布尔类型
    LWTypeInt8          = 3,//Int8类型
    LWTypeUInt8         = 4,//无符号Int8类型
    LWTypeInt16         = 5,//Int16类型
    LWTypeUInt16        = 6,//无符号Int16类型
    LWTypeInt32         = 7,//Int32类型
    LWTypeUInt32        = 8,//无符号Int32类型
    LWTypeInt64         = 9,//Int64类型
    LWTypeUInt64        = 10,//无符号Int64类型
    LWTypeFloat         = 11,//浮点型
    LWTypeDouble        = 12,//双精度浮点型
    LWTypeLongDouble    = 13,//长双精度浮点型
    LWTypeClass         = 14,//Class类型（类）
    LWTypeSEL           = 15,//SEL类型（方法）
    LWTypeCFString      = 16,//CFStringRef类型 const char*
    LWTypePointer       = 17,//Pointer类型
    LWTypeCFArray       = 18,//CFArrayRef类型
    LWTypeUnion         = 19,//联合体类型
    LWTypeStruct        = 20,//结构体类型
    LWTypeObject        = 21,//对象类型（类的实例对象）
    LWTypeBlock         = 22,//Block类型
};

/**
 *  一个Property的抽象
 */
@interface LWAlchemyPropertyInfo : NSObject

@property (nonatomic,assign,readonly) objc_property_t property;//属性
@property (nonatomic,strong,readonly) NSString* propertyName;//属性名称
@property (nonatomic,strong,readonly) NSString* ivarName;//实例对象名称
@property (nonatomic,assign,readonly) Ivar ivar;//实例对象
@property (nonatomic,assign,readonly) LWType type;//类型
@property (nonatomic,assign,readonly) Class cls;//如果是LWTypeObject类型，用来表示该对象所属的类,否则为nil
@property (nonatomic,strong,readonly) NSString* getter;//getter方法
@property (nonatomic,strong,readonly) NSString* setter;//setter方法

- (id)initWithProperty:(objc_property_t)property;

@end
