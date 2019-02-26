//
//  SnailPostManCacheController.m
//  SnailPostMan
//
//  Created by JobNewMac1 on 2018/12/11.
//  Copyright © 2018年 com.crazysnail. All rights reserved.
//

#import "SnailPostManCacheController.h"
#import "SnailPostManUtil.h"

@interface SnailPostManPrivateArchiveCache : NSObject<SnailPostManCacheProtocol>

@end

@implementation SnailPostManPrivateArchiveCache

#define SnailPostManArchiveFolder [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"SnailPostManDiskArchiveCache"]

+ (BOOL)saveCacheWithPath:(NSString *)path Header:(NSDictionary *)header Cookies:(NSDictionary *)cookies Params:(NSDictionary *)params MethodType:(NSString *)methodType Tag:(NSInteger)tag Context:(id)context Time:(NSTimeInterval)tim Response:(id)response {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:SnailPostManArchiveFolder isDirectory:nil] == false) {
        [fileManager createDirectoryAtPath:SnailPostManArchiveFolder withIntermediateDirectories:true attributes:nil error:nil];
    }
    
    NSString *identifer = [SnailPostManUtil createRequestIdentifer:path Header:header Cookie:cookies Params:params Tag:tag];
    NSString *target = [SnailPostManArchiveFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.archive",identifer]];
    
    if ([fileManager fileExistsAtPath:target]) {
        [fileManager removeItemAtPath:target error:nil];
    }
    
    [NSKeyedArchiver archiveRootObject:@{@"timeout":[NSDate dateWithTimeIntervalSinceNow:tim],@"result":response} toFile:target];
    
    return true;
    
}

+ (BOOL)haveCacheWithPath:(NSString *)path Header:(NSDictionary *)header Cookies:(NSDictionary *)cookies Params:(NSDictionary *)params MethodType:(NSString *)methodType Tag:(NSInteger)tag Context:(id)context {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:SnailPostManArchiveFolder isDirectory:nil] == false) {
        [fileManager createDirectoryAtPath:SnailPostManArchiveFolder withIntermediateDirectories:true attributes:nil error:nil];
    }
    
    NSString *identifer = [SnailPostManUtil createRequestIdentifer:path Header:header Cookie:cookies Params:params Tag:tag];
    NSString *target = [SnailPostManArchiveFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.archive",identifer]];
    
    if ([fileManager fileExistsAtPath:target] == false) return false;
    
    NSDictionary *dic = [NSKeyedUnarchiver unarchiveObjectWithFile:target];
    
    NSDate *outDate = dic[@"timeout"];
    NSTimeInterval invoffset = [outDate timeIntervalSinceDate:[NSDate date]];
    
    if (invoffset <= 0) {
        [fileManager removeItemAtPath:target error:nil];
        return false;
    }
    return true;
    
}

+ (id)takeCacheWithPath:(NSString *)path Header:(NSDictionary *)header Cookies:(NSDictionary *)cookies Params:(NSDictionary *)params MethodType:(NSString *)methodType Tag:(NSInteger)tag Context:(id)context {
    
    NSString *identifer = [SnailPostManUtil createRequestIdentifer:path Header:header Cookie:cookies Params:params Tag:tag];
    NSString *target = [SnailPostManArchiveFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.archive",identifer]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:target] == false) {
        return nil;
    }
    else {
        
        NSDictionary *dic = [NSKeyedUnarchiver unarchiveObjectWithFile:target];
        NSDate *outDate = dic[@"timeout"];
        NSTimeInterval invoffset = [outDate timeIntervalSinceDate:[NSDate date]];
        
        if (invoffset <= 0) {
            [fileManager removeItemAtPath:target error:nil];
            return nil;
        }
        
        return dic[@"result"];
    }
    
}

+ (BOOL)removeCacheWithPath:(NSString *)path Header:(NSDictionary *)header Cookies:(NSDictionary *)cookies Params:(NSDictionary *)params MethodType:(NSString *)methodType Tag:(NSInteger)tag Context:(id)context {
    
    NSString *identifer = [SnailPostManUtil createRequestIdentifer:path Header:header Cookie:cookies Params:params Tag:tag];
    NSString *target = [SnailPostManArchiveFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.archive",identifer]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:target]) {
        [fileManager removeItemAtPath:target error:nil];
    }
    return true;
}

#undef SnailPostManArchiveFolder

@end

@interface SnailPostManPrivateMemoryNSCache : NSObject<SnailPostManCacheProtocol>

@property (nonatomic ,strong) NSCache *cache;

@end

@implementation SnailPostManPrivateMemoryNSCache

+ (instancetype)shared {
    static SnailPostManPrivateMemoryNSCache *cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [SnailPostManPrivateMemoryNSCache new];
        cache.cache.totalCostLimit = 1024 * 1024 * 20;
    });
    return cache;
}

+ (BOOL)saveCacheWithPath:(NSString *)path
                   Header:(NSDictionary *)header
                  Cookies:(NSDictionary *)cookies
                   Params:(NSDictionary *)params
               MethodType:(NSString *)methodTypeName
                      Tag:(NSInteger)tag
                  Context:(id)context
                     Time:(NSTimeInterval)tim
                 Response:(id)response {
    
    NSString *tempIdentifer = [SnailPostManUtil createRequestIdentifer:path Header:header Cookie:cookies Params:params Tag:tag];
    SnailPostManPrivateMemoryNSCache *cache = [self shared];
    NSTimeInterval timtmp = [NSDate timeIntervalSinceReferenceDate];
    [cache.cache setObject:@{@"timeout":@(timtmp+tim),@"result":response} forKey:tempIdentifer];
    return true;
    
}

+ (BOOL)haveCacheWithPath:(NSString *)path Header:(NSDictionary *)header Cookies:(NSDictionary *)cookies Params:(NSDictionary *)params MethodType:(NSString *)methodType Tag:(NSInteger)tag Context:(id)context {
    
    NSString *tempIdentifer = [SnailPostManUtil createRequestIdentifer:path Header:header Cookie:cookies Params:params Tag:tag];
    SnailPostManPrivateMemoryNSCache *cache = [self shared];
    NSDictionary *dic = [cache.cache objectForKey:tempIdentifer];
    if (dic == nil) return true;
    NSTimeInterval timOut = [dic[@"timeout"] doubleValue];
    NSTimeInterval timNow = [NSDate timeIntervalSinceReferenceDate];
    if (timOut <= timNow) {
        [cache.cache removeObjectForKey:tempIdentifer];
        return false;
    }
    return true;
    
}

+ (id)takeCacheWithPath:(NSString *)path Header:(NSDictionary *)header Cookies:(NSDictionary *)cookies Params:(NSDictionary *)params MethodType:(NSString *)methodType Tag:(NSInteger)tag Context:(id)context {
    
    NSString *tempIdentifer = [SnailPostManUtil createRequestIdentifer:path Header:header Cookie:cookies Params:params Tag:tag];
    SnailPostManPrivateMemoryNSCache *cache = [self shared];
    NSDictionary *dic = [cache.cache objectForKey:tempIdentifer];
    NSTimeInterval timOut = [dic[@"timeout"] doubleValue];
    NSTimeInterval timNow = [NSDate timeIntervalSinceReferenceDate];
    if (timOut <= timNow) {
        [cache.cache removeObjectForKey:tempIdentifer];
        return nil;
    }
    return dic[@"result"];
    
}

+ (BOOL)removeCacheWithPath:(NSString *)path Header:(NSDictionary *)header Cookies:(NSDictionary *)cookies Params:(NSDictionary *)params MethodType:(NSString *)methodType Tag:(NSInteger)tag Context:(id)context {
    
    NSString *tempIdentifer = [SnailPostManUtil createRequestIdentifer:path Header:header Cookie:cookies Params:params Tag:tag];
    SnailPostManPrivateMemoryNSCache *cache = [self shared];
    [cache.cache removeObjectForKey:tempIdentifer];
    return true;
    
}




@end

@implementation SnailPostManCacheController

+ (BOOL)saveCacheType:(SnailPostManCacheStrategy)cacheStrategy Path:(NSString *)path Header:(NSDictionary *)header Cookies:(NSDictionary *)cookies Params:(NSDictionary *)params MethodType:(NSString *)methodType Tag:(NSInteger)tag Context:(id)context Response:(id)response Time:(NSTimeInterval)tim{
    
    switch (cacheStrategy) {
        case SnailPostManCacheStrategyMemoryCache:  return [SnailPostManPrivateMemoryNSCache saveCacheWithPath:path Header:header Cookies:cookies Params:params MethodType:methodType Tag:tag Context:context Time:tim Response:response];
            break;
        case SnailPostManCacheStrategyArchive: return [SnailPostManPrivateArchiveCache saveCacheWithPath:path Header:header Cookies:cookies Params:params MethodType:methodType Tag:tag Context:context Time:tim Response:response ];
            break;
        case SnailPostManCacheStrategyCustome:
            break;
        default:
            break;
    }
    return false;
    
}

+ (BOOL)haveCacheType:(SnailPostManCacheStrategy)cacheStrategy Path:(NSString *)path Header:(NSDictionary *)header Cookies:(NSDictionary *)cookies Params:(NSDictionary *)params MethodType:(NSString *)methodType Tag:(NSInteger)tag Context:(id)context{
    
    switch (cacheStrategy) {
        case SnailPostManCacheStrategyMemoryCache: return [SnailPostManPrivateMemoryNSCache haveCacheWithPath:path Header:header Cookies:cookies Params:params MethodType:methodType Tag:tag Context:context];
            break;
        case SnailPostManCacheStrategyArchive: return [SnailPostManPrivateArchiveCache haveCacheWithPath:path Header:header Cookies:cookies Params:params MethodType:methodType Tag:tag Context:context];
            break;
        case SnailPostManCacheStrategyCustome:
            break;
        default:
            break;
    }
    
    return false;
    
}

+ (id)takeCacheType:(SnailPostManCacheStrategy)cacheStrategy Path:(NSString *)path Header:(NSDictionary *)header Cookies:(NSDictionary *)cookies Params:(NSDictionary *)params MethodType:(NSString *)methodType Tag:(NSInteger)tag Context:(id)context{
    
    switch (cacheStrategy) {
        case SnailPostManCacheStrategyMemoryCache: return [SnailPostManPrivateMemoryNSCache takeCacheWithPath:path Header:header Cookies:cookies Params:params MethodType:methodType Tag:tag Context:context];
            break;
        case SnailPostManCacheStrategyArchive: return [SnailPostManPrivateArchiveCache takeCacheWithPath:path Header:header Cookies:cookies Params:params MethodType:methodType Tag:tag Context:context];
            break;
        case SnailPostManCacheStrategyCustome:
            break;
        default:
            break;
    }
    
    return nil;
    
}

+ (BOOL)removeCacheType:(SnailPostManCacheStrategy)cacheStrategy Path:(NSString *)path Header:(NSDictionary *)header Cookies:(NSDictionary *)cookies Params:(NSDictionary *)params MethodType:(NSString *)methodType Tag:(NSInteger)tag Context:(id)context {
    
    switch (cacheStrategy) {
        case SnailPostManCacheStrategyMemoryCache: return [SnailPostManPrivateMemoryNSCache takeCacheWithPath:path Header:header Cookies:cookies Params:params MethodType:methodType Tag:tag Context:context];
            break;
        case SnailPostManCacheStrategyArchive: return [SnailPostManPrivateArchiveCache takeCacheWithPath:path Header:header Cookies:cookies Params:params MethodType:methodType Tag:tag Context:context];
            break;
        case SnailPostManCacheStrategyCustome:
            break;
        default:
            break;
    }
    
    return false;
    
}

@end
