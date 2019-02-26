//
//  SnailTableAndCollectionVMCommon.m
//  SnailTCVM
//
//  Created by JobNewMac1 on 2018/12/10.
//  Copyright © 2018年 com.crazysnail. All rights reserved.
//

#import "SnailTableAndCollectionVMCommon.h"
#import <objc/runtime.h>

@interface SnailTCReg()

@property (nonatomic) Class cls;
@property (nonatomic ,copy) NSString *identifer;

@end

@implementation SnailTCReg

+ (instancetype):(Class)cls :(NSString *)identifer {
    SnailTCReg *reg = [SnailTCReg new];
    reg.cls = cls;
    reg.identifer = identifer;
    return reg;
}

+ (NSArray<SnailTCReg *> *)Clss:(NSArray<Class> *)clss Identifers:(NSArray<NSString *> *)identifers {
    NSMutableArray *tmps = [NSMutableArray new];
    [clss enumerateObjectsUsingBlock:^(Class  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [tmps addObject:[self :obj :identifers[idx]]];
    }];
    return tmps.copy;
}

@end

@implementation UITableViewCell(SnailTableAndCollectionVM)

- (void)snail_Configure:(id)model {}

- (void)setSna_isConfigureing:(BOOL)sna_isConfigureing {
    objc_setAssociatedObject(self, @selector(sna_isConfigureing), @(sna_isConfigureing), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)sna_isConfigureing {
    NSNumber *value = objc_getAssociatedObject(self, @selector(sna_isConfigureing));
    return [value boolValue];
}

- (void)snail_setConfigureBlock:(void (^)(__kindof id, NSIndexPath *, SnailScrollerTrackInfo))block {
    objc_setAssociatedObject(self, @selector(snail_setConfigureBlock:), block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setSna_have_configured:(BOOL)sna_have_configured {
    objc_setAssociatedObject(self, @selector(sna_have_configured), @(sna_have_configured), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)sna_have_configured {
    NSNumber *value = objc_getAssociatedObject(self, @selector(sna_have_configured));
    return [value boolValue];
}

@end

@implementation UICollectionViewCell(SnailTableAndCollectionVM)

- (void)snail_Configure:(id)model {}

- (void)setSna_isConfigureing:(BOOL)sna_isConfigureing {
    objc_setAssociatedObject(self, @selector(sna_isConfigureing), @(sna_isConfigureing), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)sna_isConfigureing {
    NSNumber *value = objc_getAssociatedObject(self, @selector(sna_isConfigureing));
    return [value boolValue];
}

- (void)setSna_have_configured:(BOOL)sna_have_configured {
    objc_setAssociatedObject(self, @selector(sna_have_configured), @(sna_have_configured), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)sna_have_configured {
    NSNumber *value = objc_getAssociatedObject(self, @selector(sna_have_configured));
    return [value boolValue];
}

- (void)snail_setConfigureBlock:(void (^)(__kindof id, NSIndexPath *, SnailScrollerTrackInfo))block {
    objc_setAssociatedObject(self, @selector(snail_setConfigureBlock:), block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end

@interface SnailTCPreprocessed()

@property (nonatomic) CFRunLoopObserverRef observerRef;

@end

@implementation SnailTCPreprocessed

- (void)resume {
    
    __weak typeof(self) self_weak_ = self;
    CFRunLoopRef runloopRef = CFRunLoopGetCurrent();
    CFStringRef runLoopMode = kCFRunLoopDefaultMode;
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, kCFRunLoopBeforeWaiting, true, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        if (self_weak_.dataBlock) {
            NSArray *tmps = self_weak_.dataBlock();
            if (tmps.count > 0 && self_weak_.preprocessedBlock) {
                [tmps enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    self_weak_.preprocessedBlock(obj);
                }];
                if (self_weak_.completeBlock) self_weak_.completeBlock(tmps);
            }
        }
    });
    CFRunLoopAddObserver(runloopRef, observer, runLoopMode);
    self.observerRef = observer;

}

- (void)stop {
    if (self.observerRef) {
        CFRunLoopRef runloopRef = CFRunLoopGetCurrent();
        CFRunLoopRemoveObserver(runloopRef, self.observerRef, kCFRunLoopDefaultMode);
        self.observerRef = nil;
    }
}

- (BOOL)isOpen {
    return self.observerRef;
}

- (void)dealloc {
    [self stop];
}

@end
