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




#import "NSOject+Copying.h"
#import <objc/runtime.h>


static void* LW_COPYING_IGNOREKEY = &LW_COPYING_IGNOREKEY;

@implementation NSObject(Copying)

- (void)setIgnores:(NSArray<NSString *> *)ignores {
    objc_setAssociatedObject(self, LW_COPYING_IGNOREKEY, ignores , OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSArray <NSString *>*)ignores {
    return objc_getAssociatedObject(self, LW_COPYING_IGNOREKEY);
}

- (id)lw_copy {
    id one = [[[self class] alloc] init];
    unsigned int count = 0;
    Ivar* ivars = class_copyIvarList([self class], &count);
    
    for (unsigned int i = 0; i < count; i ++) {
        Ivar ivar = ivars[i];
        NSString* ivarName = [NSString stringWithUTF8String:ivar_getName(ivar)];
        if ([self.ignores containsObject:ivarName]) {
            continue;
        }
        
        id value = [self valueForKey:ivarName];
        if ([value conformsToProtocol:@protocol(NSCopying)]) {
            [one setValue:[value copy]  forKey:ivarName];
        } else {
            [one setValue:value forKey:ivarName];
        }
    }
    return one;
}


- (id)lw_mutableCopy {
    id one = [[[self class] alloc] init];
    unsigned int count = 0;
    Ivar* ivars = class_copyIvarList([self class], &count);
    
    for (unsigned int i = 0; i < count; i ++) {
        Ivar ivar = ivars[i];
        NSString* ivarName = [NSString stringWithUTF8String:ivar_getName(ivar)];
        
        if ([self.ignores containsObject:ivarName]) {
            continue;
        }
        
        id value = [self valueForKey:ivarName];
        if ([value conformsToProtocol:@protocol(NSMutableCopying)]) {
            [one setValue:[value mutableCopy]  forKey:ivarName];
        } else if ([value conformsToProtocol:@protocol(NSCopying)]) {
            [one setValue:[value copy]  forKey:ivarName];
        } else {
            [one setValue:value forKey:ivarName];
        }
    }
    return one;
}

@end
