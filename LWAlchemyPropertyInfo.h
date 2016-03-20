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
    LWTypeUnkonw        = 0,
    LWTypeVoid          = 1,
    LWTypeBool          = 2,
    LWTypeInt8          = 3,
    LWTypeUInt8         = 4,
    LWTypeInt16         = 5,
    LWTypeUInt16        = 6,
    LWTypeInt32         = 7,
    LWTypeUInt32        = 8,
    LWTypeInt64         = 9,
    LWTypeUInt64        = 10,
    LWTypeFloat         = 11,
    LWTypeDouble        = 12,
    LWTypeLongDouble    = 13,
    LWTypeClass         = 14,
    LWTypeSEL           = 15,
    LWTypeCFString      = 16,
    LWTypePointer       = 17,
    LWTypeCFArray       = 18,
    LWTypeUnion         = 19,
    LWTypeStruct        = 20,
    LWTypeObject        = 21,
    LWTypeBlock         = 22,
};


@interface LWAlchemyPropertyInfo : NSObject

@property (nonatomic,assign,readonly) objc_property_t property;
@property (nonatomic,strong,readonly) NSString* propertyName;
@property (nonatomic,strong,readonly) NSString* ivarName;
@property (nonatomic,assign,readonly) Ivar ivar;
@property (nonatomic,assign,readonly) LWType type;
@property (nonatomic,copy,readonly) NSString* typeEncoding;
@property (nonatomic,assign,readonly) Class cls;
@property (nonatomic,strong,readonly) NSString* getter;
@property (nonatomic,strong,readonly) NSString* setter;
@property (nonatomic,assign,readonly,getter=isReadonly) BOOL readonly;
@property (nonatomic,assign,readonly,getter=isDynamic) BOOL dynamic;
@property (nonatomic,assign,readonly,getter=isNumberType) BOOL numberType;
@property (nonatomic,assign,readonly,getter=isObjectType) BOOL objectType;
@property (nonatomic,assign,readonly,getter=isIdType) BOOL idType;
@property (nonatomic,assign,readonly,getter=isFoundationType) BOOL foundationType;

- (id)initWithProperty:(objc_property_t)property;

@end
