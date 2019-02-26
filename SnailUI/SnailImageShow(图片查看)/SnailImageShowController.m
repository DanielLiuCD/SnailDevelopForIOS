//
//  SnailImageShowController.m
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/7/23.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import "SnailImageShowController.h"

#pragma mark -

@interface SnailImageShowAnimation : NSObject<UIViewControllerAnimatedTransitioning>

kSPr(BOOL isPresent)
kSPr(UIImage *fromeViewTmpImage)
kSPr(CGRect fromeViewFrame)

@end

@implementation SnailImageShowAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    if (self.isPresent) [self presentAnimation:transitionContext];
    else [self dismissAnimation:transitionContext];
}

- (void)presentAnimation:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIView *container = [transitionContext containerView];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    
    if (self.fromeViewTmpImage) {
        
        toView.frame = CGRectMake(0, 0, container.bounds.size.width, container.bounds.size.height);
        toView.hidden = true;
        [container addSubview:toView];
        
        UIImageView *imgv = [[UIImageView alloc] initWithImage:self.fromeViewTmpImage];
        imgv.frame = self.fromeViewFrame;
        imgv.contentMode = UIViewContentModeScaleAspectFit;
        
        UIView *tmp = [UIView new];
        tmp.backgroundColor = SNA_BLACK_COLOR;
        tmp.frame = toView.frame;
        tmp.alpha = 0;
        
        [container addSubview:tmp];
        [container addSubview:imgv];
        
        CGFloat targetHeihgt = self.fromeViewFrame.size.height / self.fromeViewFrame.size.width * container.frame.size.width;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            
            tmp.alpha = 1;
            imgv.frame = CGRectMake(0, 0, container.frame.size.width, targetHeihgt);
            imgv.center = container.center;
            
        } completion:^(BOOL finished) {
            
            toView.hidden = false;
            [tmp removeFromSuperview];
            [imgv removeFromSuperview];
            
            [transitionContext completeTransition:finished];
            
        }];
        
    }
    else {
        
        toView.frame = CGRectMake(0, container.bounds.size.height, container.bounds.size.width, container.bounds.size.height);
        [container addSubview:toView];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            toView.frame = CGRectMake(0, 0, container.bounds.size.width, container.bounds.size.height);
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:finished];
        }];
        
    }
    
}

- (void)dismissAnimation:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIView *container = [transitionContext containerView];
    
    UIView *fromeView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    if (self.fromeViewTmpImage) {
        
        fromeView.hidden = true;
        
        CGFloat targetHeihgt = self.fromeViewFrame.size.height / self.fromeViewFrame.size.width * fromeView.frame.size.width;
        
        UIImageView *imgv = [[UIImageView alloc] initWithImage:self.fromeViewTmpImage];
        imgv.frame = CGRectMake(0, 0, fromeView.frame.size.width, targetHeihgt);
        imgv.center = container.center;
        imgv.contentMode = UIViewContentModeScaleAspectFit;
        
        UIView *tmp = [UIView new];
        tmp.backgroundColor = SNA_BLACK_COLOR;
        tmp.frame = fromeView.frame;
        
        [container addSubview:tmp];
        [container addSubview:imgv];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            tmp.alpha = 0;
            imgv.frame = self.fromeViewFrame;
            
        } completion:^(BOOL finished) {
            [fromeView removeFromSuperview];
            [tmp removeFromSuperview];
            [imgv removeFromSuperview];
            [transitionContext completeTransition:finished];
        }];
        
    }
    else {
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            fromeView.frame = CGRectMake(0, container.bounds.size.height, container.bounds.size.width, container.bounds.size.height);
        } completion:^(BOOL finished) {
            [fromeView removeFromSuperview];
            [transitionContext completeTransition:finished];
        }];
        
    }
    
}

@end

#pragma mark -

@interface LNImageShowView : UIScrollView<UIScrollViewDelegate>


@end

@interface LNImageShowView()
@property (nonatomic ,strong) UIImageView *imageview;
@end

@implementation LNImageShowView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.imageview.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.imageview];
        self.delegate = self;
        self.maximumZoomScale = 3;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
    }
    return self;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageview;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    UIView *subView = self.imageview;
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}

@end

#pragma mark -

@interface SnailImageShowController()

kSPrStrong(UIImage *fromeViewTmpImage)
kSPr(CGRect fromeViewFrame)
kSPr(NSInteger totalCount)

@end

@interface SnailImageShowController ()<UIViewControllerTransitioningDelegate ,UIScrollViewDelegate>

kSPrStrong(UIScrollView *backScrollerView)
kSPr(NSInteger currentIndex)
kSPrStrong(void(^configureBlock)(UIImageView *imageView,NSInteger index))

@end

@implementation SnailImageShowController

+ (void)showFromeVc:(UIViewController *)vc View:(id)view Count:(NSInteger)totalCount ShowBlock:(void(^)(UIImageView *imageView,NSInteger index))showBlock {
    
    UIImage *image = nil;
    if (view) {
        image = [SnailSimpleCIMManager takeCIM:nil Cache:false Size:^CGSize{
            if ([view isKindOfClass:CALayer.class]) {
                return [(CALayer *)view frame].size;
            }
            else if ([view isKindOfClass:UIView.class]) {
                return [(UIView *)view frame].size;
            }
            return CGSizeZero;
        } Block:^(CGContextRef ctx, CGRect rect, CGFloat scale) {
            if ([view isKindOfClass:CALayer.class]) {
                return [(CALayer *)view renderInContext:ctx];
            }
            else if ([view isKindOfClass:UIView.class]) {
                return [[(UIView *)view layer] renderInContext:ctx];
            }
        }];
    }
    
    CGRect frame = CGRectZero;
    if (view) {
        if ([view isKindOfClass:CALayer.class]) {
            frame = [[(CALayer *)view superlayer] convertRect:[(CALayer *)view frame] toLayer:[UIApplication sharedApplication].keyWindow.layer];
        }
        else if ([view isKindOfClass:UIView.class]) {
            frame = [[(UIView *)view superview] convertRect:[(UIView *)view frame] toView:[UIApplication sharedApplication].keyWindow];
        }
    }
    
    SnailImageShowController *tvc = [SnailImageShowController new];
    tvc.fromeViewTmpImage = image;
    tvc.fromeViewFrame = frame;
    tvc.configureBlock = showBlock;
    tvc.totalCount = totalCount;
    [vc presentViewController:tvc animated:true completion:^{
        
        
    }];
    
}

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

- (void)snailConfigureUI {
    
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.backScrollerView];
    
    for (int i = 0; i < self.totalCount; i++) {
        CGFloat x = i * self.view.bounds.size.width;
        CGFloat y = 0;
        LNImageShowView *show = [self.backScrollerView viewWithTag:(i+1)];
        if (show == nil) {
            show = [[LNImageShowView alloc] initWithFrame:CGRectMake(x, y, self.view.bounds.size.width, self.view.bounds.size.height)];
        } else {
            show.frame = CGRectMake(x, y, self.view.bounds.size.width, self.view.bounds.size.height);
        }
        if (self.configureBlock) self.configureBlock(show.imageview, i);
        show.tag = i+1;
        [self.backScrollerView addSubview:show];
    }
    
    if (self.totalCount < self.backScrollerView.subviews.count) {
        NSInteger temp = self.backScrollerView.subviews.count;
        for (NSInteger i = self.totalCount; i <= temp; i++) {
            LNImageShowView *show = [self.backScrollerView viewWithTag:i+1];
            [show removeFromSuperview];
            show = nil;
        }
    }
    
    self.backScrollerView.contentSize = CGSizeMake(self.view.bounds.size.width * self.totalCount, 0);
    self.backScrollerView.contentOffset = CGPointMake(self.view.bounds.size.width * self.currentIndex, 0);
    
}

- (void)snailFirstAction {
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self.backScrollerView addGestureRecognizer:tap];
    
}

- (void)tapAction {
    [self dismissViewControllerAnimated:true completion:^{
        
    }];
}

#pragma mark -

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    
    SnailImageShowAnimation *model = [SnailImageShowAnimation new];
    model.fromeViewTmpImage = self.fromeViewTmpImage;
    model.fromeViewFrame = self.fromeViewFrame;
    model.isPresent = true;
    return model;
    
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    
    SnailImageShowAnimation *model = [SnailImageShowAnimation new];
    model.isPresent = false;
    model.fromeViewFrame = self.fromeViewFrame;
    model.fromeViewTmpImage = self.fromeViewTmpImage;
    return model;
    
}

#pragma mark -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.x / self.view.bounds.size.width;
    self.currentIndex = index;
}

#pragma mark -

-(UIScrollView *)backScrollerView {
    if (!_backScrollerView) {
        _backScrollerView = [UIScrollView new];
        _backScrollerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        _backScrollerView.showsVerticalScrollIndicator = NO;
        _backScrollerView.showsHorizontalScrollIndicator = NO;
        _backScrollerView.delegate = self;
        _backScrollerView.pagingEnabled = YES;
    }
    return _backScrollerView;
}


@end
