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




#import "NSObject+Maping.h"
#import <CoreData/CoreData.h>
#import "LWProperty.h"
#import "LWRuntimeHelper.h"


static void* LWAlechmyCachedPropertyKeysKey = &LWAlechmyCachedPropertyKeysKey;
static void* LWAlechmyMapDictionaryKey = &LWAlechmyMapDictionaryKey;

@implementation NSObject(Maping)

#pragma mark - Propertyies Cache

+ (NSSet *)propertysSet {
    
    //将一个类的属性列表缓存起来，避免多次处理同一个类时，重复遍历
    NSSet* cachedKeys = objc_getAssociatedObject(self, LWAlechmyCachedPropertyKeysKey);
    if (cachedKeys != nil) {
        return cachedKeys;
    }
    
    NSMutableSet* propertysSet = [NSMutableSet set];
    [LWRuntimeHelper lw_enumerateClassProperties:[self class] usingBlock:^(objc_property_t property, BOOL *stop) {
        LWProperty* theProperty = [[LWProperty alloc] initWithProperty:property mapper:[self mapper]];
        
        if (theProperty.authorityAttribute != LWPropertyAuthorityAttributeReadOnly) {//不处理readonly的属性
            [propertysSet addObject:theProperty];
        }
    }];
    
    objc_setAssociatedObject(self,LWAlechmyCachedPropertyKeysKey, propertysSet, OBJC_ASSOCIATION_COPY);
    return propertysSet;
}


#pragma mark - Public

+ (id)modelWithJSON:(id)json {
    
    NSObject* model = [[self alloc] init];
    if (model) {
        if (![json isKindOfClass:[NSDictionary class]]) {
            NSDictionary* dic = [model dictionaryWithJSON:json];
            model = [model modelWithDictionary:dic];
        } else {
            model = [model modelWithDictionary:json];
        }
    }
    return model;
}


+ (id)entityWithJSON:(id)json context:(NSManagedObjectContext *)context {
    if ([self isSubclassOfClass:[NSManagedObject class]] && context) {
        NSManagedObject* model = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self)
                                                               inManagedObjectContext:context];
        if (model) {
            if (![json isKindOfClass:[NSDictionary class]]) {
                NSDictionary* dic = [model dictionaryWithJSON:json];
                model = [model entity:model modelWithDictionary:dic context:context];
            } else {
                model = [model entity:model modelWithDictionary:json context:context];
            }
        }
        return model;
    }
    return [self modelWithJSON:json];
}

- (NSDictionary *)dictionaryWithJSON:(id)json {
    
    if (!json || json == (id)kCFNull) {
        return nil;
    }
    
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


- (instancetype)modelWithDictionary:(NSDictionary *)dictionary {
    
    if (!dictionary || dictionary == (id)kCFNull) {
        return nil;
    }
    
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    NSSet* propertysSet = self.class.propertysSet;
    
    [propertysSet enumerateObjectsUsingBlock:^(LWProperty* property, BOOL * _Nonnull stop) {
        id value = nil;
        
        NSDictionary* tmp = [dictionary copy];
        for (NSInteger i = 0; i < property.mapperName.count; i ++) {
            NSString* mapperName = property.mapperName[i];
            value = tmp[mapperName];
            if ([value isKindOfClass:[NSDictionary class]]) {
                tmp = value;
            }
        }
        
        if (value != nil && ![value isEqual:[NSNull null]]) {
            
            //非动态合成setter和getter方法使用objc_msgSend方法调用setter，否则使用KVC
            if (property.dynamicAttribute != LWPropertyIvarAttributeDynamic) {
                [self _setPropertyValueWithMsgSend:property value:value];
            } else {
                [self setValue:value forKey:property.name];
            }
        }
    }];
    return self;
}

- (instancetype)entity:(NSManagedObject *)object
   modelWithDictionary:(NSDictionary *)dictionary
               context:(NSManagedObjectContext *)contxt {
    
    if (!dictionary || dictionary == (id)kCFNull){
        return nil;
    }
    
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    NSSet* propertysSet = self.class.propertysSet;
    [propertysSet enumerateObjectsUsingBlock:^(LWProperty* property, BOOL * _Nonnull stop) {
        id value = nil;
        
        NSDictionary* tmp = [dictionary copy];
        for (NSInteger i = 0; i < property.mapperName.count; i ++) {
            NSString* mapperName = property.mapperName[i];
            value = tmp[mapperName];
            if ([value isKindOfClass:[NSDictionary class]]) {
                tmp = value;
            }
        }
        
        if (value != nil && ![value isEqual:[NSNull null]]) {
            [self _setNSManagedObjectSubclassPropertyValueWithKVC:object
                                                         property:property
                                                            value:value
                                                          context:contxt];
        }
    }];
    return self;
}

#pragma mark - set propertyies value

- (void)_setPropertyValueWithMsgSend:(LWProperty *)property value:(id)value {
    
    //根据属性的setter方法创建选择子，然后通过指向objc_msgSend函数的指针来调用setter方法
    
    SEL setterSel = NSSelectorFromString(property.setterName);
    BOOL isNull = (value == (id)kCFNull);
    
    switch (property.type) {
            
            //基础数据类型
        case LWTypeBool :{
            void (*msgSendPtr) (id,SEL,BOOL) = (void(*)(id,SEL,BOOL))objc_msgSend;
            msgSendPtr(self,setterSel,_NSNumberTypeFromIdType(value).boolValue);
            
        }break;
            
        case LWTypeInt8: {
            void (*msgSendPtr) (id,SEL,int8_t) = (void(*)(id,SEL,int8_t))objc_msgSend;
            msgSendPtr(self,setterSel,_NSNumberTypeFromIdType(value).charValue);
        }break;
            
        case LWTypeUInt8: {
            void (*msgSendPtr) (id,SEL,uint8_t) = (void(*)(id,SEL,uint8_t))objc_msgSend;
            msgSendPtr(self,setterSel,_NSNumberTypeFromIdType(value).unsignedCharValue);
        }break;
            
            
        case LWTypeInt16: {
            void (*msgSendPtr) (id,SEL,int16_t) = (void(*)(id,SEL,int16_t))objc_msgSend;
            msgSendPtr(self,setterSel,_NSNumberTypeFromIdType(value).shortValue);
        }break;
            
        case LWTypeUInt16: {
            
            void (*msgSendPtr) (id,SEL,uint16_t) = (void(*)(id,SEL,uint16_t))objc_msgSend;
            msgSendPtr(self,setterSel,_NSNumberTypeFromIdType(value).unsignedShortValue);
            
        }break;
            
        case LWTypeInt32: {
            void (*msgSendPtr) (id,SEL,int32_t) = (void(*)(id,SEL,int32_t))objc_msgSend;
            msgSendPtr(self,setterSel,_NSNumberTypeFromIdType(value).intValue);
        }break;
            
            
        case LWTypeUInt32: {
            void (*msgSendPtr) (id,SEL,uint32_t) = (void(*)(id,SEL,uint32_t))objc_msgSend;
            msgSendPtr(self,setterSel,_NSNumberTypeFromIdType(value).unsignedIntValue);
        }break;
            
            
        case LWTypeInt64: {
            if ([value isKindOfClass:[NSDecimalNumber class]]) {
                void (*msgSendPtr) (id,SEL,int64_t) = (void(*)(id,SEL,int64_t))objc_msgSend;
                msgSendPtr(self,setterSel,_NSNumberTypeFromIdType(value).stringValue.longLongValue);
            } else {
                void (*msgSendPtr) (id,SEL,int64_t) = (void(*)(id,SEL,int64_t))objc_msgSend;
                msgSendPtr(self,setterSel,_NSNumberTypeFromIdType(value).longLongValue);
            }
        }break;
            
            
        case LWTypeUInt64: {
            if ([value isKindOfClass:[NSDecimalNumber class]]) {
                void (*msgSendPtr) (id,SEL,uint64_t) = (void(*)(id,SEL,uint64_t))objc_msgSend;
                msgSendPtr(self,setterSel,_NSNumberTypeFromIdType(value).stringValue.longLongValue);
            } else {
                void (*msgSendPtr) (id,SEL,uint64_t) = (void(*)(id,SEL,uint64_t))objc_msgSend;
                msgSendPtr(self,setterSel,_NSNumberTypeFromIdType(value).longLongValue);
            }
        }break;
            
            
        case LWTypeFloat: {
            float f = _NSNumberTypeFromIdType(value).floatValue;
            if (isnan(f) || isinf(f)) {
                f = 0.0f;
            }
            void (*msgSendPtr) (id,SEL,float) = (void(*)(id,SEL,float))objc_msgSend;
            msgSendPtr(self,setterSel,f);
            
        }break;
            
            
        case LWTypeLongDouble: {
            
            double d = _NSNumberTypeFromIdType(value).floatValue;
            if (isnan(d) || isinf(d)) {
                d = 0;
            }
            void (*msgSendPtr) (id,SEL,double) = (void(*)(id,SEL,double))objc_msgSend;
            msgSendPtr(self,setterSel,d);
        }break;
            
            
            //C语言类型
        case LWTypeClass: {
            if (isNull) {
                void (*msgSendPtr) (id, SEL,Class) = (void (*)(id, SEL,Class))objc_msgSend;
                msgSendPtr((id)self, setterSel,(Class)NULL);
                
            } else {
                
                if ([value isKindOfClass:[NSString class]]) {
                    Class cls = NSClassFromString(value);
                    if (cls) {
                        void (*msgSendPtr) (id, SEL,Class) = (void (*)(id, SEL,Class))objc_msgSend;
                        msgSendPtr(self, setterSel,(Class)cls);
                    }
                    
                } else {
                    
                    Class cls = object_getClass(value);
                    if (cls) {
                        if (class_isMetaClass(cls)) {
                            void (*msgSendPtr) (id, SEL,Class) = (void (*)(id, SEL,Class))objc_msgSend;
                            msgSendPtr(self, setterSel,(Class)value);
                        } else {
                            void (*msgSendPtr) (id, SEL,Class) = (void (*)(id, SEL,Class))objc_msgSend;
                            msgSendPtr(self, setterSel,(Class)cls);
                        }
                    }
                }
            }
        }break;
            
        case LWTypeSelector: {
            if (isNull) {
                void (*msgSendPtr)(id, SEL,SEL) = (void (*)(id, SEL,SEL))objc_msgSend;
                msgSendPtr(self,setterSel,(SEL)NULL);
            } else if ([value isKindOfClass:[NSString class]]) {
                SEL theSel = NSSelectorFromString(value);
                if (theSel) {
                    void (*msgSendPtr)(id, SEL,SEL) = (void (*)(id, SEL,SEL))objc_msgSend;
                    msgSendPtr(self,setterSel,theSel);
                }
            }
        }break;
            
        case LWTypePointer:
        case LWTypeCString: {
            
            if (isNull) {
                void (*msgSendPtr)(id, SEL,void*) = (void (*)(id, SEL,void*))objc_msgSend;
                msgSendPtr(self, setterSel, (void *)NULL);
                
            } else if ([value isKindOfClass:[NSValue class]]) {
                NSValue* nsValue = value;
                if (nsValue.objCType && strcmp(nsValue.objCType, "^v") == 0) {
                    void (*msgSendPtr) (id, SEL, void*) = (void (*)(id, SEL, void*))objc_msgSend;
                    msgSendPtr(self, setterSel,nsValue.pointerValue);
                }
            }
        }break;
            
        case LWTypeCArray:
        case LWTypeCUnion:
        case LWTypeCStruct:
        case LWTypeCBitField:{
            
            if ([value isKindOfClass:[NSValue class]]) {
                const char* valueType = ((NSValue *)value).objCType;
                Ivar ivar = class_getInstanceVariable([property.cls class],[property.ivarName UTF8String]);
                const char* metaType = ivar_getTypeEncoding(ivar);
                if (valueType && metaType && strcmp(valueType, metaType) == 0) {
                    [self setValue:value forKey:property.name];
                }
            }break;
            
        }break;
            
            
            //OBJC对象类型
        case LWTypeBlock: {
            if (isNull) {
                void (*msgSendPtr)(id, SEL, void (^)()) = (void (*)(id, SEL, void (^)()))objc_msgSend;
                msgSendPtr(self, setterSel, (void (^)())NULL);
                
            } else if ([value isKindOfClass:_NSBlockClass()]) {
                void (*msgSendPtr)(id, SEL, void (^)()) = (void (*)(id, SEL, void (^)()))objc_msgSend;
                msgSendPtr(self, setterSel,(void (^)())value);
            }
        }break;
            
            
        case LWTypeID: {
            void (*msgSendPtr)(id, SEL,id) = (void (*)(id, SEL,id))objc_msgSend;
            msgSendPtr(self, setterSel,(id)value);
            
        }break;
            
        case LWTypeNSString: {
            void (*msgSendPtr)(id, SEL,NSString*) = (void (*)(id, SEL,NSString*))objc_msgSend;
            msgSendPtr(self, setterSel,[NSString stringWithFormat:@"%@",value]);
        }break;
            
        case LWTypeNSMutableString: {
            void (*msgSendPtr)(id, SEL,NSMutableString*) = (void (*)(id, SEL,NSMutableString*))objc_msgSend;
            msgSendPtr(self, setterSel,[[NSString stringWithFormat:@"%@",value] mutableCopy]);
        }break;
            
        case LWTypeNSValue: {
            void (*msgSendPtr)(id, SEL,NSValue*) = (void (*)(id, SEL,NSValue*))objc_msgSend;
            msgSendPtr(self, setterSel,value);
        }break;
            
        case LWTypeNSNumber: {
            if ([value isKindOfClass:[NSNumber class]]) {
                void (*msgSendPtr)(id, SEL,NSNumber*) = (void (*)(id, SEL,NSNumber*))objc_msgSend;
                msgSendPtr(self, setterSel, value);
            } else {
                void (*msgSendPtr)(id,SEL,NSNumber*) = (void (*)(id, SEL,NSNumber*))objc_msgSend;
                msgSendPtr(self, setterSel, _NSNumberTypeFromIdType(value));
            }
        }break;
            
        case LWTypeNSDecimalNumber: {
            if ([value isKindOfClass:[NSDecimalNumber class]]) {
                void (*msgSendPtr)(id, SEL,NSDecimalNumber*) = (void (*)(id, SEL,NSDecimalNumber*))objc_msgSend;
                msgSendPtr(self, setterSel, value);
            }
        }break;
            
            
        case LWTypeNSData: {
            if ([value isKindOfClass:[NSData class]]) {
                NSData* data = ((NSData *)value).copy;
                void (*msgSendPtr)(id, SEL,NSData*) = (void (*)(id, SEL,NSData*))objc_msgSend;
                msgSendPtr(self, setterSel, data);
            } else if ([value isKindOfClass:[NSString class]]) {
                NSData* data = [(NSString *)value dataUsingEncoding:NSUTF8StringEncoding];
                void (*msgSendPtr)(id, SEL,NSData*) = (void (*)(id, SEL,NSData*))objc_msgSend;
                msgSendPtr(self, setterSel, data);
            }
        }break;
            
            
        case LWTypeNSMutableData: {
            if ([value isKindOfClass:[NSData class]]) {
                NSMutableData* data = ((NSData *)value).mutableCopy;
                void (*msgSendPtr)(id, SEL,NSMutableData*) = (void (*)(id, SEL,NSMutableData*))objc_msgSend;
                msgSendPtr(self, setterSel, data);
            } else if ([value isKindOfClass:[NSString class]]) {
                NSMutableData* data = [(NSString *)value dataUsingEncoding:NSUTF8StringEncoding].mutableCopy;
                void (*msgSendPtr)(id, SEL,NSMutableData*) = (void (*)(id, SEL,NSMutableData*))objc_msgSend;
                msgSendPtr(self, setterSel, data);
            }
        }break;
            
            
        case LWTypeNSDate: {
            if ([value isKindOfClass:[NSDate class]]) {
                void (*msgSendPtr)(id, SEL,NSDate*) = (void (*)(id, SEL,NSDate*))objc_msgSend;
                msgSendPtr(self, setterSel, value);
                
            } else if ([value isKindOfClass:[NSString class]]) {
                void (*msgSendPtr)(id, SEL,NSDate*) = (void (*)(id, SEL,NSDate*))objc_msgSend;
                msgSendPtr(self, setterSel, _NSDateFromString(value));
                
            } else {
                void (*msgSendPtr)(id, SEL,NSDate*) = ( void (*)(id, SEL,NSDate*))objc_msgSend;
                msgSendPtr(self, setterSel,_NSDateFromString([NSString stringWithFormat:@"%@",value]));
            }
        }break;
            
        case LWTypeNSURL: {
            NSURL* URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",(NSString *)value]];
            void (*msgSendPtr)(id, SEL,NSURL*) = (void (*)(id, SEL,NSURL*))objc_msgSend;
            msgSendPtr(self, setterSel,URL);
        }break;
            
            
        case LWTypeNSArray: {
            NSArray* array = (NSArray *)value;
            void (*msgSendPtr)(id, SEL,NSArray*) = (void (*)(id, SEL,NSArray*))objc_msgSend;
            msgSendPtr(self, setterSel,array);
        }break;
            
            
        case LWTypeNSMutableArray: {
            NSMutableArray* mutableArray = ((NSArray *)value).mutableCopy;
            void (*msgSendPtr)(id, SEL,NSArray*) = (void (*)(id, SEL,NSArray*))objc_msgSend;
            msgSendPtr(self, setterSel,mutableArray);
        }break;
            
            
        case LWTypeNSDictionary: {
            NSDictionary* dict = (NSDictionary *)value;
            void (*msgSendPtr)(id, SEL,NSDictionary*) = (void (*)(id, SEL,NSDictionary*))objc_msgSend;
            msgSendPtr(self, setterSel,dict);
        }break;
            
            
        case LWTypeNSMutableDictionary: {
            NSMutableDictionary* dict = [(NSDictionary *)value mutableCopy];
            void (*msgSendPtr)(id, SEL,NSMutableDictionary*) = (void (*)(id, SEL,NSMutableDictionary*))objc_msgSend;
            msgSendPtr(self, setterSel,dict);
        }break;
            
            
        case LWTypeNSSet: {
            NSSet* set = (NSSet *)value;
            void (*msgSendPtr)(id, SEL,NSSet*) = (void (*)(id, SEL,NSSet*))objc_msgSend;
            msgSendPtr(self, setterSel,set);
        }break;
            
            
        case LWTypeNSMutableSet: {
            NSMutableSet* set = [(NSMutableSet *)value mutableCopy];
            void (*msgSendPtr)(id, SEL,NSMutableSet*) = (void (*)(id, SEL,NSMutableSet*))objc_msgSend;
            msgSendPtr(self, setterSel,set);
        }break;
            
            
        case LWTypeCustomObject: {
            if (isNull) {
                void (*msgSendPtr)(id, SEL,id) = (void (*)(id, SEL,id))objc_msgSend;
                msgSendPtr(self, setterSel,(id)nil);
                
            } else if ([value isKindOfClass:property.cls]) {
                
                void (*msgSendPtr)(id, SEL,id) = (void(*)(id, SEL,id))objc_msgSend;
                msgSendPtr(self, setterSel,(id)value);
                
            } else if ([value isKindOfClass:[NSDictionary class]]) {
                
                NSObject* child = nil;
                if (property.getterName) {
                    SEL getter = NSSelectorFromString(property.getterName);
                    child = ((id (*)(id, SEL))(void *) objc_msgSend)(self,getter);
                }
                
                if (child) {
                    [child modelWithDictionary:value];
                } else {
                    Class cls = property.cls;
                    child = [cls new];
                    [child modelWithDictionary:value];
                    
                    SEL theSel = NSSelectorFromString(property.setterName);
                    void (*msgSendPtr)(id, SEL,id) = (void (*)(id, SEL,id))objc_msgSend;
                    msgSendPtr(self,theSel,child);
                    
                }
            }
            
        }break;
            
        case LWTypeVoid:
        case LWTypeUnkown:
        default:break;
    }
}


- (void)_setNSManagedObjectSubclassPropertyValueWithKVC:(NSManagedObject *)object
                                               property:(LWProperty *)property
                                                  value:(id)value
                                                context:(NSManagedObjectContext *)context {
    
    //由于NSManagedObject的子类的属性是@dynamic动态合成的，所以需要通过KVC来赋值
    
    switch (property.type) {
            
        case LWTypeNSDate: {
            NSDate* date = _NSDateFromString([NSString stringWithFormat:@"%@",value]);
            [object setValue:date forKey:property.name];
        }break;
            
            
        case LWTypeNSURL: {
            NSURL* URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",value]];
            [object setValue:URL forKey:property.name];
        }break;
            
            
        case LWTypeNSString:{
            [object setValue:[NSString stringWithFormat:@"%@",value] forKey:property.name];
        }break;
            
        case LWTypeNSNumber:{
            NSNumber* number = _NSNumberTypeFromIdType(value);
            [object setValue:number forKey:property.name];
        } break;
            
        case LWTypeNSDecimalNumber:
        case LWTypeNSMutableString:
        case LWTypeNSValue:
        case LWTypeNSData:
        case LWTypeNSMutableData:
        case LWTypeNSArray:
        case LWTypeNSMutableArray:
        case LWTypeNSDictionary:
        case LWTypeNSMutableDictionary:
        case LWTypeNSSet:
        case LWTypeNSMutableSet:
        case LWTypeID:{
            [object setValue:value forKey:property.name];
        }break;
            
        case LWTypeCustomObject: {
            if ([object isKindOfClass:[NSManagedObject class]] && property.cls) {
                Class cls = property.cls;
                NSManagedObject* one = [cls entityWithJSON:value context:context];
                [object setValue:one forKey:property.name];
            } else {
                [object setValue:value forKey:property.name];
            }
        }
        default:break;
    }
}


#pragma mark - Description

- (NSString *)lw_description {
    NSMutableString* des = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@",self]];
    NSSet* propertysSet = self.class.propertysSet;
    [propertysSet enumerateObjectsUsingBlock:^(LWProperty* property, BOOL * _Nonnull stop) {
        NSString* d = [NSString stringWithFormat:@"<%@(%@):%@>,\n",property.name,
                       [[self valueForKey:property.name] class],
                       [self valueForKey:property.name]];
        [des appendString:d];
    }];
    return des;
}

#pragma mark - Mapper

+ (NSDictionary *)mapper {
    return nil;
}


#pragma mark - Type Helper

static inline NSNumber* _NSNumberTypeFromIdType(__unsafe_unretained id value) {
    
    static NSCharacterSet* dot;
    static NSDictionary* dic;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        dot = [NSCharacterSet characterSetWithRange:NSMakeRange('.', 1)];
        dic = @{@"TRUE" : @(YES),
                @"True" : @(YES),
                @"true" : @(YES),
                @"FALSE" : @(NO),
                @"False" : @(NO),
                @"false" : @(NO),
                @"YES" : @(YES),
                @"Yes" : @(YES),
                @"yes" : @(YES),
                @"NO" : @(NO),
                @"No" : @(NO),
                @"no" : @(NO),
                @"NIL" : (id)kCFNull,
                @"Nil" : (id)kCFNull,
                @"nil" : (id)kCFNull,
                @"NULL" : (id)kCFNull,
                @"Null" : (id)kCFNull,
                @"null" : (id)kCFNull,
                @"(NULL)" : (id)kCFNull,
                @"(Null)" : (id)kCFNull,
                @"(null)" : (id)kCFNull,
                @"<NULL>" : (id)kCFNull,
                @"<Null>" : (id)kCFNull,
                @"<null>" : (id)kCFNull};
    });
    
    if (!value || value == (id)kCFNull) {
        return nil;
    }
    
    if ([value isKindOfClass:[NSNumber class]]) {
        return value;
    }
    
    if ([value isKindOfClass:[NSString class]]) {
        NSNumber* num = dic[value];
        if (num) {
            if (num == (id)kCFNull) return nil;
            return num;
        }
        
        if ([(NSString *)value rangeOfCharacterFromSet:dot].location != NSNotFound) {
            const char* cstring = ((NSString *)value).UTF8String;
            if (!cstring) return nil;
            double num = atof(cstring);
            if (isnan(num) || isinf(num)) return nil;
            return @(num);
        } else {
            const char* cstring = ((NSString *)value).UTF8String;
            if (!cstring) return nil;
            return @(atoll(cstring));
        }
    }
    return nil;
}


static inline NSDate* _NSDateFromString(__unsafe_unretained NSString *string) {
    NSTimeInterval timeInterval = [string floatValue];
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    return date;
}


static inline Class _NSBlockClass() {
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
