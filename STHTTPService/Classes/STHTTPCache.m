//
//  STHTTPCache.m
//  STHTTPService
//
//  Created by MisakaTao on 2018/5/24.
//  Copyright © 2018年 Shengtao Liu. All rights reserved.
//

#import "STHTTPCache.h"
#import <YYCache/YYCache.h>

static NSString *const STHTTPCacheName = @"HTTPCache";

static STHTTPCache *_instance = nil;
static YYCache *_dataCache = nil;

@implementation STHTTPCache

+ (instancetype)sharedCache {
    
    return [[STHTTPCache alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

- (id)copyWithZone:(NSZone *)zone {
    return _instance;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return _instance;
}

#if __has_feature(objc_arc)

#else
- (oneway void)release {
    
}

- (instancetype)retain {
    return _instance;
}

- (NSUInteger)retainCount {
    return MAXFLOAT;
}
#endif

- (YYCache *)dataCache {
    if (!_dataCache) {
        _dataCache = [YYCache cacheWithName:STHTTPCacheName];
        _dataCache.memoryCache.shouldRemoveAllObjectsOnMemoryWarning = true;
        _dataCache.memoryCache.shouldRemoveAllObjectsWhenEnteringBackground = true;
    }
    return _dataCache;
}


#pragma mark - Public

- (void)setHttpCache:(id)httpData URL:(NSString *)URL parameters:(id)parameters {
    
    NSString *cacheKey = [self cacheKeyWithURL:URL parameters:parameters];
    [[self dataCache] setObject:httpData forKey:cacheKey withBlock:nil];
}

- (id<NSCoding>)httpCacheForURL:(NSString *)URL parameters:(id)parameters {
    
    NSString *cacheKey = [self cacheKeyWithURL:URL parameters:parameters];
    return [[self dataCache] objectForKey:cacheKey];
}

- (void)httpCacheForURL:(NSString *)URL parameters:(id)parameters block:(void(^)(id<NSCoding> httpData))block {
    
    NSString *cacheKey = [self cacheKeyWithURL:URL parameters:parameters];
    [[self dataCache] objectForKey:cacheKey withBlock:^(NSString * _Nonnull key, id<NSCoding>  _Nonnull object) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                block(object);
            }
        });
    }];
}

- (NSInteger)totalConst {
    return [[self dataCache].diskCache totalCost];
}

- (void)totalCost:(void(^)(NSInteger totalCost))block {
    return [[self dataCache].diskCache totalCostWithBlock:block];
}

- (void)removeAllHttpCache {
    [[self dataCache].diskCache removeAllObjects];
}

- (void)removeAllHttpCache:(void(^)(void))block {
    [[self dataCache].diskCache removeAllObjectsWithBlock:block];
}


#pragma mark - Private

+ (NSString *)cacheKeyWithURL:(NSString *)URL parameters:(NSDictionary *)parameters {
    
    return [[self sharedCache] cacheKeyWithURL:URL parameters:parameters];
}

- (NSString *)cacheKeyWithURL:(NSString *)URL parameters:(NSDictionary *)parameters {
    
    if (!parameters || parameters.count == 0) {
        return URL;
    }
    NSString *cacheURL = [URL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    if (![NSJSONSerialization isValidJSONObject:parameters]) {
        return cacheURL;
    }
    NSError *error;
    NSData *cacheData = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:&error];
    NSString *paramString = [[NSString alloc] initWithData:cacheData encoding:NSUTF8StringEncoding];
    
    NSString *cacheString = [NSString stringWithFormat:@"%@%@", cacheURL, paramString];
    return [NSString stringWithFormat:@"%lu", (unsigned long)cacheString.hash];
}


@end
