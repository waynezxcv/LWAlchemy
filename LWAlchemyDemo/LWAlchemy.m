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

@interface LWAlchemy ()
@property (nonatomic,strong) NSDictionary* mapDict;
@end


@implementation LWAlchemy:NSObject

- (id)initWithJSON:(id)JSON JSONKeyPathsByPropertyKey:(NSDictionary *)mapDict{
    self = [super init];
    if (self) {
        self.mapDict = mapDict;
        NSDictionary* dic = [self _dictionaryWithJSON:JSON];
        self = [self _modelWithDictionary:dic];
    }
    return self;
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
    while (!stop && ![cls isEqual:[LWAlchemy class]]) {
        unsigned count = 0;
        objc_property_t* properties = class_copyPropertyList(cls, &count);
        if (properties) {
            cls = cls.superclass;
            if (properties == NULL) continue;
            for (unsigned i = 0; i < count; i++) {
                block(properties[i], &stop);
                if (stop) break;
            }
            free(properties);
        }
    }
}


- (instancetype)_modelWithDictionary:(NSDictionary *)dictionary {
    if (!dictionary || dictionary == (id)kCFNull) return nil;
    if (![dictionary isKindOfClass:[NSDictionary class]]) return nil;
    [self _enumeratePropertiesUsingBlock:^(objc_property_t property, BOOL *stop) {
        LWAlchemyPropertyInfo* propertyInfo = [[LWAlchemyPropertyInfo alloc] initWithProperty:property];
        NSString* mapKey = self.mapDict[propertyInfo.propertyName];
        id object = dictionary[mapKey];
        _SetPropertyValue(self,propertyInfo,object);
    }];
    return self;
}



static void _SetPropertyValue(__unsafe_unretained id model,
                              __unsafe_unretained LWAlchemyPropertyInfo* propertyInfo,
                              __unsafe_unretained id value) {
    switch (propertyInfo.type) {
        case LWTypeUnkonw: {
        }break;
        case LWTypeVoid: {
        }break;
        case LWTypeBool: {
            NSNumber* num = (NSNumber *)value;
            SEL setter = NSSelectorFromString(propertyInfo.setter);
            ((void (*)(id, SEL, bool))(void *) objc_msgSend)((id)model, setter, num.boolValue);
        }break;
        case LWTypeInt8:{
            NSNumber* num = (NSNumber *)value;
            SEL setter = NSSelectorFromString(propertyInfo.setter);
            ((void (*)(id, SEL, uint8_t))(void *) objc_msgSend)((id)model,setter, (int8_t)num.charValue);
        }break;
        case LWTypeUInt8: {
            NSNumber* num = (NSNumber *)value;
            SEL setter = NSSelectorFromString(propertyInfo.setter);
            ((void (*)(id, SEL, uint8_t))(void *) objc_msgSend)((id)model,setter, (uint8_t)num.unsignedCharValue);
        }break;
        case LWTypeInt16: {
            NSNumber* num = (NSNumber *)value;
            SEL setter = NSSelectorFromString(propertyInfo.setter);
            ((void (*)(id, SEL, int16_t))(void *) objc_msgSend)((id)model,setter, (int16_t)num.shortValue);
        }break;
        case LWTypeUInt16: {
            NSNumber* num = (NSNumber *)value;
            SEL setter = NSSelectorFromString(propertyInfo.setter);
            ((void (*)(id, SEL, uint16_t))(void *) objc_msgSend)((id)model,setter, (uint16_t)num.unsignedShortValue);
        }break;
        case LWTypeInt32: {
            NSNumber* num = (NSNumber *)value;
            SEL setter = NSSelectorFromString(propertyInfo.setter);
            ((void (*)(id, SEL, int32_t))(void *) objc_msgSend)((id)model,setter, (int32_t)num.intValue);
        }break;
        case LWTypeUInt32: {
            NSNumber* num = (NSNumber *)value;
            SEL setter = NSSelectorFromString(propertyInfo.setter);
            ((void (*)(id, SEL, uint32_t))(void *) objc_msgSend)((id)model,setter, (uint32_t)num.unsignedIntValue);
        }break;
        case LWTypeInt64: {
            if ([value isKindOfClass:[NSDecimalNumber class]]) {
                NSDecimalNumber* num = (NSDecimalNumber *)value;
                SEL setter = NSSelectorFromString(propertyInfo.setter);
                ((void (*)(id, SEL, int64_t))(void *) objc_msgSend)((id)model,setter, (int64_t)num.stringValue.longLongValue);
            } else {
                NSNumber* num = (NSNumber *)value;
                SEL setter = NSSelectorFromString(propertyInfo.setter);
                ((void (*)(id, SEL, uint64_t))(void *) objc_msgSend)((id)model,setter, (uint64_t)num.longLongValue);
            }
        }break;
        case LWTypeUInt64:{
            if ([value isKindOfClass:[NSDecimalNumber class]]) {
                NSDecimalNumber* num = (NSDecimalNumber *)value;
                SEL setter = NSSelectorFromString(propertyInfo.setter);
                ((void (*)(id, SEL, int64_t))(void *) objc_msgSend)((id)model,setter, (int64_t)num.stringValue.longLongValue);
            } else {
                NSNumber* num = (NSNumber *)value;
                SEL setter = NSSelectorFromString(propertyInfo.setter);
                ((void (*)(id, SEL, uint64_t))(void *) objc_msgSend)((id)model,setter, (uint64_t)num.longLongValue);
            }
        }break;
        case LWTypeFloat: {
            NSNumber* num = (NSNumber *)value;
            SEL setter = NSSelectorFromString(propertyInfo.setter);
            float f = num.floatValue;
            if (isnan(f) || isinf(f)) f = 0;
            ((void (*)(id, SEL, float))(void *) objc_msgSend)((id)model,setter, f);
        }break;

        case LWTypeDouble:{
            NSNumber* num = (NSNumber *)value;
            SEL setter = NSSelectorFromString(propertyInfo.setter);
            double d = num.doubleValue;
            if (isnan(d) || isinf(d)) d = 0;
            ((void (*)(id, SEL, double))(void *) objc_msgSend)((id)model,setter, d);
        }break;
        case LWTypeLongDouble: {
            NSNumber* num = (NSNumber *)value;
            SEL setter = NSSelectorFromString(propertyInfo.setter);
            long double d = num.doubleValue;
            if (isnan(d) || isinf(d)) d = 0;
            ((void (*)(id, SEL, long double))(void *) objc_msgSend)((id)model,setter, (long double)d);
        }break;
        case LWTypeSEL: {
        }break;
        case LWTypeCFString: {
        }break;
        case LWTypePointer: {
        }break;
        case LWTypeUnion: {
        }break;
        case LWTypeStruct: {

        }break;
        case LWTypeObject: {
            if ([propertyInfo.cls class] == [NSString class]) {
                NSString* string = [NSString stringWithFormat:@"%@",(NSString *)value];
                SEL setter = NSSelectorFromString(propertyInfo.setter);
                ((void (*)(id, SEL, NSString*))(void *) objc_msgSend)((id)model,setter,string);
            }
            else if ([propertyInfo.cls class] == [NSMutableString class]) {
                NSMutableString* mutableString = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@",value]];;
                SEL setter = NSSelectorFromString(propertyInfo.setter);
                ((void (*)(id, SEL, NSMutableString*))(void *) objc_msgSend)((id)model,setter, mutableString);
            }
            else if ([propertyInfo.cls class] == [NSValue class]) {

            }
            else if ([propertyInfo.cls class] == [NSNumber class]) {
                if ([value isKindOfClass:[NSNumber class]]) {
                    NSNumber* num = (NSNumber *)value;
                    SEL setter = NSSelectorFromString(propertyInfo.setter);
                    ((void (*)(id, SEL, NSNumber*))(void *) objc_msgSend)((id)model,setter, num);
                }
            }
            else if ([propertyInfo.cls class] == [NSDecimalNumber class]) {
                if ([value isKindOfClass:[NSNumber class]]) {
                    NSDecimalNumber* num = (NSDecimalNumber *)value;
                    SEL setter = NSSelectorFromString(propertyInfo.setter);
                    ((void (*)(id, SEL, NSDecimalNumber*))(void *) objc_msgSend)((id)model,setter, num);
                }
            }
            else if ([propertyInfo.cls class] == [NSData class]) {
            }
            else if ([propertyInfo.cls class] == [NSMutableData class]) {
            }
            else if ([propertyInfo.cls class] == [NSDate class]) {
            }
            else if ([propertyInfo.cls class] == [NSURL class]) {
                NSURL* URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",(NSString *)value]];
                SEL setter = NSSelectorFromString(propertyInfo.setter);
                ((void (*)(id, SEL, NSURL *))(void *) objc_msgSend)((id)model,setter, URL);
            }
            else if ([propertyInfo.cls class] == [NSArray class]) {
                NSArray* array = (NSArray *)value;
                SEL setter = NSSelectorFromString(propertyInfo.setter);
                ((void (*)(id, SEL, NSArray *))(void *) objc_msgSend)((id)model,setter, array);
            }
            else if ([propertyInfo.cls class] == [NSMutableArray class]) {
                NSMutableArray* mutableArray = [[NSMutableArray alloc] initWithArray:(NSArray *)value];
                SEL setter = NSSelectorFromString(propertyInfo.setter);
                ((void (*)(id, SEL, NSArray *))(void *) objc_msgSend)((id)model,setter, mutableArray);
            }
            else if ([propertyInfo.cls class] == [NSDictionary class]) {
                NSDictionary* dictionary = (NSDictionary *)value;
                SEL setter = NSSelectorFromString(propertyInfo.setter);
                ((void (*)(id, SEL, NSDictionary *))(void *) objc_msgSend)((id)model,setter, dictionary);
            }
            else if ([propertyInfo.cls class] == [NSMutableDictionary class]) {
                NSMutableDictionary* mutableDict = [[NSMutableDictionary alloc] initWithDictionary:(NSDictionary *)value];
                SEL setter = NSSelectorFromString(propertyInfo.setter);
                ((void (*)(id, SEL, NSMutableDictionary *))(void *) objc_msgSend)((id)model,setter, mutableDict);
            }
            else if ([propertyInfo.cls class] == [NSSet class]) {
                NSSet* set = (NSSet *)value;
                SEL setter = NSSelectorFromString(propertyInfo.setter);
                ((void (*)(id, SEL, NSSet *))(void *) objc_msgSend)((id)model,setter, set);
            }
            else if ([propertyInfo.cls class] == [NSMutableSet class]) {
                NSMutableSet* mutableSet = [[NSMutableSet alloc] initWithSet:(NSSet *)value];
                SEL setter = NSSelectorFromString(propertyInfo.setter);
                ((void (*)(id, SEL, NSMutableSet *))(void *) objc_msgSend)((id)model,setter, mutableSet);
            }
        }break;
        case LWTypeBlock: {
        }break;
        default:
            break;
    }
}


@end
