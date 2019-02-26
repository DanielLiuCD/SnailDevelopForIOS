//
//  _SnailBadgeSubscribeController.m
//  SnailBadge
//
//  Created by JobNewMac1 on 2018/10/16.
//  Copyright © 2018年 com.crazysnail. All rights reserved.
//

#import "_SnailBadgeSubscribeController.h"
#import "_SnailBadgeSubscribe.h"

@interface _SnailBadgeNode : NSObject

@property (nonatomic ,copy) NSString *name;
@property (nonatomic ,copy) NSString *path;
@property (nonatomic ,strong) NSMutableArray<_SnailBadgeNode *> *childs;
@property (nonatomic ,weak) _SnailBadgeNode *supperNode;
@property (nonatomic) NSUInteger count;

@end

@implementation _SnailBadgeNode
{
    NSInteger _privateCount;
}

- (void)addChild:(_SnailBadgeNode *)child {
    if (!self.childs) self.childs = [NSMutableArray new];
    child.supperNode = self;
    [self.childs addObject:child];
}

- (_SnailBadgeNode *)searchNodeForPath:(NSString *)path {
    
    if (path && self.childs.count > 0) {
        for (_SnailBadgeNode *node in self.childs) {
            if ([node.path isEqualToString:path]) return node;
        }
    }
    return nil;
}

- (NSArray *)searchAllChildeNodeForPath:(NSString *)path {
    
    if (path && self.childs.count > 0) {
        NSMutableArray *results = [NSMutableArray new];
        NSArray *paths = [path componentsSeparatedByString:@"/"];
        NSMutableString *pathStr = [NSMutableString new];
        _SnailBadgeNode *tmpNode = self;
        for (NSString *str in paths) {
            if ([str isEqualToString:@""]) continue;
            [pathStr appendString:@"/"];
            [pathStr appendString:str];
            if ([pathStr isEqualToString:@"/root"]) continue;
            _SnailBadgeNode *node = [tmpNode searchNodeForPath:pathStr.copy];
            if (node) {
                [results addObject:node];
                tmpNode = node;
            }
        }
        if (results.count > 0) return results;
    }
    return nil;
    
}

- (NSArray *)takeAllChildNode {
    NSMutableArray *tmps = [NSMutableArray new];
    for (_SnailBadgeNode *node in self.childs) {
        [tmps addObject:node];
        if (node.childs.count > 0) {
            [tmps addObjectsFromArray:[node takeAllChildNode]];
        }
    }
    return tmps;
}

- (NSUInteger)count {
    if (self.childs.count > 0) {
        __block NSUInteger tmp = 0;
        [self.childs enumerateObjectsUsingBlock:^(_SnailBadgeNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            tmp += obj.count;
        }];
        return tmp;
    }
    return _privateCount;
}

- (void)setCount:(NSUInteger)count {
    _privateCount = count;
    if (count == 0) {
        [self.childs enumerateObjectsUsingBlock:^(_SnailBadgeNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.count = 0;
        }];
    }
}

@end

@interface _SnailBadgeSubscribeController()

@property (nonatomic ,strong) NSMutableDictionary<NSString *,_SnailBadgeSubscribe *> *subscribes;
@property (nonatomic ,strong) dispatch_queue_t queue;
@property (nonatomic ,strong) _SnailBadgeNode *root;

@end

@implementation _SnailBadgeSubscribeController

+ (instancetype)shared {
    static _SnailBadgeSubscribeController *x;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        x = [_SnailBadgeSubscribeController new];
    });
    return x;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.subscribes = [NSMutableDictionary new];
        self.queue = dispatch_queue_create("com.snailbadge.con.queue", DISPATCH_QUEUE_SERIAL);
        self.root = [_SnailBadgeNode new];
        self.root.name = @"root";
        self.root.path = @"/root";
    }
    return self;
}

- (void)registerSubscribe:(_SnailBadgeSubscribe *)subscribe Complete:(SnailBadgeCompleteBlock)block {
    
    dispatch_async(self.queue, ^{
        
        NSString *path = subscribe.path;
        _SnailBadgeSubscribe *tmpSubscribe = self.subscribes[path];
        if (!tmpSubscribe) {
            tmpSubscribe = subscribe.copy;
            self.subscribes[path] = tmpSubscribe;
        }
        else {
            [tmpSubscribe appenActions:subscribe.actions.allObjects];
        }
        
        [self _updateNodeForPath:path];
        
        NSArray *results = [self.root searchAllChildeNodeForPath:path];
        for (_SnailBadgeNode *node in results) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _SnailBadgeSubscribe *subscribe = self.subscribes[node.path];
                [subscribe postCountMessage:node.count];
            });
        }
        
        if (block) dispatch_async(dispatch_get_main_queue(), ^{block();});
        
    });
}

- (void)_updateNodeForPath:(NSString *)path {
    
    NSArray *paths = [path componentsSeparatedByString:@"/"];
    NSMutableString *tmpPathString = [NSMutableString new];
    
    _SnailBadgeNode *supper = self.root;
    
    for (NSString *tmpPath in paths) {
        @autoreleasepool {
            
            if ([tmpPath isEqualToString:@""]) continue;
            
            [tmpPathString appendString:@"/"];
            [tmpPathString appendString:tmpPath];
            
            if ([tmpPathString isEqualToString:@"/root"]) continue;
            
            _SnailBadgeNode *node = [supper searchNodeForPath:tmpPathString.copy];
            if (!node) {
                node = [_SnailBadgeNode new];
                node.name = tmpPath;
                node.path = tmpPathString.copy;
                [supper addChild:node];
            }
            supper = node;
        }
    }
    
}

- (void)removeSubscribe:(_SnailBadgeSubscribe *)subscribe Complete:(SnailBadgeCompleteBlock)block {
    dispatch_async(self.queue, ^{
        NSString *path = subscribe.path;
        _SnailBadgeSubscribe *tmpSubscribe = self.subscribes[path];
        if (tmpSubscribe) {
            [tmpSubscribe removeActions:subscribe.actions.allObjects];
            if (tmpSubscribe.actions.count == 0) self.subscribes[path] = nil;
        }
        if (block) dispatch_async(dispatch_get_main_queue(), ^{block();});
    });
}

- (void)removeSubscribeOfPath:(NSString *)path Complete:(SnailBadgeCompleteBlock)block {
    dispatch_async(self.queue, ^{
        self.subscribes[path] = nil;
        if (block) dispatch_async(dispatch_get_main_queue(), ^{block();});
    });
}

- (void)removeAllSubscribeComplete:(SnailBadgeCompleteBlock)block {
    dispatch_async(self.queue, ^{
        [self.subscribes removeAllObjects];
        if (block) dispatch_async(dispatch_get_main_queue(), ^{block();});
    });
}

- (void)changeCount:(NSInteger)count Path:(NSString *)path Complete:(SnailBadgeCompleteBlock)block {
    dispatch_async(self.queue, ^{
        
        [self _updateNodeForPath:path];
        
        NSArray *results = [self.root searchAllChildeNodeForPath:path];
        if (results) {
            
            _SnailBadgeNode *node = results.lastObject;
            BOOL isDel = count == 0;
            node.count = count;
            if (isDel && node.childs.count > 0) { //只有清0时才需要把所有子节点数量清0
                NSMutableArray *tmp = [NSMutableArray arrayWithArray:results];
                [tmp addObjectsFromArray:[node takeAllChildNode]];
                results = tmp.copy;
            }
            
        }
        for (_SnailBadgeNode *node in results) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _SnailBadgeSubscribe *subscribe = self.subscribes[node.path];
                [subscribe postCountMessage:node.count];
            });
        }
        
        if (block) dispatch_async(dispatch_get_main_queue(), ^{block();});
        
    });
}

@end
