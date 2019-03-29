//
//  STHTTPService.m
//  STHTTPService
//
//  Created by MisakaTao on 2018/5/24.
//  Copyright © 2018年 Shengtao Liu. All rights reserved.
//

#import "STHTTPService.h"

static CGFloat const timeoutInterval = 30.0f;
static NSMutableDictionary *_allSessionTask = nil;

static AFHTTPSessionManager *_sessionManager = nil;
static STHTTPService *_httpService = nil;

@implementation STHTTPService

+ (instancetype)httpService {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _httpService = [[STHTTPService alloc] init];
    });
    return _httpService;
}

- (NSMutableDictionary *)allSessionTask {
    if (!_allSessionTask) {
        _allSessionTask = [NSMutableDictionary dictionary];
    }
    return _allSessionTask;
}

- (AFHTTPSessionManager *)sessionManager {
    if (!_sessionManager) {
        _sessionManager = [AFHTTPSessionManager manager];
        // 设置请求参数的类型:JSON (AFJSONRequestSerializer, AFHTTPRequestSerializer)
        AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
        requestSerializer.timeoutInterval = timeoutInterval;
        _sessionManager.requestSerializer = requestSerializer;
        // 设置服务器返回结果的类型:JSON (AFJSONResponseSerializer, AFHTTPResponseSerializer)
        AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
        // 设置接受类型
        // responseSerializer.removesKeysWithNullValues = true;
        responseSerializer.acceptableContentTypes = [NSSet setWithObjects:
                                                     @"application/json",
                                                     @"text/json",
                                                     @"text/javascript",
                                                     @"text/html",
                                                     @"text/xml",
                                                     @"text/plain",
                                                     @"image/*", nil];
        _sessionManager.responseSerializer = responseSerializer;
        // 设置安全证书SSL
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        securityPolicy.allowInvalidCertificates = true;
        securityPolicy.validatesDomainName = false;
        // _sessionManager.securityPolicy = securityPolicy;
        
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:true];
    }
    return _sessionManager;
}

+ (void)cancelAllRequest {
    
    @synchronized(self) {
        [[[self httpService] allSessionTask] enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSURLSessionTask * _Nonnull task, BOOL * _Nonnull stop) {
            
            [task cancel];
        }];
        [[[self httpService] allSessionTask] removeAllObjects];
    }
}

+ (void)cancelTasktWithURL:(NSString *)url params:(id)params {
    
    NSString *requestURL = [[self httpService] filterURLWithURL:url];
    NSDictionary *requestParams = [[self httpService] fileterParamsWithParams:params];
    // 缓存请求
    NSString *cacheKey = [STHTTPCache cacheKeyWithURL:requestURL parameters:requestParams];
    
    if (!cacheKey) return;
    @synchronized(self) {
        [[[self httpService] allSessionTask] enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSURLSessionTask * _Nonnull task, BOOL * _Nonnull stop) {
            if ([key isEqualToString:cacheKey]) {
                [task cancel];
                [[[self httpService] allSessionTask] removeObjectForKey:cacheKey];
            }
            *stop = true;
        }];
    }
}

+ (NSURLSessionDataTask *)GET:(NSString *)url
                   parameters:(id)parameters
                      success:(STSuccessBlock)success
                      failure:(STFailureBlock)failure {
    
    return [self GET:url parameters:parameters cachePolicy:STRequestReloadIgnoringLocalCacheData success:success failure:failure];
}

+ (NSURLSessionDataTask *)GET:(NSString *)url
                   parameters:(id)parameters
                  cachePolicy:(STRequestCachePolicy)cachePolicy
                      success:(STSuccessBlock)success
                      failure:(STFailureBlock)failure {
    
    return [self requestWithURL:url methodType:STRequestTypeGET parameters:parameters cachePolicy:cachePolicy success:success failure:failure];
}

+ (NSURLSessionDataTask *)POST:(NSString *)url
                   parameters:(id)parameters
                      success:(STSuccessBlock)success
                      failure:(STFailureBlock)failure {
    
    return [self POST:url parameters:parameters cachePolicy:STRequestReloadIgnoringLocalCacheData success:success failure:failure];
}

+ (NSURLSessionDataTask *)POST:(NSString *)url
                   parameters:(id)parameters
                  cachePolicy:(STRequestCachePolicy)cachePolicy
                      success:(STSuccessBlock)success
                      failure:(STFailureBlock)failure {
    
    return [self requestWithURL:url methodType:STRequestTypePOST parameters:parameters cachePolicy:cachePolicy success:success failure:failure];
}


/**
 网络请求统一处理缓存策略

 @param url 请求地址
 @param methodType 请求方法
 @param parameters 请求参数
 @param cachePolicy 缓存策略
 @param success 成功回调
 @param failure 失败回调
 @return 返回的对象可取消请求,调用cancle方法
 */
+ (NSURLSessionDataTask *)requestWithURL:(NSString *)url
                              methodType:(STRequestType)methodType
                              parameters:(id)parameters
                             cachePolicy:(STRequestCachePolicy)cachePolicy
                                 success:(STSuccessBlock)success
                                 failure:(STFailureBlock)failure {
    
    NSString *requestURL = [[self httpService] filterURLWithURL:url];
    NSDictionary *requestParams = [[self httpService] fileterParamsWithParams:parameters];
    // 缓存请求
    NSString *cacheKey = [STHTTPCache cacheKeyWithURL:requestURL parameters:requestParams];
    
    NSURLSessionDataTask *dataTask = nil;
    switch (cachePolicy) {
        case STRequestReturnCacheDataElseLoad:
        {
            // 有缓存就返回缓存，没有就请求
            id cacheObject = [[STHTTPCache sharedCache] httpCacheForURL:url parameters:parameters];
            if (cacheObject) {
                success ? success(nil, cacheObject) : nil;
            } else {
                dataTask = [self dataTaskWithURL:url methodType:methodType parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
#if defined(DEBUG)||defined(_DEBUG)
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"\nURL: %@\tParameters: %@\tResponseObject: %@", url, [requestParams yy_modelToJSONString], responseObject);
                    });
#endif
                    [[STHTTPCache sharedCache] setHttpCache:responseObject URL:url parameters:parameters];
                    
                    success ? success(task, responseObject) : nil;
                    
                    [[[self httpService] allSessionTask] removeObjectForKey:cacheKey];
                    
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
#if defined(DEBUG)||defined(_DEBUG)
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"\nURL: %@\tParameters: %@\tError: %@", url, [requestParams yy_modelToJSONString], error);
                    });
#endif
                    failure ? failure(task, error) : nil;
                    
                    [[[self httpService] allSessionTask] removeObjectForKey:cacheKey];
                }];
            }
        }
            break;
        case STRequestReloadRevalidatingCacheData:
        {
            // 若请求成功直接返回；若失败，有缓存返回缓存
            dataTask = [self dataTaskWithURL:url methodType:methodType parameters:parameters success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
#if defined(DEBUG)||defined(_DEBUG)
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"\nURL: %@\tParameters: %@\tResponseObject: %@", url, [requestParams yy_modelToJSONString], responseObject);
                });
#endif
                [[STHTTPCache sharedCache] setHttpCache:responseObject URL:url parameters:parameters];
                
                success ? success(task, responseObject) : nil;
                
                [[[self httpService] allSessionTask] removeObjectForKey:cacheKey];
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                id cacheObject = [[STHTTPCache sharedCache] httpCacheForURL:url parameters:parameters];
                if (cacheObject) {
                    success ? success(nil, cacheObject) : nil;
                } else {
#if defined(DEBUG)||defined(_DEBUG)
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"\nURL: %@\tParameters: %@\tError: %@", url, [requestParams yy_modelToJSONString], error);
                    });
#endif
                    failure ? failure(task, error) : nil;
                    
                    [[[self httpService] allSessionTask] removeObjectForKey:cacheKey];
                }
            }];
        }
            break;
        case STRequestReturnCacheDataThenLoad:
        {
            // 先返回缓存，同时请求，会回调两次结果
            id cacheObject = [[STHTTPCache sharedCache] httpCacheForURL:url parameters:parameters];
            if (cacheObject) {
                success ? success(nil, cacheObject) : nil;
            }
            return [self dataTaskWithURL:url methodType:methodType parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
#if defined(DEBUG)||defined(_DEBUG)
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"\nURL: %@\tParameters: %@\tResponseObject: %@", url, [requestParams yy_modelToJSONString], responseObject);
                });
#endif
                [[STHTTPCache sharedCache] setHttpCache:responseObject URL:url parameters:parameters];
                
                success ? success(task, responseObject) : nil;
                
                [[[self httpService] allSessionTask] removeObjectForKey:cacheKey];
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
#if defined(DEBUG)||defined(_DEBUG)
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"\nURL: %@\tParameters: %@\tError: %@", url, [requestParams yy_modelToJSONString], error);
                });
#endif
                failure ? failure(task, error) : nil;
                
                [[[self httpService] allSessionTask] removeObjectForKey:cacheKey];
            }];
        }
            break;
        default:
        {
            // 忽略本地缓存直接请求
            dataTask = [self dataTaskWithURL:url methodType:methodType parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
#if defined(DEBUG)||defined(_DEBUG)
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"\nURL: %@\tParameters: %@\tResponseObject: %@", url, [requestParams yy_modelToJSONString], responseObject);
                });
#endif
                [[STHTTPCache sharedCache] setHttpCache:responseObject URL:url parameters:parameters];
                
                success ? success(task, responseObject) : nil;
                
                [[[self httpService] allSessionTask] removeObjectForKey:cacheKey];
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
#if defined(DEBUG)||defined(_DEBUG)
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"\nURL: %@\tParameters: %@\tError: %@", url, [requestParams yy_modelToJSONString], error);
                });
#endif
                failure ? failure(task, error) : nil;
                
                [[[self httpService] allSessionTask] removeObjectForKey:cacheKey];
            }];
        }
            break;
    }
    return dataTask;
}


/**
 网络请求统一处理不同的请求方法

 @param url 请求地址
 @param methodType 请求方法
 @param parameters 请求参数
 @param success 成功回调
 @param failure 失败回调
 @return 返回的对象可取消请求,调用cancle方法
 */
+ (NSURLSessionDataTask *)dataTaskWithURL:(NSString *)url
                               methodType:(STRequestType)methodType
                               parameters:(id)parameters
                                  success:(STSuccessBlock)success
                                  failure:(STFailureBlock)failure {
    
    NSString *requestURL = [[self httpService] filterURLWithURL:url];
    NSDictionary *requestParams = [[self httpService] fileterParamsWithParams:parameters];
    // 缓存请求
    NSString *cacheKey = [STHTTPCache cacheKeyWithURL:requestURL parameters:requestParams];
#if defined(DEBUG)||defined(_DEBUG)
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"\nURL: %@\nParameters: %@", url, parameters);
    });
#endif
    NSURLSessionDataTask *dataTask = nil;
    switch (methodType) {
        case STRequestTypeGET:
            dataTask = [[[self httpService] sessionManager] GET:requestURL parameters:requestParams progress:nil success:success failure:failure];
            break;
        case STRequestTypePOST:
            dataTask = [[[self httpService] sessionManager] POST:requestURL parameters:requestParams progress:nil success:success failure:failure];
            break;
        case STRequestTypeHEAD:
            dataTask = [[[self httpService] sessionManager] HEAD:requestURL parameters:requestParams success:nil failure:failure];
            break;
        case STRequestTypePUT:
            dataTask = [[[self httpService] sessionManager] PUT:requestURL parameters:requestParams success:success failure:failure];
            break;
        case STRequestTypePATCH:
            dataTask = [[[self httpService] sessionManager] PATCH:requestURL parameters:requestParams success:success failure:failure];
            break;
        case STRequestTypeDELETE:
            dataTask = [[[self httpService] sessionManager] DELETE:requestURL parameters:requestParams success:success failure:failure];
            break;
        default:
            break;
    }
    dataTask ? [[[self httpService] allSessionTask] setObject:dataTask forKey:cacheKey] : nil;
    return dataTask;
}


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
+ (NSURLSessionDataTask *)uploadWithURL:(NSString *)url
                                 params:(id)parameters
                                  files:(NSArray<STHTTPUploadItem *> *)files
                               progress:(void(^)(NSProgress *progress))progress
                                success:(STSuccessBlock)success
                                failure:(STFailureBlock)failure {
    
    NSString *requestURL = [[self httpService] filterURLWithURL:url];
    NSDictionary *requestParams = [[self httpService] fileterParamsWithParams:parameters];
    // 缓存请求
    NSString *cacheKey = [STHTTPCache cacheKeyWithURL:requestURL parameters:requestParams];
    
    NSURLSessionDataTask *dataTask = [[[self httpService] sessionManager] POST:requestURL parameters:requestParams constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        for (STHTTPUploadItem *model in files) {
            [formData appendPartWithFileData:model.fileData name:model.name fileName:model.fileName mimeType:model.mimeType];
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        if (progress) {
            progress(uploadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
#if defined(DEBUG)||defined(_DEBUG)
        NSLog(@"\nURL: %@\tParameters: %@\tResult: %@", url, [requestParams yy_modelToJSONString], responseObject);
#endif
        if (success) {
            success(task, responseObject);
        }
        [[[self httpService] allSessionTask] removeObjectForKey:cacheKey];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
#if defined(DEBUG)||defined(_DEBUG)
        NSLog(@"\nURL: %@\tParameters: %@\tError: %@", url, [requestParams yy_modelToJSONString], error);
#endif
        if (failure) {
            failure(task, error);
        }
        [[[self httpService] allSessionTask] removeObjectForKey:cacheKey];
    }];
    dataTask ? [[[self httpService] allSessionTask] setObject:dataTask forKey:cacheKey] : nil;
    return dataTask;
}

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
                            completionHandler:(void(^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler {
    
    NSString *requestURL = [[self httpService] filterURLWithURL:url];
    // 缓存请求
    NSString *cacheKey = [STHTTPCache cacheKeyWithURL:requestURL parameters:nil];
#if defined(DEBUG)||defined(_DEBUG)
    NSLog(@"\nUrl: %@", requestURL);
#endif
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:timeoutInterval];
    NSURLSessionDownloadTask *dataTask = [[[self httpService] sessionManager] downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
#if defined(DEBUG)||defined(_DEBUG)
        NSLog(@"\n下载进度: %.2f%%", 100.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
#endif
        progress ? progress(downloadProgress) : nil;
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        // 拼接缓存目录
        NSString *downloadDir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, true) lastObject] stringByAppendingPathComponent:@"Download"];
        // 判断是否存在缓存目录
        if (![[NSFileManager defaultManager] fileExistsAtPath:downloadDir]) {
            // 创建Download目录
            [[NSFileManager defaultManager] createDirectoryAtPath:downloadDir withIntermediateDirectories:true attributes:nil error:nil];
        }
        // 拼接文件路径 - block的返回值, 要求返回一个URL, 返回的这个URL就是文件的位置的路径
        NSString *filePath = [downloadDir stringByAppendingPathComponent:fileName];
#if defined(DEBUG)||defined(_DEBUG)
        NSLog(@"\nDownloadDir: %@", downloadDir);
#endif
        return [NSURL fileURLWithPath:filePath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        // filePath就是下载文件的位置，可以解压，也可以直接拿来使用
        if (completionHandler) {
            completionHandler(response, filePath, error);
        }
        [[[self httpService] allSessionTask] removeObjectForKey:cacheKey];
    }];
    // 开始下载
    [dataTask resume];
    dataTask ? [[[self httpService] allSessionTask] setObject:dataTask forKey:cacheKey] : nil;
    return dataTask;
}


#pragma mark - Private

/**
 过滤URL
 */
- (NSString *)filterURLWithURL:(NSString *)url  {
    
    NSString *requestURL = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    return requestURL;
}

/**
 过滤请求参数
 */
- (NSDictionary *)fileterParamsWithParams:(id)parameters {
    
    if ([parameters isKindOfClass:[NSDictionary class]]) {
        return parameters;
    }
    if ([parameters conformsToProtocol:@protocol(YYModel)])  {
        return [parameters yy_modelToJSONObject];
    }
    return @{};
}


@end

