//
//  SnailMenuBar.m
//  SnailMenu
//
//  Created by JobNewMac1 on 2018/10/24.
//  Copyright © 2018年 com.crazysnail. All rights reserved.
//

#import "SnailMenuBar.h"
#import "SnailMenuBarItem.h"

#define SNAILMENUBARITEM_PROTECTED_ACCESS

#import "SnailMenuBarItem+Private.h"
#import <objc/runtime.h>

@interface SnailMenuBarItem(__SnailMenuBar)

@property (nonatomic ,weak ,readonly) SnailMenuBarItem *__nextItem;
@property (nonatomic ,weak ,readonly) SnailMenuBarItem *__previousItem;
@property (nonatomic) BOOL __needUpdateSize;

@end

@implementation SnailMenuBarItem(__SnailMenuBar)

- (SnailMenuBarItem *)__nextItem {
    return objc_getAssociatedObject(self, @selector(__nextItem));
}

- (SnailMenuBarItem *)__previousItem {
    return objc_getAssociatedObject(self, @selector(__previousItem));
}

- (void)set__needUpdateSize:(BOOL)__needUpdateSize {
    objc_setAssociatedObject(self, @selector(__needUpdateSize), @(__needUpdateSize), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)__needUpdateSize {
    NSNumber *num = objc_getAssociatedObject(self, @selector(__needUpdateSize));
    return num.boolValue;
}

@end

@interface _SnailMenuBarButton : UIControl

@property (nonatomic ,strong) UIView *contentView;

@property (nonatomic ,strong) UIImageView *icon;
@property (nonatomic ,strong) UILabel *title;

@property (nonatomic ,strong) UIView *badgeContainer;
@property (nonatomic ,strong) UILabel *badgeLbl;

@property (nonatomic ,strong) NSLayoutConstraint *titleLeading;

@end

@implementation _SnailMenuBarButton

- (instancetype)init {
    self = [super init];
    if (self) {
        
        self.clipsToBounds = true;
        
        self.contentView = [UIView new];
        self.contentView.userInteractionEnabled = false;
        
        self.icon = [UIImageView new];
        self.title = [UILabel new];
        
        self.badgeContainer = [UIView new];
        self.badgeContainer.backgroundColor = [UIColor redColor];
        self.badgeContainer.hidden = true;
        self.badgeContainer.layer.masksToBounds = true;
        
        self.badgeLbl = [UILabel new];
        self.badgeLbl.textAlignment = NSTextAlignmentCenter;
        self.badgeLbl.textColor = [UIColor whiteColor];
        
        [self addSubview:self.contentView];
        [self addSubview:self.badgeContainer];
        
        [self.contentView addSubview:self.icon];
        [self.contentView addSubview:self.title];
        
        [self.badgeContainer addSubview:self.badgeLbl];
        
        self.contentView.translatesAutoresizingMaskIntoConstraints = false;
        self.icon.translatesAutoresizingMaskIntoConstraints = false;
        self.title.translatesAutoresizingMaskIntoConstraints = false;
        
        self.badgeContainer.translatesAutoresizingMaskIntoConstraints = false;
        self.badgeLbl.translatesAutoresizingMaskIntoConstraints = false;
        
        NSLayoutConstraint *contentX= [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
        NSLayoutConstraint *contentY = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
        NSLayoutConstraint *contentH = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
        NSLayoutConstraint *contentW = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
        
        NSLayoutConstraint *iconL = [NSLayoutConstraint constraintWithItem:self.icon attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
        NSLayoutConstraint *iconY = [NSLayoutConstraint constraintWithItem:self.icon attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
        
        NSLayoutConstraint *titleY = [NSLayoutConstraint constraintWithItem:self.title attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
        NSLayoutConstraint *titleT = [NSLayoutConstraint constraintWithItem:self.title attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
        
        self.titleLeading = [NSLayoutConstraint constraintWithItem:self.title attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.icon attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
        
        [self.contentView addConstraints:@[iconL,iconY,titleY,self.titleLeading,titleT]];
        [self addConstraints:@[contentX,contentY,contentH,contentW]];
        
        NSLayoutConstraint *badgeCB = [NSLayoutConstraint constraintWithItem:self.badgeContainer attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.title attribute:NSLayoutAttributeTop multiplier:1.0 constant:7];
        NSLayoutConstraint *badgeCT = [NSLayoutConstraint constraintWithItem:self.badgeContainer attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
        
        NSLayoutConstraint *badgeX= [NSLayoutConstraint constraintWithItem:self.badgeLbl attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.badgeContainer attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
        NSLayoutConstraint *badgeY = [NSLayoutConstraint constraintWithItem:self.badgeLbl attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.badgeContainer attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
        NSLayoutConstraint *badgeL = [NSLayoutConstraint constraintWithItem:self.badgeLbl attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.badgeContainer attribute:NSLayoutAttributeLeading multiplier:1.0 constant:3];
        NSLayoutConstraint *badgeTop = [NSLayoutConstraint constraintWithItem:self.badgeLbl attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.badgeContainer attribute:NSLayoutAttributeTop multiplier:1.0 constant:3];
        
        [self.badgeContainer addConstraints:@[badgeX,badgeY,badgeL,badgeTop]];
        [self addConstraints:@[badgeCB,badgeCT]];
        
    }
    return self;
}

@end

#define SnailMenuBarStaticHeight 44

@interface SnailMenuBar()<SnailMenuBarItemProtocol>

@property (nonatomic ,strong) UIToolbar *bar;
@property (nonatomic ,strong) UIImageView *backImageView;
@property (nonatomic ,strong) UIScrollView *scro;
@property (nonatomic ,strong) UIView *bottomLine;
@property (nonatomic ,strong) UIView *indicator;

@property (nonatomic ,strong) NSMutableArray<_SnailMenuBarButton *> *_buttons;
@property (nonatomic) NSInteger selectedIndex;

@end

@implementation SnailMenuBar

@dynamic indicatorColor,bounces;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) [self _init];
    return self;
}

- (void)_init {
    
    self.backgroundColor = [UIColor whiteColor];
    
    _itemOnePageCount = 5;

    _indicatorHeight = 2.5f;
    _indicatorAnimation = true;
    _indicatorStaticWidth = 30.f;

    _bottomLineColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    _bottomLineHeight = .8f;
    
    _padding = (SnailMenuBarPadding){.leading=0,.trailing=0};
    
    self.bar = [[UIToolbar alloc] initWithFrame:self.bounds];
    self.bar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    self.backImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.backImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    self.bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - self.bottomLineHeight, self.bounds.size.width, self.bottomLineHeight)];
   
    self.indicator = [UIView new];
    
    self.scro = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - SnailMenuBarStaticHeight - self.bottomLineHeight, self.bounds.size.width, SnailMenuBarStaticHeight)];
    self.scro.showsHorizontalScrollIndicator = false;
    self.scro.showsVerticalScrollIndicator = false;
    if (@available(iOS 11.0,*)) {
        self.scro.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    [self addSubview:self.bar];
    [self addSubview:self.backImageView];
    [self addSubview:self.scro];
    [self addSubview:self.bottomLine];
    [self.scro addSubview:self.indicator];
    
    self.indicator.backgroundColor = [UIColor blueColor];
    self.showIndicator = true;
    self.bottomLine.backgroundColor = self.bottomLineColor;
    
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.bottomLine.frame = CGRectMake(0, frame.size.height - self.bottomLineHeight, self.bounds.size.width, self.bottomLineHeight);
    self.scro.frame = CGRectMake(0, frame.size.height - SnailMenuBarStaticHeight - self.bottomLineHeight, frame.size.width, SnailMenuBarStaticHeight);
    [self refeshSize:false];
}

#pragma mark -

- (void)_buttonAction:(_SnailMenuBarButton *)button {
    NSInteger index = [self._buttons indexOfObject:button];
    [self selectedAtIndex:index animated:labs(index - self.selectedIndex) == 1 CallBack:true];
}

#pragma mark -

- (void)forceRefeshUI:(BOOL)animated {

    for (NSInteger i = 0; i < self.items.count; i++) {
        SnailMenuBarItem *item = self.items[i];
        _SnailMenuBarButton *btn;
        if (i < self._buttons.count) btn = self._buttons[i];
        else {
            btn = [_SnailMenuBarButton new];
            [btn addTarget:self action:@selector(_buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            [self._buttons addObject:btn];
            [self.scro addSubview:btn];
        }
        [self _configureBtn:btn Item:item];
        objc_setAssociatedObject(item, @selector(view), btn, OBJC_ASSOCIATION_ASSIGN);
    }
    if (self.items.count < self._buttons.count) {
        NSRange range = NSMakeRange(self.items.count, self._buttons.count - self.items.count);
        NSArray *tmp = [self._buttons subarrayWithRange:range];
        [tmp makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self._buttons removeObjectsInRange:range];
    }
    [self refeshSize:animated];
}

- (void)refeshSize:(BOOL)animaled {
    if (animaled) {
        [UIView animateWithDuration:0.2 animations:^{
            [self _updateButtonSize];
            [self _fixAvailableRect];
        } completion:^(BOOL finished) {
        
        }];
    }
    else {
        [self _updateButtonSize];
        [self _fixAvailableRect];
    }
}

#pragma mark -

static CGFloat __SnailMenuBar_fixItemSize(SnailMenuBarItem *item ,CGFloat fixX ,SnailMenuBarItemStrategy startegy,CGFloat maxWidth) {
    
    CGFloat tmpFixX = fixX;
    
    _SnailMenuBarButton *btn = (_SnailMenuBarButton *)item.view;
    CGRect frame = btn.frame;
    frame.origin.x += tmpFixX;
    
    if (item.__needUpdateSize) {
        CGFloat width = 0.0;
        BOOL needUpdateWidth = false;
        if (startegy == SnailMenuBarItemStrategyFit) {
            width = item.size.width;
            needUpdateWidth = true;
        }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        else if (startegy == SnailMenuBarItemStrategyMax) {
#pragma clang diagnostic pop
            if (maxWidth != frame.size.width) {
                width = maxWidth;
                needUpdateWidth = true;
            }
        }
        if (needUpdateWidth) {
            tmpFixX += (width - frame.size.width);
            frame.size.width = width;
        }
    }
    
    btn.frame = frame;
    
    if (item.__nextItem) return __SnailMenuBar_fixItemSize(item.__nextItem,tmpFixX,startegy,maxWidth);
    else return CGRectGetMaxX(frame);
    
}

- (void)_updateButtonSize {
    
    CGFloat x = 0;
    CGFloat maxWidth = 0;
    CGFloat avergeWidth = 0;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (self.itemStrategy == SnailMenuBarItemStrategyMax) {
#pragma ckang diagnostic pop
        for (SnailMenuBarItem *item in self.items) {
            maxWidth = MAX(item.size.width, maxWidth);
        }
    }
    else if (self.itemStrategy == SnailMenuBarItemStrategyDefault) {
        avergeWidth = floor(self.bounds.size.width / self.itemOnePageCount);
    }
    CGFloat height = self.scro.bounds.size.height - self.indicatorHeight;
    for (NSInteger i = 0; i < self.items.count; i++) {
        @autoreleasepool {
            SnailMenuBarItem *item = self.items[i];
            CGSize size = CGSizeMake(CGFLOAT_MIN, SnailMenuBarStaticHeight);
            switch (self.itemStrategy) {
                case SnailMenuBarItemStrategyDefault:size.width = avergeWidth;
                    break;
                case SnailMenuBarItemStrategyFit:size.width = item.size.width;
                    break;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                case SnailMenuBarItemStrategyMax:size.width = maxWidth;
#pragma ckang diagnostic pop
                    break;
                default:
                    NSAssert(false, @"error");
                    break;
            }
            _SnailMenuBarButton *btn = self._buttons[i];
            btn.frame = CGRectMake(x, 0, size.width, height);
            x += (size.width + self.spaceing);
        }
    }
    self.scro.contentSize = CGSizeMake(self._buttons.count>0?CGRectGetMaxX(self._buttons.lastObject.frame):0, SnailMenuBarStaticHeight);
    [self _updateIndicatorSize];
}

- (void)_updateIndicatorSize {
    if (self._buttons.count > 0 && self.selectedIndex < self._buttons.count) {
        _SnailMenuBarButton *btn = self._buttons[self.selectedIndex];
        CGFloat width;
        CGFloat x;
        switch (self.indictorStrategy) {
            case SnailMenuBarIndicatorStrategyDefault:
                width = btn.frame.size.width;
                x = btn.frame.origin.x;
                break;
            case SnailMenuBarIndicatorStrategyStatic:
                width = self.indicatorStaticWidth;
                x = btn.frame.origin.x + (btn.frame.size.width - width) * .5;
                break;
            default:
                NSAssert(nil, @"error");
                break;
        }
        self.indicator.frame = CGRectMake(x, self.scro.bounds.size.height - self.indicatorHeight, width, self.indicatorHeight);
    }
}

- (void)_fixAvailableRect {
    if (self.selectedIndex < self._buttons.count) {
        SnailMenuBarItem *item = self.items[self.selectedIndex];
        _SnailMenuBarButton *lastbtn = (_SnailMenuBarButton *)item.__previousItem.view;
        _SnailMenuBarButton *nextBtn = (_SnailMenuBarButton *)item.__nextItem.view;
        if (CGRectGetMaxX(nextBtn.frame) > (self.bounds.size.width + self.scro.contentOffset.x - self.padding.trailing)) {
            CGFloat x = CGRectGetMaxX(nextBtn.frame) - self.bounds.size.width;
            [self.scro setContentOffset:CGPointMake(x+self.padding.trailing, 0)];
        }
        else if (CGRectGetMinX(lastbtn.frame) < self.scro.contentOffset.x + self.padding.leading) {
            CGFloat x =  CGRectGetMinX(lastbtn.frame);
            [self.scro setContentOffset:CGPointMake(x-self.padding.leading, 0)];
        }
    }
}

#pragma mark -

- (void)_configureBtn:(_SnailMenuBarButton *)btn Item:(SnailMenuBarItem *)item {
    btn.icon.image = item.showImage;
    btn.title.attributedText = item.showTitle;
    if (!item.showImage) {
        btn.icon.hidden = true;
        btn.titleLeading.constant = 0;
    }
    else {
        btn.icon.hidden = false;
        btn.titleLeading.constant = item.spaceing;
    }
    [self _configureBadgeBtn:btn Item:item];
    if (item.state == SnailMenuBarItemStateNormal) btn.contentView.layer.affineTransform = item.affineTransform;
    else if (item.state == SnailMenuBarItemStateSelected) btn.contentView.layer.affineTransform = item.selectedAffineTransform;
}

- (void)_configureBadgeBtn:(_SnailMenuBarButton *)btn Item:(SnailMenuBarItem *)item {
    btn.badgeContainer.hidden = item.badgeValue?false:true;
    btn.badgeLbl.attributedText = item.showBadge;
    CGSize size = item.badgeSize;
    if (size.width == size.height) btn.badgeContainer.layer.cornerRadius = size.width * .5 + 3;
    else btn.badgeContainer.layer.cornerRadius = 3;
}

#pragma mark -

- (void)setItems:(NSArray<SnailMenuBarItem *> *)items {
    [self setItems:items animated:false];
}

- (void)setItems:(NSArray<SnailMenuBarItem *> *)items animated:(BOOL)animated {
    [self setItems:items Force:true animated:animated];
}

- (void)setItems:(NSArray<SnailMenuBarItem *> *)items Force:(BOOL)force animated:(BOOL)animated {
    
    SnailMenuBarItem *last;
    for (SnailMenuBarItem *item in items) {
        objc_setAssociatedObject(item, @selector(bar), self, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(item, @selector(__previousItem), last, OBJC_ASSOCIATION_ASSIGN);
        if (last) objc_setAssociatedObject(last, @selector(__nextItem), item, OBJC_ASSOCIATION_ASSIGN);
        last = item;
    }
    
    if (force) {
        if (_selectedIndex < _items.count) {
            SnailMenuBarItem *last = _items[_selectedIndex];
            [last setState:SnailMenuBarItemStateNormal];
        }
        _selectedIndex = 0;
        if (_selectedIndex < items.count) {
            SnailMenuBarItem *item = items[_selectedIndex];
            [item setState:SnailMenuBarItemStateSelected];
        }
    }
    else if (_selectedIndex > items.count - 1) {
        _selectedIndex = items.count - 1;
        SnailMenuBarItem *item = items[_selectedIndex];
        [item setState:SnailMenuBarItemStateSelected];
    }
    _items = items;
    [self forceRefeshUI:animated];
}

- (void)selectedAtIndex:(NSInteger)index animated:(BOOL)animated {
    [self selectedAtIndex:index animated:animated CallBack:false];
}

- (void)selectedAtIndex:(NSInteger)index animated:(BOOL)animated CallBack:(BOOL)callBack {
    
    if (index < self.items.count && index != self.selectedIndex) {
        
        NSInteger lastSelectedIndex = self.selectedIndex;
        self.selectedIndex = index;
        
        SnailMenuBarItem *lastItem = self.items[lastSelectedIndex];
        _SnailMenuBarButton *lastButton = (_SnailMenuBarButton *)lastItem.view;
        [lastItem setState:SnailMenuBarItemStateNormal];
        
        SnailMenuBarItem *item = self.items[index];
        _SnailMenuBarButton *button = (_SnailMenuBarButton *)item.view;
        [item setState:SnailMenuBarItemStateSelected];
        
        [self _configureBtn:lastButton Item:lastItem];
        [self _configureBtn:button Item:item];
        
        CGFloat maxWidth = 0;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        if (self.itemStrategy == SnailMenuBarItemStrategyMax) {
#pragma clang diagnostic pop
            for (SnailMenuBarItem *item in self.items) {
                maxWidth = MAX(item.size.width, maxWidth);
            }
        }
        
        if (self.itemStrategy == SnailMenuBarItemStrategyFit) {
            if (![lastItem isEqualSize]) lastItem.__needUpdateSize = true;
            if (![item isEqualSize]) item.__needUpdateSize = true;
        }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        else if (self.itemStrategy == SnailMenuBarItemStrategyMax) {
#pragma clang diagnostic pop
            if (lastItem.size.width != maxWidth) lastItem.__needUpdateSize = true;
            if (item.size.width != maxWidth) item.__needUpdateSize = true;
        }
        
        SnailMenuBarItem *tmpItem = nil;
        if (lastItem.__needUpdateSize && item.__needUpdateSize) {
            if (index < lastSelectedIndex) tmpItem = item;
            else tmpItem = lastItem;
        }
        else if (lastItem.__needUpdateSize) {
            tmpItem = lastItem;
        }
        else if (item.__needUpdateSize) {
            tmpItem = item;
        }
        
        if (tmpItem) {
            CGFloat width = __SnailMenuBar_fixItemSize(tmpItem, 0, self.itemStrategy, maxWidth);
            self.scro.contentSize = CGSizeMake(width, SnailMenuBarStaticHeight);
        }
    
        if (animated) {
            [UIView animateWithDuration:0.2 animations:^{
                if (self.indicatorAnimation) [self _updateIndicatorSize];
                [self _fixAvailableRect];
            }];
            if (!self.indicatorAnimation) [self _updateIndicatorSize];
        }
        else {
            [self _updateIndicatorSize];
            [self _fixAvailableRect];
        }
        
        if (callBack && self.delegate && [self.delegate respondsToSelector:@selector(menuBar:didSelectItem:)]) {
            [self.delegate menuBar:self didSelectItem:self.items[self.selectedIndex]];
        }
        
    }
    else {
        [self resetIndicator];
    }
    
}


#pragma mark -

- (void)indicatorOffsetX:(CGFloat)scale Left:(BOOL)left {
    
    if (left && self.selectedIndex == 0) {
        return;
    }
    else if (!left && self.selectedIndex == self.items.count - 1) {
        return;
    }

    CGFloat distance;
    
    if (left) {
        distance = self._buttons[self.selectedIndex].center.x - self._buttons[self.selectedIndex - 1].center.x;
    }
    else {
        distance = self._buttons[self.selectedIndex + 1].center.x - self._buttons[self.selectedIndex].center.x;
    }
    
    CGRect frame = self.indicator.frame;
    frame.origin.x += (distance * scale);
    self.indicator.frame = frame;
    if (frame.origin.x < self.scro.contentOffset.x) {
        [self.scro setContentOffset:CGPointMake(frame.origin.x, 0) animated:false];
    }
    else if (CGRectGetMaxX(frame) > self.scro.contentOffset.x + self.scro.bounds.size.width) {
        [self.scro setContentOffset:CGPointMake(CGRectGetMaxX(frame) - self.scro.bounds.size.width, 0) animated:false];
    }
}

- (void)resetIndicator {
    if (self.indicatorAnimation) {
        [UIView animateWithDuration:0.2 animations:^{
            [self _updateIndicatorSize];
        }];
    }
    else [self _updateIndicatorSize];
}

#pragma mark -

- (NSMutableArray<_SnailMenuBarButton *> *)_buttons {
    if (!__buttons) __buttons = [NSMutableArray new];
    return __buttons;
}

#pragma mark - SnailMenuBarItemProtocol

- (void)SnailMenuBarItemUpdateContent:(SnailMenuBarItem *)item {
    [self _configureBtn:(_SnailMenuBarButton *)item.view Item:item];
    [NSThread cancelPreviousPerformRequestsWithTarget:self selector:@selector(_SnailMenuBarItemUpdateContent) object:nil];
    [self performSelector:@selector(_SnailMenuBarItemUpdateContent) withObject:nil afterDelay:.15];
}

- (void)_SnailMenuBarItemUpdateContent {
    if ([NSThread isMainThread]) [self refeshSize:false];
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self refeshSize:false];
        });
    }
}

- (void)SnailMenuBarItemUpdateBadge:(SnailMenuBarItem *)item {
    [self _configureBadgeBtn:(_SnailMenuBarButton *)item.view Item:item];
}

#pragma mark -

- (void)setItemStrategy:(SnailMenuBarItemStrategy)itemStrategy {
    _itemStrategy = itemStrategy;
    [self refeshSize:false];
}

- (void)setItemOnePageCount:(NSInteger)itemOnePageCount {
    _itemOnePageCount = itemOnePageCount;
    [self refeshSize:false];
}

- (void)setBarStyle:(UIBarStyle)barStyle {
    _barStyle = barStyle;
    self.bar.barStyle = barStyle;
}

- (void)setTranslucent:(BOOL)translucent {
    self.bar.translucent = translucent;
}

- (BOOL)isTranslucent {
    return self.bar.translucent;
}

- (void)setBounces:(BOOL)bounces {
    self.scro.bounces = bounces;
}

- (BOOL)bounces {
    return self.scro.bounces;
}

- (void)setSpaceing:(CGFloat)spaceing {
    if (spaceing != _spaceing) {
        _spaceing = spaceing;
        [self refeshSize:false];
    }
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    self.backImageView.image = backgroundImage;
}

- (UIImage *)backgroundImage {
    return self.backImageView.image;
}

- (void)setIndicatorColor:(UIColor *)indicatorColor {
    self.indicator.backgroundColor = indicatorColor;
}

- (UIColor *)indicatorColor {
    return self.indicator.backgroundColor;
}

- (void)setIndicatorHeight:(CGFloat)indicatorHeight {
    _indicatorHeight = indicatorHeight;
    [self _updateIndicatorSize];
}

- (void)setIndicatorStaticWidth:(CGFloat)indicatorStaticWidth {
    _indicatorStaticWidth = indicatorStaticWidth;
    if (self.indictorStrategy == SnailMenuBarIndicatorStrategyStatic) {
        [self _updateIndicatorSize];
    }
}

- (void)setShowIndicator:(BOOL)showIndicator {
    _showIndicator = showIndicator;
    self.indicator.hidden = !showIndicator;
}

- (void)setIndictorStrategy:(SnailMenuBarIndicatorStrategy)indictorStrategy {
    _indictorStrategy = indictorStrategy;
    [self _updateIndicatorSize];
}

- (void)setBottomLineColor:(UIColor *)bottomLineColor {
    _bottomLineColor = bottomLineColor;
    self.bottomLine.backgroundColor = bottomLineColor;
}

- (void)setBottomLineHeight:(CGFloat)bottomLineHeight {
    _bottomLineHeight = bottomLineHeight;
    if (self.delegate && [self.delegate respondsToSelector:@selector(menuBarShouldUpdateHeight)]) {
        [self.delegate menuBarShouldUpdateHeight];
    }
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    if (self.delegate && [self.delegate respondsToSelector:@selector(menuBarShouldUpdateHeight)]) {
        [self.delegate menuBarShouldUpdateHeight];
    }
}

- (void)setPadding:(SnailMenuBarPadding)padding {
    _padding = padding;
    self.scro.contentInset = UIEdgeInsetsMake(0, padding.leading, 0, padding.trailing);
    [self _fixAvailableRect];
}

@end
