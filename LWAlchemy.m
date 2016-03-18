//
//  NSObject+Model.m
//  LWAlchemyDemo
//
//  Created by 刘微 on 16/1/20.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import "LWAlchemy.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "LWAlchemyPropertyInfo.h"



static const void* kJsonMapperKey;

@implementation NSObject(LWAlchemy)


- (NSDictionary *)mapper {
    return objc_getAssociatedObject(self, kJsonMapperKey);
}

- (void)setMapper:(NSDictionary *)mapper {
    objc_setAssociatedObject(self, kJsonMapperKey, mapper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (id)modelWithJSON:(id)json JSONKeyPathsByPropertyKey:(NSDictionary *)mapper {
    NSObject* model = [[self alloc] init];
    if (model) {
        model.mapper = [mapper copy];
        NSDictionary* dic = [model _dictionaryWithJSON:json];
        model = [model _modelWithDictionary:dic];
    }
    return model;
}

+ (id)coreDataModelWithJSON:(id)json
  JSONKeyPathsByPropertyKey:(NSDictionary *)mapper
                    context:(NSManagedObjectContext *)context {
    if ([self isSubclassOfClass:[NSManagedObject class]] && context) {
        NSManagedObject* model = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self) inManagedObjectContext:context];
        model.mapper = [mapper copy];
        NSDictionary* dic = [model _dictionaryWithJSON:json];
        model = [model _coreDataModelWithDictionary:dic];
        return model;
    }
    return [self modelWithJSON:json JSONKeyPathsByPropertyKey:mapper];
}

- (NSDictionary *)_dictionaryWithJSON:(id)json {
    if (!json || json == (id)kCFNull) return nil;
    NSDictionary* dic = nil;
    NSData* jsonData = nil;
    if ([json isKindOfClass:[NSDictionary class]]) {
        dic = json;
    } else if ([json isKindOfClass:[NSString class]]) {
        jsonData = [(NSString *)json dataUsingEncoding : NSUTF8StringEncoding];
    } else if ([json isKindOfClass:[NSData class]]) {
        jsonData = json;
    }
    if (jsonData) {
        dic = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        if (![dic isKindOfClass:[NSDictionary class]]) dic = nil;
    }
    return dic;
}

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

- (instancetype)_coreDataModelWithDictionary:(NSDictionary *)dictionary {
    if (!dictionary || dictionary == (id)kCFNull) return nil;
    if (![dictionary isKindOfClass:[NSDictionary class]]) return nil;
    [self _enumeratePropertiesUsingBlock:^(objc_property_t property, BOOL *stop) {
        LWAlchemyPropertyInfo* propertyInfo = [[LWAlchemyPropertyInfo alloc] initWithProperty:property];
        NSString* mapKey = self.mapper[propertyInfo.propertyName];
        id object = dictionary[mapKey];
        
        
        NSLog(@"setValue:%@...forKey:%@",object,propertyInfo.propertyName);
//        if (![propertyInfo.propertyName isEqualToString:@"forKey:managedObjectContext"]) {
//            [self setValue:object forKey:propertyInfo.propertyName];
//        }
    }];
    return self;
}


- (instancetype)_modelWithDictionary:(NSDictionary *)dictionary {
    if (!dictionary || dictionary == (id)kCFNull) return nil;
    if (![dictionary isKindOfClass:[NSDictionary class]]) return nil;
    [self _enumeratePropertiesUsingBlock:^(objc_property_t property, BOOL *stop) {
        LWAlchemyPropertyInfo* propertyInfo = [[LWAlchemyPropertyInfo alloc] initWithProperty:property];
        NSString* mapKey = self.mapper[propertyInfo.propertyName];
        id object = dictionary[mapKey];
        _SetPropertyValue(self,propertyInfo,object);
    }];
    return self;
}


static void _SetPropertyValue(__unsafe_unretained id model,
                              __unsafe_unretained LWAlchemyPropertyInfo* propertyInfo,
                              __unsafe_unretained id value) {
    if (propertyInfo.isReadonly) {
        return;
    }
    if (propertyInfo.isDynamic) {
//        _setDynamicPropertyValue(model,propertyInfo,value);
        return;
    }
    SEL setter = NSSelectorFromString(propertyInfo.setter);
    BOOL isNull = (value == (id)kCFNull);
    switch (propertyInfo.type) {
        case LWTypeBool:
        case LWTypeInt8:
        case LWTypeUInt8:
        case LWTypeInt16:
        case LWTypeUInt16:
        case LWTypeInt32:
        case LWTypeUInt32:
        case LWTypeInt64:
        case LWTypeUInt64:
        case LWTypeFloat:
        case LWTypeDouble:
        case LWTypeLongDouble:_setNumberPropertyValue(model, propertyInfo, value);break;
        case LWTypeSEL: {
            if (isNull) {
                ((void (*)(id, SEL, SEL))(void *) objc_msgSend)((id)model,setter, (SEL)NULL);
            } else if ([value isKindOfClass:[NSString class]]) {
                SEL sel = NSSelectorFromString(value);
                if (sel) ((void (*)(id, SEL, SEL))(void *) objc_msgSend)((id)model,setter, (SEL)sel);
            }
        }break;
        case LWTypeObject: {
//            _setObjectTypePropertyValue(model, propertyInfo, value);
        }break;
        case LWTypeBlock: {
            if (isNull) {
                ((void (*)(id, SEL, void (^)()))(void *) objc_msgSend)((id)model, setter, (void (^)())NULL);
            } else if ([value isKindOfClass:LWNSBlockClass()]) {
                ((void (*)(id, SEL, void (^)()))(void *) objc_msgSend)((id)model, setter, (void (^)())value);
            }
        }break;
        case LWTypeClass:{
            if (isNull) {
                ((void (*)(id, SEL, Class))(void *) objc_msgSend)((id)model,setter, (Class)NULL);
            } else {
                Class cls = nil;
                if ([value isKindOfClass:[NSString class]]) {
                    cls = NSClassFromString(value);
                    if (cls) {
                        ((void (*)(id, SEL, Class))(void *) objc_msgSend)((id)model,setter, (Class)cls);
                    }
                } else {
                    cls = object_getClass(value);
                    if (cls) {
                        if (class_isMetaClass(cls)) {
                            ((void (*)(id, SEL, Class))(void *) objc_msgSend)((id)model,setter, (Class)value);
                        } else {
                            ((void (*)(id, SEL, Class))(void *) objc_msgSend)((id)model,setter, (Class)cls);
                        }
                    }
                }
            }
        }break;
        case LWTypeUnkonw: {
        }break;
        case LWTypeVoid: {
        }break;
        case LWTypeCFString: {
        }break;
        case LWTypePointer: {
        }break;
        case LWTypeUnion: {
        }break;
        case LWTypeStruct: {
        }break;
        case LWTypeCFArray:{
        }break;
        default:break;
    }
}



static void _setNumberPropertyValue(__unsafe_unretained id model,
                                    __unsafe_unretained LWAlchemyPropertyInfo* propertyInfo,
                                    __unsafe_unretained id value) {
    if (!propertyInfo.setter) {
        return;
    }
    NSNumber* num = (NSNumber *)value;
    SEL setterSelector = NSSelectorFromString(propertyInfo.setter);
    switch (propertyInfo.type) {
        case LWTypeBool: {
            //定义一个函数指针
            void (*objc_setValue)(id, SEL, bool);
            objc_setValue = (void (*)(id m, SEL s, bool v))(objc_msgSend(m,s,v));
            objc_setValue((id)model,setterSelector,num.boolValue);
        }break;
        case LWTypeInt8:{
            void (*objc_setValue)(id, SEL, int8_t);
            objc_setValue = (void (*)(id m, SEL s, uint8_t v))(objc_msgSend(m,s,v));
            objc_setValue((id)model,setterSelector,(int8_t)num.charValue);
        }break;
        case LWTypeUInt8: {
            void (*objc_setValue)(id, SEL, uint8_t);
            objc_setValue = (void (*)(id m, SEL s, uint8_t v))(objc_msgSend(m,s,v));
            objc_setValue((id)model,setterSelector,(uint8_t)num.unsignedCharValue);
        }break;
        case LWTypeInt16: {
            void (*objc_setValue)(id, SEL, int16_t);
            objc_setValue = (void (*)(id m, SEL s, int16_t v))(objc_msgSend(m,s,v));
            objc_setValue((id)model,setterSelector,(int16_t)num.shortValue);
        }break;
        case LWTypeUInt16: {
            void (*objc_setValue)(id, SEL, uint16_t);
            objc_setValue = (void (*)(id m, SEL s, uint16_t v))(objc_msgSend(m,s,v));
            objc_setValue((id)model,setterSelector,(uint16_t)num.unsignedShortValue);
        }break;
        case LWTypeInt32: {
            void (*objc_setValue)(id, SEL, int32_t);
            objc_setValue = (void (*)(id m, SEL s, int32_t v))(objc_msgSend(m,s,v));
            objc_setValue((id)model,setterSelector,(int32_t)num.intValue);
        }break;
        case LWTypeUInt32: {
            void (*objc_setValue)(id, SEL, uint32_t);
            objc_setValue = (void (*)(id m, SEL s, uint32_t v))(objc_msgSend(m,s,v));
            objc_setValue((id)model,setterSelector,(uint32_t)num.unsignedIntValue);
        }break;
        case LWTypeInt64: {
            if ([value isKindOfClass:[NSDecimalNumber class]]) {
                void (*objc_setValue)(id, SEL, int64_t);
                objc_setValue = (void (*)(id m, SEL s, int64_t v))(objc_msgSend(m,s,v));
                objc_setValue((id)model,setterSelector,(int64_t)num.stringValue.longLongValue);
            } else {
                void (*objc_setValue)(id, SEL, uint64_t);
                objc_setValue = (void (*)(id m, SEL s, uint64_t v))(objc_msgSend(m,s,v));
                objc_setValue((id)model,setterSelector,(uint64_t)num.longLongValue);
            }
        }break;
        case LWTypeUInt64:{
            if ([value isKindOfClass:[NSDecimalNumber class]]) {
                void (*objc_setValue)(id, SEL, int64_t);
                objc_setValue = (void (*)(id m, SEL s, int64_t v))(objc_msgSend(m,s,v));
                objc_setValue((id)model,setterSelector,(int64_t)num.stringValue.longLongValue);
            } else {
                void (*objc_setValue)(id, SEL, uint64_t);
                objc_setValue = (void (*)(id m, SEL s, uint64_t v))(objc_msgSend(m,s,v));
                objc_setValue((id)model,setterSelector,(uint64_t)num.longLongValue);
            }
        }break;
        case LWTypeFloat: {
            float f = num.floatValue;
            if (isnan(f) || isinf(f)) f = 0;
            void (*objc_setValue)(id, SEL, float);
            objc_setValue = (void (*)(id m, SEL s, float v))(objc_msgSend(m,s,v));
            objc_setValue((id)model,setterSelector,f);
        }break;
        case LWTypeDouble:{
//            double d = num.doubleValue;
//            if (isnan(d) || isinf(d)) d = 0;
//            void (*objc_setValue)(id, SEL, double);
//            objc_setValue = (void (*)(id m, SEL s, double v))(objc_msgSend(m,s,v));
//            objc_setValue((id)model,setterSelector,d);
        }break;
        case LWTypeLongDouble: {
//            long double d = num.doubleValue;
//            if (isnan(d) || isinf(d)) d = 0;
//            void (*objc_setValue)(id, SEL, long double);
//            objc_setValue = (void (*)(id m, SEL s, long double v))(objc_msgSend(m,s,v));
//            objc_setValue((id)model,setterSelector,d);
        }break;
    }
}


static void _setObjectTypePropertyValue(__unsafe_unretained id model,
                                        __unsafe_unretained LWAlchemyPropertyInfo* propertyInfo,
                                        __unsafe_unretained id value) {
    SEL setter = NSSelectorFromString(propertyInfo.setter);
    BOOL isNull = (value == (id)kCFNull);
    if ([propertyInfo.cls class] == [NSString class]) {
        NSString* string = [NSString stringWithFormat:@"%@",(NSString *)value];
        ((void (*)(id, SEL, NSString*))(void *) objc_msgSend)((id)model,setter,string);
    }
    else if ([propertyInfo.cls class] == [NSMutableString class]) {
        NSMutableString* mutableString = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@",value]];;
        ((void (*)(id, SEL, NSMutableString*))(void *) objc_msgSend)((id)model,setter, mutableString);
    }
    else if ([propertyInfo.cls class] == [NSValue class]) {
        if ([value isKindOfClass:[NSValue class]]) {
            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,setter, value);
        }
    }
    else if ([propertyInfo.cls class] == [NSNumber class]) {
        if ([value isKindOfClass:[NSNumber class]]) {
            NSNumber* num = (NSNumber *)value;
            ((void (*)(id, SEL, NSNumber*))(void *) objc_msgSend)((id)model,setter, num);
        }
    }
    else if ([propertyInfo.cls class] == [NSDecimalNumber class]) {
        if ([value isKindOfClass:[NSNumber class]]) {
            NSDecimalNumber* num = (NSDecimalNumber *)value;
            ((void (*)(id, SEL, NSDecimalNumber*))(void *) objc_msgSend)((id)model,setter, num);
        }
    }
    else if ([propertyInfo.cls class] == [NSData class]) {
        if ([value isKindOfClass:[NSData class]]) {
            NSData *data = ((NSData *)value).copy;
            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,setter, data);
        } else if ([value isKindOfClass:[NSString class]]) {
            NSData *data = [(NSString *)value dataUsingEncoding:NSUTF8StringEncoding];
            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,setter, data);
        }
    }
    else if ([propertyInfo.cls class] == [NSMutableData class]) {
        if ([value isKindOfClass:[NSData class]]) {
            NSMutableData *data = ((NSData *)value).mutableCopy;
            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,setter, data);
        } else if ([value isKindOfClass:[NSString class]]) {
            NSData *data = [(NSString *)value dataUsingEncoding:NSUTF8StringEncoding];
            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,setter, data);
        }
    }
    else if ([propertyInfo.cls class] == [NSDate class]) {
        if ([value isKindOfClass:[NSDate class]]) {
            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,setter, value);
        } else if ([value isKindOfClass:[NSString class]]) {
            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,setter,LWNSDateFromString(value));
        } else {
            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,setter,LWNSDateFromString([NSString stringWithFormat:@"%@",value]));
        }
    }
    else if ([propertyInfo.cls class] == [NSURL class]) {
        NSURL* URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",(NSString *)value]];
        ((void (*)(id, SEL, NSURL *))(void *) objc_msgSend)((id)model,setter, URL);
    }
    else if ([propertyInfo.cls class] == [NSArray class]) {
        NSArray* array = (NSArray *)value;
        ((void (*)(id, SEL, NSArray *))(void *) objc_msgSend)((id)model,setter, array);
    }
    else if ([propertyInfo.cls class] == [NSMutableArray class]) {
        NSMutableArray* mutableArray = [[NSMutableArray alloc] initWithArray:(NSArray *)value];
        ((void (*)(id, SEL, NSArray *))(void *) objc_msgSend)((id)model,setter, mutableArray);
    }
    else if ([propertyInfo.cls class] == [NSDictionary class]) {
        NSDictionary* dictionary = (NSDictionary *)value;
        ((void (*)(id, SEL, NSDictionary *))(void *) objc_msgSend)((id)model,setter, dictionary);
    }
    else if ([propertyInfo.cls class] == [NSMutableDictionary class]) {
        NSMutableDictionary* mutableDict = [[NSMutableDictionary alloc] initWithDictionary:(NSDictionary *)value];
        ((void (*)(id, SEL, NSMutableDictionary *))(void *) objc_msgSend)((id)model,setter, mutableDict);
    }
    else if ([propertyInfo.cls class] == [NSSet class]) {
        NSSet* set = (NSSet *)value;
        ((void (*)(id, SEL, NSSet *))(void *) objc_msgSend)((id)model,setter, set);
    }
    else if ([propertyInfo.cls class] == [NSMutableSet class]) {
        NSMutableSet* mutableSet = [[NSMutableSet alloc] initWithSet:(NSSet *)value];
        ((void (*)(id, SEL, NSMutableSet *))(void *) objc_msgSend)((id)model,setter, mutableSet);
    }
    else {
        SEL setter = NSSelectorFromString(propertyInfo.setter);
        if (isNull) {
            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,setter, (id)nil);
        } else if ([value isKindOfClass:propertyInfo.cls]) {
            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,setter, (id)value);
        }
    }
}

static NSDate* LWNSDateFromString(__unsafe_unretained NSString *string) {
    NSTimeInterval timeInterval = [string floatValue];
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    return date;
}

static  Class LWNSBlockClass() {
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


@end
