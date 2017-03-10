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



@interface LWRuntimeHelper : NSObject

/**
 *  动态生成一个类
 *
 */
+ (BOOL)lw_createClassWithClassName:(NSString *)className superClassName:(NSString *)superClassName;


/**
 *  遍历一个类的成员变量列表
 *
 */



/**
 *  获取一个类的成员变列表
 *
 */




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



/**
 *  遍历一个类的方法列表
 *
 */



/**
 *  获取一个类的方法列表
 *
 */


/**
 *  遍历一个类的协议列表
 *
 */



/**
 *  获取一个类的协议列表
 *
 */





/**
 *  为一个类动态添加一个属性
 *
 */
+ (void)lw_addPropertyForClass:(Class)cls propertyName:(NSString *)ivarName propertyType:(LWType)type;

/**
 *  为一个类动态添加一个实例方法
 *
 */
+ (void)lw_addClassInstanceMethodForClass:(Class)cls;

/**
 *  为一个类动态添加一个类方法
 *
 */
+ (void)lw_addClassMethodForClass:(Class)cls;


/**
 *  为一个类动态添加一个类方法
 *
 */


/**
 *  交换类的两个方法
 *
 */

@end
