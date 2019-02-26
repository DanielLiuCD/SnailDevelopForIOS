//
//  SnailMaskScreen.m
//  QianXun
//
//  Created by JobNewMac1 on 2018/11/7.
//  Copyright © 2018年 com.jobnew. All rights reserved.
//

#import "SnailMaskScreen.h"

@interface SnailMaskScreen()

@property (nonatomic ,strong) NSArray<UIVisualEffectView *> *effects;

@property (nullable ,nonatomic ,strong) UIView *innerView;
@property (nullable ,nonatomic ,strong) UIPanGestureRecognizer *panGes;

@end

@implementation SnailMaskScreen

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self comminInit];
    }
    return self;
}

- (void)comminInit {
    _translucent = false;
    _dragInnerView = true;
    NSMutableArray *tmps = [NSMutableArray new];
    for (int i = 0; i < 4; i++) {
        UIVisualEffectView *effectView = [UIVisualEffectView new];
        effectView.backgroundColor = [UIColor blackColor];
        effectView.alpha = .6;
        [tmps addObject:effectView];
        [self addSubview:effectView];
    }
    self.effects = tmps.copy;
    [self refesh];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self refesh];
}

- (void)refesh {
    
    CGRect paddingRect = CGRectMake(self.marignInsets.left, self.marignInsets.top, self.bounds.size.width - self.marignInsets.left - self.marignInsets.right, self.bounds.size.height - self.marignInsets.top - self.marignInsets.bottom);
    
    CGRect innerFrame = CGRectZero;
    if (self.innerView) innerFrame = self.innerView.frame;
    
    CGFloat maxInnerSize = 0;
    BOOL isWidthMax = false;
    if (innerFrame.size.width >= innerFrame.size.height) {
        maxInnerSize = innerFrame.size.width;
        isWidthMax = true;
    }
    else {
        maxInnerSize = innerFrame.size.height;
    }
    
    if (maxInnerSize > paddingRect.size.width || maxInnerSize > paddingRect.size.height) {
        CGFloat scale = innerFrame.size.width / innerFrame.size.height;
        if (isWidthMax) {
            innerFrame.size.width = paddingRect.size.width;
            innerFrame.size.height = paddingRect.size.width / scale;
        }
        else {
            innerFrame.size.width = paddingRect.size.height * scale;
            innerFrame.size.height = paddingRect.size.height;
        }
    }
    
    if (innerFrame.origin.x < paddingRect.origin.x) innerFrame.origin.x = paddingRect.origin.x;
    if (innerFrame.origin.y < paddingRect.origin.y) innerFrame.origin.y = paddingRect.origin.y;
    if (CGRectGetMaxX(innerFrame) > CGRectGetMaxX(paddingRect)) innerFrame.origin.x = CGRectGetMaxX(paddingRect) - innerFrame.size.width;
    if (CGRectGetMaxY(innerFrame) > CGRectGetMaxY(paddingRect)) innerFrame.origin.y = CGRectGetMaxY(paddingRect) - innerFrame.size.height;
    
    CGRect topFrame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetMinY(innerFrame));
    CGRect leadingFrame = CGRectMake(0, CGRectGetMinY(innerFrame), CGRectGetMinX(innerFrame), CGRectGetHeight(innerFrame));
    CGRect bottomFrame = CGRectMake(0, CGRectGetMaxY(innerFrame), CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - CGRectGetMaxY(innerFrame));
    CGRect trailingFrame = CGRectMake(CGRectGetMaxX(innerFrame), CGRectGetMinY(innerFrame), CGRectGetWidth(self.bounds) - CGRectGetMaxX(innerFrame), CGRectGetHeight(innerFrame));
    
    self.innerView.frame = innerFrame;
    self.effects[0].frame = topFrame;
    self.effects[1].frame = leadingFrame;
    self.effects[2].frame = bottomFrame;
    self.effects[3].frame = trailingFrame;
    
}

- (void)replaceInnerView:(UIView *)innerView {
    if (_innerView) {
        [_innerView removeGestureRecognizer:self.panGes];
        [_innerView removeFromSuperview];
    }
    _innerView = innerView;
    [self addSubview:_innerView];
    _innerView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    if (self.dragInnerView) {
        [self enablePanGes];
    }
    [self refesh];
}

- (void)updateInnerViewFrame:(CGRect)frame {
    _innerView.frame = frame;
    [self refesh];
}

- (void)updateInnerViewCenter:(CGPoint)center {
    _innerView.center = center;
    [self refesh];
}

- (void)panAction:(UIPanGestureRecognizer *)ges {
    CGPoint offsetPoint = [ges translationInView:self];
    NSLog(@"offset:%@",NSStringFromCGPoint(offsetPoint));
    CGPoint poin = self.innerView.center;
    poin.x += offsetPoint.x;
    poin.y += offsetPoint.y;
    [self updateInnerViewCenter:poin];
    [ges setTranslation:CGPointMake(0, 0) inView:self];
}

- (void)enablePanGes {
    if (_innerView) {
        [_innerView addGestureRecognizer:self.panGes];
        _innerView.userInteractionEnabled = true;
    }
}

- (void)disablePanGes {
    [_innerView removeGestureRecognizer:self.panGes];
    self.panGes = nil;
}

- (UIPanGestureRecognizer *)panGes {
    if (!_panGes) {
        _panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    }
    return _panGes;
}

- (void)setDragInnerView:(BOOL)dragInnerView {
    if (dragInnerView != _dragInnerView) {
        _dragInnerView = dragInnerView;
        if (_dragInnerView) [self enablePanGes];
        else [self disablePanGes];
    }
}

- (void)setTranslucent:(BOOL)translucent {
    if (_translucent != translucent) {
        _translucent = translucent;
        if (translucent) {
            [self.effects enumerateObjectsUsingBlock:^(UIVisualEffectView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                obj.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            }];
        }
        else {
            [self.effects enumerateObjectsUsingBlock:^(UIVisualEffectView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                obj.effect = nil;
            }];
        }
    }
}

- (CGFloat)alpha {
    return self.effects[0].alpha;
}

- (void)setAlpha:(CGFloat)alpha {
    [self.effects enumerateObjectsUsingBlock:^(UIVisualEffectView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.alpha = alpha;
    }];
}

@end
