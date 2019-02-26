//
//  SnailCameraCoreHelper.h
//  SnailCamera
//
//  Created by JobNewMac1 on 2018/8/29.
//  Copyright © 2018年 com.snail. All rights reserved.
//

@import Foundation;
@import AVFoundation;
@import UIKit;
#import "SnailCameraCoreHeader.h"

typedef void(^SnailCameraCanSwitchCameraBlock)(BOOL can);

typedef void(^SnailCameraVideoOrientationChangeBlock)(AVCaptureVideoOrientation orientation);

#define kSnailCameraCoreProKey(...) @property (__VA_ARGS__)
#define kSnailCameraCoreProStrong(...) kSnailCameraCoreProKey(nonatomic ,strong) __VA_ARGS__;
#define kSnailCameraCoreProCopy(...) kSnailCameraCoreProKey(nonatomic ,copy) __VA_ARGS__;
#define kSnailCameraCoreProWeak(...) kSnailCameraCoreProKey(nonatomic ,weak) __VA_ARGS__;
#define kSnailCameraCorePro(...) kSnailCameraCoreProKey(nonatomic) __VA_ARGS__;

#define kSnailCameraDocumentPath NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject
#define kSnailCameraCachePath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, true).firstObject

#define kSnailCameraMovieFolder @"SNAILCAMERAMOVIECACHEFOLDER"
