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




#import "LWRuntimeHelper.h"
#import <objc/runtime.h>
#import <objc/message.h>


@implementation LWRuntimeHelper

+ (BOOL)lw_createClassWithClassName:(NSString *)className superClassName:(NSString *)superClassName {
    
    if (!className || className.length == 0 || !superClassName || superClassName.length == 0) {
        return NO;
    }
    
    Class superClass;
    Class theCreatingClass;
    
    //检验父类是否存在
    superClass = objc_lookUpClass([superClassName UTF8String]);
    if (!superClass) {
        return NO;
    }
    
    //确保要创建的类还不存在
    if (objc_lookUpClass([className UTF8String])) {
        return NO;
    }
    
    //动态生成一个类pair，包括Class和metaClass
    theCreatingClass = objc_allocateClassPair(superClass, [className UTF8String], 0);
    //注册这个类到runtime系统中
    objc_registerClassPair(theCreatingClass);
    return YES;
}


+ (void)lw_enumerateClassProperties:(Class)cls usingBlock:(void (^)(objc_property_t property, BOOL *stop))block {
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

+ (NSArray<LWProperty *> *)lw_getPropertyListOfClass:(Class)cls {
    
    NSMutableArray* tmp = [[NSMutableArray alloc] init];
    unsigned int propertyCount = 0;
    objc_property_t* properties = class_copyPropertyList(cls,&propertyCount);
    
    for (unsigned int i = 0; i < propertyCount; i ++) {
        @autoreleasepool {
            objc_property_t objc_property_t = properties[i];
            LWProperty* property = [LWProperty lw_propertyWithObjcProperty:objc_property_t];
            [tmp addObject:property];
        }
    }
    
    if (properties) {
        free(properties);
    }
    
    return [tmp copy];
}


+ (void)lw_addPropertyForClass:(Class)cls propertyName:(NSString *)ivarName propertyType:(LWType)type {
    
}

@end
