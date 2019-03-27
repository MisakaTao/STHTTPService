//
//  STHTTPService.h
//  STHTTPService
//
//  Created by MisakaTao on 2018/5/24.
//  Copyright © 2018年 Shengtao Liu. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIKit+AFNetworking.h>

#import "STHTTPCache.h"
#import "STHTTPUploadItem.h"

typedef NS_ENUM(NSUInteger, STRequestType) {
    STRequestTypeGET = 0,    /** GET请求方式 */
    STRequestTypePOST,       /** POST请求方式 */
    STRequestTypeHEAD,       /** HEAD请求方式 */
    STRequestTypePUT,        /** PUT请求方式 */
    STRequestTypePATCH,      /** PATCH请求方式 */
    STRequestTypeDELETE,     /** DELETE请求方式 */
};

typedef NS_ENUM(NSUInteger, STRequestCachePolicy) {
    STRequestUseProtocolCachePolicy = 0, // Unimplemented
    
    STRequestReloadIgnoringLocalCacheData = 1,/** 忽略缓存，重新请求 */
    STRequestReturnCacheDataElseLoad = 2,/** 有缓存就用缓存，没有缓存就重新请求(用于数据不变时) */
    STRequestReloadRevalidatingCacheData = 4, /** 若请求成功直接返回；若失败，有缓存返回缓存 */
    STRequestReturnCacheDataThenLoad = 5, /** 有缓存就先返回缓存，同步请求数据 */
};

NS_ASSUME_NONNULL_BEGIN

typedef void(^STSuccessBlock)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject);
typedef void(^STFailureBlock)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error);

@interface STHTTPService : NSObject

+ (instancetype)httpService;

/**
 取消所有HTTP请求
 */
+ (void)cancelAllRequest;

/**
 取消指定URL的HTTP请求
 */
+ (void)cancelTasktWithURL:(NSString *)url params:(id)params;

/**
 GET 请求（默认忽略缓存）

 @param url 请求地址
 @param parameters 请求参数
 @param success 成功回调
 @param failure 失败回调
 @return 返回的对象可取消请求,调用cancle方法
 */
+ (__kindof NSURLSessionDataTask *)GET:(NSString *)url
                            parameters:(id)parameters
                               success:(STSuccessBlock)success
                               failure:(STFailureBlock)failure;

/**
 GET 请求

 @param url 请求地址
 @param parameters 请求参数
 @param cachePolicy 缓存策略
 @param success 成功回调
 @param failure 失败回调
 @return 返回的对象可取消请求,调用cancle方法
 */
+ (__kindof NSURLSessionDataTask *)GET:(NSString *)url
                            parameters:(id)parameters
                           cachePolicy:(STRequestCachePolicy)cachePolicy
                               success:(STSuccessBlock)success
                               failure:(STFailureBlock)failure;

/**
 POST 请求（默认忽略缓存）

 @param url 请求地址
 @param parameters 请求参数
 @param success 成功回调
 @param failure 失败回调
 @return 返回的对象可取消请求,调用cancle方法
 */
+ (__kindof NSURLSessionDataTask *)POST:(NSString *)url
                             parameters:(id)parameters
                                success:(STSuccessBlock)success
                                failure:(STFailureBlock)failure;

/**
 POST 请求

 @param url 请求地址
 @param parameters 请求参数
 @param cachePolicy 缓存策略
 @param success 成功回调
 @param failure 失败回调
 @return 返回的对象可取消请求,调用cancle方法
 */
+ (__kindof NSURLSessionDataTask *)POST:(NSString *)url
                             parameters:(id)parameters
                            cachePolicy:(STRequestCachePolicy)cachePolicy
                                success:(STSuccessBlock)success
                                failure:(STFailureBlock)failure;


/**
 上传文件
 
 @param url 请求地址
 @param parameters 请求参数
 @param files 上传文件数组
 @param progress 上传进度
 @param success 成功回调
 @param failure 失败回调
 @return 返回的对象可取消请求,调用cancle方法
 */
+ (__kindof NSURLSessionDataTask *)uploadWithURL:(NSString *)url
                                          params:(id)parameters
                                           files:(NSArray<STHTTPUploadItem *> *)files
                                        progress:(void(^)(NSProgress *progress))progress
                                         success:(STSuccessBlock)success
                                         failure:(STFailureBlock)failure;

/**
 下载文件
 
 @param url 请求地址
 @param fileName 文件名
 @param progress 文件下载的进度信息
 @param completionHandler 下载完成的回调
 @return 返回的对象可取消请求,调用cancle方法
 */
+ (NSURLSessionDownloadTask *)downloadWithURL:(NSString *)url
                                     fileName:(NSString *)fileName
                                     progress:(void(^)(NSProgress *progress))progress
                            completionHandler:(void(^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler;

@end
NS_ASSUME_NONNULL_END
