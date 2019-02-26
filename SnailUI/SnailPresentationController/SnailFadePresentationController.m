//
//  SnailFadePresentationController.m
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/7/2.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import "SnailFadePresentationController.h"

@interface SnailFadePresentationController()

@property (nonatomic ,strong) UIView *dim;

@end

@implementation SnailFadePresentationController

- (void)presentationTransitionWillBegin {
    
    UIColor *color = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    if (self.dimColor) color = self.dimColor();
    self.dim = [UIView new];
    self.dim.backgroundColor = color;
    self.dim.bounds = self.containerView.bounds;
    self.dim.center = self.containerView.center;
    self.dim.alpha = 0;
    [self.containerView insertSubview:self.dim atIndex:0];
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.dim.alpha = 1;
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    }];
    
}

- (void)presentationTransitionDidEnd:(BOOL)completed {
    if (completed) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        self.dim.userInteractionEnabled = true;
        [self.dim addGestureRecognizer:tap];
    }
}

- (void)dismissalTransitionWillBegin {
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.dim.alpha = 0;
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    }];
}

- (void)dismissalTransitionDidEnd:(BOOL)completed {
    if (completed) {
        [self.dim removeFromSuperview];
        self.tapClick = nil;
        self.dimColor = nil;
    }
}

- (void)containerViewWillLayoutSubviews {
    self.dim.bounds = self.containerView.bounds;
}

- (void)tapAction {
    if (self.tapClick) self.tapClick();
}

@end
