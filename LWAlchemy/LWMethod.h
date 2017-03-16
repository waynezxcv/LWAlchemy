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

@interface LWMethod : NSObject

@property (nonatomic,assign,readonly) Method method;
@property (nonatomic,copy,readonly) NSString* name;
@property (nonatomic,assign,readonly) IMP implementation;
@property (nonatomic,copy,readonly) NSString* typeEncoding;
@property (nonatomic,assign,readonly) NSInteger numberOfArguments;
@property (nonatomic,copy,readonly) NSString* returnType;
@property (nonatomic,copy,readonly) NSArray<NSString*>* argumentTypeList;

+ (LWMethod *)lw_methodWithMethod:(Method)method;

@end
