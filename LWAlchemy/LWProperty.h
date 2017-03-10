/*
 https://github.com/waynezxcv/LWAlchemy
 
 Copyright (c) 2016 waynezxcv <liuweiself@126.com>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */



#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>




/*
 
 类型相关:
 attributeName : T
 attributeValue :
 
 v : void
 B : BOOL
 c : int_8_t
 C : u_int_8_t
 s : int_16_t
 S : uint_16_t
 i : int_32_t
 I : uint_32_t
 l : int_32_t
 L : uint_32_t
 q : int_64_t
 Q : uint_64_t
 f : float
 d : double
 D : long double
 # : Class (struct objc_class)
 : : SEL
 * : string
 ^ : pointer
 [ : array
 ( : union
 { : struct
 @ : OBJC Object
 */

typedef NS_ENUM(NSUInteger, LWType) {
    LWTypeUnkown,//未知类型
    
    //基础数据类型
    LWTypeVoid,//void
    LWTypeBool,//BOOL
    LWTypeInt8,//int_8_t
    LWTypeUInt8,//uint8_t
    LWTypeInt16,//int_16_t
    LWTypeUInt16,//uint16_t
    LWTypeInt32,//int_32_t
    LWTypeUInt32,//uint32_t
    LWTypeInt64,//int_64_t
    LWTypeUInt64,//uint64_t
    LWTypeFloat,//float
    LWTypeDouble,//double
    LWTypeLongDouble,//long double
    
    //(C语言)类型
    LWTypeClass,//struct objc_class*
    LWTypePointer,//指针类型
    LWTypeSelector,//SEL
    LWTypeCString,//C字符串
    LWTypeCArray,//C数组
    LWTypeCUnion,//联合体
    LWTypeCStruct,//结构体
    LWTypeCBitField,//位域
    
    //OBJC对象类型
    LWTypeBlock,//block类型
    LWTypeID,//id类型
    LWTypeNSString,//NSString
    LWTypeNSMutableString,//NSMutableString
    LWTypeNSValue,//NSValue
    LWTypeNSNumber,//NSNumber
    LWTypeNSDecimalNumber,//NSDecimalNumber
    LWTypeNSData,//NSData
    LWTypeNSMutableData,//NSMutabaleData
    LWTypeNSDate,//NSDate
    LWTypeNSURL,//NSURL
    LWTypeNSArray,//NSArray
    LWTypeNSMutableArray,//NSMutableArray
    LWTypeNSDictionary,//NSDictionary
    LWTypeNSMutableDictionary,//NSMutableDictionary
    LWTypeNSSet,//NSSet
    LWTypeNSMutableSet,//NSMutableSet
    LWTypeCustomObject,//用户自定义的OBJC对象类型
    
};


/*
 内存管理相关属性:
 &:strong
 W:weak
 C:copy
 如果是assign，则不带这个字段
 */

typedef NS_ENUM(NSUInteger, LWPropertyMemoryAttribute) {
    LWPropertyMemoryAttributeAssign,
    LWPropertyMemoryAttributeStrong,
    LWPropertyMemoryAttributeWeak,
    LWPropertyMemoryAttributeCopy,
};



/*
 线程安全相关属性:
 N:nonatomic非原子性
 如果是原子性atomic的，则不包含这个字段
 */

typedef NS_ENUM(NSUInteger, LWPropertyThreadSafeAttribute) {
    LWPropertyThreadSafeAttributeAtomic,
    LWPropertyThreadSafeAttributeNonAtomic,
};

/*
 读写权限相关属性
 R:readonly
 如果是readwrite，则不包含这个字段
 */

typedef NS_ENUM(NSUInteger, LWPropertyAuthorityAttribute) {
    LWPropertyAuthorityAttributeReadWrite,
    LWPropertyAuthorityAttributeReadOnly,
};

/*
 成员变量相关属性
 V:成员变量ivar名称
 G:getter方法的名称
 S:Setter方法的名称
 D:dynamic 动态合成getter和setter方法，不自动合成
 */

typedef NS_ENUM(NSUInteger, LWPropertyIvarAttribute) {
    LWPropertyIvarAttributeNonDynamic,
    LWPropertyIvarAttributeDynamic,
};





//封装自objc_property_t

@interface LWProperty : NSObject

@property (nonatomic,assign,readonly) objc_property_t objcProperty;
@property (nonatomic,copy,readonly) NSString* name;
@property (nonatomic,assign,readonly) LWType type;
@property (nonatomic,assign,readonly) LWPropertyMemoryAttribute memoryAttribute;
@property (nonatomic,assign,readonly) LWPropertyThreadSafeAttribute threadSafeAttribute;
@property (nonatomic,assign,readonly) LWPropertyAuthorityAttribute authorityAttribute;
@property (nonatomic,assign,readonly) LWPropertyIvarAttribute ivarAttribute;
@property (nonatomic,copy,readonly) NSString* ivarName;//成员变量名
@property (nonatomic,copy,readonly) NSString* setterName;//setter方法名
@property (nonatomic,copy,readonly) NSString* getterName;//getter方法名
@property (nonatomic,strong,readonly) Class cls;//类名称，如果是OBJC对象类型

+ (LWProperty *)lw_propertyWithObjcProperty:(objc_property_t)objcProperty;










#pragma mark - Just For NSObject+Maping
@property (nonatomic,strong,readonly) NSArray* mapperName;//模型映射的名称
- (id)initWithProperty:(objc_property_t)objcProperty mapper:(NSDictionary *)mapper;

@end
