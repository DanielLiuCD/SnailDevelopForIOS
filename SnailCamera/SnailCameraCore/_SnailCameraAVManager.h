//
//  SnailCameraAVManager.h
//  SnailCamera
//
//  Created by JobNewMac1 on 2018/8/29.
//  Copyright © 2018年 com.snail. All rights reserved.
//

#import "_SnailCameraCoreHelper.h"


@interface _SnailCameraAVManager : NSObject

kSnailCameraCoreProCopy(SnailCameraPhotoCallbacks cameraImageBlock)
kSnailCameraCoreProCopy(SnailCameraMovieCallbacks cameraMovieBlock)
kSnailCameraCoreProCopy(SnailCameraErrorCallbacks cameraErrorBlock)

kSnailCameraCoreProCopy(SnailCameraVideoOrientationChangeBlock videoOrientationChangeBlock)

kSnailCameraCorePro(CGFloat cameraMovieClarity)

kSnailCameraCoreProCopy(SnailCameraSampleBufferBlock videoSamleBufferBlock)
kSnailCameraCoreProCopy(SnailCameraSampleBufferBlock audioSamleBufferBlock)

@end

@interface _SnailCameraAVManager()

- (instancetype)initWithVideoSetting:(NSDictionary *)videoSetting;

- (void)run;

- (SnailCameraRunMode)takeMode;

- (AVCaptureVideoOrientation)takeCurrentVideoOrientation;

- (void)takeAPhoto;

- (void)startMovie;

- (void)stopMovie;

- (void)clear;

@end

@interface _SnailCameraAVManager(CAMERAACTION)

- (void)switchCamera:(SnailCameraCanSwitchCameraBlock)block;
- (SnailCameraVideoPosition)currentCamera;

- (void)zoomLevel:(CGFloat)level Rate:(float)rate;
- (CGFloat)takeCurrentZoomLevel;
- (CGFloat)takeMaxZoomLevel;

- (void)focusOnPoint:(CGPoint)point;
- (BOOL)canFocus;

- (void)changeLight:(SnailCameraLightMode)mode;
- (SnailCameraLightMode)currentLight;

- (void)enableDeviceAreaChangeObserver;
- (void)disableDeviceAreaChangeObserver;

@end

@interface _SnailCameraAVManager(GETTER)

- (AVCaptureSession *)takeMineSession;

@end

@interface _SnailCameraAVManager(SNAOTHER)

- (BOOL)addOutput:(AVCaptureOutput *)output;
- (void)removeOutput:(AVCaptureOutput *)output;

@end
