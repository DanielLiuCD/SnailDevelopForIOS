//
//  SnailTimer.m
//  QianXun
//
//  Created by JobNewMac1 on 2018/10/23.
//  Copyright © 2018年 com.jobnew. All rights reserved.
//

#import "SnailTimer.h"
#import <objc/runtime.h>

@interface SnailTimer()

kSPrStrong(NSTimer *timer)
kSPrStrong(CADisplayLink *link)
kSPrStrong(dispatch_source_t source)

kSPr(BOOL isOnceTimer)
kSPr(BOOL isOnceLink)
kSPr(BOOL isOnceSource)

@end

@implementation SnailTimer

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
    [self remove:SnailTimerDefault];
}

- (void)stopLink {
    [self.link invalidate];
    self.link = nil;
    [self remove:SnailTimerLink];
}

- (void)stopSource {
    dispatch_source_cancel(self.source);
    self.source = nil;
    [self remove:SnailTimerGCD];
}

- (NSString *)takeKeyForType:(SnailTimerType)type {
    NSString *typeStr;
    switch (type) {
        case SnailTimerDefault:typeStr = @"SnailTimerTimerKey";
            break;
        case SnailTimerLink:typeStr = @"SnailTimerLinkKey";
            break;
        default:typeStr = @"SnailTimerGCDKey";
            break;
    }
    return typeStr;
}

- (void)save:(SnailTimerType)type Block:(void(^)(SnailTimer *timer))block {
    NSString *key = [self takeKeyForType:type];
    objc_setAssociatedObject(self, (__bridge const void *)key, block, OBJC_ASSOCIATION_COPY);
}

- (void (^)(SnailTimer *))take:(SnailTimerType)type {
    NSString *key = [self takeKeyForType:type];
    return objc_getAssociatedObject(self, (__bridge const void *)key);
}

- (void)remove:(SnailTimerType)type {
    NSString *key = [self takeKeyForType:type];
    objc_setAssociatedObject(self, (__bridge const void *)key, nil, OBJC_ASSOCIATION_COPY);
}

- (void)prepareType:(SnailTimerType)type {
    switch (type) {
        case SnailTimerDefault:[self stopTimer];break;
        case SnailTimerLink:[self stopLink];break;
        default:[self stopSource];break;
    }
}

- (void)timerAction {
    void (^block)(SnailTimer *) = [self take:SnailTimerDefault];
    if (block) block(self);
    if (self.isOnceTimer) [self stopTimer];
}

- (void)linkAction {
    void (^block)(SnailTimer *) = [self take:SnailTimerLink];
    if (block) block(self);
    if (self.isOnceLink) [self stopLink];
}

- (void(^)(void))sourceAction {
    return ^{
        void (^block)(SnailTimer *) = [self take:SnailTimerGCD];
        if (block) block(self);
        if (self.isOnceSource) [self stopSource];
    };
}

- (void)delay:(NSTimeInterval)time Type:(SnailTimerType)type Block:(void (^)(SnailTimer *))block {
    [self prepareType:type];
    [self save:type Block:block];
    switch (type) {
        case SnailTimerDefault:
        {
            self.timer = [NSTimer timerWithTimeInterval:time target:self selector:@selector(timerAction) userInfo:nil repeats:false];
            [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
            self.isOnceLink = false;
        }
            break;
        case SnailTimerLink:
        {
            self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(linkAction)];
            if (@available(iOS 10.0,*)) self.link.preferredFramesPerSecond = time * 60;
            else self.link.frameInterval = time * 60;
            self.isOnceLink = true;
        }
            break;
        default:
        {
            self.source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
            dispatch_source_set_timer(self.source, dispatch_time(DISPATCH_TIME_NOW, time * NSEC_PER_SEC), 1 * NSEC_PER_SEC, 0);
            dispatch_source_set_event_handler(self.source, self.sourceAction);
            self.isOnceLink = true;
            dispatch_resume(self.source);
        }
            break;
    }
}

@end
