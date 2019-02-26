//
//  SnailCameraManager.m
//  SnailCamera
//
//  Created by JobNewMac1 on 2018/8/29.
//  Copyright © 2018年 com.snail. All rights reserved.
//

#import "SnailCameraManager.h"

#import "_SnailCameraCoreHelper.h"

#import "_SnailCameraPreviewView.h"
#import "_SnailCameraAVManager.h"


NSErrorDomain const NSSnailCameraErrorDomain = @"NSSnailCameraErrorDomain";

#pragma mark -

@interface SnailCameraTimeRecord : NSObject

kSnailCameraCoreProStrong(NSTimer *timer)
kSnailCameraCorePro(CFTimeInterval startTime)
kSnailCameraCoreProCopy(SnailCameraMovieTimeProgressCallbacks recordCallbacks)

@end

@implementation SnailCameraTimeRecord

- (void)startRecord {
    
    self.startTime = CACurrentMediaTime();
    
    [self clearTimer];
    self.timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timerAction) userInfo:nil repeats:true];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
}

- (void)timerAction {
    
    CFTimeInterval tmp = CACurrentMediaTime();
    if (self.recordCallbacks) {
        self.recordCallbacks(tmp - self.startTime);
    }
    
}

- (void)clearTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)clear {
    [self clearTimer];
    self.startTime = 0;
    self.recordCallbacks = nil;
}

- (void)dealloc {
    [self clear];
}

@end

#pragma mark -

@interface SnailCameraManager(Notify)

///区域改变的通知
- (void)deviceAreaChangeNotify:(NSNotification *)notify;

@end

#pragma mark -

@interface SnailCameraManager()

/*-----------------------------------私有----------------------------------------------*/
kSnailCameraCoreProStrong(_SnailCameraPreviewView *previewView)
kSnailCameraCoreProStrong(_SnailCameraAVManager *avManager)

/*-----------------------------------拍照----------------------------------------------*/
kSnailCameraCoreProCopy(SnailCameraPhotoCallbacks cameraImageBlock)

/*-----------------------------------录像----------------------------------------------*/
kSnailCameraCoreProCopy(SnailCameraMovieCallbacks cameraMovieBlock)
kSnailCameraCoreProCopy(SnailCameraMovieTimeProgressCallbacks cameraMovieTimeProgressBlock);
kSnailCameraCoreProStrong(SnailCameraTimeRecord *cameraMovieTimeRecord)

kSnailCameraCorePro(CGFloat movieClarity)

/*-----------------------------------其它----------------------------------------------*/

kSnailCameraCoreProCopy(SnailCameraSampleBufferBlock videoSamleBufferBlock)
kSnailCameraCoreProCopy(SnailCameraSampleBufferBlock audioSamleBufferBlock)
kSnailCameraCoreProCopy(SnailCameraVideoSettingBlock videoSettingBlock)

@end

@implementation SnailCameraManager

- (void)runAsync:(void (^)(UIView *))block {
    
    if (@available(iOS 10.0, *)) {
        [NSThread detachNewThreadWithBlock:^{
            [self _run:block];
        }];
    } else {
        [NSThread detachNewThreadSelector:@selector(_run:) toTarget:self withObject:block];
    }
    
}

- (void)_run:(void (^)(UIView *))block {
    
    if (self.avManager == nil) {
        
        NSDictionary *videoSetting = nil;
        if (self.videoSettingBlock) videoSetting = self.videoSettingBlock();
        
        __weak typeof(self) weakself = self;
        self.avManager = [[_SnailCameraAVManager alloc] initWithVideoSetting:videoSetting];
        self.avManager.cameraImageBlock = self.cameraImageBlock;
        self.avManager.cameraMovieBlock = self.cameraMovieBlock;
        self.avManager.cameraErrorBlock = self.cameraErrorBlock;
        self.avManager.videoOrientationChangeBlock = ^(AVCaptureVideoOrientation orientation) {
            [weakself.previewView changeVideoOrientation:orientation];
        };
        self.avManager.videoSamleBufferBlock = self.videoSamleBufferBlock;
        self.avManager.audioSamleBufferBlock = self.audioSamleBufferBlock;
        [self.avManager run];
    }
    [self.avManager enableDeviceAreaChangeObserver]; //激活区域变化的监听
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (!self.previewView) {
            self.previewView = [_SnailCameraPreviewView new];
            [self.previewView bindWithSession:self.avManager.takeMineSession];
            [self.previewView changeVideoOrientation:self.avManager.takeCurrentVideoOrientation];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceAreaChangeNotify:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:nil];
        
        if (block) block(self.previewView);
        
    });
    
}

- (BOOL)isRuning {
    return self.previewView != nil;
}

- (SnailCameraRunMode)runMode {
    return [[self.avManager valueForKey:@"mode"] charValue];
}

- (void)stop {
    
    [self.previewView removeFromSuperview];
    [self.previewView clear];
    self.previewView = nil;
    [self.avManager clear];
    self.avManager = nil;
    
}

- (void)clear {
    
    [self stop];
    
    [self.cameraMovieTimeRecord clear];
    self.cameraMovieTimeRecord = nil;
    
    self.cameraMovieBlock = nil;
    self.cameraMovieTimeProgressBlock = nil;
    self.cameraImageBlock = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)dealloc {
    [self clear];
}

@end

#pragma mark -

@implementation SnailCameraManager(Show)

- (void)changePreviewShowMode:(SnailCameraPreviewContentMode)mode {
    [self.previewView setContentMode:mode];
}

- (SnailCameraPreviewContentMode)takePreviewMode {
    return self.previewView.contentMode;
}

@end

#pragma mark -

@implementation SnailCameraManager(Camera)

- (void)switchCamera {
    
    [self.avManager switchCamera:^(BOOL can) {
        if (can) {
            CATransition *animation = [CATransition animation];
            animation.type = @"oglFlip";
            animation.subtype = kCATransitionFromLeft;
            animation.duration = 0.5;
            [self.previewView.layer addAnimation:animation forKey:@"flip"];
        }
    }];
    [self.avManager enableDeviceAreaChangeObserver];
    
}

- (SnailCameraVideoPosition)currentCamera {
    return [self.avManager currentCamera];
}

- (void)zoomLevel:(CGFloat)level {
    [self.avManager zoomLevel:level Rate:0];
}

- (void)zoomLevel:(CGFloat)level Rate:(float)rate {
    [self.avManager zoomLevel:level Rate:rate];
}

- (CGFloat)takeCurrentZoomLevel {
    return [self.avManager takeCurrentZoomLevel];
}

- (CGFloat)takeMaxZoomLevel {
    return [self.avManager takeMaxZoomLevel];
}

- (void)focusOnPoint:(CGPoint)point {
    [self.avManager focusOnPoint:[self.previewView captureDevicePointForPoint:point]];
}

- (void)changeLight:(SnailCameraLightMode)mode {
    [self.avManager changeLight:mode];
}

- (SnailCameraLightMode)currentLight {
    return [self.avManager currentLight];
}

@end

#pragma mark -

@implementation SnailCameraManager(Photo)

- (void)takePhoto {
    [self.avManager takeAPhoto];
}

@end

#pragma mark -

@implementation SnailCameraManager(Movie)

- (void)resumeMovie {
    
    self.avManager.cameraMovieClarity = self.movieClarity;
    [self.avManager startMovie];
    
    if (!self.cameraMovieTimeRecord) {
        self.cameraMovieTimeRecord = [SnailCameraTimeRecord new];
    }
    
    self.cameraMovieTimeRecord.recordCallbacks = self.cameraMovieTimeProgressBlock;
    [self.cameraMovieTimeRecord startRecord];

}

- (void)pauseMovie {
    
}

- (void)stopMovie {
    [self.avManager stopMovie];
    [self.cameraMovieTimeRecord clear];
}

@end

#pragma mark -

@implementation SnailCameraManager(Notify)

- (void)deviceAreaChangeNotify:(NSNotification *)notify {
    [self focusOnPoint:[self.previewView center]];
}

@end

#pragma mark -

@implementation SnailCameraManager(SNAOTHER)

- (BOOL)addOutput:(AVCaptureOutput *)output {
    return [self.avManager addOutput:output];
}

- (void)removeOutput:(AVCaptureOutput *)output {
    [self.avManager removeOutput:output];
}

@end
