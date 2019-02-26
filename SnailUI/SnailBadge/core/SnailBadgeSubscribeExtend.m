//
//  SnailBadgeSubscribeExtend.m
//  SnailBadge
//
//  Created by JobNewMac1 on 2018/10/19.
//  Copyright © 2018年 com.crazysnail. All rights reserved.
//

#import "SnailBadgeSubscribeExtend.h"
#import <objc/runtime.h>

@implementation NSObject(SnailBadgeSubscribeExtend)

- (SnailBadgeSubscribeExtend *)snailBadgeExtend {
    return objc_getAssociatedObject(self, @selector(snailBadgeExtend));
}

@end

@implementation SnailBadgeSubscribeExtend

- (void)setLinkView:(id)linkView {
    _linkView = linkView;
    objc_setAssociatedObject(linkView, @selector(snailBadgeExtend), linkView, OBJC_ASSOCIATION_ASSIGN);
}

@end
