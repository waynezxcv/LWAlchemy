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


#import "LWTypeHelper.h"
#import <objc/runtime.h>


@implementation LWTypeHelper


+ (LWType) lw_typeFromAttributeValue:(const char*)attributeValue {
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
                Class cls = [LWTypeHelper lw_classFromAttributeValue:attributeValue];
                if (cls) {
                    return [LWTypeHelper lw_typeFromClass:cls];
                }
                return LWTypeID;
            }
        default:return LWTypeUnkown;
        };
    }
}


+ (LWType) lw_typeFromClass:(Class)cls {
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


+ (Class)lw_classFromAttributeValue:(const char*)attributeValue {
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


+ (const char)lw_attributeValueFromLWType:(LWType)type {
    switch (type) {
        case LWTypeVoid:return 'v';
        case LWTypeBool:return 'B';
        case LWTypeInt8:return 'c';
        case LWTypeUInt8:return 'C';
        case LWTypeInt16:return 's';
        case LWTypeUInt16:return 'S';
        case LWTypeInt32:return 'i';
        case LWTypeUInt32:return 'L';
        case LWTypeInt64:return 'q';
        case LWTypeUInt64:return 'Q';
        case LWTypeFloat:return 'f';
        case LWTypeDouble:return 'd';
        case LWTypeLongDouble:return 'D';
        case LWTypeClass:return '#';
        case LWTypeSelector:return ':';
        case LWTypeCString:return '*';
        case LWTypePointer:return '^';
        case LWTypeCArray:return '[';
        case LWTypeCUnion:return '(';
        case LWTypeCStruct:return '{';
        case LWTypeCBitField:return 'b';
        case LWTypeBlock:
        case LWTypeID:
        case LWTypeNSString:
        case LWTypeNSMutableString:
        case LWTypeNSValue:
        case LWTypeNSNumber:
        case LWTypeNSDecimalNumber:
        case LWTypeNSData:
        case LWTypeNSMutableData:
        case LWTypeNSDate:
        case LWTypeNSURL:
        case LWTypeNSArray:
        case LWTypeNSMutableArray:
        case LWTypeNSDictionary:
        case LWTypeNSMutableDictionary:
        case LWTypeNSSet:
        case LWTypeNSMutableSet:
        case LWTypeCustomObject:return '@';
        case LWTypeUnkown:return ' ';
    }
}

@end
