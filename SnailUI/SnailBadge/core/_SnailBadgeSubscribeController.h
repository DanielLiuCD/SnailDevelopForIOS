//
//  _SnailBadgeSubscribeController.h
//  SnailBadge
//
//  Created by JobNewMac1 on 2018/10/16.
//  Copyright © 2018年 com.crazysnail. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SnailBadgeHeader.h"
@class _SnailBadgeSubscribe;

@interface _SnailBadgeSubscribeController : NSObject

+ (instancetype)shared;

- (void)registerSubscribe:(_SnailBadgeSubscribe *)subscribe Complete:(SnailBadgeCompleteBlock)block;

- (void)removeSubscribe:(_SnailBadgeSubscribe *)subscribe Complete:(SnailBadgeCompleteBlock)block;
- (void)removeSubscribeOfPath:(NSString *)path Complete:(SnailBadgeCompleteBlock)block;
- (void)removeAllSubscribeComplete:(SnailBadgeCompleteBlock)block;

- (void)changeCount:(NSInteger)count Path:(NSString *)path Complete:(SnailBadgeCompleteBlock)block;

@end
