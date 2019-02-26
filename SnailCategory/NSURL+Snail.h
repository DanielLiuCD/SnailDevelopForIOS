//
//  NSURL+Snail.h
//  lesan
//
//  Created by JobNewMac1 on 2018/9/6.
//  Copyright © 2018年 ning. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SnailVideoInfoModel : NSObject

kSPrStrong(UIImage *firstFrameImage)
kSPr(NSTimeInterval duration)
kSPr(NSUInteger fileSize)

@end

@interface NSURL (Snail)

///文件大小
- (NSUInteger)snail_takeFileSize;

///音频时长
- (NSTimeInterval)snail_takeAudioDuration;

///视频压缩
- (void)snail_compressVudeoDesUrl:(NSURL *)desUrl Complete:(void(^)(BOOL isSuccess))block;

///获取视频第一帧图片
- (UIImage *)snail_takeVideoFirstFrameImage;

///获取视频信息
- (void)snail_takeVideoInfoBlock:(void(^)(SnailVideoInfoModel *videoInfo))block;

@end
