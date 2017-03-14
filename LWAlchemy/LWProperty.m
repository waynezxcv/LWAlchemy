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




#import "LWProperty.h"

@implementation LWProperty

#pragma mark - Public

+ (LWProperty *)lw_propertyWithObjcProperty:(objc_property_t)property {
    return [[LWProperty alloc] initWithProperty:property];
}

- (id)initWithProperty:(objc_property_t)objcProperty mapper:(NSDictionary *)mapper {
    self = [super init];
    if (self) {
        [self setupWithProperty:objcProperty];
        if (mapper[_name]) {
            NSMutableArray* mappedToKeyArray = [[NSMutableArray alloc] init];
            NSArray* keyPath = [mapper[_name] componentsSeparatedByString:@"."];
            if (keyPath.count > 1) {
                for (NSString* oneKey in keyPath) {
                    [mappedToKeyArray addObject:oneKey];
                }
            } else {
                [mappedToKeyArray addObject:mapper[_name]];
            }
            _mapperName = mappedToKeyArray;
        }
    }
    return self;
}


- (id)initWithProperty:(objc_property_t)objcProperty {
    self = [super init];
    if (self) {
        [self setupWithProperty:objcProperty];
    }
    return self;
}

+ (LWType)lw_typeFromNSObjCValueType:(const char*)type {
    return _lwtypeFromAttirbuteValue(type);
}


#pragma mark - Private

- (void)setupWithProperty:(objc_property_t)objcProperty {
    
    _objcProperty = objcProperty;
    _name = [[NSString alloc] initWithUTF8String:property_getName(_objcProperty)];
    _type = LWTypeUnkown;
    _memoryAttribute = LWPropertyMemoryAttributeAssign;
    _threadSafeAttribute = LWPropertyThreadSafeAttributeAtomic;
    _authorityAttribute = LWPropertyAuthorityAttributeReadWrite;
    _ivarAttribute = LWPropertyIvarAttributeNonDynamic;
    _setterName = [NSString stringWithFormat:@"set%@%@:",[_name substringToIndex:1].uppercaseString,[_name substringFromIndex:1]];
    _getterName = _name;
    _mapperName =  @[@(property_getName(_objcProperty))];
    
    unsigned int attributeCount = 0;
    objc_property_attribute_t* attributes = property_copyAttributeList(objcProperty, &attributeCount);
    
    
    //遍历attributes
    for (unsigned int i = 0; i < attributeCount; i ++) {
        
        objc_property_attribute_t attribute = attributes[i];
        const char* attributeName = attribute.name;
        const char* attributeValue = attribute.value;
        
        switch (attributeName[0]) {
                //类型
            case 'T': {
                _type = _lwtypeFromAttirbuteValue(attributeValue);
                
                if (_type > LWTypeID) {
                    _cls = _classFromAttributeValue(attributeValue);
                }
                
            } break;
                //成员变量名称
            case 'V': {
                if (attributeValue) {
                    _ivarName = [NSString stringWithUTF8String:attributeValue];
                }
            } break;
                //Getter方法
            case 'G': {
                if (attributeValue) {
                    _getterName = [NSString stringWithUTF8String:attributeValue];
                }
            } break;
                //Setter方法
            case 'S': {
                if (attributeValue) {
                    _setterName = [NSString stringWithUTF8String:attributeValue];
                }
            }break;
                //读写权限
            case 'R': {
                _authorityAttribute = LWPropertyAuthorityAttributeReadOnly;
            } break;
                //LWPropertyIvarAttribute
            case 'D': {
                _ivarAttribute = LWPropertyIvarAttributeDynamic;
            } break;
                //原子性
            case 'N':{
                _threadSafeAttribute = LWPropertyThreadSafeAttributeNonAtomic;
            }break;
                //内存管理相关属性
            case '&': {
                _memoryAttribute = LWPropertyMemoryAttributeStrong;
            }break;
                
            case 'W': {
                _memoryAttribute = LWPropertyMemoryAttributeWeak;
            }break;
                
            case 'C': {
                _memoryAttribute = LWPropertyMemoryAttributeCopy;
            }break;
            default:break;
        }
    }
    
    if (attributes) {
        free(attributes);
        attributes = NULL;
    }
}


static inline LWType _lwtypeFromAttirbuteValue(const char* attributeValue) {
    
    size_t len = strlen(attributeValue);
    if (len == 0) {
        return LWTypeUnkown;
    }
    
    switch (*attributeValue) {
            //基础数据类型
        case 'v': return LWTypeVoid;
        case 'B': return LWTypeBool;
        case 'c': return LWTypeInt8;
        case 'C': return LWTypeUInt8;
        case 's': return LWTypeInt16;
        case 'S': return LWTypeUInt16;
        case 'i': return LWTypeInt32;
        case 'I': return LWTypeUInt32;
        case 'l': return LWTypeInt32;
        case 'L': return LWTypeUInt32;
        case 'q': return LWTypeInt64;
        case 'Q': return LWTypeUInt64;
        case 'f': return LWTypeFloat;
        case 'd': return LWTypeDouble;
        case 'D': return LWTypeLongDouble;
            
            //(C语言)类型
        case '#': return LWTypeClass;
        case '^': return LWTypePointer;
        case ':': return LWTypeSelector;
        case '*': return LWTypeCString;
        case '[': return LWTypeCArray;
        case '(': return LWTypeCUnion;
        case '{': return LWTypeCStruct;
        case 'b': return LWTypeCBitField;
            
            //OBJC对象类型
        case '@':{
            if (len == 2 && *(attributeValue + 1) == '?') {
                return LWTypeBlock;
            } else {
                if (len == 1) {
                    return LWTypeID;
                }
                //除了block和id类型外的其他OBJC对象类型
                Class cls = _classFromAttributeValue(attributeValue);
                if (cls) {
                    return _lwtypeFromClass(cls);
                }
                return LWTypeID;
            }
        default:return LWTypeUnkown;
        };
    }
}



//根据Class获取LWType

static inline LWType _lwtypeFromClass(Class cls) {
    
    if (!cls) return LWTypeUnkown;
    if ([cls isSubclassOfClass:[NSMutableString class]])
        return LWTypeNSMutableString;
    if ([cls isSubclassOfClass:[NSString class]])
        return LWTypeNSString;
    if ([cls isSubclassOfClass:[NSDecimalNumber class]])
        return LWTypeNSDecimalNumber;
    if ([cls isSubclassOfClass:[NSNumber class]])
        return LWTypeNSNumber;
    if ([cls isSubclassOfClass:[NSValue class]])
        return LWTypeNSValue;
    if ([cls isSubclassOfClass:[NSMutableData class]])
        return LWTypeNSMutableData;
    if ([cls isSubclassOfClass:[NSData class]])
        return LWTypeNSData;
    if ([cls isSubclassOfClass:[NSDate class]])
        return LWTypeNSDate;
    if ([cls isSubclassOfClass:[NSURL class]])
        return LWTypeNSURL;
    if ([cls isSubclassOfClass:[NSMutableArray class]])
        return LWTypeNSMutableArray;
    if ([cls isSubclassOfClass:[NSArray class]])
        return LWTypeNSArray;
    if ([cls isSubclassOfClass:[NSMutableDictionary class]])
        return LWTypeNSMutableDictionary;
    if ([cls isSubclassOfClass:[NSDictionary class]])
        return LWTypeNSDictionary;
    if ([cls isSubclassOfClass:[NSMutableSet class]])
        return LWTypeNSMutableSet;
    if ([cls isSubclassOfClass:[NSSet class]])
        return LWTypeNSSet;
    return LWTypeCustomObject;
}



static inline Class _classFromAttributeValue(const char* attributeValue) {
    //从atrributeValue中获取类名称，然后获取Class对象
    size_t len = strlen(attributeValue);
    if (len > 3) {
        char name[len - 2];
        name[len - 3] = '\0';
        memcpy(name, attributeValue + 2, len - 3);
        
        Class cls = objc_getClass(name);
        return cls;
    }
    return nil;
}


@end
