//
//  SnailCameraAVManager.m
//  SnailCamera
//
//  Created by JobNewMac1 on 2018/8/29.
//  Copyright © 2018年 com.snail. All rights reserved.
//

#import "_SnailCameraAVManager.h"
#import "_SnailCameraCoreHelper.h"
#import "_SnailCameraMovieWriter.h"
#import "SnailDeviceOrientationObserver.h"
#import <Availability.h>

#pragma mark -

@interface _SnailCameraAVManager(AVDELEGATE)<AVCapturePhotoCaptureDelegate,AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate>

@end

#pragma mark -

@interface _SnailCameraAVManager(SnailPrivate)

@end

#pragma mark -

API_AVAILABLE(ios(10.0))
@interface _SnailCameraAVManager()

kSnailCameraCorePro(SnailCameraRunMode mode)

kSnailCameraCoreProStrong(AVCaptureSession *session)

kSnailCameraCoreProStrong(AVCaptureDevice *videoDevice)
kSnailCameraCoreProStrong(AVCaptureDevice *audioDevice)

kSnailCameraCorePro(AVCaptureDeviceInput *videoCaptureInput)
kSnailCameraCorePro(AVCaptureDeviceInput *audioCaptureInput)

kSnailCameraCoreProStrong(AVCaptureVideoDataOutput *videoDataOutput)
kSnailCameraCoreProStrong(AVCaptureAudioDataOutput *audioDataOutput)

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

kSnailCameraCoreProStrong(AVCapturePhotoOutput *photoOutput)
kSnailCameraCoreProStrong(NSMutableDictionary *photoSettings)
kSnailCameraCorePro(AVCaptureFlashMode flashMode)
kSnailCameraCorePro(AVCaptureVideoOrientation photoPrientation)

#endif

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

kSnailCameraCoreProStrong(AVCaptureStillImageOutput *imageOutput)

#pragma clang diagnostic pop

kSnailCameraCoreProStrong(AVCaptureConnection *videoConnect)
kSnailCameraCoreProStrong(AVCaptureConnection *audioConnect)

kSnailCameraCoreProStrong(dispatch_queue_t av_queue)

kSnailCameraCoreProStrong(_SnailCameraMovieWriter *writer)
kSnailCameraCoreProStrong(SnailDeviceOrientationObserver *deviceOrentationObserver)

kSnailCameraCoreProStrong(dispatch_semaphore_t semaphore)

@end

#pragma mark -

@implementation _SnailCameraAVManager

- (instancetype)init {
    return [self initWithVideoSetting:nil];
}

- (instancetype)initWithVideoSetting:(NSDictionary *)videoSetting {
    
    self = [super init];
    if (self) {
        if (!videoSetting) videoSetting = @{(id)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA)};
        [self initlizeConfigureWithVideoSetting:videoSetting];
    }
    return self;
    
}

- (void)initlizeConfigureWithVideoSetting:(NSDictionary *)videoSetting {
    
    self.av_queue = dispatch_queue_create("com.snail.camera.av.queue", DISPATCH_QUEUE_SERIAL);
    
    self.semaphore = dispatch_semaphore_create(1);
    
    self.session = [AVCaptureSession new];
    if ([self.session canSetSessionPreset:AVCaptureSessionPresetHigh]) {
        [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    }
    
    NSError *error;
    
    self.videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.videoCaptureInput = [AVCaptureDeviceInput deviceInputWithDevice:self.videoDevice error:&error];
    if (error) {
        [self detailError:error];
        return;
    }
    if ([self.session canAddInput:self.videoCaptureInput]) [self.session addInput:self.videoCaptureInput];
    
    self.videoDataOutput = [AVCaptureVideoDataOutput new];
    self.videoDataOutput.alwaysDiscardsLateVideoFrames = true;
    self.videoDataOutput.videoSettings = videoSetting;
    [self.videoDataOutput setSampleBufferDelegate:self queue:self.av_queue];
    if (self.videoDataOutput && [self.session canAddOutput:self.videoDataOutput]) [self.session addOutput:self.videoDataOutput];
    
    self.videoConnect = [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
    
    self.audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    self.audioCaptureInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.audioDevice error:&error];
    if (error) {
        [self detailError:error];
        return;
    }
    
    if (self.audioCaptureInput && [self.session canAddInput:self.audioCaptureInput]) [self.session addInput:self.audioCaptureInput];
    self.audioDataOutput = [AVCaptureAudioDataOutput new];
    [self.audioDataOutput setSampleBufferDelegate:self queue:self.av_queue];
    if (self.audioDataOutput && [self.session canAddOutput:self.audioDataOutput]) [self.session addOutput:self.audioDataOutput];
    
    self.audioConnect = [self.audioDataOutput connectionWithMediaType:AVMediaTypeAudio];
    
    if (@available(iOS 10.0,*)) {
        
        self.photoOutput = [AVCapturePhotoOutput new];
        if ([self.session canAddOutput:self.photoOutput]) [self.session addOutput:self.photoOutput];
        else self.photoOutput = nil;
        
        self.photoSettings = [NSMutableDictionary dictionaryWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    }
    else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        self.imageOutput = [AVCaptureStillImageOutput new];
        self.imageOutput.outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
        if ([self.session canAddOutput:self.imageOutput]) [self.session addOutput:self.imageOutput];
        else self.imageOutput = nil;
#pragma clang diagnostic pop
    }
    
    __weak typeof(self) weakself = self;
    self.writer = [_SnailCameraMovieWriter new];
    self.deviceOrentationObserver = [SnailDeviceOrientationObserver new];
    self.deviceOrentationObserver.deviceOrientationDidChangeBlock = ^(UIDeviceOrientation orientation) {
        
        AVCaptureVideoOrientation videoorientation = [weakself currentVideoOrientation:orientation];
        if ([weakself.videoConnect isVideoOrientationSupported] && weakself.videoConnect.videoOrientation != videoorientation) {
            weakself.videoConnect.videoOrientation = videoorientation;
            if (weakself.videoOrientationChangeBlock) {
                weakself.videoOrientationChangeBlock(videoorientation);
            }
        }
        
    };
    
    AVCaptureVideoOrientation videoorientation = [self currentVideoOrientation:[self.deviceOrentationObserver currentDeviceOrientation]];
    if ([self.videoConnect isVideoOrientationSupported] && self.videoConnect.videoOrientation != videoorientation) {
        self.videoConnect.videoOrientation = [self currentVideoOrientation:[self.deviceOrentationObserver currentDeviceOrientation]];
    }
    
}

- (void)run {
    
    if (![self.session isRunning]) {
        [self.session startRunning];
    }
    
}

- (SnailCameraRunMode)takeMode {
    return self.mode;
}

- (AVCaptureVideoOrientation)takeCurrentVideoOrientation {
    return self.videoConnect.videoOrientation;
}

- (void)takeAPhoto {
    
    if (self.mode != SnailCameraRunModeNone) {
        
        if (self.cameraErrorBlock) {
            NSError *error = [NSError errorWithDomain:NSSnailCameraErrorDomain code:-101 userInfo:@{NSLocalizedDescriptionKey:@"正在录像无法拍照"}];
            [self detailError:error];
        }
        
        return;
        
    }
    
    self.mode = SnailCameraRunModePhoto;
    
    if (@available (iOS 10.0,*)) {
        
        self.photoPrientation = self.videoConnect.videoOrientation;
        
        AVCapturePhotoSettings *photoSet = [AVCapturePhotoSettings photoSettingsWithFormat:self.photoSettings];
        photoSet.flashMode = self.flashMode;
        [self.photoOutput capturePhotoWithSettings:photoSet delegate:self];
        
    }
    else {
        
        AVCaptureConnection *connection = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
        
        [self.imageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef _Nullable imageDataSampleBuffer, NSError * _Nullable error) {
            
            if (error) {
                return;
            }
            if (self.cameraImageBlock) {
                
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
#pragma clang diagnostic pop
                UIImage *image = [[UIImage alloc]initWithData:imageData];
                NSString *imageName = [NSString stringWithFormat:@"%@-%.0f.png",[UIDevice currentDevice].identifierForVendor.UUIDString,[[NSDate date] timeIntervalSince1970]];
                
                self.cameraImageBlock(image, imageName);
                

            }
            self.mode = SnailCameraRunModeNone;
            
        }];
        
    }
    
}

- (void)startMovie {
    
    if (self.mode != SnailCameraRunModeNone) {
        
        if (self.cameraErrorBlock) {
            NSError *error = [NSError errorWithDomain:NSSnailCameraErrorDomain code:-101 userInfo:@{NSLocalizedDescriptionKey:@"正在拍照无法录像"}];
            [self detailError:error];
        }
        
        return;
        
    }
    
    self.writer.cameraMovieClarity = self.cameraMovieClarity;
    [self.writer prepare];
    self.mode = SnailCameraRunModeMovie;
    
}

- (void)stopMovie {
    
    [self.writer stopWithCallback:^(NSURL *moviewUrl, NSTimeInterval duration, UIImage *previewImage, NSUInteger fileSize) {
        
        self.mode = SnailCameraRunModeNone;
        if (self.cameraMovieBlock) self.cameraMovieBlock(moviewUrl,duration,previewImage,fileSize);
        else {
            [[NSFileManager defaultManager] removeItemAtURL:moviewUrl error:nil];
        }
        
    }];
    
}

- (void)clear {
    
    if ([self.session isRunning]) [self.session stopRunning];
    
    [self.session removeInput:self.videoCaptureInput];
    [self.session removeOutput:self.videoDataOutput];
    
    [self.session removeInput:self.audioCaptureInput];
    [self.session removeOutput:self.audioDataOutput];
    
    if (@available(iOS 10.0,*)) {
        [self.session removeOutput:self.photoOutput];
    }
    else [self.session removeOutput:self.imageOutput];
    
    [self.writer stopWithCallback:nil];
    [self.writer clear];
    
    [self.deviceOrentationObserver clear];
    self.deviceOrentationObserver = nil;
    
    self.videoCaptureInput = nil;
    self.videoDataOutput = nil;
    self.videoConnect = nil;
    self.videoDevice = nil;
    
    self.audioCaptureInput = nil;
    self.audioDataOutput = nil;
    self.audioConnect = nil;
    self.audioDevice = nil;
    
    if (@available(iOS 10.0,*)) {
        self.photoOutput = nil;
        self.photoSettings = nil;
        self.flashMode = AVCaptureFlashModeOff;
    }
    else {
        self.imageOutput = nil;
    }

    self.session = nil;
    self.av_queue = nil;

    self.cameraImageBlock = nil;
    self.cameraMovieBlock = nil;
    self.videoOrientationChangeBlock = nil;
    
    self.writer = nil;
    
}

- (void)dealloc {
    [self clear];
}

#pragma mark -

- (void)detailError:(NSError *)error {
    
#if DEBUG
    NSLog(@"error: %@",error);
#endif
    if (self.cameraErrorBlock) {
        self.cameraErrorBlock(error);
    }
    
}

- (AVCaptureVideoOrientation)currentVideoOrientation:(UIDeviceOrientation)deviceOrentation {
    
    AVCaptureVideoOrientation orientation;
    switch (deviceOrentation) {
        case UIDeviceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationLandscapeLeft:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
    }
    return orientation;
    
}

#pragma mark -

- (void)setMode:(SnailCameraRunMode)mode {
    
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    _mode = mode;
    dispatch_semaphore_signal(self.semaphore);
    
}

@end

#pragma mark -

@implementation _SnailCameraAVManager(SnailPrivate)

@end

#pragma mark -

@implementation _SnailCameraAVManager(CAMERAACTION)

- (void)switchCamera:(SnailCameraCanSwitchCameraBlock)block {
    
    AVCaptureDevicePosition currentDevicePostition = self.videoDevice.position;
    AVCaptureDevicePosition shouldDevicePosition = AVCaptureDevicePositionUnspecified;
    switch (currentDevicePostition) {
        case AVCaptureDevicePositionBack: shouldDevicePosition = AVCaptureDevicePositionFront;
            break;
        case AVCaptureDevicePositionFront: shouldDevicePosition = AVCaptureDevicePositionBack;
            break;
        default:break;
    }
    
    NSArray *videoDevices = nil;
    
    if (@available(iOS 10.0,*)) {
        
        AVCaptureDeviceDiscoverySession *discoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:shouldDevicePosition];
        videoDevices = discoverySession.devices;
        
    }
    else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
#pragma clang diagnostic pop
    }
    
    AVCaptureDevice *shouldDevice = nil;
    if ([videoDevices count] > 0) {
        
        for (AVCaptureDevice *device in videoDevices) {
            if (device.position == shouldDevicePosition) {
                shouldDevice = device;
                break;
            }
        }
        
    }
    
    if (shouldDevice) {
        NSError *error;
        AVCaptureDeviceInput *shouldVideoInput = [AVCaptureDeviceInput deviceInputWithDevice:shouldDevice error:&error];
        if (error) {
            [self detailError:error];
            return;
        }
        [self.session beginConfiguration];
        
        [self.session removeInput:self.videoCaptureInput];
        if ([self.session canAddInput:shouldVideoInput]) {
            block(true);
            [self.session addInput:shouldVideoInput];
            self.videoCaptureInput = shouldVideoInput;
            self.videoDevice = shouldDevice;
        }
        else {
            block(false);
            [self.session addInput:self.videoCaptureInput];
        }
        self.videoConnect = [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
        
        AVCaptureVideoOrientation videoorientation = [self currentVideoOrientation:[self.deviceOrentationObserver currentDeviceOrientation]];
        if ([self.videoConnect isVideoOrientationSupported] && self.videoConnect.videoOrientation != videoorientation) {
            self.videoConnect.videoOrientation = videoorientation;
        }
        
        [self.session commitConfiguration];
    }
    else block(false);

}

- (SnailCameraVideoPosition)currentCamera {
    return self.videoDevice.position == AVCaptureDevicePositionBack?SnailCameraVideoBack:SnailCameraVideoFront;
}

- (void)zoomLevel:(CGFloat)level Rate:(float)rate {

    CGFloat max = [self takeMaxZoomLevel];
    if (level > max) level = max;
    if (level < 0) level = 0;
    if (rate < 0) rate = 0;
    NSError *error;
    if ([self.videoDevice lockForConfiguration:&error]) {
        if (rate > 0) [self.videoDevice rampToVideoZoomFactor:level withRate:rate];
        else if (rate == 0) [self.videoDevice setVideoZoomFactor:level];
        [self.videoDevice unlockForConfiguration];
    }
    
}

- (CGFloat)takeCurrentZoomLevel {
    return self.videoDevice.videoZoomFactor;
}

- (CGFloat)takeMaxZoomLevel {
    return self.videoDevice.activeFormat.videoMaxZoomFactor;
}

- (BOOL)canFocus {
    BOOL can = [self.videoDevice isFocusPointOfInterestSupported] && [self.videoDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus];
    return can;
}

- (void)focusOnPoint:(CGPoint)point {
    if ([self canFocus]) {
        NSError *error;
        if ([self.videoDevice lockForConfiguration:&error]) {
            self.videoDevice.focusPointOfInterest = point;
            self.videoDevice.focusMode = AVCaptureFocusModeAutoFocus;
            [self.videoDevice unlockForConfiguration];
        }
    }
}

- (void)changeLight:(SnailCameraLightMode)mode {
    
    SnailCameraLightMode lightModel = [self currentLight];
    if (mode != lightModel) {
        
        NSError *error;
        switch (mode) {
            case SnailCameraLightModeFlash:
            {
                if ([self.videoDevice lockForConfiguration:&error]) {
                    if (lightModel == SnailCameraLightModeTorch || lightModel == SnailCameraLightModeTorchAuto) [self.videoDevice setTorchMode:AVCaptureTorchModeOff];
                    
                    if (@available(iOS 10.0,*)) {
                        self.flashMode = AVCaptureFlashModeOn;
                    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    else if ([self.videoDevice isFlashModeSupported:AVCaptureFlashModeOn]) {
                        [self.videoDevice setFlashMode:AVCaptureFlashModeOn];
                    }
#pragma clang diagnostic pop
                    [self.videoDevice unlockForConfiguration];
                }
            }
                break;
            case SnailCameraLightModeFlashAuto:
            {
                if ([self.videoDevice lockForConfiguration:&error]) {
                    if (lightModel == SnailCameraLightModeTorch || lightModel == SnailCameraLightModeTorchAuto) [self.videoDevice setTorchMode:AVCaptureTorchModeOff];
                    
                    if (@available(iOS 10.0,*)) {
                        self.flashMode = AVCaptureFlashModeAuto;
                    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    else if ([self.videoDevice isFlashModeSupported:AVCaptureFlashModeAuto]) {
                        [self.videoDevice setFlashMode:AVCaptureFlashModeAuto];
                    }
#pragma clang diagnostic pop
                    [self.videoDevice unlockForConfiguration];
                }
            }
                break;
            case SnailCameraLightModeTorch:
            {
                if ([self.videoDevice lockForConfiguration:&error]) {
                    if (lightModel == SnailCameraLightModeFlash || lightModel == SnailCameraLightModeFlashAuto) {
                        
                        if (@available(iOS 10.0,*)) {
                            self.flashMode = AVCaptureFlashModeOff;
                        }
                        else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                            [self.videoDevice setFlashMode:AVCaptureFlashModeOff];
#pragma clang diagnostic pop
                        }
                
                    }
                    
                    if ([self.videoDevice isTorchModeSupported:AVCaptureTorchModeOn]) {
                        [self.videoDevice setTorchMode:AVCaptureTorchModeOn];
                    }
                    [self.videoDevice unlockForConfiguration];
                    
                }
            }
                break;
            case SnailCameraLightModeTorchAuto:
            {
                if ([self.videoDevice lockForConfiguration:&error]) {
                    if (lightModel == SnailCameraLightModeFlash || lightModel == SnailCameraLightModeFlashAuto) {
                        
                        if (@available(iOS 10.0,*)) {
                            self.flashMode = AVCaptureFlashModeOff;
                        }
                        else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                            [self.videoDevice setFlashMode:AVCaptureFlashModeOff];
#pragma clang diagnostic pop
                        }
                        
                    }
                    if ([self.videoDevice isTorchModeSupported:AVCaptureTorchModeAuto]) {
                        [self.videoDevice setTorchMode:AVCaptureTorchModeAuto];
                    }
                    [self.videoDevice unlockForConfiguration];
                }
            }
                break;
            case SnailCameraLightModeOff:
            {
                if ([self.videoDevice lockForConfiguration:&error]) {
                    if (lightModel == SnailCameraLightModeFlash || lightModel == SnailCameraLightModeFlashAuto) {
                        if (@available(iOS 10.0,*)) {
                            self.flashMode = AVCaptureFlashModeOff;
                        }
                        else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                            [self.videoDevice setFlashMode:AVCaptureFlashModeOff];
#pragma clang diagnostic pop
                        }
                    }
                    if (lightModel == SnailCameraLightModeTorch || lightModel == SnailCameraLightModeTorchAuto) [self.videoDevice setTorchMode:AVCaptureTorchModeOff];
                    [self.videoDevice unlockForConfiguration];
                }
            }
                break;
            default:
                break;
        }
        
    }
    
}

- (SnailCameraLightMode)currentLight {
    
    AVCaptureFlashMode flashModel;
    
    if (@available(iOS 10.0,*)) {
        flashModel = self.flashMode;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    else flashModel = [self.videoDevice flashMode];
#pragma clang diagnostic pop
    
    if (flashModel == AVCaptureFlashModeOn) {
        return SnailCameraLightModeFlash;
    }
    else if (flashModel == AVCaptureTorchModeAuto) {
        return SnailCameraLightModeFlashAuto;
    }
    
    AVCaptureTorchMode torchMode = [self.videoDevice torchMode];
    if (torchMode == AVCaptureTorchModeOn) {
        return SnailCameraLightModeTorch;
    }
    else if (torchMode == AVCaptureTorchModeAuto) {
        return SnailCameraLightModeTorchAuto;
    }
    
    return SnailCameraLightModeOff;
    
}

- (void)enableDeviceAreaChangeObserver {
    
    NSError *error;
    if ([self.videoDevice lockForConfiguration:&error]) {
        self.videoDevice.subjectAreaChangeMonitoringEnabled = true;
        [self.videoDevice unlockForConfiguration];
    }
    
}

- (void)disableDeviceAreaChangeObserver {
    NSError *error;
    if ([self.videoDevice lockForConfiguration:&error]) {
        self.videoDevice.subjectAreaChangeMonitoringEnabled = false;
        [self.videoDevice unlockForConfiguration];
    }
}

@end

#pragma mark -

@implementation _SnailCameraAVManager(GETTER)

- (AVCaptureSession *)takeMineSession {
    return self.session;
}

@end

#pragma mark -

@implementation _SnailCameraAVManager(AVDELEGATE)

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    if (connection == self.videoConnect) {
        if (self.videoSamleBufferBlock) sampleBuffer = self.videoSamleBufferBlock(sampleBuffer);
    }
    else if (connection == self.audioConnect) {
        if (self.audioSamleBufferBlock) sampleBuffer = self.audioSamleBufferBlock(sampleBuffer);
    }
    
    if (self.mode == SnailCameraRunModeMovie) {
        
        if (connection == self.videoConnect) {
            if (sampleBuffer) [self.writer movieAppendBuffer:sampleBuffer Type:AVMediaTypeVideo];
        }
        else if (connection == self.audioConnect) {
            if (sampleBuffer) [self.writer movieAppendBuffer:sampleBuffer Type:AVMediaTypeAudio];
        }
        
    }
    
}

- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(NSError *)error  API_AVAILABLE(ios(11.0)){
    
    if (self.cameraImageBlock) {
        
        if (@available(iOS 11.0, *)) {
            
            CGImageRef imgref = [photo CGImageRepresentation];
            
            UIImageOrientation imageOrientation = UIImageOrientationUp;
            switch (self.photoPrientation) {
                case AVCaptureVideoOrientationPortrait:
                    imageOrientation = UIImageOrientationRight;
                    break;
                case AVCaptureVideoOrientationPortraitUpsideDown:
                    imageOrientation = UIImageOrientationLeft;
                    break;
                case AVCaptureVideoOrientationLandscapeLeft:
                    imageOrientation = UIImageOrientationDown;
                    break;
                case AVCaptureVideoOrientationLandscapeRight:
                    imageOrientation = UIImageOrientationUp;
                    break;
                default:
                    break;
            }
            
            UIImage *image = [UIImage imageWithCGImage:imgref scale:UIScreen.mainScreen.scale orientation:imageOrientation];
            
            NSString *imageName = [NSString stringWithFormat:@"%@-%.0f.png",[UIDevice currentDevice].identifierForVendor.UUIDString,[[NSDate date] timeIntervalSince1970]];
            self.cameraImageBlock(image, imageName);
            
        } else {
            // Fallback on earlier versions
        }
        
    }
    self.mode = SnailCameraRunModeNone;
    
}


- (void)captureOutput:(AVCapturePhotoOutput *)captureOutput didFinishProcessingPhotoSampleBuffer:(nullable CMSampleBufferRef)photoSampleBuffer previewPhotoSampleBuffer:(nullable CMSampleBufferRef)previewPhotoSampleBuffer resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings bracketSettings:(nullable AVCaptureBracketedStillImageSettings *)bracketSettings error:(nullable NSError *)error  API_AVAILABLE(ios(10.0)){
    
    if (self.cameraImageBlock) {
        
        if (@available(iOS 11.0 ,*)) {
            
        }
        else {
            
            NSData *imageData = [AVCapturePhotoOutput JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer previewPhotoSampleBuffer:previewPhotoSampleBuffer];
            UIImage *image = [UIImage imageWithData:imageData];
            NSString *imageName = [NSString stringWithFormat:@"%@-%.0f.png",[UIDevice currentDevice].identifierForVendor.UUIDString,[[NSDate date] timeIntervalSince1970]];
            self.cameraImageBlock(image, imageName);
         
        }
        
    }
    
    self.mode = SnailCameraRunModeNone;
    
}

@end

#pragma mark -

@implementation _SnailCameraAVManager(SNAOTHER)

- (BOOL)addOutput:(AVCaptureOutput *)output {
    if ([self.session canAddOutput:output]) {
        [self.session beginConfiguration];
        [self.session addOutput:output];
        [self.session commitConfiguration];
        return true;
    }
    return false;
}

- (void)removeOutput:(AVCaptureOutput *)output {
    [self.session removeOutput:output];
}

@end
