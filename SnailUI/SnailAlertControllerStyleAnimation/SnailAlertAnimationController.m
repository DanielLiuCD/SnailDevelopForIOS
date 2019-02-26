//
//  SnailAlertAnimationController.m
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/7/20.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import "SnailAlertAnimationController.h"
#import "SnailFadePresentationController.h"

#pragma mark -

typedef NS_ENUM(NSInteger ,SnailAlertAnimationShowType) {
    SnailAlertAnimationShowTypePresent,
    SnailAlertAnimationShowTypeDismiss,
};

#pragma mark -

@interface SnailAlertAnimate : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic) SnailAlertAnimationShowType type;
@property (nonatomic) SnailAlertAnimationType manuleType;
@property (nonatomic) CGFloat offset;//动画移动距离

@end

@implementation SnailAlertAnimate

- (instancetype)initWithType:(SnailAlertAnimationShowType)type {
    self = [super init];
    if (self) self.type = type;
    return self;
}

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    switch (self.type) {
        case SnailAlertAnimationShowTypePresent:
        {
            if (self.manuleType == SnailAlertAnimation_Fade) [self presentFadeAnimated:transitionContext];
            else if (self.manuleType == SnailAlertAnimation_FromeBottom) [self presentFromeBottomAnimated:transitionContext];
        }
            break;
        case SnailAlertAnimationShowTypeDismiss:
        {
            if (self.manuleType == SnailAlertAnimation_Fade) [self dismissFadeAnimated:transitionContext];
            else if (self.manuleType == SnailAlertAnimation_FromeBottom) [self dismissFromeBottomAnimated:transitionContext];
        }
            break;
        default:
            break;
    }
    
}

#pragma mark - fade

- (void)presentFadeAnimated:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIView *container = [transitionContext containerView];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    toView.frame = CGRectMake(0, 0, container.bounds.size.width, container.bounds.size.height);
    toView.alpha = 0;
    [container addSubview:toView];
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        toView.alpha = 1;
    } completion:^(BOOL finished) {
        toView.alpha = 1;
        [transitionContext completeTransition:finished];
    }];
    
}

- (void)dismissFadeAnimated:(id<UIViewControllerContextTransitioning>)transitionContext {

    UIView *fromeView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        fromeView.alpha = 0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:finished];
        [fromeView removeFromSuperview];
    }];
    
}

#pragma mark - frome bottom

- (void)presentFromeBottomAnimated:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIView *container = [transitionContext containerView];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    toView.frame = CGRectMake(0, self.offset, container.bounds.size.width, container.bounds.size.height);
    [container addSubview:toView];
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        toView.frame = CGRectMake(0, 0, container.bounds.size.width, container.bounds.size.height);
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:finished];
    }];
    
}

- (void)dismissFromeBottomAnimated:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIView *container = [transitionContext containerView];
    UIView *fromeView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        fromeView.frame = CGRectMake(0, self.offset, container.bounds.size.width, container.bounds.size.height);
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:finished];
        [fromeView removeFromSuperview];
    }];
    
}

@end

#pragma mark -

@interface SnailAlertAnimationController ()<UIViewControllerTransitioningDelegate>

@end

@implementation SnailAlertAnimationController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.transitioningDelegate = self;
        self.modalPresentationStyle = UIModalPresentationCustom;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    
    SnailAlertAnimate *animate = [[SnailAlertAnimate alloc] initWithType:SnailAlertAnimationShowTypePresent];
    animate.manuleType = self.type;
    if (self.offsetBlock) animate.offset = self.offsetBlock();
    return animate;
    
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    
    SnailAlertAnimate *animate = [[SnailAlertAnimate alloc] initWithType:SnailAlertAnimationShowTypeDismiss];
    animate.manuleType = self.type;
    if (self.offsetBlock) animate.offset = self.offsetBlock();
    return animate;
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    SnailFadePresentationController *vc = [[SnailFadePresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    return vc;
}

@end
