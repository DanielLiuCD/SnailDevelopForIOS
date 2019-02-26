//
//  SnailDeviceOrientationObserver.m
//  SnailCamera
//
//  Created by JobNewMac1 on 2018/9/5.
//  Copyright © 2018年 com.snail. All rights reserved.
//

#import "SnailDeviceOrientationObserver.h"

@implementation SnailDeviceOrientationObserver

- (instancetype)init {
    self = [super init];
    if (self) {
        if (![UIDevice currentDevice].generatesDeviceOrientationNotifications) {
            [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        }
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceOrientationChangeNotify:)
                                                    name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

- (UIDeviceOrientation)currentDeviceOrientation {
    return [UIDevice currentDevice].orientation;
}

- (void)deviceOrientationChangeNotify:(NSNotification *)notify {
    if (self.deviceOrientationDidChangeBlock) {
        self.deviceOrientationDidChangeBlock(self.currentDeviceOrientation);
    }
}

- (void)clear {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.deviceOrientationDidChangeBlock = nil;
}

- (void)dealloc {
    [self clear];
}

@end
