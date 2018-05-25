//
//  STHTTPCache.h
//  STHTTPService
//
//  Created by MisakaTao on 2018/5/24.
//  Copyright © 2018年 Shengtao Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STHTTPCache : NSObject

+ (instancetype)sharedCache;

- (void)setHttpCache:(id)httpData URL:(NSString *)URL parameters:(id)parameters;
- (id<NSCoding>)httpCacheForURL:(NSString *)URL parameters:(id)parameters;
- (void)httpCacheForURL:(NSString *)URL parameters:(id)parameters block:(void(^)(id<NSCoding> httpData))block;

+ (NSString *)cacheKeyWithURL:(NSString *)URL parameters:(NSDictionary *)parameters;

- (NSInteger)totalConst;
- (void)totalCost:(void(^)(NSInteger totalCost))block;
- (void)removeAllHttpCache;
- (void)removeAllHttpCache:(void(^)(void))block;

@end
