//
//  SnailBadge.m
//  SnailBadge
//
//  Created by JobNewMac1 on 2018/10/17.
//  Copyright © 2018年 com.crazysnail. All rights reserved.
//

#import "SnailBadge.h"
#import "_SnailBadgeSubscribeController.h"
#import "_SnailBadgeSubscribe.h"
#import "_SnailBadgeDragView.h"
#import <objc/runtime.h>

NSSnailBadgeValueKey const NSSnailBadgeFontKey = @"NSSnailBadgeFontKey";
NSSnailBadgeValueKey const NSSnailBadgeTextColorKey = @"NSSnailBadgeTextColorKey";
NSSnailBadgeValueKey const NSSnailBadgeBackgroundColorKey = @"NSSnailBadgeBackgroundColorKey";
NSSnailBadgeValueKey const NSSnailBadgePaddingKey = @"NSSnailBadgePaddingKey";
NSSnailBadgeValueKey const NSSnailBadgeBackgroundImageKey = @"NSSnailBadgeBackgroundImageKey";
NSSnailBadgeValueKey const NSSnailBadgeEnableDragAnimationKey = @"NSSnailBadgeEnableDragAnimationKey";

@interface _SnailBadgeView : _SnailBadgeDragView

@property (nonatomic) CGSize snailBadgeTextSize;
@property (nonatomic) CGPoint snailBadgeOffset;
@property (nonatomic) UIEdgeInsets snailBadgePadding;

@property (nonatomic ,copy) UIFont *font;
@property (nonatomic ,copy) NSString *text;
@property (nonatomic ,copy) UIColor *backColor;
@property (nonatomic ,copy) UIImage *backImg;
@property (nonatomic ,copy) UIColor *textColor;

@property (nonatomic ,copy) SnailBadgeBoolCallbackBlock snailBadgeViewStopBlock;

- (void)addCustomeView:(UIView *)view;
- (UIView *)takeCustomeView;

@end

@interface _SnailBadgeView()

@property (nonatomic ,strong) UIView *contentView;

@end

@interface _SnailBadgeTmpObjc : NSObject

@property (nonatomic ,strong) NSMutableArray *subscribes;
@property (nonatomic) NSUInteger tag;

@end

@implementation _SnailBadgeTmpObjc

- (instancetype)init {
    self = [super init];
    if (self) {
        self.subscribes = [NSMutableArray new];
    }
    return self;
}

- (void)incersent {
    self.tag++;
}

- (void)dealloc {
    for (_SnailBadgeSubscribe *subscribe in self.subscribes) {
        [[_SnailBadgeSubscribeController shared] removeSubscribe:subscribe Complete:nil];
    }
}

@end

@implementation NSObject(SnailBadge)

- (_SnailBadgeSubscribe *)_createSubscribe:(NSString *)path LinkView:(id)linkView Block:(SnailBadgeSubscribeBlock)block {
    
    if (!self.tmpObjc) {
        _SnailBadgeTmpObjc *objc = [_SnailBadgeTmpObjc new];
        self.tmpObjc = objc;
    }
    _SnailBadgeSubscribe *subscribe = [_SnailBadgeSubscribe Father:self Path:path Tag:self.tmpObjc.tag LinkView:linkView Block:block];
    [self.tmpObjc incersent];
    if (![self.tmpObjc.subscribes containsObject:subscribe]) {
        [self.tmpObjc.subscribes addObject:subscribe];
        return subscribe;
    }
    return nil;
}

- (void)snailBadgePostMessage:(NSString *)path Count:(NSInteger)count Complete:(SnailBadgeCompleteBlock)completeBlock {
    [[_SnailBadgeSubscribeController shared] changeCount:count Path:path Complete:completeBlock];
}

- (void)snailBadgeSubscribe:(NSString *)path Block:(SnailBadgeSubscribeBlock)block Complete:(SnailBadgeCompleteBlock)completeBlock {
    _SnailBadgeSubscribe *subscribe = [self _createSubscribe:path LinkView:nil Block:block];
    [[_SnailBadgeSubscribeController shared] registerSubscribe:subscribe Complete:completeBlock];
}


- (void)snailBadgeSubscribe:(NSString *)path View:(id<SnailBadgeViewProtocol>)view MaxCount:(NSInteger)maxCount Block:(SnailBadgeSubscribeBlock)block Complete:(SnailBadgeCompleteBlock)completeBlock {
    [self snailBadgeSubscribe:path View:view Strategy:SnailBadgeShowStrategyAuto MaxCount:maxCount Block:block Complete:completeBlock];
}

- (void)snailBadgeSubscribe:(NSString *)path View:(id<SnailBadgeViewProtocol>)view Strategy:(SnailBadgeShowStrategy)strategy MaxCount:(NSInteger)maxCount Block:(SnailBadgeSubscribeBlock)block Complete:(SnailBadgeCompleteBlock)completeBlock {
    NSObject *target = self;
    if (view && [view isKindOfClass:[NSObject class]]) target = (NSObject *)view;
    [target _snailBadgeSubscribe:path View:view Strategy:strategy MaxCount:maxCount Block:block Complete:completeBlock];
}

- (void)_snailBadgeSubscribe:(NSString *)path View:(id<SnailBadgeViewProtocol>)view Strategy:(SnailBadgeShowStrategy)strategy MaxCount:(NSInteger)maxCount Block:(SnailBadgeSubscribeBlock)block Complete:(SnailBadgeCompleteBlock)completeBlock {
    
    [view snailBadgeDragAnimationEndBlock:^(BOOL result, id<SnailBadgeViewProtocol> tmpView) {
        if (result) {
            [[_SnailBadgeSubscribeController shared] changeCount:0 Path:path Complete:completeBlock];
            [tmpView snailBadgeHidden];
        }
    }];
    
    SnailBadgeSubscribeBlock tmpBlock = ^(SnailBadgeSubscribeExtend *extend) {
        
        id<SnailBadgeViewProtocol> targteView = extend.linkView;
        NSInteger count = extend.count;
        
        NSString *tmpText = nil;
        BOOL hiddenBadge = false;
        switch (strategy) {
            case SnailBadgeShowStrategyPoint: {
                if (count <= 0) hiddenBadge = true;
            }
                break;
            case SnailBadgeShowStrategyNum:
            {
                if (count > maxCount) tmpText = [NSString stringWithFormat:@"%ld+",maxCount];
                else tmpText = [NSString stringWithFormat:@"%ld",count];
            }
                break;
            case SnailBadgeShowStrategyAuto:
            {
                if (count <= 0) tmpText = nil;
                else if (count > maxCount) tmpText = [NSString stringWithFormat:@"%ld+",maxCount];
                else tmpText = [NSString stringWithFormat:@"%ld",count];
            }
                break;
            case SnailBadgeShowStrategyNoNumHidden:
            {
                if (count <= 0) hiddenBadge = true;
                else if (count > maxCount) tmpText = [NSString stringWithFormat:@"%ld+",maxCount];
                else tmpText = [NSString stringWithFormat:@"%ld",count];
            }
            default:
                break;
        }
        
        [targteView snailBadgeShow:tmpText];
    
        if (hiddenBadge) [targteView snailBadgeHidden];
        
        if (block) block(extend);
    };
    
    _SnailBadgeSubscribe *subscribe = [self _createSubscribe:path LinkView:view Block:tmpBlock];
    [[_SnailBadgeSubscribeController shared] registerSubscribe:subscribe Complete:completeBlock];
    
}

- (_SnailBadgeTmpObjc *)tmpObjc {
    return objc_getAssociatedObject(self, @selector(tmpObjc));
}

- (void)setTmpObjc:(_SnailBadgeTmpObjc *)objc {
    objc_setAssociatedObject(self, @selector(tmpObjc), objc, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

#define SnailBadgeChineseLabelBug    0x0   //修复uilabel,显示中文时,添加加子控件,不显示的问题

@implementation UIView(SnailBadge)

- (_SnailBadgeView *)_createSnailBadgeView {
    
    _SnailBadgeView *view = [_SnailBadgeView new];
    view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
    view.snailEnableDrag = false; //默认关闭拖拽动画
#ifdef SnailBadgeChineseLabelBug
    if ([self isKindOfClass:[UILabel class]]) [self layoutIfNeeded];
#endif
    return view;
}

- (void)snailBadgeStyle:(NSDictionary *)style {
    self.privateSnailBadgeStyle = style;
    [self _snailBadgeStyle:style];
}

- (void)_snailBadgeStyle:(NSDictionary *)style {
    
    if (!style) return;
    if (style[NSSnailBadgeFontKey]) {
        self.privateSnailBadgeView.font = style[NSSnailBadgeFontKey];
        UIView *customeView = [self.privateSnailBadgeView takeCustomeView];
        if (!customeView) {
            CGSize size = CGSizeMake(4, 4);
            if (self.privateSnailBadgeView.text.length > 0) {
                CGSize tmp = [self.privateSnailBadgeView.text boundingRectWithSize:CGSizeMake(UIScreen.mainScreen.bounds.size.width - 30, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.privateSnailBadgeView.font} context:nil].size;
                size = CGSizeMake(ceil(tmp.width), ceil(tmp.height));
            };
            self.privateSnailBadgeView.snailBadgeTextSize = size;
            [self _refeshBadgeFrame];
        }
    }
    if (style[NSSnailBadgeTextColorKey]) self.privateSnailBadgeView.textColor = style[NSSnailBadgeTextColorKey];
    if (style[NSSnailBadgeBackgroundColorKey]) self.privateSnailBadgeView.backColor = style[NSSnailBadgeBackgroundColorKey];
    if (style[NSSnailBadgeBackgroundImageKey]) self.privateSnailBadgeView.backImg = style[NSSnailBadgeBackgroundImageKey];
    if (style[NSSnailBadgeEnableDragAnimationKey]) self.privateSnailBadgeView.snailEnableDrag = [style[NSSnailBadgeEnableDragAnimationKey] boolValue];
    if (style[NSSnailBadgePaddingKey]) {
        UIView *customeView = [self.privateSnailBadgeView takeCustomeView];
        if (!customeView) {
            self.privateSnailBadgeView.snailBadgePadding = [style[NSSnailBadgePaddingKey] UIEdgeInsetsValue];
            [self _refeshBadgeFrame];
        }
    }
    
}

- (void)snailBadgeOffset:(CGPoint)offset {
    self.privateSnailBadgeView.snailBadgeOffset = offset;
    CGRect frame = self.privateSnailBadgeView.frame;
    frame.origin.x = self.bounds.size.width - frame.size.width - self.privateSnailBadgeView.snailBadgeOffset.x;
    frame.origin.y = self.privateSnailBadgeView.snailBadgeOffset.y;
    self.privateSnailBadgeView.frame = frame;
}

- (void)snailBadgeShow:(NSString *)text {
    
    self.privateSnailBadgeView.text = text;
    [self bringSubviewToFront:self.privateSnailBadgeView];
    UIView *customeView = [self.privateSnailBadgeView takeCustomeView];
    if (customeView && self.privateConfigureCustomeViewBlock) {
        self.privateConfigureCustomeViewBlock(customeView,text);
        CGSize size = customeView.frame.size;
        CGRect frame = self.privateSnailBadgeView.frame;
        frame.size = size;
        frame.origin.x = self.bounds.size.width - frame.size.width - self.privateSnailBadgeView.snailBadgeOffset.x;
        frame.origin.y = self.privateSnailBadgeView.snailBadgeOffset.y;
        self.privateSnailBadgeView.frame = frame;
        self.privateSnailBadgeView.contentView.layer.cornerRadius = 0;
        self.privateSnailBadgeView.contentView.layer.masksToBounds = true;
    }
    else if (!customeView) {
        
        CGSize size = CGSizeMake(4, 4);
        if (text.length > 0) {
            CGSize tmp = [text boundingRectWithSize:CGSizeMake(UIScreen.mainScreen.bounds.size.width - 30, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.privateSnailBadgeView.font} context:nil].size;
            size = CGSizeMake(ceil(tmp.width), ceil(tmp.height));
        };
        self.privateSnailBadgeView.snailBadgeTextSize = size;
        [self _refeshBadgeFrame];
        
    }
    [self addSubview:self.privateSnailBadgeView];

}

- (void)snailBadgeShowCustomeView:(UIView *)customeView Block:(SnailBadgeCustomeViewConfigureBlock)block {
    self.privateConfigureCustomeViewBlock = block;
    self.privateCustomeView = customeView;
    [self.privateSnailBadgeView addCustomeView:customeView];
    [self snailBadgeShow:self.privateSnailBadgeView.text];
}

- (void)snailBadgeDragAnimationEndBlock:(SnailBadgeDragEndBlock)dragEndBlock {
    self.privateDragEndCallBlock = dragEndBlock;
}

- (void)snailBadgeClearBackgroundImage {
    self.privateSnailBadgeView.backImg = nil;
}

- (void)snailBadgeHidden {
    [self.privateSnailBadgeView removeFromSuperview];
}

- (void)_refeshBadgeFrame {
    
    CGSize size = self.privateSnailBadgeView.snailBadgeTextSize;
    CGRect frame = self.privateSnailBadgeView.frame;
    
    frame.size.width = size.width + self.privateSnailBadgeView.snailBadgePadding.left + self.privateSnailBadgeView.snailBadgePadding.right;
    frame.size.height = size.height + self.privateSnailBadgeView.snailBadgePadding.top + self.privateSnailBadgeView.snailBadgePadding.bottom;
    
    if (frame.size.width < frame.size.height) frame.size.width = frame.size.height;
    else if (frame.size.width != frame.size.height) frame.size.width += 8;
    
    frame.origin.x = self.bounds.size.width - frame.size.width - self.privateSnailBadgeView.snailBadgeOffset.x;
    frame.origin.y = self.privateSnailBadgeView.snailBadgeOffset.y;
    self.privateSnailBadgeView.frame = frame;
    self.privateSnailBadgeView.contentView.layer.cornerRadius = frame.size.height * .5;
    self.privateSnailBadgeView.contentView.layer.masksToBounds = true;
    
}

- (_SnailBadgeView *)privateSnailBadgeView {
    _SnailBadgeView *view = objc_getAssociatedObject(self, @selector(privateSnailBadgeView));
    if (!view) {
        view = [self _createSnailBadgeView];
        [self setPrivateSnailBadgeView:view];
        
        __weak typeof(self) self_weak_ = self;
        view.snailBadgeViewStopBlock = ^(BOOL isBroken) {
            if (self_weak_.privateDragEndCallBlock) self_weak_.privateDragEndCallBlock(isBroken,self_weak_);
        };
        
        if (self.privateCustomeView) {
            [self snailBadgeShowCustomeView:self.privateCustomeView Block:self.privateConfigureCustomeViewBlock];
        }
        [self _snailBadgeStyle:self.privateSnailBadgeStyle];
        
    }
    return view;
}

- (void)setPrivateSnailBadgeView:(_SnailBadgeView *)view {
    objc_setAssociatedObject(self, @selector(privateSnailBadgeView), view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)privateCustomeView {
    return objc_getAssociatedObject(self, @selector(privateCustomeView));
}

- (void)setPrivateCustomeView:(UIView *)view {
    objc_setAssociatedObject(self, @selector(privateCustomeView), view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SnailBadgeCustomeViewConfigureBlock)privateConfigureCustomeViewBlock {
    return objc_getAssociatedObject(self, @selector(privateConfigureCustomeViewBlock));
}

- (void)setPrivateConfigureCustomeViewBlock:(SnailBadgeCustomeViewConfigureBlock)block {
    objc_setAssociatedObject(self, @selector(privateConfigureCustomeViewBlock), block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SnailBadgeDragEndBlock)privateDragEndCallBlock {
    return objc_getAssociatedObject(self, @selector(privateDragEndCallBlock));
}

- (void)setPrivateDragEndCallBlock:(SnailBadgeDragEndBlock)block {
    objc_setAssociatedObject(self, @selector(privateDragEndCallBlock), block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)privateSnailBadgeStyle {
    return objc_getAssociatedObject(self, @selector(privateSnailBadgeStyle));
}

- (void)setPrivateSnailBadgeStyle:(NSDictionary *)style {
    objc_setAssociatedObject(self, @selector(privateSnailBadgeStyle), style, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation UITabBarItem(SnailBadge)

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"view"]) {
    
        UIView *view = change[NSKeyValueChangeOldKey];
        if (view && ![view isEqual:[NSNull null]]) {
            SnailBadgeSubscribeExtend *tmp = view.snailBadgeExtend;
            tmp.linkView = change[NSKeyValueChangeNewKey];
            [self _snailBadgeDragAnimationEndBlock:view.privateDragEndCallBlock];
        }
        
        NSDictionary *dic = objc_getAssociatedObject(self, @selector(snailBadgeStyle:));
        [self snailBadgeStyle:dic];
        
        NSString *text = objc_getAssociatedObject(self, @selector(snailBadgeShow:));
        if (text) [self _snailBadgeShow:text];
        
    }
}

- (void)dealloc {
    BOOL isOb = [objc_getAssociatedObject(self, @selector(snailBadgeTargetView)) boolValue];
    if (isOb) {
        [self removeObserver:self forKeyPath:@"view"];
    }
}

- (UIView *)snailBadgeTargetView {
    BOOL isOb = [objc_getAssociatedObject(self, @selector(snailBadgeTargetView)) boolValue];
    if (!isOb) {
        [self addObserver:self forKeyPath:@"view" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        objc_setAssociatedObject(self, @selector(snailBadgeTargetView), @true, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return [self valueForKey:@"_view"];
}

- (void)snailBadgeClearBackgroundImage {
    [self.snailBadgeTargetView snailBadgeClearBackgroundImage];
}

- (void)snailBadgeHidden {
    dispatch_async(dispatch_get_main_queue(), ^{
        objc_setAssociatedObject(self, @selector(snailBadgeShow:), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self.snailBadgeTargetView snailBadgeHidden];
    });
}

- (void)snailBadgeOffset:(CGPoint)offset {
    objc_setAssociatedObject(self, @selector(snailBadgeOffset:), [NSValue valueWithCGPoint:offset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    offset = [self fixBadgeOffset:offset];
    [self _snailBadgeOffset:offset];
}

- (void)_snailBadgeOffset:(CGPoint)offset {
    [self.snailBadgeTargetView snailBadgeOffset:offset];
}

- (void)snailBadgeShow:(NSString *)text {
    objc_setAssociatedObject(self, @selector(snailBadgeShow:), text, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self _snailBadgeShow:text];
}

- (void)_snailBadgeShow:(NSString *)text {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.snailBadgeTargetView snailBadgeShow:text];
        NSValue *value = objc_getAssociatedObject(self, @selector(snailBadgeOffset:));
        [self snailBadgeOffset:value.CGPointValue];
    });
}

- (void)snailBadgeShowCustomeView:(UIView *)customeView Block:(SnailBadgeCustomeViewConfigureBlock)block {
    [self.snailBadgeTargetView snailBadgeShowCustomeView:customeView Block:block];
}

- (void)snailBadgeStyle:(NSDictionary *)style {
    objc_setAssociatedObject(self, @selector(snailBadgeStyle:), style, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self _snailBadgeStyle:style];
}

- (void)_snailBadgeStyle:(NSDictionary *)style {
    [self.snailBadgeTargetView snailBadgeStyle:style];
}

- (void)snailBadgeDragAnimationEndBlock:(SnailBadgeDragEndBlock)dragEndBlock {
    [self _snailBadgeDragAnimationEndBlock:dragEndBlock];
}

- (void)_snailBadgeDragAnimationEndBlock:(SnailBadgeDragEndBlock)dragEndBlock {
    [self.snailBadgeTargetView snailBadgeDragAnimationEndBlock:dragEndBlock];
}

#pragma mark - SnailBadgeReplaceViewProtocol

- (CGPoint)fixBadgeOffset:(CGPoint)offset {
    
    CGPoint point = CGPointMake(0, 2);
    
    CGSize imgSize = [(UIView *)[self.snailBadgeTargetView valueForKey:@"info"] bounds].size;
    CGSize lblSize = [(UIView *)[self.snailBadgeTargetView valueForKey:@"label"] bounds].size;
    if (!CGSizeEqualToSize(CGSizeZero, imgSize)) {
        CGFloat x = self.snailBadgeTargetView.bounds.size.width * .5 - imgSize.width * .5 - self.snailBadgeTargetView.privateSnailBadgeView.bounds.size.width;
        point.x = x;
    }
    else if (!CGSizeEqualToSize(CGSizeZero, lblSize)) {
        CGFloat x = self.snailBadgeTargetView.bounds.size.width * .5 - lblSize.width * .5 - self.snailBadgeTargetView.privateSnailBadgeView.bounds.size.width;
        point.x = x;
    }
    
    point.x -= (offset.x - 5);
    point.y += offset.y;
    
    return point;
    
}

@end

@implementation UIBarButtonItem(SnailBadge)

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"view"]) {
        
        UIView *view = change[NSKeyValueChangeOldKey];
        if (view && ![view isEqual:[NSNull null]]) {
            SnailBadgeSubscribeExtend *tmp = view.snailBadgeExtend;
            tmp.linkView = change[NSKeyValueChangeNewKey];
            [self snailBadgeDragAnimationEndBlock:view.privateDragEndCallBlock];
        }
        
        NSDictionary *dic = objc_getAssociatedObject(self, @selector(snailBadgeStyle:));
        [self snailBadgeStyle:dic];
        
        NSString *text = objc_getAssociatedObject(self, @selector(snailBadgeShow:));
        if (text) [self _snailBadgeShow:text];
        
    }
}

- (void)dealloc {
    BOOL isOb = [objc_getAssociatedObject(self, @selector(snailBadgeTargetView)) boolValue];
    if (isOb) {
        [self removeObserver:self forKeyPath:@"view"];
    }
}

- (UIView *)snailBadgeTargetView {
    BOOL isOb = [objc_getAssociatedObject(self, @selector(snailBadgeTargetView)) boolValue];
    if (!isOb) {
        [self addObserver:self forKeyPath:@"view" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        objc_setAssociatedObject(self, @selector(snailBadgeTargetView), @true, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return [self valueForKey:@"_view"];
}

- (void)snailBadgeClearBackgroundImage {
    [self.snailBadgeTargetView snailBadgeClearBackgroundImage];
}

- (void)snailBadgeHidden {
    objc_setAssociatedObject(self, @selector(snailBadgeShow:), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.snailBadgeTargetView snailBadgeHidden];
}

- (void)snailBadgeOffset:(CGPoint)offset {
    [self.snailBadgeTargetView snailBadgeOffset:offset];
}

- (void)snailBadgeShow:(NSString *)text {
    objc_setAssociatedObject(self, @selector(snailBadgeShow:), text, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self _snailBadgeShow:text];
}

- (void)_snailBadgeShow:(NSString *)text {
    [self.snailBadgeTargetView snailBadgeShow:text];
}

- (void)snailBadgeShowCustomeView:(UIView *)customeView Block:(SnailBadgeCustomeViewConfigureBlock)block {
    [self.snailBadgeTargetView snailBadgeShowCustomeView:customeView Block:block];
}

- (void)snailBadgeStyle:(NSDictionary *)style {
    [self.snailBadgeTargetView snailBadgeStyle:style];
}

- (void)snailBadgeDragAnimationEndBlock:(SnailBadgeDragEndBlock)dragEndBlock {
    [self.snailBadgeTargetView snailBadgeDragAnimationEndBlock:dragEndBlock];
}

@end

@implementation _SnailBadgeView
{
    UILabel *_contentLbl;
    UIView *_customeView;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        self.snailBadgeOffset = CGPointZero;
        self.snailBadgePadding = UIEdgeInsetsMake(1, 1, 1 ,1);
        
        self.font = [UIFont systemFontOfSize:13];
        self.textColor = [UIColor whiteColor];
        self.backColor = [UIColor redColor];
        self.backImg = nil;
        
        _contentView = [UIView new];
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        _contentLbl = [UILabel new];
        _contentLbl.textAlignment = NSTextAlignmentCenter;
        
        [_contentView addSubview:_contentLbl];
        [self addSubview:_contentView];
        
        __weak typeof(self) self_weak_ = self;
        self.startBlock = ^{
            self_weak_.contentView.hidden = true;
        };
        self.stopBlock = ^(BOOL isBroken) {
            self_weak_.contentView.hidden = false;
            if (self_weak_.snailBadgeViewStopBlock) {
                self_weak_.snailBadgeViewStopBlock(isBroken);
            }
        };
        
    }
    return self;
}

- (void)addCustomeView:(UIView *)customeView {
    if (_customeView) {
        [_customeView removeFromSuperview];
        _customeView = nil;
    }
    _customeView = customeView;
    _customeView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _customeView.frame = _contentView.bounds;
    [_contentView addSubview:_customeView];
    [self refesh];
}

- (UIView *)takeCustomeView {
    return _customeView;
}

- (void)refesh {
    _contentLbl.font = self.font;
    _contentLbl.textColor = self.textColor;
    _contentLbl.text = self.text;
    _contentLbl.hidden = _customeView!=nil;
    _contentLbl.numberOfLines = 0;
    if (self.backImg) _contentView.layer.contents = (__bridge id _Nullable)(self.backImg.CGImage);
    else {
        _contentView.layer.contents = nil;
        _contentView.backgroundColor = self.backColor;
    }
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    _contentLbl.frame = CGRectMake(self.snailBadgePadding.left, self.snailBadgePadding.top, frame.size.width - self.snailBadgePadding.left - self.snailBadgePadding.right, frame.size.height - self.snailBadgePadding.top - self.snailBadgePadding.bottom);
    _contentView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    if (_customeView) _customeView.frame = _contentView.bounds;
}

- (void)setText:(NSString *)text {
    _text = text;
    [self refesh];
}

- (void)setFont:(UIFont *)font {
    _font = font;
    [self refesh];
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    [self refesh];
}

- (void)setBackColor:(UIColor *)backColor {
    _backColor = backColor;
    [self snailFilleColor:backColor];
    [self refesh];
}

- (void)setBackImg:(UIImage *)backImg {
    _backImg = backImg;
    [self refesh];
}

@end
