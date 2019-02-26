//
//  SnailBadgeHeader.h
//  SnailBadge
//
//  Created by JobNewMac1 on 2018/10/16.
//  Copyright © 2018年 com.crazysnail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SnailBadgeSubscribeExtend.h"

typedef NS_ENUM(uint8_t,SnailBadgeShowStrategy) {
    SnailBadgeShowStrategyAuto,
    SnailBadgeShowStrategyPoint,
    SnailBadgeShowStrategyNum,
    SnailBadgeShowStrategyNoNumHidden
};

typedef void(^SnailBadgeSubscribeBlock)(SnailBadgeSubscribeExtend *extend);

typedef void(^SnailBadgeCompleteBlock)(void);
typedef void(^SnailBadgeCustomeViewConfigureBlock)(__kindof UIView * customeBlockView, NSString *text);
typedef void(^SnailBadgeBoolCallbackBlock)(BOOL result);

