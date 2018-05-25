//
//  STHttpConfig.h
//  STHTTPService
//
//  Created by MisakaTao on 2018/5/24.
//  Copyright © 2018年 Shengtao Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <YYModel/YYModel.h>

@interface STHTTPUploadItem : NSObject <YYModel, NSCoding, NSCopying>

/**
 *  文件数据
 */
@property (strong, nonatomic) NSData *fileData;

/**
 *  服务器接收参数名
 */
@property (copy, nonatomic) NSString *name;

/**
 *  文件名
 */
@property (copy, nonatomic) NSString *fileName;

/**
 *  文件类型
 */
@property (copy, nonatomic) NSString *mimeType;

+ (instancetype)modelWithfileData:(NSData *)fileData
                             name:(NSString *)name
                         fileName:(NSString *)fileName
                         mimeType:(NSString *)mimeType;

- (instancetype)initWithfileData:(NSData *)fileData
                            name:(NSString *)name
                        fileName:(NSString *)fileName
                        mimeType:(NSString *)mimeType;

@end
