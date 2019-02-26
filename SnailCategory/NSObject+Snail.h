//
//  NSObject+Snail.h
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/7/9.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Snail)

#pragma mark - 获取一个分页数字 最小0

- (NSNumber *)snailCurrentPage;
- (NSNumber *)snailLastPage;
- (NSNumber *)snailNextPage;
- (void)snailPageAutoIncrement; //自增一个page
- (BOOL)snailResetPage;

#pragma mark - 获取NSObject的图片 ,默认缓存

- (UIImage *)snailCreateObjcPreviewImage; //需要自己实现
- (void)snailAsyncTakeObjcPreviewImage:(void(^)(UIImage *previewImage))block;
- (void)snailSyncTakeObjcPreviewImage:(void(^)(UIImage *previewImage))block;
- (void)snailCancleTakeObjcPreviewImage;
- (void)clearSnailObjcPreviewImageCache;
- (BOOL)snailCreateObjcPreviewImageIsCancled;
- (BOOL)snailIsHaveCachedPreviewImage;
- (BOOL)snailIsCreatingPreviewImage;

#pragma mark -

- (void)snailSaveTempData:(NSString *)key Data:(id)data;

- (void)snailSaveTempDatas:(NSArray<NSString *> *)keys Data:(NSArray *)datas;

- (id)snailTakeTempData:(NSString *)key;

- (void)snailClearTempData;

@end
