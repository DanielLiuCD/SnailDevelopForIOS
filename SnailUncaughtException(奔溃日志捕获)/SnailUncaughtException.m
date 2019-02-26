//
//  SnailUncaughtException.m
//  KuaiYiTou
//
//  Created by JobNewMac1 on 2019/1/7.
//  Copyright © 2019年 com.jonnew. All rights reserved.
//

#import "SnailUncaughtException.h"
#import <objc/runtime.h>
#import <sys/utsname.h>

@interface SnailUncaughtExceptionItem : NSObject

@property (nonatomic ,strong) NSString *name;
@property (nonatomic ,strong) NSString *path;

- (NSString *)content;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end

@implementation SnailUncaughtExceptionItem

- (NSString *)content {
    return [[NSString alloc] initWithContentsOfFile:self.path encoding:NSUTF8StringEncoding error:nil];
}

@end

@implementation SnailUncaughtException

static UIViewController *topViewController(UIViewController *rootViewController) {
    
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        
        UITabBarController *tabBarController = (UITabBarController *)rootViewController;
        return topViewController(tabBarController.selectedViewController);
        
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return topViewController(navigationController.visibleViewController);
        
    } else if (rootViewController.presentedViewController) {
        
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return topViewController(presentedViewController);
        
    } else {
        return rootViewController;
    }
    
}

static NSString* deviceModelName(void)
{
    
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    //iPhone 系列
    
    if ([deviceModel isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([deviceModel isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([deviceModel isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([deviceModel isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceModel isEqualToString:@"iPhone3,2"])    return @"Verizon iPhone 4";
    if ([deviceModel isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceModel isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceModel isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([deviceModel isEqualToString:@"iPhone5,3"])    return @"iPhone 5C";
    if ([deviceModel isEqualToString:@"iPhone5,4"])    return @"iPhone 5C";
    if ([deviceModel isEqualToString:@"iPhone6,1"])    return @"iPhone 5S";
    if ([deviceModel isEqualToString:@"iPhone6,2"])    return @"iPhone 5S";
    if ([deviceModel isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceModel isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceModel isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceModel isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceModel isEqualToString:@"iPhone9,1"])    return @"iPhone 7 (CDMA)";
    if ([deviceModel isEqualToString:@"iPhone9,3"])    return @"iPhone 7 (GSM)";
    if ([deviceModel isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus (CDMA)";
    if ([deviceModel isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus (GSM)";
    if ([deviceModel isEqualToString:@"iPhone10,1"]) return @"iPhone 8 (Global)";
    if ([deviceModel isEqualToString:@"iPhone10,4"]) return @"iPhone 8 (GSM)";
    if ([deviceModel isEqualToString:@"iPhone10,2"]) return @"iPhone 8 Plus (Global)";
    if ([deviceModel isEqualToString:@"iPhone10,5"]) return @"iPhone 8 Plus (GSM)";
    if ([deviceModel isEqualToString:@"iPhone10,3"]) return @"iPhone X (Global)";
    if ([deviceModel isEqualToString:@"iPhone10,6"]) return @"iPhone X (GSM)";
    if ([deviceModel isEqualToString:@"iPhone11,2"]) return @"iPhone XS";
    if ([deviceModel isEqualToString:@"iPhone11,4"]) return @"iPhone XS Max";
    if ([deviceModel isEqualToString:@"iPhone11,6"]) return @"iPhone XS Max";
    if ([deviceModel isEqualToString:@"iPhone11,8"]) return @"iPhone XR";
    if ([deviceModel hasPrefix:@"iPhone"]) return @"iPhone";
    
    //iPod 系列
    if ([deviceModel isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceModel isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceModel isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceModel isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceModel isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    if ([deviceModel hasPrefix:@"iPod"]) return @"iPod";
    
    //iPad 系列
    if ([deviceModel isEqualToString:@"iPad1,1"])      return @"iPad";
    
    if ([deviceModel isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([deviceModel isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceModel isEqualToString:@"iPad2,4"])      return @"iPad 2 (32nm)";
    
    if ([deviceModel isEqualToString:@"iPad2,5"])      return @"iPad mini (WiFi)";
    if ([deviceModel isEqualToString:@"iPad2,6"])      return @"iPad mini (GSM)";
    if ([deviceModel isEqualToString:@"iPad2,7"])      return @"iPad mini (CDMA)";
    
    if ([deviceModel isEqualToString:@"iPad3,1"])      return @"iPad 3(WiFi)";
    if ([deviceModel isEqualToString:@"iPad3,2"])      return @"iPad 3(CDMA)";
    if ([deviceModel isEqualToString:@"iPad3,3"])      return @"iPad 3(4G)";
    
    if ([deviceModel isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad3,5"])      return @"iPad 4 (4G)";
    if ([deviceModel isEqualToString:@"iPad3,6"])      return @"iPad 4 (CDMA)";
    
    if ([deviceModel isEqualToString:@"iPad4,1"])      return @"iPad Air";
    if ([deviceModel isEqualToString:@"iPad4,2"])      return @"iPad Air";
    if ([deviceModel isEqualToString:@"iPad4,3"])      return @"iPad Air";
    if ([deviceModel isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([deviceModel isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    
    if ([deviceModel isEqualToString:@"i386"])        return @"Simulator";
    if ([deviceModel isEqualToString:@"x86_64"])       return @"Simulator";
    
    if ([deviceModel isEqualToString:@"iPad4,4"]||[deviceModel isEqualToString:@"iPad4,5"]||[deviceModel isEqualToString:@"iPad4,6"])      return @"iPad mini 2";
    
    if ([deviceModel isEqualToString:@"iPad4,7"]||[deviceModel isEqualToString:@"iPad4,8"]||[deviceModel isEqualToString:@"iPad4,9"])      return @"iPad mini 3";
    
    if ([deviceModel hasPrefix:@"iPad"]) return @"iPad";
    
    return deviceModel;
    
}

static void UncaughtExceptionHandler(NSException *exception) {
    
    NSMutableString *string = [NSMutableString new];

    //异常信息
    NSArray *callStack = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    
    //日期
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString * dateStr = [formatter stringFromDate:[NSDate date]];
    
    //获取崩溃界面
    UIViewController * viewNow = topViewController([UIApplication sharedApplication].keyWindow.rootViewController);
    //class 转字符串
    NSString * nowview = NSStringFromClass([viewNow class]);
    
    //app版本
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *buildVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
    //iOS系统
    NSString * devicetext = [NSString stringWithFormat:@"%f",[[[UIDevice currentDevice] systemVersion] floatValue]];
    //设备
    NSString *deviceStr = deviceModelName();
    
    [string appendFormat:@"Date: %@",dateStr];
    [string appendFormat:@"\n\n"];
    [string appendFormat:@"Version: %@",appCurVersion];
    [string appendFormat:@"\n\n"];
    [string appendFormat:@"Build: %@",buildVersion];
    [string appendFormat:@"\n\n"];
    [string appendFormat:@"OS: %@",devicetext];
    [string appendFormat:@"\n\n"];
    [string appendFormat:@"Device: %@",deviceStr];
    [string appendFormat:@"\n\n"];
    [string appendFormat:@"View: %@",nowview];
    [string appendFormat:@"\n\n"];
    [string appendFormat:@"Error: %@",name];
    [string appendFormat:@"\n\n"];
    [string appendFormat:@"Reasion: %@",reason];
    
    UIApplication *application = [UIApplication sharedApplication];
    
    NSString *(^block)(void) = objc_getAssociatedObject(application, "SNAIL_UNCAUGHT_EXCEPTIONHANDER_BLOCK_KEY");
    if (block) {
        NSString *otherInfo = block();
        [string appendFormat:@"\n\n"];
        [string appendFormat:@"Other Info: %@",otherInfo];
    }
    
    NSString *callBack = [callStack componentsJoinedByString:@"\n"];
    
    [string appendFormat:@"\n\n"];
    [string appendString:@"CallStack:"];
    [string appendFormat:@"\n\n"];
    [string appendString:callBack];
    
    NSString *root = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, true).firstObject;
    NSString *folder = [root stringByAppendingPathComponent:@"SNAIL_UNCAUGHT_EXCEPTIONHANDER"];
    NSString *path = [folder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%ld.log",[NSUUID UUID].UUIDString,(long)[[NSDate date] timeIntervalSince1970]]];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folder]) {
        [manager createDirectoryAtPath:folder withIntermediateDirectories:true attributes:nil error:nil];
    }
    if ([manager fileExistsAtPath:path]) {
        [manager removeItemAtPath:path error:nil];
    }
    [string writeToURL:[NSURL fileURLWithPath:path] atomically:true encoding:NSUTF8StringEncoding error:nil];
    
}

+ (void)SET_UncaughtException:(NSString *(^)(void))block {
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
    UIApplication *application = [UIApplication sharedApplication];
    objc_setAssociatedObject(application, "SNAIL_UNCAUGHT_EXCEPTIONHANDER_BLOCK_KEY", block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+ (NSArray<NSURL *> *)TAKE_ALL_Exception {
    
    NSString *root = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, true).firstObject;
    NSString *folder = [root stringByAppendingPathComponent:@"SNAIL_UNCAUGHT_EXCEPTIONHANDER"];
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folder]) {
        [manager createDirectoryAtPath:folder withIntermediateDirectories:true attributes:nil error:nil];
        return nil;
    }
    NSMutableArray *tmps = [NSMutableArray new];
    NSDirectoryEnumerator<NSString *> *enume = [manager enumeratorAtPath:folder];
    
    NSString *name = nil;
    while ((name = enume.nextObject)) {
        NSString *path = [folder stringByAppendingPathComponent:name];
        if ([name hasSuffix:@"log"]) {
            [tmps addObject:[NSURL fileURLWithPath:path]];
        }
    }
    return tmps.copy;

}

+ (NSArray<SnailUncaughtExceptionItem *> *)takeAllItem {
    
    NSString *root = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, true).firstObject;
    NSString *folder = [root stringByAppendingPathComponent:@"SNAIL_UNCAUGHT_EXCEPTIONHANDER"];
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folder]) {
        [manager createDirectoryAtPath:folder withIntermediateDirectories:true attributes:nil error:nil];
        return nil;
    }
    NSMutableArray *tmps = [NSMutableArray new];
    NSDirectoryEnumerator<NSString *> *enume = [manager enumeratorAtPath:folder];
    
    NSString *name = nil;
    while ((name = enume.nextObject)) {
        NSString *path = [folder stringByAppendingPathComponent:name];
        if ([name hasSuffix:@"log"]) {
            SnailUncaughtExceptionItem *item = [NSClassFromString(@"SnailUncaughtExceptionItem") new];
            item.name = name;
            item.path = path;
            [tmps addObject:item];
        }
    }
    
    [tmps sortUsingComparator:^NSComparisonResult(SnailUncaughtExceptionItem *obj1, SnailUncaughtExceptionItem *obj2) {
        
        NSArray *tmps1 = [obj1.name componentsSeparatedByString:@"-"];
        NSInteger time1 = [[(NSString *)tmps1.lastObject stringByDeletingPathExtension] integerValue];
        
        NSArray *tmps2 = [obj2.name componentsSeparatedByString:@"-"];
        NSInteger time2 = [[(NSString *)tmps2.lastObject stringByDeletingPathExtension] integerValue];
        
        if (time1 < time2) return NSOrderedDescending;
        else if (time2 > time1) return NSOrderedAscending;
        return NSOrderedSame;
    }];
    
    return tmps.copy;
    
}

+ (void)clear:(NSString *)name {
    
    NSString *root = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, true).firstObject;
    NSString *folder = [root stringByAppendingPathComponent:@"SNAIL_UNCAUGHT_EXCEPTIONHANDER"];
    NSString *path = [folder stringByAppendingPathComponent:name];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folder]) {
        [manager createDirectoryAtPath:folder withIntermediateDirectories:true attributes:nil error:nil];
    }
    if ([manager fileExistsAtPath:path]) {
        [manager removeItemAtPath:path error:nil];
    }
    
}

+ (void)clear {
    
    NSString *root = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, true).firstObject;
    NSString *folder = [root stringByAppendingPathComponent:@"SNAIL_UNCAUGHT_EXCEPTIONHANDER"];

    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:folder]) {
        [manager removeItemAtPath:folder error:nil];
        [manager createDirectoryAtPath:folder withIntermediateDirectories:true attributes:nil error:nil];
    }
    
}

@end
