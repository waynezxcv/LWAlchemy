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
#import <objc/runtime.h>
#import <objc/message.h>
#import "LWTypeHelper.h"




//封装自objc_property_t

@interface LWProperty : NSObject

@property (nonatomic,assign,readonly) objc_property_t objcProperty;
@property (nonatomic,copy,readonly) NSString* name;
@property (nonatomic,assign,readonly) LWType type;
@property (nonatomic,assign,readonly) LWPropertyOwnershipAttribute ownershipAttribute;
@property (nonatomic,assign,readonly) LWPropertyThreadSafeAttribute threadSafeAttribute;
@property (nonatomic,assign,readonly) LWPropertyAuthorityAttribute authorityAttribute;
@property (nonatomic,assign,readonly) LWPropertyDynamicAttribute dynamicAttribute;
@property (nonatomic,copy,readonly) NSString* ivarName;//成员变量名
@property (nonatomic,copy,readonly) NSString* setterName;//setter方法名
@property (nonatomic,copy,readonly) NSString* getterName;//getter方法名
@property (nonatomic,strong,readonly) Class cls;//类名称，如果是OBJC对象类型


+ (LWProperty *)lw_propertyWithObjcProperty:(objc_property_t)objcProperty;




#pragma mark - Just For NSObject+Maping
@property (nonatomic,strong,readonly) NSArray* mapperName;//模型映射的名称
- (id)initWithProperty:(objc_property_t)objcProperty mapper:(NSDictionary *)mapper;

@end





@interface LWIvar : NSObject



@property (nonatomic,assign,readonly) Ivar ivar;
@property (nonatomic,copy,readonly) NSString* name;
@property (nonatomic,copy,readonly) NSString* TypeEncoding;

+ (LWIvar *)lw_ivarWithObjcProperty:(Ivar)ivar;
- (id)initWithIvar:(Ivar)ivar;


@end

