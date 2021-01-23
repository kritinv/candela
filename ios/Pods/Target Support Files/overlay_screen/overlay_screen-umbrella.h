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

#import "OverlayScreenPlugin.h"

FOUNDATION_EXPORT double overlay_screenVersionNumber;
FOUNDATION_EXPORT const unsigned char overlay_screenVersionString[];

