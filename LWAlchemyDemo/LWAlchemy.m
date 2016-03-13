//
//  NSObject+Model.m
//  LWAlchemyDemo
//
//  Created by 刘微 on 16/1/20.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import "LWAlchemy.h"
#import <objc/runtime.h>
#import "LWAlchemyPropertyInfo.h"



@interface LWAlchemy ()

@property (nonatomic,strong) NSDictionary* map;

@end


@implementation LWAlchemy:NSObject

- (id)initWithJSON:(id)JSON JSONKeyPathsByPropertyKey:(NSDictionary *)map{
    self = [super init];
    if (self) {
        self.map = map;
        NSDictionary* dic = [self _dictionaryWithJSON:JSON];
        self = [self _modelWithDictionary:dic];
    }
    return self;
}

- (instancetype)_modelWithDictionary:(NSDictionary *)dictionary {
    if (!dictionary || dictionary == (id)kCFNull) return nil;
    if (![dictionary isKindOfClass:[NSDictionary class]]) return nil;
    [self _enumeratePropertiesUsingBlock:^(objc_property_t property, BOOL *stop) {
        LWAlchemyPropertyInfo* propertyInfo = [[LWAlchemyPropertyInfo alloc] init];
        unsigned int attrCount;
        objc_property_attribute_t* attributes = property_copyAttributeList(property, &attrCount);
        for (unsigned int i = 0; i < attrCount; i++) {
            switch (attributes[i].name[0]) {
                    //类型属性
                case 'T': {
                    if (attributes[i].value) {
                        propertyInfo.type = _getPropertyType(attributes[i].value);
                        if (propertyInfo.type == LWTypeObject) {
                            size_t len = strlen(attributes[i].value);
                            if (len > 3) {
                                char name[len - 2];
                                name[len - 3] = '\0';
                                memcpy(name, attributes[i].value + 2, len - 3);
                                propertyInfo.cls = objc_getClass(name);
                            }
                        }
                    }
                } break;
                    //实例对象属性
                case 'V': {
                    if (attributes[i].value) {
                        propertyInfo.ivarName = [NSString stringWithUTF8String:attributes[i].value];
                    }
                } break;
                default:break;
            }
        }
        if (propertyInfo.type == LWTypeObject) {
            Ivar ivar = class_getInstanceVariable([self class],[propertyInfo.ivarName UTF8String]);
            NSString* propertyName = @(property_getName(property));
            NSString* mapKey = self.map[propertyName];
            id object = dictionary[mapKey];
            if ([propertyInfo.cls class] == [NSString class]) {
                object_setIvar(self, ivar, [NSString stringWithFormat:@"%@",object]);
            }
            else if ([propertyInfo.cls class] == [NSURL class]) {
                object_setIvar(self, ivar, [NSURL URLWithString:[NSString stringWithFormat:@"%@",object]]);
            }
        }
        
    }];
    return self;
}


static LWType _getPropertyType(const char* type) {
    size_t len = strlen(type);
    if (len == 0) return LWTypeUnkonw;
    switch (*type) {
        case 'v': return LWTypeBasic;
        case 'B': return LWTypeBasic;
        case 'c': return LWTypeBasic;
        case 'C': return LWTypeBasic;
        case 's': return LWTypeBasic;
        case 'S': return LWTypeBasic;
        case 'i': return LWTypeBasic;
        case 'I': return LWTypeBasic;
        case 'l': return LWTypeBasic;
        case 'L': return LWTypeBasic;
        case 'q': return LWTypeBasic;
        case 'Q': return LWTypeBasic;
        case 'f': return LWTypeBasic;
        case 'd': return LWTypeBasic;
        case 'D': return LWTypeBasic;
        case '#': return LWTypeBasic;
        case ':': return LWTypeBasic;
        case '*': return LWTypeBasic;
        case '^': return LWTypeBasic;
        case '[': return LWTypeBasic;
        case '(': return LWTypeBasic;
        case '{': return LWTypeBasic;
        case '@': {
            if (len == 2 && *(type + 1) == '?')
                return LWTypeBlock;
            else
                return LWTypeObject;
        }
        default: return LWTypeUnkonw;
    }
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
        cls = cls.superclass;
        if (properties == NULL) continue;
        for (unsigned i = 0; i < count; i++) {
            block(properties[i], &stop);
            if (stop) break;
        }
    }
}


//- (instancetype)_modelWithDictionary:(NSDictionary *)dictionary {
//    if (!dictionary || dictionary == (id)kCFNull) return nil;
//    if (![dictionary isKindOfClass:[NSDictionary class]]) return nil;
//    [self _enumeratePropertiesUsingBlock:^(objc_property_t property, BOOL *stop) {
//        NSString* attributes = [NSString stringWithUTF8String:property_getAttributes(property)];
//        NSArray* components = [attributes componentsSeparatedByString:@","];
//        LWAlchemyPropertyInfo* propertyInfo = [[LWAlchemyPropertyInfo alloc] init];
//        for (NSString* string in components) {
//            //类型
//            if ([[string substringToIndex:1] isEqualToString:@"T"]) {
//                NSString* typeString = [string substringWithRange:NSMakeRange(1, string.length -1)];
//                NSString* type = [typeString substringToIndex:1];
//                propertyInfo.type = _getPropertyType([type UTF8String]);
//                if (propertyInfo.type == LWTypeObject) {
//                    size_t len = strlen([typeString UTF8String]);
//                    if (len > 3) {
//                        char name[len - 2];
//                        name[len - 3] = '\0';
//                        memcpy(name, [typeString UTF8String] + 2, len - 3);
//                        propertyInfo.cls = objc_getClass(name);
//                    }
//                }
//            }
//            else if ([[string substringToIndex:1] isEqualToString:@"V"]){
//                NSString* ivarNameString = [string substringWithRange:NSMakeRange(1, string.length - 1)];
//                if (ivarNameString) {
//                    propertyInfo.ivarName = ivarNameString;
//                }
//            }
//        }
//        if (propertyInfo.type == LWTypeObject) {
//            Ivar ivar = class_getInstanceVariable([self class],[propertyInfo.ivarName UTF8String]);
//            id varObj = [[propertyInfo.cls alloc] init];
//
//            NSString* propertyName = @(property_getName(property));
//            NSString* mapKey = self.map[propertyName];
//            id object = dictionary[mapKey];
//            NSLog(@"%@",object);
//
//
//            object_setIvar(self, ivar, object);
//        }
//
//    }];
//    return self;
//}

@end
