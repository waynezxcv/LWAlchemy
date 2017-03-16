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





#import "LWMethod.h"

@implementation LWMethod


+ (LWMethod *)lw_methodWithMethod:(Method)method {
    return [[LWMethod alloc] init];
}


- (id)initWithMethod:(Method)method {
    self = [super init];
    if (self) {
        _method = method;
        _name = NSStringFromSelector(method_getName(_method));
        _implementation = method_getImplementation(_method);
        _typeEncoding = [NSString stringWithUTF8String:method_getTypeEncoding(_method)];
        _numberOfArguments = method_getNumberOfArguments(_method);
        _returnType = [NSString stringWithUTF8String:method_copyReturnType(_method)];

        NSMutableArray* tmp = [[NSMutableArray alloc] init];
        for (unsigned int i = 0; i < _numberOfArguments; i ++) {
            NSString* argsType = [NSString stringWithUTF8String:method_copyArgumentType(_method, i)];
            [tmp addObject:argsType];
        }
        _argumentTypeList = tmp.copy;

    }
    return self;
}

@end