#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "STHTTPCache.h"
#import "STHTTPService.h"
#import "STHTTPUploadItem.h"

FOUNDATION_EXPORT double STHTTPServiceVersionNumber;
FOUNDATION_EXPORT const unsigned char STHTTPServiceVersionString[];

