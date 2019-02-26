//
//  SnailMenuBarController.m
//  SnailMenu
//
//  Created by JobNewMac1 on 2018/10/24.
//  Copyright © 2018年 com.crazysnail. All rights reserved.
//

#import "SnailMenuBarController.h"

#define SNAILMENUBARITEM_PROTECTED_ACCESS

#import "SnailMenuBarItem+Private.h"
#import <objc/runtime.h>

@interface SnailMenuBar()

- (void)setItems:(nullable NSArray<SnailMenuBarItem *> *)items Force:(BOOL)force animated:(BOOL)animated;

- (void)indicatorOffsetX:(CGFloat)scale Left:(BOOL)left;
- (void)resetIndicator;

@end

@interface UIViewController(SNAILMENUCONTROLLER)

@property (nonatomic) BOOL snail_menu_controller_have_display;

@end

@implementation UIViewController(SNAILMENUCONTROLLER)

- (void)setSnail_menu_controller_have_display:(BOOL)snail_menu_controller_have_display {
    objc_setAssociatedObject(self, @selector(snail_menu_controller_have_display), @(snail_menu_controller_have_display), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)snail_menu_controller_have_display {
    NSNumber *num = objc_getAssociatedObject(self, @selector(snail_menu_controller_have_display));
    return [num boolValue];
}

@end

@interface SnailMenuBarController ()<UIScrollViewDelegate>

@property (nonatomic ,strong) UIView *menuBarHeader;
@property (nonatomic ,strong) UIView *menuBarFooter;
@property (nonatomic ,strong) SnailMenuBar *bar;
@property (nonatomic ,strong) UIScrollView *containerView;

@property (nonatomic) BOOL isDragging;
@property (nonatomic) BOOL isDecelerate;
@property (nonatomic) CGFloat lastOffsetX;
@property (nonatomic) CGFloat originalOffsetX;

@end

@implementation SnailMenuBarController

@dynamic hiddenMenuBar;

- (void)viewDidLoad {
    [super viewDidLoad];
    _menuBarHeader = [[UIView alloc] initWithFrame:CGRectZero];
    _menuBarFooter = [[UIView alloc] initWithFrame:CGRectZero];
    _bar = [SnailMenuBar new];
    _bar.delegate = self;
    self.containerView = [UIScrollView new];
    self.containerView.pagingEnabled = true;
    self.containerView.delegate = self;
    [self.view insertSubview:self.containerView atIndex:0];
    [self.view insertSubview:self.bar atIndex:0];
    if (self.menuBarHeader) [self.view insertSubview:self.menuBarHeader atIndex:0];
    if (self.menuBarFooter) [self.view insertSubview:self.menuBarFooter atIndex:0];
    [self refeshBarFrame];
    [self refeshContainerUI];
    
    [self.view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"navigationController" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"tabBarController" options:NSKeyValueObservingOptionNew context:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)_refeshFrame {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refeshBarFrame];
        [self refeshContainerUI];
        [self.containerView setContentOffset:CGPointMake(self.menuBar.selectedIndex * self.containerView.bounds.size.width, 0) animated:false];
    });
}

- (void)_refeshBarFrame {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refeshBarFrame];
    });
}

- (void)refeshBarFrame {
    
    CGFloat height = 0;
    CGFloat originalY = 0;
    if (self.navigationController && !self.navigationController.navigationBarHidden) {
        if (@available(iOS 11.0,*)) {
            
        }
        else {
           // originalY = [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height;
        }
        height = 44 + self.menuBar.bottomLineHeight;
    }
    else {
        if (@available(iOS 11.0,*)) {
            
        }
        else {
          //  originalY = 0;
        }
        height = 44 + self.menuBar.bottomLineHeight + [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    
    CGFloat y = originalY;
    
    if (!self.menuBar.hidden && self.menuBarHeader) {
        CGRect rect = self.menuBarHeader.frame;
        rect.origin.y = y;
        self.menuBarHeader.frame = rect;
        y = CGRectGetMaxY(rect);
    }
    
    self.bar.frame = CGRectMake(0, y, self.view.bounds.size.width, height);
    
    if (!self.menuBar.hidden && self.menuBarFooter) {
        CGRect rect = self.menuBarFooter.frame;
        rect.origin.y = CGRectGetMaxY(self.bar.frame);
        self.menuBarFooter.frame = rect;
        y = CGRectGetMaxY(rect);
    }
    
    CGFloat tabBarHeight = 0;
    if (self.tabBarController && !self.tabBarController.tabBar.hidden) {
        tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    }
    
    CGFloat containerY = originalY;
    if (!self.bar.hidden) containerY = y;
    
    self.containerView.frame = CGRectMake(0, containerY, self.view.bounds.size.width, self.view.bounds.size.height - containerY - tabBarHeight);
}

- (void)_refeshContainerUI {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refeshContainerUI];
    });
}

- (void)refeshContainerUI {
    [self.containerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSMutableArray *tmpItems = [NSMutableArray new];
    CGFloat x = 0.0;
    for (NSInteger i = 0; i < self.childViewControllers.count; i++) {
        UIViewController *vc = self.childViewControllers[i];
        vc.view.frame = (CGRect){.origin=CGPointMake(x, 0),.size=self.containerView.bounds.size};
        if (vc.snail_menu_controller_have_display) {
            [self.containerView addSubview:vc.view];
        }
        [tmpItems addObject:vc.menuBarItem];
        x += self.containerView.frame.size.width;
    }
    [self.bar setItems:tmpItems Force:false animated:false];
    [self _updateContainerContentSize];
}

- (void)displayViewController:(NSInteger)index {
    if (index < self.childViewControllers.count) {
        UIViewController *vc = self.childViewControllers[index];
        if (!vc.snail_menu_controller_have_display) {
            vc.snail_menu_controller_have_display = true;
            [self.containerView addSubview:vc.view];
        }
    }
}

- (void)_updateContainerContentSize {
    self.containerView.contentSize = CGSizeMake(self.childViewControllers.count * self.containerView.bounds.size.width, self.containerView.bounds.size.height);
}

- (void)addChildViewController:(UIViewController *)childController {
    [super addChildViewController:childController];
    if (self.childViewControllers.count == 1) {
        childController.snail_menu_controller_have_display = true;
        [childController.menuBarItem setState:SnailMenuBarItemStateSelected];
    }
    [NSThread cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(_refeshContainerUI) withObject:nil afterDelay:0.3];
}

- (void)setBar:(SnailMenuBar *)bar {
    if (_bar) {
        [_bar removeFromSuperview];
        _bar = nil;
    }
    [self _setBar:bar];
    [self.view addSubview:bar];
}

- (void)_setBar:(SnailMenuBar *)bar {
    _bar = bar;
    _bar.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
    _bar.delegate = self;
    [self refeshBarFrame];
}

- (void)setMenuBarHeader:(UIView * _Nullable)menuBarHeader {
    if (_menuBarHeader) {
        [_menuBarHeader removeFromSuperview];
        _menuBarHeader = nil;
    }
    _menuBarHeader = menuBarHeader;
    _menuBarHeader.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:menuBarHeader];
    [NSThread cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(_refeshFrame) withObject:nil afterDelay:0.3];
}

- (void)setMenuBarFooter:(UIView * _Nullable)menuBarFooter {
    if (_menuBarFooter) {
        [_menuBarFooter removeFromSuperview];
        _menuBarFooter = nil;
    }
    _menuBarFooter = menuBarFooter;
    _menuBarFooter.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:menuBarFooter];
    [NSThread cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(_refeshFrame) withObject:nil afterDelay:0.3];
}

#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"frame"] || [keyPath isEqualToString:@"tabBarController"] || [keyPath isEqualToString:@"navigationController"]) {
        [NSThread cancelPreviousPerformRequestsWithTarget:self];
        [self performSelector:@selector(_refeshFrame) withObject:nil afterDelay:0.3];
    }
}

#pragma mark -

- (void)_notifySelected:(NSInteger)index {
    if (self.delegate && [self.delegate respondsToSelector:@selector(snailMenuBarController:didSelectedViewController:)]) {
        [self.delegate snailMenuBarController:self didSelectedViewController:self.childViewControllers[index]];
    }
}

#pragma mark -

- (void)menuBar:(SnailMenuBar *)tabBar didSelectItem:(SnailMenuBarItem *)item {
    NSInteger index = [self.childViewControllers indexOfObject:item.viewController];
    [self displayViewController:index];
    CGFloat tmpOffsetX = index * self.containerView.bounds.size.width;
    [self.containerView setContentOffset:CGPointMake(tmpOffsetX, 0) animated:fabs(tmpOffsetX - self.containerView.contentOffset.x) == self.containerView.bounds.size.width];
    [self _notifySelected:index];
}

- (void)menuBarShouldUpdateHeight {
    [self refeshBarFrame];
}

#pragma mark -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.isDragging) {
        CGFloat x = scrollView.contentOffset.x;
        CGFloat offsetX = (x - self.lastOffsetX) / self.containerView.bounds.size.width;
        [self.bar indicatorOffsetX:offsetX Left:self.originalOffsetX > x];
        self.lastOffsetX = x;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isDragging = true;
    self.originalOffsetX = scrollView.contentOffset.x;
    self.lastOffsetX = self.originalOffsetX;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.isDragging = false;
    self.lastOffsetX = 0;
    self.originalOffsetX = 0;
    if (decelerate) {
        self.isDecelerate = true;
    }
    else {
        self.isDecelerate = false;
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    NSInteger index = targetContentOffset->x / self.containerView.bounds.size.width;
    [self displayViewController:index];
    [self.bar selectedAtIndex:index animated:true];
    [self _notifySelected:index];
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.isDecelerate) {
        self.isDecelerate = false;
    }
}

#pragma mark -

- (NSArray<UIViewController *> *)viewControllers {
    return self.childViewControllers.copy;
}

- (void)setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers {
    if (self.viewControllers.count > 0) {
        [self.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromParentViewController];
            [obj.view removeFromSuperview];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [self addChildViewController:obj];
            }];
        });
    }
    else {
        [viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self addChildViewController:obj];
        }];
    }
}

- (UIViewController *)selecterViewController {
    if (self.selectedIndex < self.childViewControllers.count) {
        return self.childViewControllers[self.selectedIndex];
    }
    return nil;
}

- (NSUInteger)selectedIndex {
    return self.bar.selectedIndex;
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    [self.bar selectedAtIndex:selectedIndex animated:true CallBack:true];
}

- (SnailMenuBar *)menuBar {
    return self.bar;
}

- (BOOL)hiddenMenuBar {
    return self.bar.hidden;
}

- (void)setHiddenMenuBar:(BOOL)hiddenMenuBar {
    self.bar.hidden = hiddenMenuBar;
    [self refeshBarFrame];
}

#pragma mark -

- (void)dealloc {
    [self.view removeObserver:self forKeyPath:@"frame" context:nil];
    [self removeObserver:self forKeyPath:@"navigationController"];
    [self removeObserver:self forKeyPath:@"tabBarController"];
}

@end

@implementation UIViewController(SnailMenuBarControllerItem)

- (SnailMenuBarItem *)menuBarItem {
    SnailMenuBarItem *item = objc_getAssociatedObject(self, @selector(menuBarItem));
    if (item == nil) {
        item = [SnailMenuBarItem new];
        [item setViewController:self];
        [self setMenuBarItem:item];
    }
    return item;
}

- (void)setMenuBarItem:(SnailMenuBarItem *)menuBarItem {
    objc_setAssociatedObject(self, @selector(menuBarItem), menuBarItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SnailMenuBarController *)menuBarController {
    return objc_getAssociatedObject(self, @selector(menuBarController));
}

@end
