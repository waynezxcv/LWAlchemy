//
//  NSObject+Model.m
//  LWAlchemyDemo
//
//  Created by 刘微 on 16/1/20.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import "LWAlchemy.h"
#import <objc/runtime.h>

@interface LWAlchemy ()

@property (nonatomic,strong) NSDictionary* map;

@end


@implementation LWAlchemy:NSObject

- (id)initWithJSON:(id)JSON JSONKeyPathsByPropertyKey:(NSDictionary *)map{
    self = [super init];
    if (self) {
        self.map = map;
        NSDictionary* dic = [self _dictionaryWithJSON:JSON];
        self = [self _modelWithDictionary:dic];
    }
    return self;
}


- (instancetype)_modelWithDictionary:(NSDictionary *)dictionary {
    if (!dictionary || dictionary == (id)kCFNull) return nil;
    if (![dictionary isKindOfClass:[NSDictionary class]]) return nil;
    
    [self _enumeratePropertiesUsingBlock:^(objc_property_t property, BOOL *stop) {
        NSString* key = @(property_getName(property));
        NSString* k = self.map[key];
        [self setValue:dictionary[k] forKey:key];
    }];
    
    return self;
}

- (NSDictionary *)_dictionaryWithJSON:(id)json {
    if (!json || json == (id)kCFNull) return nil;
    NSDictionary *dic = nil;
    NSData *jsonData = nil;
    if ([json isKindOfClass:[NSDictionary class]]) {
        dic = json;
    } else if ([json isKindOfClass:[NSString class]]) {
        jsonData = [(NSString *)json dataUsingEncoding : NSUTF8StringEncoding];
    } else if ([json isKindOfClass:[NSData class]]) {
        jsonData = json;
    }
    if (jsonData) {
        dic = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        if (![dic isKindOfClass:[NSDictionary class]]) dic = nil;
    }
    return dic;
}


- (void)_enumeratePropertiesUsingBlock:(void (^)(objc_property_t property, BOOL *stop))block {
    Class cls = [self class];
    BOOL stop = NO;
    while (!stop && ![cls isEqual:[LWAlchemy class]]) {
        unsigned count = 0;
        objc_property_t* properties = class_copyPropertyList(cls, &count);
        cls = cls.superclass;
        if (properties == NULL) continue;
        for (unsigned i = 0; i < count; i++) {
            block(properties[i], &stop);
            if (stop) break;
        }
    }
}

@end
