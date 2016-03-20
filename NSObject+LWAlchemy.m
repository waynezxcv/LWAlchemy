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
//  Copyright © 2016年 Wayne Liu. All rights reserved.
//  https://github.com/waynezxcv/LWAlchemy
//  See LICENSE for this sample’s licensing information
//


#import "NSObject+LWAlchemy.h"
#import "LWAlchemyPropertyInfo.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <CoreData/CoreData.h>



static void* LWAlechmyCachedPropertyKeysKey = &LWAlechmyCachedPropertyKeysKey;
static void* LWAlechmyMapDictionaryKey = &LWAlechmyMapDictionaryKey;

@implementation NSObject(LWAlchemy)


#pragma mark - Associate

+ (NSDictionary *)mapDictionary {
    //TODO:
    return nil;
}

+ (NSSet *)propertysSet {
    NSSet* cachedKeys = objc_getAssociatedObject(self, LWAlechmyCachedPropertyKeysKey);
    if (cachedKeys != nil) {
        return cachedKeys;
    }
    NSMutableSet* propertysSet = [NSMutableSet set];
    [self _enumeratePropertiesUsingBlock:^(objc_property_t property, BOOL *stop) {
        LWAlchemyPropertyInfo* propertyInfo = [[LWAlchemyPropertyInfo alloc] initWithProperty:property];
        [propertysSet addObject:propertyInfo];
    }];
    objc_setAssociatedObject(self,LWAlechmyCachedPropertyKeysKey, propertysSet, OBJC_ASSOCIATION_COPY);
    return propertysSet;
}

#pragma mark - Init

+ (id)modelWithJSON:(id)json {
    NSObject* model = [[self alloc] init];
    if (model) {
        if (![json isKindOfClass:[NSDictionary class]]) {
            NSDictionary* dic = [model _dictionaryWithJSON:json];
            model = [model modelWithDictionary:dic];
        }
        else {
            model = [model modelWithDictionary:json];
        }
    }
    return model;
}


+ (id)coreDataModelWithJSON:(id)json
                    context:(NSManagedObjectContext *)context {
    if ([self isSubclassOfClass:[NSManagedObject class]] && context) {
        NSManagedObject* model = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self)
                                                               inManagedObjectContext:context];
        if (model) {
            if (![json isKindOfClass:[NSDictionary class]]) {
                NSDictionary* dic = [model _dictionaryWithJSON:json];
                model = [model coreDataModelWithDictionary:dic context:context];
            }
            else {
                model = [model coreDataModelWithDictionary:json context:context];
            }
        }
        return model;
    }
    return [self modelWithJSON:json];
}

- (instancetype)modelWithDictionary:(NSDictionary *)dictionary {
    if (!dictionary || dictionary == (id)kCFNull) return nil;
    if (![dictionary isKindOfClass:[NSDictionary class]]) return nil;
    NSSet* propertysSet = self.class.propertysSet;
    [propertysSet enumerateObjectsUsingBlock:^(LWAlchemyPropertyInfo* propertyInfo, BOOL * _Nonnull stop) {
        id object = dictionary[propertyInfo.propertyName];
        _SetPropertyValue(self,propertyInfo,object);
    }];
    return self;
}

- (instancetype)coreDataModelWithDictionary:(NSDictionary *)dictionary context:(NSManagedObjectContext *)contxt {
    if (!dictionary || dictionary == (id)kCFNull) return nil;
    if (![dictionary isKindOfClass:[NSDictionary class]]) return nil;
    NSSet* propertysSet = self.class.propertysSet;
    [propertysSet enumerateObjectsUsingBlock:^(LWAlchemyPropertyInfo* propertyInfo, BOOL * _Nonnull stop) {
        id object = dictionary[propertyInfo.propertyName];
        if (!propertyInfo.isReadonly) {
            if (propertyInfo.isFoundationType) {
                [self setValue:object forKey:propertyInfo.propertyName];
            } else {
                if (propertyInfo.isIdType) {
                    [self setValue:object forKey:propertyInfo.propertyName];
                } else {
                    Class cls = propertyInfo.cls;
                    NSManagedObject* model = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(cls)
                                                                           inManagedObjectContext:contxt];
                    [model coreDataModelWithDictionary:object context:contxt];
                    [self setValue:model forKey:propertyInfo.propertyName];
                }
            }
        }
    }];
    return self;
}

#pragma mark - Private Methods

/**
 *  将Json转化成NSDictionary字典
 *
 */
- (NSDictionary *)_dictionaryWithJSON:(id)json {
    if (!json || json == (id)kCFNull) return nil;
    NSDictionary* dic = nil;
    NSData* jsonData = nil;
    if ([json isKindOfClass:[NSDictionary class]]) {
        dic = json;
    } else if ([json isKindOfClass:[NSString class]]) {
        jsonData = [(NSString *)json dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([json isKindOfClass:[NSData class]]) {
        jsonData = json;
    }
    if (jsonData) {
        dic = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        if (![dic isKindOfClass:[NSDictionary class]]) dic = nil;
    }
    return dic;
}


/**
 *  遍历实例的对象的objc_property_t
 *
 */
- (void)_enumeratePropertiesUsingBlock:(void (^)(objc_property_t property, BOOL *stop))block {
    Class cls = [self class];
    BOOL stop = NO;
    while (!stop && ![cls isEqual:[NSObject class]]) {
        unsigned count = 0;
        objc_property_t* properties = class_copyPropertyList(cls, &count);
        if (properties) {
            cls = cls.superclass;
            if (properties == NULL) return;
            for (unsigned i = 0; i < count; i++) {
                block(properties[i], &stop);
                if (stop) break;
            }
            free(properties);
        }
    }
}


/**
 *  设置Property的值
 *
 *  @param model        模型对象
 *  @param propertyInfo 属性的封装对象
 *  @param value        值
 */
static void _SetPropertyValue(__unsafe_unretained id model,
                              __unsafe_unretained LWAlchemyPropertyInfo* propertyInfo,
                              __unsafe_unretained id value) {
    if (propertyInfo.isReadonly || propertyInfo.isDynamic) {
        return;
    }
    if (propertyInfo.isNumberType) {
        _SetNumberPropertyValue(model, propertyInfo, value);
    }
    else if (propertyInfo.isObjectType) {
        _SetObjectTypePropertyValue(model, propertyInfo, value);
    }
    else {
        _SetOtherTypePropertyValue(model,propertyInfo,value);
    }
}

/**
 *  设置LWTypeNumber类型Property的值
 *
 *  @param model        模型对象
 *  @param propertyInfo 属性的封装对象
 *  @param value        值
 */
static void _SetNumberPropertyValue(__unsafe_unretained id model,
                                    __unsafe_unretained LWAlchemyPropertyInfo* propertyInfo,
                                    __unsafe_unretained id value) {
    if (!propertyInfo.setter) {
        return;
    }
    SEL setterSelector = NSSelectorFromString(propertyInfo.setter);
    switch (propertyInfo.type) {
        case LWTypeBool: {
            //定义一个函数指针
            NSNumber* num = (NSNumber *)value;
            void (*objc_msgSendToSetter)(id, SEL, bool) = (void*)objc_msgSend;
            objc_msgSendToSetter((id)model, setterSelector, num.boolValue);
        }break;
        case LWTypeInt8:{
            NSNumber* num = (NSNumber *)value;
            void (*objc_msgSendToSetter)(id, SEL, int8_t) = (void*)objc_msgSend;
            objc_msgSendToSetter((id)model, setterSelector, (int8_t)num.charValue);
        }break;
        case LWTypeUInt8: {
            NSNumber* num = (NSNumber *)value;
            void (*objc_msgSendToSetter)(id, SEL, uint8_t) = (void*)objc_msgSend;
            objc_msgSendToSetter((id)model, setterSelector, (uint8_t)num.unsignedCharValue);
        }break;
        case LWTypeInt16: {
            NSNumber* num = (NSNumber *)value;
            void (*objc_msgSendToSetter)(id, SEL, int16_t) = (void*)objc_msgSend;
            objc_msgSendToSetter((id)model, setterSelector, (int16_t)num.shortValue);
        }break;
        case LWTypeUInt16: {
            NSNumber* num = (NSNumber *)value;
            void (*objc_msgSendToSetter)(id, SEL, uint16_t) = (void*)objc_msgSend;
            objc_msgSendToSetter((id)model, setterSelector, (uint16_t)num.unsignedShortValue);
        }break;
        case LWTypeInt32: {
            NSNumber* num = (NSNumber *)value;
            void (*objc_msgSendToSetter)(id, SEL, int32_t) = (void*)objc_msgSend;
            objc_msgSendToSetter((id)model, setterSelector, (int32_t)num.intValue);
        }break;
        case LWTypeUInt32: {
            NSNumber* num = (NSNumber *)value;
            void (*objc_msgSendToSetter)(id, SEL, uint32_t) = (void*)objc_msgSend;
            objc_msgSendToSetter((id)model, setterSelector, (uint32_t)num.unsignedIntValue);
        }break;
        case LWTypeInt64: {
            if ([value isKindOfClass:[NSDecimalNumber class]]) {
                NSNumber* num = (NSDecimalNumber *)value;
                void (*objc_msgSendToSetter)(id, SEL, int64_t) = (void*)objc_msgSend;
                objc_msgSendToSetter((id)model, setterSelector, (int64_t)num.stringValue.longLongValue);
            } else {
                NSNumber* num = (NSNumber *)value;
                void (*objc_msgSendToSetter)(id, SEL, int64_t) = (void*)objc_msgSend;
                objc_msgSendToSetter((id)model, setterSelector, (int64_t)num.longLongValue);
            }
        }break;
        case LWTypeUInt64:{
            if ([value isKindOfClass:[NSDecimalNumber class]]) {
                NSNumber* num = (NSDecimalNumber *)value;
                void (*objc_msgSendToSetter)(id, SEL, uint64_t) = (void*)objc_msgSend;
                objc_msgSendToSetter((id)model, setterSelector, (uint64_t)num.stringValue.longLongValue);
            } else {
                NSNumber* num = (NSNumber *)value;
                void (*objc_msgSendToSetter)(id, SEL, uint64_t) = (void*)objc_msgSend;
                objc_msgSendToSetter((id)model, setterSelector, (uint64_t)num.longLongValue);
            }
        }break;
        case LWTypeFloat: {
            NSNumber* num = (NSNumber *)value;
            float f = num.floatValue;
            if (isnan(f) || isinf(f)) f = 0;
            void (*objc_msgSendToSetter)(id, SEL, float) = (void*)objc_msgSend;
            objc_msgSendToSetter((id)model, setterSelector, f);
        }break;
        case LWTypeDouble:{
            NSNumber* num = (NSNumber *)value;
            double d = num.doubleValue;
            if (isnan(d) || isinf(d)) d = 0;
            void (*objc_msgSendToSetter)(id, SEL, double) = (void*)objc_msgSend;
            objc_msgSendToSetter((id)model, setterSelector, d);
        }break;
        case LWTypeLongDouble: {
            NSNumber* num = (NSNumber *)value;
            long double d = num.doubleValue;
            if (isnan(d) || isinf(d)) d = 0;
            void (*objc_msgSendToSetter)(id, SEL, long double) = (void*)objc_msgSend;
            objc_msgSendToSetter((id)model, setterSelector, d);
        }break;
        default:break;
    }
}

/**
 *  设置LWTypeOjbect类型Property的值
 *
 *  @param model        模型对象
 *  @param propertyInfo 属性的封装对象
 *  @param value        值
 */
static void _SetObjectTypePropertyValue(__unsafe_unretained id model,
                                        __unsafe_unretained LWAlchemyPropertyInfo* propertyInfo,
                                        __unsafe_unretained id value) {
    if (!propertyInfo.setter) {
        return;
    }
    SEL setterSelector = NSSelectorFromString(propertyInfo.setter);
    BOOL isNull = (value == (id)kCFNull);
    if ([propertyInfo.cls class] == [NSString class]) {
        NSString* string = [NSString stringWithFormat:@"%@",(NSString *)value];
        void (*objc_msgSendToSetter)(id, SEL,NSString*) = (void*)objc_msgSend;
        objc_msgSendToSetter((id)model, setterSelector, string);
    }
    else if ([propertyInfo.cls class] == [NSMutableString class]) {
        NSMutableString* mutableString = [NSString stringWithFormat:@"%@",value].mutableCopy;
        void (*objc_msgSendToSetter)(id, SEL, NSMutableString*) = (void*)objc_msgSend;
        objc_msgSendToSetter((id)model, setterSelector, mutableString);
    }
    else if ([propertyInfo.cls class] == [NSValue class]) {
        void (*objc_msgSendToSetter)(id, SEL,NSValue*) = (void*)objc_msgSend;
        objc_msgSendToSetter((id)model, setterSelector, value);
    }
    else if ([propertyInfo.cls class] == [NSNumber class]) {
        if ([value isKindOfClass:[NSNumber class]]) {
            NSNumber* num = (NSNumber *)value;
            void (*objc_msgSendToSetter)(id, SEL,NSNumber*) = (void*)objc_msgSend;
            objc_msgSendToSetter((id)model, setterSelector, num);
        }
    }
    else if ([propertyInfo.cls class] == [NSDecimalNumber class]) {
        if ([value isKindOfClass:[NSDecimalNumber class]]) {
            NSDecimalNumber* num = (NSDecimalNumber *)value;
            void (*objc_msgSendToSetter)(id, SEL,NSDecimalNumber*) = (void*)objc_msgSend;
            objc_msgSendToSetter((id)model, setterSelector, num);
        }
    }
    else if ([propertyInfo.cls class] == [NSData class]) {
        if ([value isKindOfClass:[NSData class]]) {
            NSData* data = ((NSData *)value).copy;
            void (*objc_msgSendToSetter)(id, SEL,NSData*) = (void*)objc_msgSend;
            objc_msgSendToSetter((id)model, setterSelector, data);
        } else if ([value isKindOfClass:[NSString class]]) {
            NSData* data = [(NSString *)value dataUsingEncoding:NSUTF8StringEncoding];
            void (*objc_msgSendToSetter)(id, SEL,NSData*) = (void*)objc_msgSend;
            objc_msgSendToSetter((id)model, setterSelector, data);
        }
    }
    else if ([propertyInfo.cls class] == [NSMutableData class]) {
        if ([value isKindOfClass:[NSData class]]) {
            NSMutableData* data = ((NSData *)value).mutableCopy;
            void (*objc_msgSendToSetter)(id, SEL,NSMutableData*) = (void*)objc_msgSend;
            objc_msgSendToSetter((id)model, setterSelector, data);
        } else if ([value isKindOfClass:[NSString class]]) {
            NSMutableData* data = [(NSString *)value dataUsingEncoding:NSUTF8StringEncoding].mutableCopy;
            void (*objc_msgSendToSetter)(id, SEL,NSMutableData* ) = (void*)objc_msgSend;
            objc_msgSendToSetter((id)model, setterSelector, data);
        }
    }
    else if ([propertyInfo.cls class] == [NSDate class]) {
        if ([value isKindOfClass:[NSDate class]]) {
            void (*objc_msgSendToSetter)(id, SEL,NSDate*) = (void*)objc_msgSend;
            objc_msgSendToSetter((id)model, setterSelector, value);
        } else if ([value isKindOfClass:[NSString class]]) {
            void (*objc_msgSendToSetter)(id, SEL,NSDate*) = (void*)objc_msgSend;
            objc_msgSendToSetter((id)model, setterSelector, LWNSDateFromString(value));
        } else {
            void (*objc_msgSendToSetter)(id, SEL,NSDate*) = (void*)objc_msgSend;
            objc_msgSendToSetter((id)model, setterSelector,LWNSDateFromString([NSString stringWithFormat:@"%@",value]));
        }
    }
    else if ([propertyInfo.cls class] == [NSURL class]) {
        NSURL* URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",(NSString *)value]];
        void (*objc_msgSendToSetter)(id, SEL,NSURL*) = (void*)objc_msgSend;
        objc_msgSendToSetter((id)model, setterSelector,URL);
    }
    else if ([propertyInfo.cls class] == [NSArray class]) {
        NSArray* array = (NSArray *)value;
        void (*objc_msgSendToSetter)(id, SEL,NSArray*) = (void*)objc_msgSend;
        objc_msgSendToSetter((id)model, setterSelector,array);
    }
    else if ([propertyInfo.cls class] == [NSMutableArray class]) {
        NSMutableArray* mutableArray = ((NSArray *)value).mutableCopy;
        void (*objc_msgSendToSetter)(id, SEL,NSMutableArray*) = (void*)objc_msgSend;
        objc_msgSendToSetter((id)model, setterSelector,mutableArray);
    }
    else if ([propertyInfo.cls class] == [NSDictionary class]) {
        NSDictionary* dictionary = (NSDictionary *)value;
        void (*objc_msgSendToSetter)(id, SEL,NSDictionary*) = (void*)objc_msgSend;
        objc_msgSendToSetter((id)model, setterSelector,dictionary);
    }
    else if ([propertyInfo.cls class] == [NSMutableDictionary class]) {
        NSMutableDictionary* mutableDict = ((NSDictionary *)value).mutableCopy;
        void (*objc_msgSendToSetter)(id, SEL,NSMutableDictionary*) = (void*)objc_msgSend;
        objc_msgSendToSetter((id)model, setterSelector,mutableDict);
    }
    else if ([propertyInfo.cls class] == [NSSet class]) {
        NSSet* set = (NSSet *)value;
        void (*objc_msgSendToSetter)(id, SEL,NSSet*) = (void*)objc_msgSend;
        objc_msgSendToSetter((id)model, setterSelector,set);
    }
    else if ([propertyInfo.cls class] == [NSMutableSet class]) {
        NSMutableSet* mutableSet = ((NSSet *)value).mutableCopy;
        void (*objc_msgSendToSetter)(id, SEL,NSMutableSet*) = (void*)objc_msgSend;
        objc_msgSendToSetter((id)model, setterSelector,mutableSet);
    }
    else {
        if (isNull) {
            void (*objc_msgSendToSetter)(id, SEL,id) = (void*)objc_msgSend;
            objc_msgSendToSetter((id)model, setterSelector,(id)nil);
        } else if ([value isKindOfClass:propertyInfo.cls]) {
            void (*objc_msgSendToSetter)(id, SEL,id) = (void*)objc_msgSend;
            objc_msgSendToSetter((id)model, setterSelector,(id)value);
        }
        else if ([value isKindOfClass:[NSDictionary class]]) {
            NSObject* child = nil;
            if (propertyInfo.getter) {
                SEL getter = NSSelectorFromString(propertyInfo.getter);
                child = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model,getter);
            }
            if (child) {
                [child modelWithDictionary:value];
            } else {
                Class cls = propertyInfo.cls;
                child = [cls new];
                [child modelWithDictionary:value];
                SEL setterSelector = NSSelectorFromString(propertyInfo.setter);
                void (*objc_msgSendToSetter)(id, SEL,id) = (void*)objc_msgSend;
                objc_msgSendToSetter((id)model,setterSelector,child);
            }
        }
    }
}

/**
 *  设置其他类型Property的值
 *
 *  @param model        模型对象
 *  @param propertyInfo 属性的封装对象
 *  @param value        值
 */
static void _SetOtherTypePropertyValue(__unsafe_unretained id model,
                                       __unsafe_unretained LWAlchemyPropertyInfo* propertyInfo,
                                       __unsafe_unretained id value) {
    if (!propertyInfo.setter) {
        return;
    }
    SEL setterSelector = NSSelectorFromString(propertyInfo.setter);
    BOOL isNull = (value == (id)kCFNull);
    switch (propertyInfo.type) {
        case LWTypeBlock: {
            if (isNull) {
                void (*objc_msgSendToSetter)(id, SEL, void (^)()) = (void*)objc_msgSend;
                objc_msgSendToSetter((id)model, setterSelector, (void (^)())NULL);
            } else if ([value isKindOfClass:LWNSBlockClass()]) {
                void (*objc_msgSendToSetter)(id, SEL, void (^)()) = (void*)objc_msgSend;
                objc_msgSendToSetter((id)model, setterSelector,(void (^)())value);
            }
        }break;
        case LWTypeClass:{
            if (isNull) {
                void (*objc_msgSendToSetter)(id, SEL,Class) = (void*)objc_msgSend;
                objc_msgSendToSetter((id)model, setterSelector,(Class)NULL);
            } else {
                Class cls = nil;
                if ([value isKindOfClass:[NSString class]]) {
                    cls = NSClassFromString(value);
                    if (cls) {
                        void (*objc_msgSendToSetter)(id, SEL,Class) = (void*)objc_msgSend;
                        objc_msgSendToSetter((id)model, setterSelector,(Class)cls);
                    }
                } else {
                    cls = object_getClass(value);
                    if (cls) {
                        if (class_isMetaClass(cls)) {
                            void (*objc_msgSendToSetter)(id, SEL,Class) = (void*)objc_msgSend;
                            objc_msgSendToSetter((id)model, setterSelector, (Class)value);
                        } else {
                            void (*objc_msgSendToSetter)(id, SEL,Class) = (void*)objc_msgSend;
                            objc_msgSendToSetter((id)model, setterSelector,(Class)cls);
                        }
                    }
                }
            }
        case LWTypeSEL: {
            if (isNull) {
                void (*objc_msgSendToSetter)(id, SEL,SEL) = (void*)objc_msgSend;
                objc_msgSendToSetter((id)model, setterSelector,(SEL)NULL);
            } else if ([value isKindOfClass:[NSString class]]) {
                SEL sel = NSSelectorFromString(value);
                if (sel) {
                    void (*objc_msgSendToSetter)(id, SEL,SEL) = (void*)objc_msgSend;
                    objc_msgSendToSetter((id)model, setterSelector,sel);
                }
            }
        }break;
        case LWTypeCFString:
        case LWTypePointer:{
            if (isNull) {
                void (*objc_msgSendToSetter)(id, SEL,void*) = (void*)objc_msgSend;
                objc_msgSendToSetter((id)model, setterSelector, (void *)NULL);
            } else if ([value isKindOfClass:[NSValue class]]) {
                NSValue *nsValue = value;
                if (nsValue.objCType && strcmp(nsValue.objCType, "^v") == 0) {
                    void (*objc_msgSendToSetter)(id, SEL, void* ) = (void*)objc_msgSend;
                    objc_msgSendToSetter((id)model, setterSelector,nsValue.pointerValue);
                }
            }
        }break;
        case LWTypeUnion:
        case LWTypeStruct:
        case LWTypeCFArray:
            if ([value isKindOfClass:[NSValue class]]) {
                const char* valueType = ((NSValue *)value).objCType;
                Ivar ivar = class_getInstanceVariable([propertyInfo.cls class],[propertyInfo.ivarName UTF8String]);
                const char* metaType = ivar_getTypeEncoding(ivar);
                if (valueType && metaType && strcmp(valueType, metaType) == 0) {
                    [model setValue:value forKey:propertyInfo.propertyName];
                }
            }break;
        case LWTypeUnkonw:
        case LWTypeVoid:
        default:break;
        }
    }
}

/**
 *  将时间戳字符串转化成NSDate
 */
static inline NSDate* LWNSDateFromString(__unsafe_unretained NSString *string) {
    NSTimeInterval timeInterval = [string floatValue];
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    return date;
}

static inline Class LWNSBlockClass() {
    static Class cls;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        void (^block)(void) = ^{};
        cls = ((NSObject *)block).class;
        while (class_getSuperclass(cls) != [NSObject class]) {
            cls = class_getSuperclass(cls);
        }
    });
    return cls;
}

#pragma mark - Description
//
//- (NSString *)lwAlchemyDescription {
//    return  _ModelDescription(self);
//}
//
//static NSString* _ModelDescription(NSObject *model) {
//    if (!model) return @"<nil>";
//    if (model == (id)kCFNull) return @"<null>";
//    if (![model isKindOfClass:[NSObject class]]) return [NSString stringWithFormat:@"%@",model];
//    __block NSMutableString* des = [[NSMutableString alloc] init];
//    [model.propertysSet enumerateObjectsUsingBlock:^(LWAlchemyPropertyInfo* propertyInfo, BOOL * _Nonnull stop) {
//        if (propertyInfo.getter) {
//            SEL getter = NSSelectorFromString(propertyInfo.getter);
//            id value = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model,getter);
//            NSString* propertyDes = [NSString stringWithFormat:@"propertyName:%@,value:%@\n",propertyInfo.propertyName,value];
//            [des appendFormat:propertyDes];
//        }
//    }];
//    return des;
//}
@end
