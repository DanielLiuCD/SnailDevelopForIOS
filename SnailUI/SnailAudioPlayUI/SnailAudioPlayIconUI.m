//
//  SnailAudioPlayIconUI.m
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/7/10.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import "SnailAudioPlayIconUI.h"

@interface SnailAudioPlayIconUI()

kSPrStrong(NSTimer *timer)
kSPr(BOOL isPlay)
kSPr(NSInteger index)

@end

@implementation SnailAudioPlayIconUI

- (instancetype)init {
    self = [super init];
    if (self) {
        self.layer.contentsGravity = kCAGravityCenter;
        self.layer.contentsScale = UIScreen.mainScreen.scale;
        self.layer.masksToBounds = true;
        [self changeUI];
    }
    return self;
}

- (void)play {
    [self startTimer];
    self.isPlay = true;
}

- (void)pause {
    [self stopTimer];
    self.isPlay = false;
}

- (void)stop {
    [self pause];
    self.index = 0;
    [self changeUI];
}

- (void)startTimer {
    [self stopTimer];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerAction) userInfo:nil repeats:false];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)timerAction {
    self.index ++;
    if (self.index > 3) self.index = 1;
    [self changeUI];
    if (self.isPlay) [self startTimer];
}

- (void)changeUI {
    
    NSString *prefix = !self.isSend?@"snail_from_voice_":@"snail_to_voice_";
    NSString *name = [NSString stringWithFormat:@"%@%ld",prefix,(long)self.index];
    UIImage *img = [UIImage imageNamed:name];
    self.layer.contents = (__bridge id)img.CGImage;
    
}

- (void)setIsSend:(BOOL)isSend {
    _isSend = isSend;
    [self changeUI];
}

- (void)dealloc {
    [self stopTimer];
}

@end
