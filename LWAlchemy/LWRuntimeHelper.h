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


#import <Foundation/Foundation.h>
#import "LWProperty.h"
#import "LWMethod.h"
#import "LWTypeHelper.h"






@interface LWRuntimeHelper : NSObject


/**
 *  动态生成一个类
 *
 */
+ (Class)lw_createClassWithClassName:(NSString *)className superClassName:(NSString *)superClassName;



#pragma mark - ivar list

/**
 *  遍历一个类的成员变量列表
 *
 */
+ (void)lw_enumerateClassIvars:(Class)cls usingBlock:(void (^)(Ivar ivar, BOOL *stop))block;


/**
 *  获取一个类的成员变列表(LWIvar封装)
 *
 */
+ (NSArray <LWIvar *> *)lw_getIvarsListOfClass:(Class)cls;


#pragma mark - property list


/**
 *  遍历一个类的属性列表
 *
 */
+ (void)lw_enumerateClassProperties:(Class)cls usingBlock:(void (^)(objc_property_t property, BOOL *stop))block;


/**
 *  获取一个类的属性列表（封装成了LWProperty）
 *
 */
+ (NSArray<LWProperty *> *)lw_getPropertyListOfClass:(Class)cls;

#pragma mark - method list

/**
 *  遍历一个类的 实例方法列表
 *
 */
+ (void)lw_enumerateClassInstanceMethods:(Class)cls usingBlock:(void (^)(Method method, BOOL *stop))block;



/**
 *  遍历一个类的 类方法列表
 *
 */
+ (void)lw_enumerateClassMethods:(Class)cls usingBlock:(void (^)(Method method, BOOL *stop))block;



/**
 *  获取一个类的 实例方法列表(用LWMethod封装)
 *
 */
+ (NSArray<LWMethod *>*)lw_getClassInstanceMethodList:(Class)cls;


/**
 *  获取一个类的 类方法列表(用LWMethod封装)
 *
 */
+ (NSArray<LWMethod *>*)lw_getClassMethodList:(Class)cls;

/**
 *  为一个类动态添加一个 实例方法
 *
 */
+ (BOOL)lw_classAddInstanceMethodForClass:(Class)cls
                                      sel:(SEL)selector
                                      IMP:(IMP)imp
                          returnValueType:(LWType)returnValueType
                           argumentsTypes:(NSArray<NSNumber*/*nsnumber of LWType*/> *)argumentsTypes;


/**
 *  为一个类动态添加一个 类方法
 *
 */
+ (BOOL)lw_classAddClassMethodForClass:(Class)cls
                                   sel:(SEL)selector
                                   IMP:(IMP)imp
                       returnValueType:(LWType)returnValueType
                        argumentsTypes:(NSArray<NSNumber*/*nsnumber of LWType*/> *)argumentsTypes;



/**
 *  用一个新方法替换类的实例方法
 *
 */
+ (void)lw_exchangeInstanceMethodWithClass:(Class)cls originSelector:(SEL)originSel insteadSelector:(SEL)insteadSel;


/**
 *  用一个新方法替换类的类方法
 *
 */
+ (void)lw_exchangeClassMethodWithClass:(Class)cls originSelector:(SEL)originSel insteadSelector:(SEL)insteadSel;



@end
