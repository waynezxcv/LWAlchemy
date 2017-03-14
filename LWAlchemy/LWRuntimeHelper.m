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


/**
 *  动态生成一个类
 *
 */
+ (Class)lw_createClassWithClassName:(NSString *)className superClassName:(NSString *)superClassName {
    
    if (!className || className.length == 0 || !superClassName || superClassName.length == 0) {
        return nil;
    }
    
    Class superClass;
    Class theClass;
    
    //检验父类是否存在
    superClass = objc_lookUpClass([superClassName UTF8String]);
    if (!superClass) {
        return nil;
    }
    
    //确保要创建的类还不存在
    if (objc_lookUpClass([className UTF8String])) {
        return nil;
    }
    
    //动态生成一个类pair，包括Class和metaClass元类
    //实例对象的isa指向类，类对象的isa指向元类，元类对象的isa指针指向一个“根元类”（root metaclass）。
    //所有子类的元类都继承父类的元类，换而言之，类对象和元类对象有着同样的继承关系。
    theClass = objc_allocateClassPair(superClass, [className UTF8String], 0);
    //注册这个类到runtime
    objc_registerClassPair(theClass);
    
    return theClass;
}

#pragma mark - ivar list

/**
 *  遍历一个类的成员变量列表
 *
 */
+ (void)lw_enumerateClassIvars:(Class)cls usingBlock:(void (^)(Ivar ivar, BOOL *stop))block {
    
}


/**
 *  获取一个类的成员变列表
 *
 */
+ (void)lw_getIvarsListOfClass:(Class)cls ivars:(Ivar *)ivars count:(unsigned)count {
    
}



#pragma mark - property list
/**
 *  遍历一个类的属性列表
 *
 */

+ (void)lw_enumerateClassProperties:(Class)cls usingBlock:(void (^)(objc_property_t property, BOOL *stop))block {
    BOOL stop = NO;
    while (!stop && ![cls isEqual:[NSObject class]]) {
        unsigned count = 0;
        objc_property_t* properties = class_copyPropertyList(cls, &count);
        if (properties) {
            cls = cls.superclass;
            
            if (properties == NULL){
                return;
            }
            
            for (unsigned i = 0; i < count; i++) {
                block(properties[i], &stop);
                if (stop) break;
            }
            free(properties);
        }
    }
}

/**
 *  获取一个类的属性列表（封装成了LWProperty）
 *
 */
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


#pragma mark - method list

/**
 *  遍历一个类的方法列表
 *
 */
+ (void)lw_enumerateClassMethods:(Class)cls usingBlock:(void (^)(Method method, BOOL *stop))block {
    
}


/**
 *  获取一个类的方法列表
 *
 */
+ (void)lw_getClassMethodList:(Class)cls methods:(Method *)method count:(unsigned)count {
    
}


#pragma mark - Dynamic add

/**
 *  为一个类动态添加一个属性
 *
 */
/**
 *  为一个类动态添加一个属性
 *
 */
+ (void)lw_addPropertyForClass:(Class)cls
                  propertyName:(NSString *)propertyName
                  propertyType:(LWType)type
               memoryAttribute:(LWPropertyMemoryAttribute)memeoryAttribute
           threadSafeAttribute:(LWPropertyThreadSafeAttribute)threadSafeAttribute
            authorityAttribute:(LWPropertyAuthorityAttribute)authorityAttribute
              dynamicAttribute:(LWPropertyIvarAttribute)dynamicAttribute {
    
    //先判断属性是否存在
    BOOL isExsit = NO;
    NSArray* properties = [self lw_getPropertyListOfClass:cls];
    
    for (LWProperty* property in properties) {
        if ([property.name isEqualToString:propertyName]) {
            isExsit = YES;
            return;
        }
    }
    
    if (!isExsit) {
        
    }
}

/**
 *  为一个类动态添加一个实例方法
 *
 */
+ (BOOL)lw_classAddInstanceMethodForClass:(Class)cls sel:(SEL)selector IMP:(IMP)imp {
    return NO;
}

/**
 *  为一个类动态添加一个类方法
 *
 */
+ (BOOL)lw_classAddClassMethodForClass:(Class)cls sel:(SEL)selector IMP:(IMP)imp {
    return NO;
}

#pragma mark - Method swizzling

/**
 *  用一个新方法替换类的实例方法
 *
 */
+ (void)lw_exchangeInstanceMethodWithClass:(Class)cls originSelector:(SEL)originSel insteadSelector:(SEL)insteadSel {
    
}


/**
 *  用一个新方法替换类的类方法
 *
 */
+ (void)lw_exchangeClassMethodWithClass:(Class)cls originSelector:(SEL)originSel insteadSelector:(SEL)insteadSel {
    
}
@end
