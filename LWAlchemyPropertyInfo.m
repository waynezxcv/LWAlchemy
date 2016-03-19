//
//  LWAlchemyPropertyInfo.m
//  WarmerApp
//
//  Created by 刘微 on 16/3/14.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "LWAlchemyPropertyInfo.h"


@interface LWAlchemyPropertyInfo ()

@property (nonatomic, assign) objc_property_t property;//属性
@property (nonatomic, strong) NSString* propertyName;//属性名称
@property (nonatomic, strong) NSString* ivarName;//实例对象名称
@property (nonatomic, assign) LWType type;//类型
@property (nonatomic, assign) Class cls;//如果是LWTypeObject类型，用来表示该对象所属的类,否则为nil
@property (nonatomic, strong) NSString* getter;//getter方法
@property (nonatomic, strong) NSString* setter;//setter方法
@property (nonatomic,assign,getter=isReadonly) BOOL readonly;//是否是只读属性
@property (nonatomic,assign,getter=isDynamic) BOOL dynamic;
@property (nonatomic,assign,getter=isIdType) BOOL idType;
@property (nonatomic,assign,getter=isNumberType) BOOL numberType;
@property (nonatomic,assign,getter=isObjectType) BOOL objectType;
@property (nonatomic,assign,getter=isFoundationType) BOOL foundationType;

@end

@implementation LWAlchemyPropertyInfo

- (id)initWithProperty:(objc_property_t)property {
    self = [super init];
    if (self) {
        self.readonly = NO;
        self.dynamic = NO;
        self.idType = NO;
        self.numberType = NO;
        self.objectType = NO;
        self.foundationType = NO;
        
        self.property = property;
        unsigned int attrCount;
        objc_property_attribute_t* attributes = property_copyAttributeList(property, &attrCount);
        for (unsigned int i = 0; i < attrCount; i++) {
            switch (attributes[i].name[0]) {
                    //类型属性
                case 'T': {
                    if (attributes[i].value) {
                        LWType type = _GetPropertyInfoType(self, attributes[i].value);
                        self.type = type;
                        if (self.type == LWTypeObject) {
                            self.cls = _GetPropertyInfoClass(attributes[i].value);
                            _IsObjectFoundationType(self.cls);
                        } else {
                            self.cls = nil;
                        }
                    }
                } break;
                    //实例对象属性
                case 'V': {
                    if (attributes[i].value) {
                        self.ivarName = [NSString stringWithUTF8String:attributes[i].value];
                    }
                } break;
                    //自定义的Getter方法
                case 'G': {
                    if (attributes[i].value) {
                        self.getter = [NSString stringWithUTF8String:attributes[i].value];
                    }
                } break;
                    //自定义的Setter方法
                case 'S': {
                    if (attributes[i].value) {
                        self.setter = [NSString stringWithUTF8String:attributes[i].value];
                    }
                }break;
                    //是否是只读属性
                case 'R': {
                    self.readonly = YES;
                } break;
                case 'D': {
                    self.dynamic = YES;
                } break;
                default:break;
            }
        }
        if (attributes) {
            free(attributes);
            attributes = NULL;
        }
        //propertyName
        self.propertyName =  @(property_getName(property));
        //setter & getter
        if (self.propertyName) {
            if (!self.getter) {
                self.getter = self.propertyName;
            }
            if (!self.setter) {
                self.setter = [NSString stringWithFormat:@"set%@%@:",
                               [self.propertyName substringToIndex:1].uppercaseString,
                               [self.propertyName substringFromIndex:1]];
            }
        }
    }
    return self;
}

- (void)setType:(LWType)type {
    _type = type;
    switch (_type) {
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
        case LWTypeLongDouble:self.numberType = YES;break;
        case LWTypeObject:self.objectType = YES;break;
        case LWTypeBlock:break;
        case LWTypeClass:break;
        case LWTypeUnkonw:break;
        case LWTypeVoid:break;
        case LWTypeCFString:break;
        case LWTypePointer:break;
        case LWTypeUnion:break;
        case LWTypeStruct:break;
        case LWTypeCFArray:break;
        case LWTypeSEL:break;
        default:break;
    }
}


static inline bool _IsObjectFoundationType(Class cls) {
    if (!cls) return NO;
    if ([cls isSubclassOfClass:[NSMutableString class]]) return YES;
    if ([cls isSubclassOfClass:[NSString class]]) return YES;
    if ([cls isSubclassOfClass:[NSDecimalNumber class]]) return YES;
    if ([cls isSubclassOfClass:[NSNumber class]]) return YES;
    if ([cls isSubclassOfClass:[NSValue class]]) return YES;
    if ([cls isSubclassOfClass:[NSMutableData class]]) return YES;
    if ([cls isSubclassOfClass:[NSData class]]) return YES;
    if ([cls isSubclassOfClass:[NSDate class]]) return YES;
    if ([cls isSubclassOfClass:[NSURL class]]) return YES;
    if ([cls isSubclassOfClass:[NSMutableArray class]]) return YES;
    if ([cls isSubclassOfClass:[NSArray class]]) return YES;
    if ([cls isSubclassOfClass:[NSMutableDictionary class]]) return YES;
    if ([cls isSubclassOfClass:[NSDictionary class]]) return YES;
    if ([cls isSubclassOfClass:[NSMutableSet class]]) return YES;
    if ([cls isSubclassOfClass:[NSSet class]]) return YES;
    return NO;
}


static LWType _GetPropertyInfoType(LWAlchemyPropertyInfo* propertyInfo, const char* value) {
    size_t len = strlen(value);
    if (len == 0) return LWTypeUnkonw;
    switch (* value) {
        case 'v': {return LWTypeVoid;}
        case 'B': {return LWTypeBool;}
        case 'c': {return LWTypeInt8;}
        case 'C': {return LWTypeUInt8;}
        case 's': {return LWTypeInt16;}
        case 'S': {return LWTypeUInt16;}
        case 'i': {return LWTypeInt32;}
        case 'I': {return LWTypeUInt32;}
        case 'l': {return LWTypeInt32;}
        case 'L': {return LWTypeUInt32;}
        case 'q': {return LWTypeInt64;}
        case 'Q': {return LWTypeUInt64;}
        case 'f': {return LWTypeFloat;}
        case 'd': {return LWTypeDouble;}
        case 'D': {return LWTypeLongDouble;}
        case '#': {return LWTypeClass;}
        case ':': {return LWTypeSEL;}
        case '*': {return LWTypeCFString;}
        case '^': {return LWTypePointer;}
        case '[': {return LWTypeCFArray;}
        case '(': {return LWTypeUnion;}
        case '{': {return LWTypeStruct;}
        case '@': {
            if (len == 2 && *(value + 1) == '?'){
                return LWTypeBlock;
            } else {
                if (len == 1) {
                    propertyInfo.idType = YES;
                }
                else {
                    propertyInfo.idType = NO;
                }
                return LWTypeObject;
            }
        }
        default:{return LWTypeUnkonw;}
    }
}

static Class _GetPropertyInfoClass(const char* value) {
    size_t len = strlen(value);
    if (len > 3) {
        char name[len - 2];
        name[len - 3] = '\0';
        memcpy(name, value + 2, len - 3);
        return objc_getClass(name);
    }
    return nil;
}


@end
