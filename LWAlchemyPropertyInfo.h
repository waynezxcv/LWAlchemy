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
