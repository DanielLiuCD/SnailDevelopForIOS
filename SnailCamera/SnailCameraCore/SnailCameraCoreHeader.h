//
//  SnailCameraCoreHeader.m
//  SnailCamera
//
//  Created by JobNewMac1 on 2018/8/29.
//  Copyright © 2018年 com.snail. All rights reserved.
//

@import Foundation;
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(char, SnailCameraPreviewContentMode) {
    SnailCameraPreviewContentResizeAspect,
    SnailCameraPreviewContentResizeAspectFill,
    SnailCameraPreviewContentResize,
};

typedef void(^SnailCameraPhotoCallbacks)(UIImage *image,NSString *imageName);
typedef void(^SnailCameraMovieTimeProgressCallbacks)(NSTimeInterval duration);
typedef void(^SnailCameraMovieCallbacks)(NSURL *moviewUrl ,NSTimeInterval duration ,UIImage *previewImage ,NSUInteger fileSize);
typedef void(^SnailCameraErrorCallbacks)(NSError *error);

typedef CMSampleBufferRef(^SnailCameraSampleBufferBlock)(CMSampleBufferRef sampleBuffer);

typedef NSDictionary *(^SnailCameraVideoSettingBlock)(void);

typedef NS_ENUM(char, SnailCameraRunMode) {
    SnailCameraRunModeNone,
    SnailCameraRunModePhoto, //拍照
    SnailCameraRunModeMovie, //录像
};

FOUNDATION_EXPORT NSErrorDomain const NSSnailCameraErrorDomain;

typedef NS_ENUM(char, SnailCameraLightMode) {
    SnailCameraLightModeOff,
    SnailCameraLightModeFlash, //闪光灯
    SnailCameraLightModeFlashAuto,
    SnailCameraLightModeTorch, //手电筒
    SnailCameraLightModeTorchAuto,
};

typedef NS_ENUM(char ,SnailCameraVideoPosition) {
    SnailCameraVideoBack, //后置
    SnailCameraVideoFront, //前置
};
