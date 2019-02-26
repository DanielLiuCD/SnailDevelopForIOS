//
//  SnailBadgeSubscribeExtend.h
//  SnailBadge
//
//  Created by JobNewMac1 on 2018/10/19.
//  Copyright © 2018年 com.crazysnail. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SnailBadgeSubscribeExtend;

@interface NSObject(SnailBadgeSubscribeExtend)

- (SnailBadgeSubscribeExtend *)snailBadgeExtend;

@end

@interface SnailBadgeSubscribeExtend : NSObject

@property (nonatomic ,weak) id linkView;
@property (nonatomic) NSInteger count;

@end
