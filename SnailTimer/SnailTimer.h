//
//  SnailTimer.h
//  QianXun
//
//  Created by JobNewMac1 on 2018/10/23.
//  Copyright © 2018年 com.jobnew. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(char,SnailTimerType) {
    SnailTimerDefault,
    SnailTimerLink,
    SnailTimerGCD
};

@interface SnailTimer : NSObject

- (void)delay:(NSTimeInterval)time Type:(SnailTimerType)type Block:(void(^)(SnailTimer *timer))block;
- (void)repeat:(NSTimeInterval)time Type:(SnailTimerType)type Block:(void(^)(SnailTimer *timer))block;

- (void)pause:(SnailTimerType)type;
- (void)resume:(SnailTimerType)type;
- (void)stop:(SnailTimerType)type;

@end
