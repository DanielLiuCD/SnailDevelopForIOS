//
//  SnailCameraManager.h
//  SnailCamera
//
//  Created by JobNewMac1 on 2018/8/29.
//  Copyright © 2018年 com.snail. All rights reserved.
//

@import UIKit;
#import "SnailCameraCoreHeader.h"
@class AVCaptureOutput;

@interface SnailCameraManager : NSObject

@property (nonatomic ,copy) SnailCameraErrorCallbacks cameraErrorBlock;

- (SnailCameraRunMode)runMode;

- (void)runAsync:(void(^)(UIView *preview))block;

- (BOOL)isRuning;

///清理内存
- (void)clear;

@end

@interface SnailCameraManager(Show)

- (void)changePreviewShowMode:(SnailCameraPreviewContentMode)mode;
- (SnailCameraPreviewContentMode)takePreviewMode;

@end

@interface SnailCameraManager(Camera)

- (void)switchCamera;
- (SnailCameraVideoPosition)currentCamera;

- (void)zoomLevel:(CGFloat)level;
- (void)zoomLevel:(CGFloat)level Rate:(float)rate;
- (CGFloat)takeCurrentZoomLevel;
- (CGFloat)takeMaxZoomLevel;

- (void)focusOnPoint:(CGPoint)point;

- (void)changeLight:(SnailCameraLightMode)mode;
- (SnailCameraLightMode)currentLight;

@end

@interface SnailCameraManager(Photo)

///拍照回调
@property (nonatomic ,copy) SnailCameraPhotoCallbacks cameraImageBlock;

///拍照
- (void)takePhoto;

@end

@interface SnailCameraManager(Movie)

///录制视频回调
@property (nonatomic ,copy) SnailCameraMovieTimeProgressCallbacks cameraMovieTimeProgressBlock;
@property (nonatomic ,copy) SnailCameraMovieCallbacks cameraMovieBlock;

///录制视频清晰度  0 - 1
@property (nonatomic) CGFloat movieClarity;

///开始
- (void)resumeMovie;

///暂停
- (void)pauseMovie; //尚未实现

///停止
- (void)stopMovie;

@end

@interface SnailCameraManager(SNAOTHER)

@property (nonatomic ,copy) SnailCameraSampleBufferBlock videoSamleBufferBlock;
@property (nonatomic ,copy) SnailCameraSampleBufferBlock audioSamleBufferBlock;
@property (nonatomic ,copy) SnailCameraVideoSettingBlock videoSettingBlock;

- (BOOL)addOutput:(AVCaptureOutput *)output;
- (void)removeOutput:(AVCaptureOutput *)output;

@end
