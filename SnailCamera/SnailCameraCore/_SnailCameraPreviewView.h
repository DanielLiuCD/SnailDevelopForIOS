//
//  SnailCameraPreviewView.h
//  SnailCamera
//
//  Created by JobNewMac1 on 2018/8/29.
//  Copyright © 2018年 com.snail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "_SnailCameraCoreHelper.h"
#import "SnailCameraHeader.h"

@interface _SnailCameraPreviewView : UIView

kSnailCameraCorePro(SnailCameraPreviewContentMode contentMode)

- (void)bindWithSession:(AVCaptureSession *)session;

- (void)changeVideoOrientation:(AVCaptureVideoOrientation)orientation;

- (CGPoint)captureDevicePointForPoint:(CGPoint)point;

- (AVCaptureSession * _Nullable)takeSession;

- (void)clear;

@end
