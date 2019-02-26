//
//  SnailPopupController.m
//  QianXun
//
//  Created by JobNewMac1 on 2018/12/3.
//  Copyright © 2018年 com.jobnew. All rights reserved.
//

#import "SnailPopupController.h"

SNAIL_POPUPCONTROLLER_KEY const SnailPopupControllerImage = @"Sna_SnailPopupControllerImage";
SNAIL_POPUPCONTROLLER_KEY const SnailPopupControllerText = @"Sna_SnailPopupControllerText";
SNAIL_POPUPCONTROLLER_KEY const SnailPopupControllerDetail = @"Sna_SnailPopupControllerDetail";
SNAIL_POPUPCONTROLLER_KEY const SnailPopupControllerTextAttribute = @"Sna_SnailPopupControllerTextAttribute";
SNAIL_POPUPCONTROLLER_KEY const SnailPopupControllerDetailAttribute = @"Sna_SnailPopupControllerDetailAttribute";

@interface SNA_SnailPopupPresentationController : UIPresentationController

@property (nonatomic ,strong) UIView *mask;
@property (nonatomic ,strong) UIVisualEffectView *effect;

@property (nonatomic ,copy) UIColor *(^maskColorBlock)(void);
@property (nonatomic ,copy) BOOL(^effectBlock)(void);
@property (nonatomic ,copy) void(^maskAction)(void);

@end

@implementation SNA_SnailPopupPresentationController

- (void)presentationTransitionWillBegin {
    
    UIColor *color = nil;
    if (self.maskColorBlock) color = self.maskColorBlock();
    if (!color) color = [UIColor clearColor];
    
    BOOL enableEffect = false;
    if (self.effectBlock) enableEffect = self.effectBlock();
    
    self.mask = [UIView new];
    self.mask.backgroundColor = color;
    self.mask.frame = self.containerView.bounds;
    self.mask.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.mask.alpha = 0;
    
    if (enableEffect) {
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        self.effect = [[UIVisualEffectView alloc] initWithEffect:blur];
        self.effect.frame = self.containerView.bounds;
        self.effect.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    [self.containerView insertSubview:self.mask atIndex:0];
    if (self.effect) [self.mask addSubview:self.effect];
    
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.mask.alpha = 1;
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {

    }];
    
}

- (void)presentationTransitionDidEnd:(BOOL)completed {
    if (completed) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        self.mask.userInteractionEnabled = true;
        [self.mask addGestureRecognizer:tap];
    }
}

- (void)dismissalTransitionWillBegin {
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.mask.alpha = 0;
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    }];
}

- (void)dismissalTransitionDidEnd:(BOOL)completed {
    if (completed) {
        [self.mask removeFromSuperview];
        self.maskAction = nil;
        self.maskColorBlock = nil;
        self.effectBlock = nil;
    }
}

- (void)tapAction {
    if (self.maskAction) self.maskAction();
}

@end

@interface SNA_SnailPopupBridge : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic) BOOL isShow;

@end

@implementation SNA_SnailPopupBridge

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.25;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    if (self.isShow) {
        UIView *container = [transitionContext containerView];
        UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
        toView.frame = CGRectMake(0, 0, container.bounds.size.width, container.bounds.size.height);
        toView.alpha = 0;
        [container addSubview:toView];
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            toView.alpha = 1;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:finished];
        }];
    }
    else {
        UIView *fromeView = [transitionContext viewForKey:UITransitionContextFromViewKey];
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            fromeView.alpha = 0;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:finished];
            [fromeView removeFromSuperview];
        }];
    }
    
}

@end

@interface SNA_SnailPopupListController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic ,strong) UITableView *tab;
@property (nonatomic ,strong) void(^didSelectedIndexRow)(NSDictionary *dataDic);
@property (nonatomic ,strong) NSMutableArray *datas;
@property (nonatomic ,strong) UIColor *seperatorColor;

@end

@implementation SNA_SnailPopupListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.tab = [UITableView new];
    self.tab.separatorInset = UIEdgeInsetsZero;
    self.tab.separatorColor = self.seperatorColor;
    self.tab.tableFooterView = UIView.new;
    self.tab.delegate = self;
    self.tab.dataSource = self;
    self.tab.rowHeight = 45;
    self.tab.bounces = false;
    self.tab.showsVerticalScrollIndicator = false;
    self.tab.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.tab.frame = self.view.bounds;
    [self.view addSubview:self.tab];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = self.datas[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"c"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"c"];
    }
    cell.imageView.image = dic[SnailPopupControllerImage];
    
    if (dic[SnailPopupControllerTextAttribute] && dic[SnailPopupControllerText]) cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:dic[SnailPopupControllerText] attributes:dic[SnailPopupControllerTextAttribute]];
    else cell.textLabel.text = dic[SnailPopupControllerText];
    
    if (dic[SnailPopupControllerDetailAttribute] && dic[SnailPopupControllerDetail]) cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:dic[SnailPopupControllerDetail] attributes:dic[SnailPopupControllerDetailAttribute]];
    else cell.detailTextLabel.text = dic[SnailPopupControllerDetail];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    if (self.didSelectedIndexRow) self.didSelectedIndexRow(self.datas[indexPath.row]);
}

- (NSMutableArray *)datas {
    if (!_datas) _datas = [NSMutableArray new];
    return _datas;
}

@end

#define SNA_POPUP_CONTROLLER_MARIGN 8.f
#define SNA_POPUP_CONTROLLER_SPACEING 15.f
#define SNA_POPUP_CONTROLLER_TRAN_LENGTH 15.f
#define SNA_POPUP_CONTROLLER_TRAN_HEIGHT SNA_POPUP_CONTROLLER_TRAN_LENGTH * sin(M_PI / 3.0)
#define SNA_POPUP_CONTROLLER_CORNER_WIDTH 5.0f

typedef NS_ENUM(NSInteger,SnailPopupControllerLayoutType) {
    SnailPopupController_Right,
    SnailPopupController_Left,
    SnailPopupController_Center,
    SnailPopupController_Top,
    SnailPopupController_Bottom,
};

@interface SnailPopupController ()<UIViewControllerTransitioningDelegate>

@property (nonatomic ,strong) UIView *controllerView;
@property (nonatomic ,strong) CAShapeLayer *layer;

@property (nonatomic ,strong) UIViewController *sna_tmp_vc;
@property (nonatomic) CGPoint sna_origin;
@property (nonatomic) CGSize sna_size;

@end

@implementation SnailPopupController

+ (instancetype)Point:(CGPoint)origin Size:(CGSize)size List:(NSArray<NSDictionary<SNAIL_POPUPCONTROLLER_KEY,id> *> *)datas Block:(void (^)(NSDictionary<SNAIL_POPUPCONTROLLER_KEY,id> *))block {
    SNA_SnailPopupListController *vc = [SNA_SnailPopupListController new];
    vc.datas = [datas mutableCopy];
    vc.didSelectedIndexRow = block;
    return [self Point:origin Size:size Controller:vc];
}

+ (instancetype)Point:(CGPoint)origin Size:(CGSize)size Controller:(UIViewController *)controller {
    if (!controller) return nil;
    SnailPopupController *vc = [SnailPopupController new];
    vc.sna_tmp_vc = controller;
    vc.sna_origin = origin;
    vc.sna_size = size;
    return vc;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.transitioningDelegate = self;
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.backgroundClose = true;
        self.blur = false;
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.3];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];

    self.controllerView = [UIView new];
    if (self.sna_tmp_vc.view.backgroundColor) self.controllerView.backgroundColor = self.sna_tmp_vc.view.backgroundColor;
    else self.controllerView.backgroundColor = [UIColor whiteColor];
    
    self.layer = [CAShapeLayer layer];
    self.layer.strokeColor = [UIColor colorWithRed:210 / 255.0 green:210 / 255.0 blue:210 / 255.0 alpha:1].CGColor;
    self.layer.fillColor = UIColor.whiteColor.CGColor;
    self.layer.lineWidth = 0.5f;
    self.layer.shadowOffset = CGSizeMake(0, 2);
    self.layer.shadowOpacity = 1;
    self.layer.shadowRadius = 3;
    self.layer.shadowColor = [UIColor colorWithRed:110 / 255.0 green:110 / 255.0 blue:110 / 255.0 alpha:1].CGColor;
    
    UIButton *btn = [UIButton new];
    btn.frame = self.view.bounds;
    btn.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [btn addTarget:self action:@selector(tapAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self addChildViewController:self.sna_tmp_vc];
    [self.view addSubview:btn];
    [self.view addSubview:self.controllerView];
    [self.controllerView addSubview:self.sna_tmp_vc.view];
    [self.controllerView.layer insertSublayer:self.layer atIndex:0];
    
    self.sna_tmp_vc.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    [self updateContainerFrame];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)updateContainerFrame {
    
    SnailPopupControllerLayoutType layoutTypeLR = SnailPopupController_Center;
    if (self.sna_origin.x > self.view.bounds.size.width - self.sna_size.width * .5 - SNA_POPUP_CONTROLLER_SPACEING) layoutTypeLR = SnailPopupController_Right;
    else if (self.sna_origin.x < SNA_POPUP_CONTROLLER_SPACEING + self.sna_size.width * .5) layoutTypeLR = SnailPopupController_Left;
    
    SnailPopupControllerLayoutType layoutTypeTB = SnailPopupController_Top;
    if (self.sna_origin.y > self.view.bounds.size.height - self.sna_size.height - SNA_POPUP_CONTROLLER_SPACEING) layoutTypeTB = SnailPopupController_Bottom;
    
    CGFloat containerX = self.sna_origin.x - self.sna_size.width * .5;
    if (layoutTypeLR == SnailPopupController_Left) containerX = SNA_POPUP_CONTROLLER_SPACEING;
    else if (layoutTypeLR == SnailPopupController_Right) containerX = self.view.bounds.size.width - SNA_POPUP_CONTROLLER_SPACEING - self.sna_size.width;
    
    CGFloat containerY = self.sna_origin.y;
    if (layoutTypeTB == SnailPopupController_Bottom) {
        containerY = self.view.bounds.size.height - self.sna_size.height - SNA_POPUP_CONTROLLER_SPACEING;
    }
    
    self.controllerView.frame = (CGRect){.origin=CGPointMake(containerX, containerY),.size=self.sna_size};
    
    if (layoutTypeTB == SnailPopupController_Top) {
        self.sna_tmp_vc.view.frame = CGRectMake(SNA_POPUP_CONTROLLER_MARIGN, SNA_POPUP_CONTROLLER_MARIGN + SNA_POPUP_CONTROLLER_TRAN_HEIGHT, self.sna_size.width - SNA_POPUP_CONTROLLER_MARIGN * 2, self.sna_size.height - SNA_POPUP_CONTROLLER_MARIGN * 2 - SNA_POPUP_CONTROLLER_TRAN_HEIGHT);
    }
    else if (layoutTypeTB == SnailPopupController_Bottom) {
        self.sna_tmp_vc.view.frame = CGRectMake(SNA_POPUP_CONTROLLER_MARIGN, SNA_POPUP_CONTROLLER_MARIGN, self.sna_size.width - SNA_POPUP_CONTROLLER_MARIGN * 2, self.sna_size.height - SNA_POPUP_CONTROLLER_MARIGN * 2 - SNA_POPUP_CONTROLLER_TRAN_HEIGHT);
    }
    
    {
        CGFloat tranHeight = SNA_POPUP_CONTROLLER_TRAN_HEIGHT;
        
        CGPoint arrowTop = CGPointMake(self.sna_origin.x - containerX, 0);
        CGPoint arrowLeft = CGPointMake(arrowTop.x - SNA_POPUP_CONTROLLER_TRAN_LENGTH * .5, tranHeight);
        CGPoint arrowRight = CGPointMake(arrowTop.x + SNA_POPUP_CONTROLLER_TRAN_LENGTH * .5, tranHeight);
        
        CGRect roundRect = CGRectMake(0, tranHeight, self.sna_size.width, self.sna_size.height - tranHeight);
        
        CGPoint leftTopCenter = CGPointMake(SNA_POPUP_CONTROLLER_CORNER_WIDTH, SNA_POPUP_CONTROLLER_CORNER_WIDTH + tranHeight);
        CGPoint rightTopCenter = CGPointMake(self.sna_size.width - SNA_POPUP_CONTROLLER_CORNER_WIDTH, SNA_POPUP_CONTROLLER_CORNER_WIDTH + tranHeight);
        CGPoint leftBottomCenter = CGPointMake(SNA_POPUP_CONTROLLER_CORNER_WIDTH, self.sna_size.height - SNA_POPUP_CONTROLLER_CORNER_WIDTH);
        CGPoint rightBottomCenter = CGPointMake(self.sna_size.width - SNA_POPUP_CONTROLLER_CORNER_WIDTH, self.sna_size.height - SNA_POPUP_CONTROLLER_CORNER_WIDTH);
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(leftTopCenter.x, roundRect.origin.y)];
        [path addArcWithCenter:leftTopCenter radius:SNA_POPUP_CONTROLLER_CORNER_WIDTH startAngle:M_PI * 1.5 endAngle:M_PI clockwise:false];
        [path addLineToPoint:CGPointMake(roundRect.origin.x, leftBottomCenter.y)];
        [path addArcWithCenter:leftBottomCenter radius:SNA_POPUP_CONTROLLER_CORNER_WIDTH startAngle:M_PI endAngle:M_PI * .5 clockwise:false];
        [path addLineToPoint:CGPointMake(rightBottomCenter.x, CGRectGetMaxY(roundRect))];
        [path addArcWithCenter:rightBottomCenter radius:SNA_POPUP_CONTROLLER_CORNER_WIDTH startAngle:M_PI * .5 endAngle:0 clockwise:false];
        [path addLineToPoint:CGPointMake(CGRectGetMaxX(roundRect), rightTopCenter.y)];
        [path addArcWithCenter:rightTopCenter radius:SNA_POPUP_CONTROLLER_CORNER_WIDTH startAngle:0 endAngle:M_PI * 1.5 clockwise:false];
        [path addLineToPoint:arrowRight];
        [path addLineToPoint:arrowTop];
        [path addLineToPoint:arrowLeft];
        [path closePath];
        
        self.layer.path = path.CGPath;
        self.layer.shadowPath = path.CGPath;
        
        if (layoutTypeTB == SnailPopupController_Bottom) {
            CGAffineTransform transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, self.sna_size.height);
            self.layer.affineTransform = CGAffineTransformScale(transform, 1, -1);
            self.controllerView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, self.sna_origin.y - CGRectGetMaxY(self.controllerView.frame));
        }
        
    }
    
}

- (void)tapAction {
    if (self.backgroundClose) {
        [self dismissViewControllerAnimated:true completion:^{
            
        }];
    }
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    SNA_SnailPopupBridge *animate = [SNA_SnailPopupBridge new];
    animate.isShow = true;
    return animate;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [SNA_SnailPopupBridge new];
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    __weak typeof(self) self_weak_ = self;
    SNA_SnailPopupPresentationController *vc = [[SNA_SnailPopupPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    vc.maskAction = ^{
        if (self_weak_.backgroundClose) {
            [self_weak_ dismissViewControllerAnimated:true completion:^{
                
            }];
        }
    };
    vc.effectBlock = ^BOOL{
        return self_weak_.blur;
    };
    vc.maskColorBlock = ^UIColor *{
        return self_weak_.backgroundColor;
    };
    return vc;
}

- (void)setSna_size:(CGSize)sna_size {
    CGSize size = sna_size;
    size.width += SNA_POPUP_CONTROLLER_MARIGN * 2;
    size.height += SNA_POPUP_CONTROLLER_MARIGN * 2 + SNA_POPUP_CONTROLLER_TRAN_HEIGHT;
    _sna_size = size;
}

@end
