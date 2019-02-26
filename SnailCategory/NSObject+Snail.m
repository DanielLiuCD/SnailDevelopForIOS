//
//  NSObject+Snail.m
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/7/9.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import "NSObject+Snail.h"
#import <objc/runtime.h>
#import <mach/mach_time.h>

static char SNAILTEMPDATADICTIONARY;
static char SNAILOBJCPREVIEWTOKEN;

@interface NSObject()

/*-----------------------------------snailTempData------------------------------------------------------------*/

@property (nonatomic ,strong) NSMutableDictionary *snailTempDataDictionary;

/*-----------------------------------snailObjcPreview------------------------------------------------------------*/

@property (nonatomic ,strong) NSString *snailObjcPreviewTempToken;
@property (nonatomic ,strong) NSString *snailObjcPreviewToken;
@property (nonatomic) BOOL isCancleSnailObjcPreviewTask;
@property (nonatomic ,copy) NSMutableArray<void (^)(UIImage *previewImage)> *snailObjcPreviewBlocks;

@end

@implementation NSObject (Snail)

#pragma mark -

static dispatch_semaphore_t _snail_viewcontroller_dst_lock() {
    static dispatch_once_t onceToken;
    static dispatch_semaphore_t dst;
    dispatch_once(&onceToken, ^{
        dst = dispatch_semaphore_create(1);
    });
    return dst;
}

#pragma mark -

static dispatch_queue_t _snail_objc_create_preview_queue() {
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.snail.create.objc.preivew.image.queue", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}

#pragma mark -

#define SNAIL_DATA_PAGE_IDENTIFER_PRIVATE @"SNAIL_DATA_PAGE_IDENTIFER_PRIVATE"

- (NSNumber *)snailCurrentPage {
    NSNumber *num = [self snailTakeTempData:SNAIL_DATA_PAGE_IDENTIFER_PRIVATE];
    return num?:@0;
}

- (NSNumber *)snailLastPage {
    NSNumber *num = self.snailCurrentPage;
    if (!num) return @0;
    NSInteger tmp = num.integerValue - 1;
    if (tmp < 0) tmp = 0;
    return @(tmp);
}

- (NSNumber *)snailNextPage {
    NSNumber *num = self.snailCurrentPage;
    if (!num) return @0;
    return @(num.integerValue + 1);
}

- (void)snailPageAutoIncrement {
    NSNumber *num = self.snailNextPage;
    [self snailSaveTempData:SNAIL_DATA_PAGE_IDENTIFER_PRIVATE Data:@(num.integerValue + 1)];
}

- (BOOL)snailResetPage {
    [self snailSaveTempData:SNAIL_DATA_PAGE_IDENTIFER_PRIVATE Data:nil];
    return true;
}

#undef SNAIL_DATA_PAGE_IDENTIFER_PRIVATE

#pragma mark -

#define SNAILOBJCPREVIEWIMAGEFOLDER [NSTemporaryDirectory() stringByAppendingPathComponent:@"SNAILOBJCPREVIEWIMAGEFOLDER"]

- (UIImage *)snailCreateObjcPreviewImage {
    NSAssert(false, @"请自行实现");
    return nil;
};

- (void)clearSnailObjcPreviewImageCache {
    
    if (self.snailObjcPreviewToken) {
        
        NSFileManager *manager = [NSFileManager defaultManager];
        if (![manager fileExistsAtPath:SNAILOBJCPREVIEWIMAGEFOLDER]) {
            [manager createDirectoryAtPath:SNAILOBJCPREVIEWIMAGEFOLDER withIntermediateDirectories:true attributes:nil error:nil];
        }
        [manager removeItemAtPath:[SNAILOBJCPREVIEWIMAGEFOLDER stringByAppendingPathComponent:self.snailObjcPreviewToken] error:nil];
    }
    
}

- (BOOL)snailCreateObjcPreviewImageIsCancled {
    return self.isCancleSnailObjcPreviewTask;
}

- (void)snailCancleTakeObjcPreviewImage {
    self.isCancleSnailObjcPreviewTask = true;
    [self.snailObjcPreviewBlocks enumerateObjectsUsingBlock:^(void (^ _Nonnull obj)(UIImage *), NSUInteger idx, BOOL * _Nonnull stop) {
        obj(nil);
    }];
    [self.snailObjcPreviewBlocks removeAllObjects];
}

- (void)snailAsyncTakeObjcPreviewImage:(void (^)(UIImage *))block {
    
    dispatch_async(_snail_objc_create_preview_queue(), ^{
        [self snailSyncTakeObjcPreviewImage:block];
    });
    
}

- (void)snailSyncTakeObjcPreviewImage:(void (^)(UIImage *))block {
    
    self.isCancleSnailObjcPreviewTask = false;
    if (block) {
        [self.snailObjcPreviewBlocks addObject:block];
    }
    
    if (self.isCancleSnailObjcPreviewTask) {
        self.isCancleSnailObjcPreviewTask = false;
        [self.snailObjcPreviewBlocks enumerateObjectsUsingBlock:^(void (^ _Nonnull obj)(UIImage *), NSUInteger idx, BOOL * _Nonnull stop) {
            obj(nil);
        }];
        [self.snailObjcPreviewBlocks removeAllObjects];
        return;
    }
    
    UIImage *tmp = nil;
    
    if (self.snailObjcPreviewToken) {
        
        NSFileManager *manager = [NSFileManager defaultManager];
        if (![manager fileExistsAtPath:SNAILOBJCPREVIEWIMAGEFOLDER]) {
            [manager createDirectoryAtPath:SNAILOBJCPREVIEWIMAGEFOLDER withIntermediateDirectories:true attributes:nil error:nil];
        }
        
        if (self.isCancleSnailObjcPreviewTask) {
            self.isCancleSnailObjcPreviewTask = false;
            [self.snailObjcPreviewBlocks enumerateObjectsUsingBlock:^(void (^ _Nonnull obj)(UIImage *), NSUInteger idx, BOOL * _Nonnull stop) {
                obj(nil);
            }];
            [self.snailObjcPreviewBlocks removeAllObjects];
            return;
        }
        
        tmp = [UIImage imageWithContentsOfFile:[SNAILOBJCPREVIEWIMAGEFOLDER stringByAppendingPathComponent:self.snailObjcPreviewToken]];
        
    }
    
    if (tmp == nil) {
        
        if (self.isCancleSnailObjcPreviewTask) {
            self.isCancleSnailObjcPreviewTask = false;
            [self.snailObjcPreviewBlocks enumerateObjectsUsingBlock:^(void (^ _Nonnull obj)(UIImage *), NSUInteger idx, BOOL * _Nonnull stop) {
                obj(nil);
            }];
            [self.snailObjcPreviewBlocks removeAllObjects];
            return;
        }
        
        if (!self.snailObjcPreviewTempToken) {
            
            NSTimeInterval tim = [[NSDate date] timeIntervalSince1970];
            NSString *token = [NSString stringWithFormat:@"SNAILOBJCPREVIEWTOKEN%f",tim];
            self.snailObjcPreviewTempToken = token;
            tmp = [self snailCreateObjcPreviewImage];
            
            if (self.isCancleSnailObjcPreviewTask) {
                self.isCancleSnailObjcPreviewTask = false;
                [self.snailObjcPreviewBlocks enumerateObjectsUsingBlock:^(void (^ _Nonnull obj)(UIImage *), NSUInteger idx, BOOL * _Nonnull stop) {
                    obj(nil);
                }];
                [self.snailObjcPreviewBlocks removeAllObjects];
                self.snailObjcPreviewTempToken = nil;
                return;
            }
            
            self.snailObjcPreviewToken = self.snailObjcPreviewTempToken;
            self.snailObjcPreviewTempToken = nil;
            [UIImagePNGRepresentation(tmp) writeToFile:[SNAILOBJCPREVIEWIMAGEFOLDER stringByAppendingPathComponent:token] atomically:true];
            
        }
        else {
            return;
        }
        
    }
    
    if (self.isCancleSnailObjcPreviewTask) {
        self.isCancleSnailObjcPreviewTask = false;
        [self.snailObjcPreviewBlocks enumerateObjectsUsingBlock:^(void (^ _Nonnull obj)(UIImage *), NSUInteger idx, BOOL * _Nonnull stop) {
            obj(nil);
        }];
        [self.snailObjcPreviewBlocks removeAllObjects];
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.isCancleSnailObjcPreviewTask) {
            self.isCancleSnailObjcPreviewTask = false;
            [self.snailObjcPreviewBlocks enumerateObjectsUsingBlock:^(void (^ _Nonnull obj)(UIImage *), NSUInteger idx, BOOL * _Nonnull stop) {
                obj(nil);
            }];
            [self.snailObjcPreviewBlocks removeAllObjects];
            return;
        }
        
        [self.snailObjcPreviewBlocks enumerateObjectsUsingBlock:^(void (^ _Nonnull obj)(UIImage *), NSUInteger idx, BOOL * _Nonnull stop) {
            obj(tmp);
        }];
        self.isCancleSnailObjcPreviewTask = false;
        [self.snailObjcPreviewBlocks removeAllObjects];
        
    });
    
}

- (void)setSnailObjcPreviewTempToken:(NSString *)snailObjcPreviewTempToken {
    dispatch_semaphore_t dst = _snail_viewcontroller_dst_lock();
    dispatch_semaphore_wait(dst, DISPATCH_TIME_FOREVER);
    objc_setAssociatedObject(self, @selector(setSnailObjcPreviewTempToken:), snailObjcPreviewTempToken, OBJC_ASSOCIATION_RETAIN);
    dispatch_semaphore_signal(dst);
}

- (NSString *)snailObjcPreviewTempToken {
    NSString *tmp = nil;
    dispatch_semaphore_t dst = _snail_viewcontroller_dst_lock();
    dispatch_semaphore_wait(dst, DISPATCH_TIME_FOREVER);
    tmp = objc_getAssociatedObject(self, @selector(setSnailObjcPreviewTempToken:));
    dispatch_semaphore_signal(dst);
    return tmp;
}

- (void)setSnailObjcPreviewToken:(NSString *)snailObjcPreviewToken {
    [self clearSnailObjcPreviewImageCache];
    dispatch_semaphore_t dst = _snail_viewcontroller_dst_lock();
    dispatch_semaphore_wait(dst, DISPATCH_TIME_FOREVER);
    objc_setAssociatedObject(self, &SNAILOBJCPREVIEWTOKEN, snailObjcPreviewToken, OBJC_ASSOCIATION_RETAIN);
    dispatch_semaphore_signal(dst);
}

- (NSString *)snailObjcPreviewToken {
    NSString *tmp = nil;
    dispatch_semaphore_t dst = _snail_viewcontroller_dst_lock();
    dispatch_semaphore_wait(dst, DISPATCH_TIME_FOREVER);
    tmp = objc_getAssociatedObject(self, &SNAILOBJCPREVIEWTOKEN);
    dispatch_semaphore_signal(dst);
    return tmp;
}

- (NSMutableArray<void (^)(UIImage *)> *)snailObjcPreviewBlocks {
    NSMutableArray *tmp = nil;
    dispatch_semaphore_t dst = _snail_viewcontroller_dst_lock();
    dispatch_semaphore_wait(dst, DISPATCH_TIME_FOREVER);
    tmp = objc_getAssociatedObject(self, @selector(snailObjcPreviewBlocks));
    if (!tmp) {
        tmp = [NSMutableArray new];
        objc_setAssociatedObject(self, @selector(snailObjcPreviewBlocks), tmp, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    dispatch_semaphore_signal(dst);
    return tmp;
}

- (void)setIsCancleSnailObjcPreviewTask:(BOOL)isCancleSnailObjcPreviewTask {
    dispatch_semaphore_t dst = _snail_viewcontroller_dst_lock();
    dispatch_semaphore_wait(dst, DISPATCH_TIME_FOREVER);
    objc_setAssociatedObject(self, @selector(setIsCancleSnailObjcPreviewTask:), @(isCancleSnailObjcPreviewTask), OBJC_ASSOCIATION_RETAIN);
    dispatch_semaphore_signal(dst);
}

- (BOOL)isCancleSnailObjcPreviewTask {
    BOOL tmp = false;
    dispatch_semaphore_t dst = _snail_viewcontroller_dst_lock();
    dispatch_semaphore_wait(dst, DISPATCH_TIME_FOREVER);
    tmp = [objc_getAssociatedObject(self, @selector(setIsCancleSnailObjcPreviewTask:)) boolValue];
    dispatch_semaphore_signal(dst);
    return tmp;
}

- (BOOL)snailIsHaveCachedPreviewImage {
    if (self.snailObjcPreviewToken) return [[NSFileManager defaultManager] fileExistsAtPath:[SNAILOBJCPREVIEWIMAGEFOLDER stringByAppendingPathComponent:self.snailObjcPreviewToken]];
    return false;
}

- (BOOL)snailIsCreatingPreviewImage {
    return self.snailObjcPreviewTempToken != nil;
}

#undef SNAILOBJCPREVIEWIMAGEFOLDER

#pragma mark -

- (void)snailSaveTempData:(NSString *)key Data:(id)data {
    if (key == nil) return;
    dispatch_semaphore_t dst = _snail_viewcontroller_dst_lock();
    dispatch_semaphore_wait(dst, DISPATCH_TIME_FOREVER);
    if (data == nil) [self.snailTempDataDictionary removeObjectForKey:key];
    else [self.snailTempDataDictionary setObject:data forKey:key];
    dispatch_semaphore_signal(dst);
}

- (void)snailSaveTempDatas:(NSArray<NSString *> *)keys Data:(NSArray *)datas {
    if (keys == nil) return;
    dispatch_semaphore_t dst = _snail_viewcontroller_dst_lock();
    dispatch_semaphore_wait(dst, DISPATCH_TIME_FOREVER);
    for (int i = 0; i < keys.count; i++) {
        if (i < datas.count) self.snailTempDataDictionary[keys[i]] = datas[i];
    }
    dispatch_semaphore_signal(dst);
}

- (id)snailTakeTempData:(NSString *)key {
    if (key == nil) return nil;
    return self.snailTempDataDictionary[key];
}

- (void)snailClearTempData {
    dispatch_semaphore_t dst = _snail_viewcontroller_dst_lock();
    dispatch_semaphore_wait(dst, DISPATCH_TIME_FOREVER);
    [self.snailTempDataDictionary removeAllObjects];
    dispatch_semaphore_signal(dst);
}

- (NSMutableDictionary *)snailTempDataDictionary {
    NSMutableDictionary *dic = objc_getAssociatedObject(self, &SNAILTEMPDATADICTIONARY);
    if (dic == nil) {
        dic = [NSMutableDictionary new];
        objc_setAssociatedObject(self, &SNAILTEMPDATADICTIONARY, dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return dic;
}

@end
