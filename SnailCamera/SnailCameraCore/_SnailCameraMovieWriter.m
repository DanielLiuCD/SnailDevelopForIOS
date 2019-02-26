//
//  _SnailCameraMovieWriter.m
//  SnailCamera
//
//  Created by JobNewMac1 on 2018/8/30.
//  Copyright © 2018年 com.snail. All rights reserved.
//

#import "_SnailCameraMovieWriter.h"

#pragma mark -

#define kSnailCameraMovieFolderPath [kSnailCameraCachePath stringByAppendingPathComponent:kSnailCameraMovieFolder]

#define kSnailCameraMovieWirteOnQueue(block) if (self.avWriterQueue == nil) {\
self.avWriterQueue = dispatch_queue_create("com.snail.camera.writer.queue", DISPATCH_QUEUE_SERIAL);\
}\
dispatch_async(self.avWriterQueue, block);

#pragma mark -

@interface _SnailCameraMovieWriter()

kSnailCameraCoreProStrong(AVAssetWriter *avWriter)
kSnailCameraCoreProStrong(AVAssetWriterInput *avVideoWriterInput)
kSnailCameraCoreProStrong(AVAssetWriterInput *avAudioWriterInput)

kSnailCameraCoreProStrong(dispatch_queue_t avWriterQueue)

kSnailCameraCorePro(BOOL prepared)
kSnailCameraCorePro(BOOL readyForAudio)
kSnailCameraCorePro(BOOL readyForVideo)

kSnailCameraCoreProStrong(dispatch_semaphore_t sem)


@end

#pragma mark -

@implementation _SnailCameraMovieWriter

- (instancetype)init {
    self = [super init];
    if (self) {
        NSFileManager *nm = [NSFileManager defaultManager];
        if (![nm fileExistsAtPath:kSnailCameraMovieFolderPath]) {
            [nm createDirectoryAtPath:kSnailCameraMovieFolderPath withIntermediateDirectories:true attributes:nil error:nil];
        }
        self.sem = dispatch_semaphore_create(1);
    }
    return self;
}

#pragma mark -

- (void)prepare {
    
    if (!self.prepared) {
        dispatch_semaphore_wait(self.sem, DISPATCH_TIME_FOREVER);
        if (!self.avWriter) {
            NSError *error;
            NSString *fileName = [NSString stringWithFormat:@"%.0f.mov",[[NSDate date] timeIntervalSince1970]];
            NSString *filePath = [kSnailCameraMovieFolderPath stringByAppendingPathComponent:fileName];
            self.avWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:filePath] fileType:AVFileTypeQuickTimeMovie error:&error];
            if (error) {
#if DEBUG
                NSLog(@"error:%@",error);
#endif
            }
            self.prepared = true;
        }
        dispatch_semaphore_signal(self.sem);
    }
    
}

- (BOOL)isPrepared {
    return self.prepared;
}

- (void)movieAppendBuffer:(CMSampleBufferRef)sampleBuffer Type:(AVMediaType)mediaType {
    
    if (!self.prepared) return;
    
    CFRetain(sampleBuffer);
    kSnailCameraMovieWirteOnQueue(^{
        
        if (mediaType == AVMediaTypeVideo) {
            
            if (!self.readyForVideo) [self createVideoWriterInput:CMSampleBufferGetFormatDescription(sampleBuffer)];
            if (self.readyForAudio && self.readyForVideo) [self appendBuffer:sampleBuffer Type:mediaType];
            
        }
        else if (mediaType == AVMediaTypeAudio) {
            
            if (!self.readyForAudio) [self createAudioWriterInput:CMSampleBufferGetFormatDescription(sampleBuffer)];
            if (self.readyForAudio && self.readyForVideo) [self appendBuffer:sampleBuffer Type:mediaType];
            
        }
        
        CFRelease(sampleBuffer);
        
    });
    
}

- (void)appendBuffer:(CMSampleBufferRef)sampleBuffer Type:(AVMediaType)mediaType {
    
    if (self.avWriter.status == AVAssetWriterStatusUnknown) {
        [self.avWriter startWriting];
        [self.avWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
    }
    if (self.avWriter.status == AVAssetWriterStatusWriting) {
        
        if (mediaType == AVMediaTypeVideo) {
            if (self.avVideoWriterInput.readyForMoreMediaData) {
                [self.avVideoWriterInput appendSampleBuffer:sampleBuffer];
            }
        }
        else if (mediaType == AVMediaTypeAudio) {
            if (self.avAudioWriterInput.readyForMoreMediaData) {
                [self.avAudioWriterInput appendSampleBuffer:sampleBuffer];
            }
        }
        
    }
    
}

#pragma mark -

- (void)createVideoWriterInput:(CMFormatDescriptionRef)formatRef {
    
    dispatch_semaphore_wait(self.sem, DISPATCH_TIME_FOREVER);
    
    CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(formatRef);
    NSUInteger width = dimensions.width;
    NSUInteger height = dimensions.height;
    
    NSUInteger numPixel = width * height;
    
    int8_t bitsPerPixel = ((numPixel < (640 * 480))?4.05:10.1) * (self.cameraMovieClarity <= 0 ? 0.5:self.cameraMovieClarity);
    int8_t rate = 30;
    
    CGFloat bitPerSecend = numPixel * bitsPerPixel;
    
    NSString *videoCode = nil;
    if (@available(iOS 11.0 ,*)) {
        videoCode = AVVideoCodecTypeH264;
    }
    else videoCode = AVVideoCodecH264;
    
    NSDictionary *videoSettings = @{
                                    AVVideoCodecKey : videoCode,
                                    AVVideoWidthKey : @(width),
                                    AVVideoHeightKey : @(height),
                                    AVVideoCompressionPropertiesKey : @{
                                            AVVideoAverageBitRateKey : @(bitPerSecend),
                                            AVVideoMaxKeyFrameIntervalKey : @(rate),
                                            }
                                    };
    if ([self.avWriter canApplyOutputSettings:videoSettings forMediaType:AVMediaTypeVideo]) {
        self.avVideoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
        self.avVideoWriterInput.expectsMediaDataInRealTime = true;
      //  self.avVideoWriterInput.transform = CGAffineTransformMakeRotation(M_PI * .5);
        if ([self.avWriter canAddInput:self.avVideoWriterInput]) [self.avWriter addInput:self.avVideoWriterInput];
        else self.avVideoWriterInput = nil;
    }
    
    self.readyForVideo = self.avVideoWriterInput != nil;
    
    dispatch_semaphore_signal(self.sem);
    
}

- (void)createAudioWriterInput:(CMFormatDescriptionRef)formatRef {
    
    dispatch_semaphore_wait(self.sem, DISPATCH_TIME_FOREVER);
    
    size_t aclSize = 0;
    const AudioStreamBasicDescription *currentASBD = CMAudioFormatDescriptionGetStreamBasicDescription(formatRef);
    const AudioChannelLayout *currentChannelLayout = CMAudioFormatDescriptionGetChannelLayout(formatRef, &aclSize);
    
    NSData *currentChannelLayoutData = nil;
    if (currentChannelLayout && aclSize > 0 ){
        currentChannelLayoutData = [NSData dataWithBytes:currentChannelLayout length:aclSize];
    }
    else{
        currentChannelLayoutData = [NSData data];
    }
    
    NSDictionary *audioCompressionSettings = @{
                                               AVFormatIDKey : @(kAudioFormatMPEG4AAC),
                                               AVSampleRateKey : @(currentASBD->mSampleRate),
                                               AVEncoderBitRatePerChannelKey : @64000,
                                               AVNumberOfChannelsKey : @(currentASBD->mChannelsPerFrame),
                                               AVChannelLayoutKey : currentChannelLayoutData};
    
    if ([self.avWriter canApplyOutputSettings:audioCompressionSettings forMediaType:AVMediaTypeAudio])
    {
        self.avAudioWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioCompressionSettings];
        self.avAudioWriterInput.expectsMediaDataInRealTime = YES;
        
        if ([self.avWriter canAddInput:self.avAudioWriterInput]) [self.avWriter addInput:self.avAudioWriterInput];
        else self.avAudioWriterInput = nil;
    }
    
    self.readyForAudio = self.avAudioWriterInput != nil;
    
    dispatch_semaphore_signal(self.sem);
    
}

#pragma mark -

- (void)stopWithCallback:(SnailCameraMovieCallbacks)callback {
    
    if (self.avWriter.status == AVAssetWriterStatusWriting) {
        
        dispatch_semaphore_wait(self.sem, DISPATCH_TIME_FOREVER);
        
        self.prepared = false;
    
        kSnailCameraMovieWirteOnQueue(^{
            
            [self.avWriter finishWritingWithCompletionHandler:^{
                
                if (callback) {
                    
                    NSURL *url = self.avWriter.outputURL;
                    
                    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
                    
                    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
                    CGImageRef imageRef = [gen copyCGImageAtTime:CMTimeMakeWithSeconds(0.0, 600) actualTime:nil error:nil];
                    UIImage *img = [[UIImage alloc] initWithCGImage:imageRef];
                    CGImageRelease(imageRef);
                    
                    CMTime time = [asset duration];
                    NSTimeInterval seconds = ceil(time.value/time.timescale);
                    
                    NSString *path = [url.absoluteString stringByReplacingOccurrencesOfString:@"file://" withString:@""];

                    NSUInteger fileSize = (NSUInteger)[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil].fileSize;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        callback(url,seconds,img,fileSize);
                    });
                    
                }
                
                [self clear];
                dispatch_semaphore_signal(self.sem);
                
            }];
            
        });
        
    }
    
}

- (void)clear {

    self.avAudioWriterInput = nil;
    self.avVideoWriterInput = nil;
    self.avWriter = nil;
    self.avWriterQueue = nil;
    self.readyForAudio = false;
    self.readyForVideo = false;
    
}

@end

#undef kSnailCameraMovieFolderPath
