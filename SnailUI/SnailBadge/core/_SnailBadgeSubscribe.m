//
//  _SnailBadgeSubscribe.m
//  SnailBadge
//
//  Created by JobNewMac1 on 2018/10/16.
//  Copyright © 2018年 com.crazysnail. All rights reserved.
//

#import "_SnailBadgeSubscribe.h"

@interface _SnailBadgeSubscribeAction()

@property (nonatomic ,copy) SnailBadgeSubscribeBlock block;
@property (nonatomic) NSUInteger tag;
@property (nonatomic ,strong) SnailBadgeSubscribeExtend *extend;
@property (nonatomic ,weak) id father;
@property (nonatomic ,copy) NSString *fatherClassString;

@end

@implementation _SnailBadgeSubscribeAction

+ (instancetype)Tag:(NSUInteger)tag Block:(SnailBadgeSubscribeBlock)block {
    if (block) {
        _SnailBadgeSubscribeAction *action = [_SnailBadgeSubscribeAction new];
        action.block = block;
        action.tag = tag;
        action.extend = [SnailBadgeSubscribeExtend new];
        return action;
    }
    return nil;
}

- (void)dealloc {
    self.block = nil;
}

- (void)setFather:(id)father {
    _father = father;
    if ([father isKindOfClass:[NSObject class]]) self.fatherClassString = NSStringFromClass([(NSObject *)father class]);
    else self.fatherClassString = nil;
    
}

- (NSUInteger)hash {
    return self.tag;
}

- (BOOL)isEqual:(_SnailBadgeSubscribeAction *)object {
    return [self.father isEqual:object] && self.tag == object.tag;
}

@end

@interface _SnailBadgeSubscribe()<NSCopying>

@property (nonatomic ,copy) NSString *path;
@property (nonatomic ,strong) NSMutableSet<_SnailBadgeSubscribeAction *> *actions;

@end

@implementation _SnailBadgeSubscribe

+ (instancetype)Father:(id)father Path:(NSString *)path Tag:(NSUInteger)tag LinkView:(id)linkView Block:(SnailBadgeSubscribeBlock)block {
    
    _SnailBadgeSubscribeAction *action = [_SnailBadgeSubscribeAction Tag:tag Block:block];
    if (action) {
        action.extend.linkView = linkView;
        if (father) action.father = father;
    }
    
    _SnailBadgeSubscribe *objc = [_SnailBadgeSubscribe new];
    objc.path = path;
    if (action) [objc.actions addObject:action];
    
    return objc;
    
}

- (id)copyWithZone:(NSZone *)zone {
    _SnailBadgeSubscribe *objc = [[_SnailBadgeSubscribe allocWithZone:zone] init];
    objc.path = self.path;
    objc.actions = self.actions.mutableCopy;
    return objc;
}

- (void)appenAction:(_SnailBadgeSubscribeAction *)action {
    [self.actions addObject:action];
}

- (void)appenActions:(NSArray<_SnailBadgeSubscribeAction *> *)actions {
    [self.actions addObjectsFromArray:actions];
}

- (void)removeAction:(_SnailBadgeSubscribeAction *)action {
    [self.actions removeObject:action];
}

- (void)removeActions:(NSArray<_SnailBadgeSubscribeAction *> *)actions {
    for (_SnailBadgeSubscribeAction *action in actions) {
        [self removeAction:action];
    }
}

- (void)postCountMessage:(NSInteger)count {
    if (self.actions.count > 0) {
        [self.actions enumerateObjectsUsingBlock:^(_SnailBadgeSubscribeAction * _Nonnull obj, BOOL * _Nonnull stop) {
            obj.extend.count = count;
            if (obj.block) obj.block(obj.extend);
        }];
    }
}

- (NSMutableSet<_SnailBadgeSubscribeAction *> *)actions {
    if (!_actions) _actions = [NSMutableSet new];
    return _actions;
}

@end
