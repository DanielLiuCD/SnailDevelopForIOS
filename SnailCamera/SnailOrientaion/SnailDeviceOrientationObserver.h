//
//  SnailDeviceOrientationObserver.h
//  SnailCamera
//
//  Created by JobNewMac1 on 2018/9/5.
//  Copyright © 2018年 com.snail. All rights reserved.
//

@import UIKit;

@interface SnailDeviceOrientationObserver : NSObject

@property (nonatomic ,copy) void (^deviceOrientationDidChangeBlock)(UIDeviceOrientation orientation);

- (UIDeviceOrientation)currentDeviceOrientation;

- (void)clear;

@end
