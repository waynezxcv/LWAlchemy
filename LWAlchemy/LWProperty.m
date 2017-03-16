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


#pragma mark - Private

- (void)setupWithProperty:(objc_property_t)objcProperty {

    _objcProperty = objcProperty;
    _name = [[NSString alloc] initWithUTF8String:property_getName(_objcProperty)];
    _type = LWTypeUnkown;
    _ownershipAttribute = LWPropertyOwnershipAttributeAssign;
    _threadSafeAttribute = LWPropertyThreadSafeAttributeAtomic;
    _authorityAttribute = LWPropertyAuthorityAttributeReadWrite;
    _dynamicAttribute = LWPropertyIvarAttributeNonDynamic;
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
                _type = [LWTypeHelper lw_typeFromAttributeValue:attributeValue];
                if (_type > LWTypeID) {
                    _cls = [LWTypeHelper lw_classFromAttributeValue:attributeValue];
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
                _dynamicAttribute = LWPropertyIvarAttributeDynamic;
            } break;
                //原子性
            case 'N':{
                _threadSafeAttribute = LWPropertyThreadSafeAttributeNonAtomic;
            }break;
                //内存管理相关属性
            case '&': {
                _ownershipAttribute = LWPropertyOwnershipAttributeStrong;
            }break;

            case 'W': {
                _ownershipAttribute = LWPropertyOwnershipAttributeWeak;
            }break;

            case 'C': {
                _ownershipAttribute = LWPropertyOwnershipAttributeCopy;
            }break;
            default:break;
        }
    }

    if (attributes) {
        free(attributes);
        attributes = NULL;
    }
}

@end




@implementation LWIvar


+ (LWIvar *)lw_ivarWithObjcProperty:(Ivar)ivar {
    return [[LWIvar alloc] initWithIvar:ivar];
}


- (id)initWithIvar:(Ivar)ivar {
    self = [super init];
    if (self) {
        _ivar = ivar;
        _name = [NSString stringWithUTF8String:ivar_getName(_ivar)];
        _TypeEncoding = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
    }
    return self;
}

@end

