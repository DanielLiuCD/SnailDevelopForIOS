//
//  _SnailBadgeSubscribe.h
//  SnailBadge
//
//  Created by JobNewMac1 on 2018/10/16.
//  Copyright © 2018年 com.crazysnail. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SnailBadgeHeader.h"


@interface _SnailBadgeSubscribeAction : NSObject

@property (nonatomic ,weak ,readonly) id father;
@property (nonatomic ,copy ,readonly) NSString *fatherClassString;
@property (nonatomic ,copy ,readonly) SnailBadgeSubscribeBlock block;
@property (nonatomic ,readonly) NSUInteger tag;
@property (nonatomic ,strong ,readonly) SnailBadgeSubscribeExtend *extend;

@end

@interface _SnailBadgeSubscribe : NSObject

@property (nonatomic ,copy ,readonly) NSString *path;
@property (nonatomic ,strong ,readonly) NSMutableSet<_SnailBadgeSubscribeAction *> *actions;

+ (instancetype)Father:(id)father Path:(NSString *)path Tag:(NSUInteger)tag LinkView:(id)linkView Block:(SnailBadgeSubscribeBlock)block;

- (void)appenAction:(_SnailBadgeSubscribeAction *)action;
- (void)appenActions:(NSArray<_SnailBadgeSubscribeAction *> *)actions;

- (void)removeAction:(_SnailBadgeSubscribeAction *)action;
- (void)removeActions:(NSArray<_SnailBadgeSubscribeAction *> *)actions;

- (void)postCountMessage:(NSInteger)count;

@end
