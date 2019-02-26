//
//  SnailBadge.h
//  SnailBadge
//
//  Created by JobNewMac1 on 2018/10/17.
//  Copyright © 2018年 com.crazysnail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SnailBadgeHeader.h"

@protocol SnailBadgeViewProtocol;

@interface NSObject(SnailBadge)

- (void)snailBadgePostMessage:(NSString *)path Count:(NSInteger)count Complete:(SnailBadgeCompleteBlock)completeBlock;

- (void)snailBadgeSubscribe:(NSString *)path Block:(SnailBadgeSubscribeBlock)block Complete:(SnailBadgeCompleteBlock)completeBlock;

- (void)snailBadgeSubscribe:(NSString *)path View:(id<SnailBadgeViewProtocol>)view MaxCount:(NSInteger)maxCount Block:(SnailBadgeSubscribeBlock)block Complete:(SnailBadgeCompleteBlock)completeBlock;

- (void)snailBadgeSubscribe:(NSString *)path View:(id<SnailBadgeViewProtocol>)view Strategy:(SnailBadgeShowStrategy)strategy MaxCount:(NSInteger)maxCount Block:(SnailBadgeSubscribeBlock)block Complete:(SnailBadgeCompleteBlock)completeBlock;

@end

typedef NSString * NSSnailBadgeValueKey NS_STRING_ENUM;

FOUNDATION_EXPORT NSSnailBadgeValueKey const NSSnailBadgeFontKey;
FOUNDATION_EXPORT NSSnailBadgeValueKey const NSSnailBadgeTextColorKey;
FOUNDATION_EXPORT NSSnailBadgeValueKey const NSSnailBadgeBackgroundColorKey;
FOUNDATION_EXPORT NSSnailBadgeValueKey const NSSnailBadgePaddingKey;
FOUNDATION_EXPORT NSSnailBadgeValueKey const NSSnailBadgeBackgroundImageKey;
FOUNDATION_EXPORT NSSnailBadgeValueKey const NSSnailBadgeEnableDragAnimationKey;

typedef void(^SnailBadgeDragEndBlock)(BOOL result,id view);

@protocol SnailBadgeViewProtocol<NSObject>

- (void)snailBadgeStyle:(NSDictionary<NSSnailBadgeValueKey ,id> *)style;
- (void)snailBadgeOffset:(CGPoint)offset;
- (void)snailBadgeShow:(NSString *)text;
- (void)snailBadgeShowCustomeView:(UIView *)customeView Block:(SnailBadgeCustomeViewConfigureBlock)block;
- (void)snailBadgeClearBackgroundImage;
- (void)snailBadgeDragAnimationEndBlock:(SnailBadgeDragEndBlock)dragEndBlock;
- (void)snailBadgeHidden;

@end

@interface UIView(SnailBadge)<SnailBadgeViewProtocol>

@end

@interface UITabBarItem(SnailBadge)<SnailBadgeViewProtocol>

@end

@interface UIBarButtonItem(SnailBadge)<SnailBadgeViewProtocol>

@end

