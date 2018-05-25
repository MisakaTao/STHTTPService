//
//  STHttpConfig.m
//  STHTTPService
//
//  Created by MisakaTao on 2018/5/24.
//  Copyright © 2018年 Shengtao Liu. All rights reserved.
//

#import "STHTTPUploadItem.h"

@implementation STHTTPUploadItem

/// Coding/Copying/hash/equal
- (void)encodeWithCoder:(NSCoder *)aCoder { [self yy_modelEncodeWithCoder:aCoder]; }
- (id)initWithCoder:(NSCoder *)aDecoder { return [self yy_modelInitWithCoder:aDecoder]; }
- (id)copyWithZone:(NSZone *)zone { return [self yy_modelCopy]; }
- (NSUInteger)hash { return [self yy_modelHash]; }
- (BOOL)isEqual:(id)object { return [self yy_modelIsEqual:object]; }

/// Properties optional
- (void)setValue:(id)value forUndefinedKey:(NSString *)key { }

/// desc
- (NSString *)description { return [self yy_modelDescription]; }


+ (instancetype)modelWithfileData:(NSData *)fileData
                             name:(NSString *)name
                         fileName:(NSString *)fileName
                         mimeType:(NSString *)mimeType {
    
    return [[STHTTPUploadItem alloc] initWithfileData:fileData
                                                 name:name
                                             fileName:fileName
                                             mimeType:mimeType];
}

- (instancetype)initWithfileData:(NSData *)fileData
                            name:(NSString *)name
                        fileName:(NSString *)fileName
                        mimeType:(NSString *)mimeType {
    
    self = [super init];
    if (self) {
        _fileData = fileData;
        _name = name;
        _mimeType = mimeType ? mimeType : [self contentTypeForImageData:fileData];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMddHHmmss"];
        NSString *fileDate = [formatter stringFromDate:[NSDate date]];
        _fileName = fileName ? fileName : [NSString stringWithFormat:@"%@.%@", fileName ? fileName : fileDate, _mimeType];
    }
    return self;
}

- (NSString *)contentTypeForImageData:(NSData *)data {
    
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return @"jpeg";
        case 0x89:
            return @"png";
        case 0x47:
            return @"gif";
        case 0x49:
        case 0x4D:
            return @"tiff";
        case 0x52:
            if ([data length] < 12) {
                return nil;
            }
            NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
            if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                return @"webp";
            }
            return nil;
    }
    return nil;
}

@end
