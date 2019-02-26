//
//  SnailCameraPreviewView.m
//  SnailCamera
//
//  Created by JobNewMac1 on 2018/8/29.
//  Copyright © 2018年 com.snail. All rights reserved.
//

#import "_SnailCameraPreviewView.h"

@interface _SnailCameraPreviewView()

@end

@implementation _SnailCameraPreviewView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setContentMode:SnailCameraPreviewContentResizeAspectFill];
    }
    return self;
}

+ (Class)layerClass {
    return AVCaptureVideoPreviewLayer.class;
}

- (void)changeVideoOrientation:(AVCaptureVideoOrientation)orientation {
    
    AVCaptureVideoPreviewLayer *layer = (AVCaptureVideoPreviewLayer *)self.layer;
    if ([layer.connection isVideoOrientationSupported]) {
        layer.connection.videoOrientation = orientation;
    }
}

- (void)setContentMode:(SnailCameraPreviewContentMode)contentMode {
    
    AVLayerVideoGravity gravity = nil;
    switch (contentMode) {
        case SnailCameraPreviewContentResizeAspect: gravity = AVLayerVideoGravityResizeAspect; break;
        case SnailCameraPreviewContentResizeAspectFill: gravity = AVLayerVideoGravityResizeAspectFill; break;
        default: gravity = AVLayerVideoGravityResize; break;
    }
    _contentMode = contentMode;
    [(AVCaptureVideoPreviewLayer *)self.layer setVideoGravity:gravity];
    
}

- (void)bindWithSession:(AVCaptureSession *)session {
    if (session) [(AVCaptureVideoPreviewLayer *)self.layer setSession:session];
}

- (CGPoint)captureDevicePointForPoint:(CGPoint)point {
    AVCaptureVideoPreviewLayer *layer = (AVCaptureVideoPreviewLayer *)self.layer;
    return [layer captureDevicePointOfInterestForPoint:point];
}

- (AVCaptureSession * _Nullable)takeSession {
    return [(AVCaptureVideoPreviewLayer *)self.layer session];
}

- (void)clear {
    [(AVCaptureVideoPreviewLayer *)self.layer setSession:nil];
}

@end
