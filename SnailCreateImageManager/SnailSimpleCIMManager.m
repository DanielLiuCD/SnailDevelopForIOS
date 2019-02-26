//
//  SnailSimpleCIMManager.m
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/6/25.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import "SnailSimpleCIMManager.h"

#define SNAILCIMPATH [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"SnailSimpleCIMImageFolder"]

#define SNAILCIMPATH_VERSION [SNAILCIMPATH stringByAppendingPathComponent:[self _TAKE_VERSION]]

#define SNAILCIM_H_PATH [SNAILCIMPATH_VERSION stringByAppendingPathComponent:@"H"]
#define SNAILCIM_V_PATH [SNAILCIMPATH_VERSION stringByAppendingPathComponent:@"V"]

#define SNAILIMAGEPATH_LANGUAGE(isV) [isV?SNAILCIM_V_PATH:SNAILCIM_H_PATH stringByAppendingPathComponent:[self _takeLanguadge]]

#define SNAILIMAGEPATH(isV,NAME) [SNAILIMAGEPATH_LANGUAGE(isV) stringByAppendingPathComponent:NAME]

#define SnailSimpleCIMManagerLanguageCode @"SnailSimpleCIMManagerLanguageCode"

@implementation SnailSimpleCIMManager

+ (void)customeLanguage:(NSString *)languageCode {
    
    if (![languageCode isKindOfClass:NSString.class]) return;
    
    if (languageCode) [[NSUserDefaults standardUserDefaults] setObject:languageCode forKey:SnailSimpleCIMManagerLanguageCode];
    else [[NSUserDefaults standardUserDefaults] removeObjectForKey:SnailSimpleCIMManagerLanguageCode];
}

+ (NSString *)_takeLanguadge {
    NSString *lan = [[NSUserDefaults standardUserDefaults] stringForKey:SnailSimpleCIMManagerLanguageCode];
    if (!lan) lan = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] firstObject];
    if (!lan) lan = @"unknow";
    return lan;
}

+ (NSString *)_TAKE_VERSION {
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    return [NSString stringWithFormat:@"%@-%@",version,build];
}

+ (UIImage *)takeCIM:(NSString *)name Cache:(BOOL)shouleCache Size:(CGSize (^)(void))sizeBlock Block:(void (^)(CGContextRef, CGRect, CGFloat))block {
    return [self _takeCIM:name Alpha:true Cache:shouleCache Size:sizeBlock Block:block];
}

+ (UIImage *)takeNoAlphaCIM:(NSString *)name Cache:(BOOL)shouleCache Size:(CGSize(^)(void))sizeBlock Block:(void(^)(CGContextRef ctx, CGRect rect, CGFloat scale))block {
    return [self _takeCIM:name Alpha:false Cache:shouleCache Size:sizeBlock Block:block];
}

+ (UIImage *)_takeCIM:(NSString *)name Alpha:(BOOL)alpha Cache:(BOOL)shouleCache Size:(CGSize (^)(void))sizeBlock Block:(void (^)(CGContextRef, CGRect, CGFloat))block {
    
    BOOL screen_v = true; //竖屏
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
            screen_v = false;
            break;
        default:
            screen_v = true;
            break;
    }
    
    UIImage *img;
    if (shouleCache) {
        NSString *path = SNAILIMAGEPATH(screen_v,name);
        img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfFile:path] scale:UIScreen.mainScreen.scale];
        if (img == nil) {
            NSFileManager *mn = [NSFileManager defaultManager];
            if ([mn fileExistsAtPath:SNAILCIMPATH] == false) {
                [mn createDirectoryAtPath:SNAILCIMPATH withIntermediateDirectories:true attributes:nil error:nil];
            }
            if ([mn fileExistsAtPath:SNAILCIMPATH_VERSION] == false) {
                [mn createDirectoryAtPath:SNAILCIMPATH_VERSION withIntermediateDirectories:true attributes:nil error:nil];
            }
            if (screen_v && [mn fileExistsAtPath:SNAILCIM_V_PATH] == false) {
                [mn createDirectoryAtPath:SNAILCIM_V_PATH withIntermediateDirectories:true attributes:nil error:nil];
            }
            else if ([mn fileExistsAtPath:SNAILCIM_H_PATH] == false) {
                [mn createDirectoryAtPath:SNAILCIM_H_PATH withIntermediateDirectories:true attributes:nil error:nil];
            }
            
            NSString *languageCode = SNAILIMAGEPATH_LANGUAGE(screen_v);
            if ([mn fileExistsAtPath:languageCode] == false) {
                [mn createDirectoryAtPath:languageCode withIntermediateDirectories:true attributes:nil error:nil];
            }
            
            img = [self createImgWithAlpha:alpha Size:sizeBlock Block:block];
            if (img) [UIImagePNGRepresentation(img) writeToFile:path atomically:true];
        }
    }
    else {
        img = [self createImgWithAlpha:alpha Size:sizeBlock Block:block];
    }
    
    return img;
    
}

+ (UIImage * )createImgWithAlpha:(BOOL)alpha Size:(CGSize (^)(void))sizeBlock Block:(void (^)(CGContextRef, CGRect, CGFloat))block {
    
    CGFloat scale = UIScreen.mainScreen.scale;
    CGSize si = sizeBlock();
    CGSize si_ceil = CGSizeMake(ceil(si.width), ceil(si.height));
    CGRect ctxRect = (CGRect){.origin = CGPointZero,.size={.width=si_ceil.width*scale,.height=si_ceil.height*scale}};
    
    CGImageAlphaInfo alphaInfo = alpha?kCGImageAlphaPremultipliedFirst:kCGImageAlphaNoneSkipFirst;
    
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(nil,
                                             ctxRect.size.width,
                                             ctxRect.size.height ,
                                             8,
                                             4 * ctxRect.size.width,
                                             space,
                                             alphaInfo | kCGBitmapByteOrder32Host);
    
    CGContextTranslateCTM(ctx, 0, ctxRect.size.height);
    CGContextScaleCTM(ctx, scale, -scale);
    
    UIGraphicsPushContext(ctx);
    CGContextClearRect(ctx, ctxRect);
    block(ctx,(CGRect){.origin=CGPointZero,.size=si_ceil},scale);
    UIGraphicsPopContext();
    CGColorSpaceRelease(space);
    
    CGImageRef imgRef = CGBitmapContextCreateImage(ctx);
    UIImage *img = [[UIImage alloc] initWithCGImage:imgRef scale:scale orientation:UIImageOrientationUp];
    CGContextRelease(ctx);
    CGImageRelease(imgRef);
    
    return img;
    
}

@end

#undef SNAILCIMPATH
#undef SNAILCIM_V_PATH
#undef SNAILCIM_H_PATH
#undef SNAILIMAGEPATH
