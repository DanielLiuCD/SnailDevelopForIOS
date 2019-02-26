//
//  NSURL+Snail.m
//  lesan
//
//  Created by JobNewMac1 on 2018/9/6.
//  Copyright © 2018年 ning. All rights reserved.
//

#import "NSURL+Snail.h"
@import AVFoundation;

@implementation SnailVideoInfoModel

@end

@implementation NSURL (Snail)

- (NSUInteger)snail_takeFileSize {
    return [[NSData dataWithContentsOfURL:self] length];
}

- (NSTimeInterval)snail_takeAudioDuration {
    
    AVURLAsset*audioAsset = [AVURLAsset URLAssetWithURL:self options:nil];
    Float64 duration = CMTimeGetSeconds(audioAsset.duration);
    return duration;

}

/*
 压缩的质量
 AVAssetExportPresetLowQuality   最low的画质最好不要选择实在是看不清楚
 AVAssetExportPresetMediumQuality  使用到压缩的话都说用这个
 AVAssetExportPresetHighestQuality  最清晰的画质
 */
- (void)snail_compressVudeoDesUrl:(NSURL *)desUrl Complete:(void(^)(BOOL isSuccess))block {
    
#ifdef DEBUG
    NSLog(@"压缩前大小 %f MB",[self snail_takeFileSize]);
#endif
    AVAsset* asset = [AVAsset assetWithURL:self];
    
    AVAssetExportSession * session = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    session.shouldOptimizeForNetworkUse = YES;
    
    [[NSFileManager defaultManager] removeItemAtURL:desUrl error:nil];
    
    session.outputURL = desUrl;
    session.outputFileType = AVFileTypeMPEG4;
    
    [session exportAsynchronouslyWithCompletionHandler:^{
        
        if (session.status==AVAssetExportSessionStatusCompleted) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
#ifdef DEBUG
                NSLog(@"压缩完毕,压缩后大小 %f MB",[self snail_takeFileSize]);
#endif
                if (block) block(true);
                
            });
            
        }
        
    }];
    
}

- (UIImage *)_snail_takeVideoFirstFrameImage:(AVURLAsset *)asset {
    
    AVAssetImageGenerator *assetGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    assetGen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [assetGen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *videoImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return videoImage;
    
}

- (UIImage *)snail_takeVideoFirstFrameImage {
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:self options:nil];
    return [self _snail_takeVideoFirstFrameImage:asset];
    
}

- (void)snail_takeVideoInfoBlock:(void(^)(SnailVideoInfoModel *videoInfo))block {
    
    if (block) {
        SnailVideoInfoModel *info = [SnailVideoInfoModel new];
        
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:self options:nil];
        UIImage *image = [self _snail_takeVideoFirstFrameImage:asset];
        Float64 duration = CMTimeGetSeconds(asset.duration);
        NSUInteger fileSize = [self snail_takeFileSize];
        
        info.firstFrameImage = image;
        info.duration = duration;
        info.fileSize = fileSize;
        
        block(info);
    }
    
}

@end
